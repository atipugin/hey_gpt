# frozen_string_literal: true

class ChangeMessagesLimitDefaultInUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :messages_limit, 5
  end
end
