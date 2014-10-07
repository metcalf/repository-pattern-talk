repository-pattern-talk
=======================

Talk about using the repository pattern to replace ORMs

## ORM Example Commands
```
rm -f orm_example.db
pry
require './orm_example/lib/orm_example.rb'
ORMExample.init('orm_example.db')
ORMExample::CreateTables.new.change

vc = ORMExample::VerificationCode.create_verification_message('sms', '6508675309', 'Your code is 123456', '123456')
vc.verify('123123')
ORMExample::VerificationCode.find_by_id(vc.id)
vc.verify('123456')
ORMExample::VerificationCode.find_by_id(vc.id)

ls vc
```

## Repository Example Commands
```
rm -f repo_example.db
sqlite3 repo_example.db < repo_example/schema.sql
pry
require './repo_example/lib/repo_example.rb'

repo = RepoExample::Repository.new("repo_example.db")

id = repo.create_verification_message('sms', '6508675309', 'Your code is 123456', '123456')
repo.verify_code(id, '123123')
repo.get_verification(id)
repo.verify_code(id, '123456')
vc = repo.get_verification(id)

ls repo
ls vc
```

UPDATE verification_codes SET attempts=attempts+1 WHERE id = :id
