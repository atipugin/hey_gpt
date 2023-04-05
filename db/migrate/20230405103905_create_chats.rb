# frozen_string_literal: true

class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.timestamps
      t.bigint :telegram_id, null: false, index: { unique: true }
      t.jsonb :telegram_data, null: false
    end
  end
end
