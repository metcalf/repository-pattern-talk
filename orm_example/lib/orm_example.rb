require 'active_record'

module ORMExample
  def self.init(db_path)
    # Ignore me being lurky
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => db_path,
      )
  end
end

require_relative 'migration.rb'
require_relative 'models.rb'
