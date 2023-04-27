# frozen_string_literal: true

class AddBlockedToChats < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :blocked, :boolean, null: false, default: false
  end
end
