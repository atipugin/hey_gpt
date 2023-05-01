# frozen_string_literal: true

class CreateReferrals < ActiveRecord::Migration[7.0]
  def change
    create_table :referrals do |t|
      t.timestamps
      t.references :referrer, null: false, foreign_key: { to_table: :users }
      t.references :referee, null: false, foreign_key: { to_table: :users }, index: { unique: true }
    end
  end
end
