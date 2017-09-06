desc "This task is called by the Heroku scheduler add-on"
task :send_reminders => :environment do
  Core::Student.all.each do |student|
    if !student.device_token.nil? and !student.remember_token.nil?
      student.send_push "外教们开始上线啦！小伙伴们抓紧时间来预约!"
    end
  end
end