module Core
  class Certificate < ApplicationRecord
    def to_json(options={})
      options[:except] ||= [:created_at, :updated_at, :id]
      super(options)
    end

    def as_json(options={})
      options[:except] ||= [:created_at, :updated_at, :id]
      super(options)
    end
  end
end
