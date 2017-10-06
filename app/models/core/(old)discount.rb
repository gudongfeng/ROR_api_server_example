module Core
  class Discount < ApplicationRecord
    has_many :appointments
  end
end
