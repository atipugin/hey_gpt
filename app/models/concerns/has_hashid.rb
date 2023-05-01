# frozen_string_literal: true

module HasHashid
  extend ActiveSupport::Concern

  HASHID_SIZE = 8

  class_methods do
    def by_hashid(val)
      id = Hashids.new(hashids_salt, HASHID_SIZE).decode(val)
      find_by(id:)
    end

    def hashids_salt
      Rails.application.secret_key_base
    end
  end

  def hashid
    return unless id?

    @hashid ||= Hashids.new(self.class.hashids_salt, HASHID_SIZE).encode(id)
  end
end
