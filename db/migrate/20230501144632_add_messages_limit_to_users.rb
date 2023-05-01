# frozen_string_literal: true

class AddMessagesLimitToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :messages_limit, :integer, null: false, default: 10
  end
end
