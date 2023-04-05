# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.timestamps
      t.bigint :telegram_id, null: false, index: { unique: true }
      t.jsonb :telegram_data, null: false
      t.references :chat, null: false
      t.references :user
    end
  end
end
