class Core::StudentSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phoneNumber, :country_code, :balance,
    :gender
end
