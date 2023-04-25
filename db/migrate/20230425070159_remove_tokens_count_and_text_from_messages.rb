# frozen_string_literal: true

class RemoveTokensCountAndTextFromMessages < ActiveRecord::Migration[7.0]
  def change
    remove_column :messages, :tokens_count, :integer, null: false, default: 0
  end
end
