require 'active_record'

module ORMExample
  class CreateTables < ActiveRecord::Migration
    def change
      create_table :messages do |t|
        t.string :twilio_sid, limit: 34
        t.string :phone, null: false, limit: 32
        t.text :body, null: false
        t.string :sender_type, null: false, limit: 16
        t.string :status, null: false, default: 'unsent', limit: 16
        t.timestamp :created_at, null: false
        t.integer :verification_code_id
      end

      add_index(:messages, :twilio_sid, unique: true)

      create_table :verification_codes do |t|
        t.string :code, null: false, limit: 6
        t.integer :attempts, default: 0
        t.timestamp :used_at
        t.timestamp :expires_at
        t.timestamp :created_at, null: false
      end
    end
  end
end
