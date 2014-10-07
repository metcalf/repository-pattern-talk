require 'sqlite3'

module RepoExample
  class Repository
    MAX_ATTEMPTS = 5

    FIND_VERIFICATION = <<-SQL
SELECT phone, sender_type, status, body, attempts, code,
  expires_at, used_at
FROM verification_codes
LEFT JOIN messages ON messages.verification_code_id = verification_codes.rowid
WHERE verification_codes.rowid = :id
LIMIT 1
SQL

    INSERT_MESSAGE = <<-SQL
INSERT INTO messages(verification_code_id, phone, body, sender_type)
VALUES (:verification_code_id, :phone, :body, :sender_type)
SQL

    INSERT_VERIFICATION_CODE = <<-SQL
INSERT INTO verification_codes(code, expires_at)
VALUES (:code, :expires_at)
SQL

    UPDATE_CODE_ATTEMPTS = <<-SQL
UPDATE verification_codes
SET attempts=attempts+1
WHERE rowid = :id
SQL

    UPDATE_USED_AT = <<-SQL
UPDATE verification_codes
SET used_at = :used_at
WHERE rowid = :id AND used_at IS NULL
SQL

    def initialize(db_file)
      @db = SQLite3::Database.new(db_file)
      @db.results_as_hash = true
    end

    def create_verification_message(sender_type, phone, body, code)
      id = nil

      @db.transaction do |db|
        db.execute(INSERT_VERIFICATION_CODE,
          "code" => code,
          "expires_at" => (Time.now + (3600 * 12)).to_i
          )

        db.execute(INSERT_MESSAGE,
          "verification_code_id" => db.last_insert_row_id,
          "sender_type" => sender_type,
          "phone" => phone,
          "body" => body,
          )

        id = db.last_insert_row_id
      end

      id
    end

    def get_verification(id)
      row = @db.get_first_row(FIND_VERIFICATION, 'id' => id)

      verification = Verification.new
      %w{phone sender_type body attempts code}.each do |key|
        verification.send("#{key}=", row[key])
      end
      verification.id = id

      %w{expires_at used_at}.each do |key|
        val = row[key] ? Time.at(row[key]) : nil
        verification.send("#{key}=", val)
      end

      verification
    end

    def verify_code(id, code)
      @db.execute(UPDATE_CODE_ATTEMPTS, 'id' => id)
      return nil if @db.changes == 0 # Does not exist

      vc = get_verification(id)
      return false if vc.nil? || vc.expires_at < Time.now || vc.attempts > MAX_ATTEMPTS

      valid = vc.code == code

      @db.execute(UPDATE_USED_AT, 'id' => id, 'used_at' => Time.now.to_i) if valid

      valid
    end
  end

  class Verification
    attr_accessor :id, :phone, :sender_type, :status, :body, :attempts, :code, :expires_at, :used_at
  end
end
