# frozen_string_literal: true

class AddFromUserToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :from_user, :boolean, null: false, default: false
  end
end
