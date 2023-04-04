# frozen_string_literal: true

class RenameUsersToChats < ActiveRecord::Migration[7.0]
  def change
    rename_table :users, :chats
  end
end
