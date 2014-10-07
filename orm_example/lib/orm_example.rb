require 'active_record'

module ORMExample
  # Ignore me being lurky
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'orm_example.db',
    )
end

require_relative 'migration.rb'
require_relative 'models.rb'
