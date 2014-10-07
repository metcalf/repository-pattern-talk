require 'active_record'

module ORMExample
  class Message < ActiveRecord::Base
    belongs_to :verification_code
  end

  class VerificationCode < ActiveRecord::Base
    has_one :message
    after_initialize :init_defaults

    MAX_ATTEMPTS = 5

    def self.create_verification_message(type, phone, body, code)
      vc = nil

      ActiveRecord::Base.transaction do
        msg = Message.new(
          sender_type: type,
          phone: phone,
          body: body,
          )
        vc = VerificationCode.new(code: '123456')

        vc.message = msg
        vc.save
        msg.save
      end

      vc
    end

    def init_defaults
      self.expires_at ||= 1.hour.from_now
    end

    def verify(attempted_code)
      valid = attempts < MAX_ATTEMPTS && code == attempted_code

      return false if expires_at < Time.now

      # Compare and swap attempts counter
      while true
        cnt = VerificationCode.where(:id => id)
          .where(:attempts => attempts)
          .update_all(attempts: attempts + 1)

        break if cnt > 0

        reload
      end

      update(:used_at => Time.new) if valid

      valid
    end
  end
end
