class Error < ApplicationRecord
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :message
  
  validates_presence_of :message
  
  def initialize(message)
    self.message = message
    self.to_json
  end
  
end
