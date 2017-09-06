class Core::TutorSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phoneNumber, :country_code, :country,
    :picture, :region, :description, :balance, :level, :gender
  has_many :educations
  class Core::EducationSerializer < ActiveModel::Serializer
    attributes :id, :degree, :school, :major, :start_time, :end_time
  end
end
