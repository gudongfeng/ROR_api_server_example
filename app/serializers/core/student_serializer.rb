class Core::StudentSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phoneNumber, :state, :country_code, :balance,
    :prioritized_tutor, :gender
end
