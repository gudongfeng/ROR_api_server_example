require 'rubygems'
# require 'plivo'
# include Plivo

class Api::V1::VoiceController < Api::ApiController
  before_action :check_for_tutor_valid_authtoken, :only => [:reconnect]
  before_action :set_locale

  def reconnect
    if params && params[:appointment_id]
      if @tutor && @tutor.remember_expiry > Time.now
        appointment = Core::Appointment.find(params[:appointment_id])
        if appointment.end_time - Time.now < 3.minutes
          # cannot make the call if only 3 minutes left
          json_error_message 400, (I18n.t 'error.messages.reconnect.min')
        else
          # remove the previous schedule
          Sidekiq::Status.cancel appointment.hard_worker unless appointment.hard_worker.nil?
          appointment.update_attribute(:hard_worker, nil)

          # perform the call
          MakeCall.perform_async appointment.student.phoneNumber,
                                 appointment.tutor.phoneNumber,
                                 appointment.id
          render :json => {:message => (I18n.t 'success.messages.reconnect')},
                 :status => 200
        end
      else
        json_error_message 401, (I18n.t 'error.messages.login')
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  def answer
    if params[:appointmentID]
      # Assigning the conference name to this specific appointment
      appointment = Core::Appointment.find(params[:appointmentID])
      if appointment
        # generate the appointment conference name if it is empty
        appointment.update_attribute(:conference_name, SecureRandom.hex(12)) if appointment.conference_name.nil?
        # Get the call uuid and store it into the appointment,
        student = Core::Student.find_by(phoneNumber: params[:To].to_i)
        tutor = Core::Tutor.find_by(phoneNumber: params[:To].to_i)
        if !student.nil?
          # this phone call is student
          appointment.update_attribute(:student_call_uuid, params[:CallUUID])
          # Start the speaker to remind the tutor
          job_id = CallSpeakReminder.perform_at(appointment.end_time - Settings.call_speak_reminder_time,
                                                appointment.student_call_uuid)
          # remove the previous schedule job
          Sidekiq::Status.cancel appointment.student_sidekiq_job_id if appointment.student_sidekiq_job_id
          appointment.update_attribute(:student_sidekiq_job_id, job_id)
        end
        if !tutor.nil?
          # this phone call is tutor
          appointment.update_attribute(:tutor_call_uuid, params[:CallUUID])
          # Start the speaker to remind the tutor
          job_id = CallSpeakReminder.perform_at(appointment.end_time - Settings.call_speak_reminder_time,
                                                appointment.tutor_call_uuid)
          # remove the previous schedule job
          Sidekiq::Status.cancel appointment.tutor_sidekiq_job_id if appointment.tutor_sidekiq_job_id
          appointment.update_attribute(:tutor_sidekiq_job_id, job_id)
        end

        r = Response.new()
        r.addSpeak('welcome to talk with sam')
        r.addConference(appointment.conference_name,
                        {
                            'record' => 'true',
                            'maxMembers' => '2',
                            'timeLimit' => (appointment.end_time - Time.now).to_i,
                            'waitSound' => Settings.heroku_server + '/api/v1/voice/waitmusic',
                            'endConferenceOnExit' => 'true'
                        })
        render :xml => r.to_xml(), :status => 200
      else
        json_error_message 400, (I18n.t 'error.messages.no_appointment')
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  def waitmusic
    r = Response.new()
    r.addPlay('https://raw.githubusercontent.com/slimsheep/TWSMusic/master/home.mp3')
    render :xml => r.to_xml(), :status => 200
  end

  # this function will be called after the tutor & student hangup the phone
  def hangup
    # record the call duration time to the appointment record
    if params[:appointmentID]
      appointment = Core::Appointment.find_by_id(params[:appointmentID])
      # Get the call uuid and store it into the appointment,
      student = Core::Student.find_by(phoneNumber: params[:To])
      tutor = Core::Tutor.find_by(phoneNumber: params[:To])
      if !student.nil?
        # this phone call is student, store the call duration into the appointment
        if appointment.student_call_duration.nil?
          appointment.student_call_duration = params[:Duration].to_i
        else
          appointment.student_call_duration+=params[:Duration].to_i
        end
      end
      if !tutor.nil?
        # this phone call is tutor
        if appointment.tutor_call_duration.nil?
          appointment.tutor_call_duration = params[:Duration].to_i
        else
          appointment.tutor_call_duration+=params[:Duration].to_i
        end
      end
      # update the appointment to the database
      appointment.save
    end
    # return the message to Plivo
    render text: 'successfully hangup'
  end

  private

  # Check the tutor auth token
  def check_for_tutor_valid_authtoken
    authenticate_or_request_with_http_token do |token, options|
      @tutor = Core::Tutor.find_by(remember_token: token)
    end
  end

end
