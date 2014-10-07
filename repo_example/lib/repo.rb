require 'sqlite3'

module RepoExample
  class Repository
    MAX_ATTEMPTS = 5

    FIND_VERIFICATION = <<-SQL
SELECT verification_codes.rowid
  phone, sender_type, status, body, attempts, code,
  expires_at < datetime("now") as expired,
  used_at IS NOT NULL as used
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
WHERE rowid = :id AND attempts = :attempts
SQL

    UPDATE_USED_AT = <<-SQL
UPDATE verification_codes
SET used_at = 'now'
WHERE rowid = :id AND used_at IS NULL
SQL

    def initialize(db)
      @db = db
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
      row = @db.get_first_row(FIND_VERIFICATION, "id" => id)

      row["expired"] = row["expired"] == 0
      row["used"] = row["expired"] == 0

      row
    end

    def verify_code(id, code)
      vc = nil

      while true
        vc = get_verification(id)
        return false if vc.nil? or vc["expired"] or vc["attempts"] > MAX_ATTEMPTS

        @db.execute(UPDATE_CODE_ATTEMPTS, "id" => id, "attempts" => vc["attempts"])
        break if @db.changes > 0
      end

      valid = vc["code"] == code

      @db.execute(UPDATE_USED_AT, "id" => id) if valid

      valid
    end
  end
end
