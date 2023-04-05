# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.timestamps
      t.bigint :telegram_id, null: false, index: { unique: true }
      t.jsonb :telegram_data, null: false
    end
  end
end
