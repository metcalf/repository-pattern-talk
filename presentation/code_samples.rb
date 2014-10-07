# Highlight with:
# highlight -O rtf presentation/code_samples.rb --font-size 20 --font Inconsolata --style solarized-dark --src-lang ruby | pbcopy

#### ORM / SQL comparison

return VerificationCode.find_by_id(1)

#######

FIND_VERIFICATION = <<-SQL
SELECT phone, sender_type, status, body, attempts, code,
  expires_at, used_at
FROM verification_codes
LEFT JOIN messages ON messages.verification_code_id = verification_codes.rowid
WHERE verification_codes.rowid = :id
LIMIT 1
SQL

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

return verification


### AR magic

VerificationCode.increment_counter(:attempts, id)

#####

UPDATE_CODE_ATTEMPTS = 'UPDATE verification_codes SET attempts=attempts+1 WHERE rowid = :id'
@db.execute(UPDATE_CODE_ATTEMPTS, 'id' => id)
