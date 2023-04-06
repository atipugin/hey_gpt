# frozen_string_literal: true

module ActsAsService
  Result = Struct.new(:success, :error, :data)

  def success(data: nil)
    Result.new(success: true, data:)
  end

  def failure(error:, data: nil)
    Result.new(success: false, error:, data:)
  end
end
