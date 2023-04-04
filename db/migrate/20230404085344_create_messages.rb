# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.timestamps
      t.references :chat, null: false, foreign_key: true
      t.text :text, null: false
    end
  end
end
