# frozen_string_literal: true

module ActsAsService
  Result = Struct.new(:success?, :error, :data)

  def success(data: nil)
    Result.new(true, nil, data)
  end

  def failure(error: nil, data: nil)
    Result.new(false, error, data)
  end

  private

  def t(key, opts = {})
    I18n.t(key, **opts.merge(scope: i18n_scope))
  end

  def i18n_scope
    [:services, self.class.name.underscore]
  end
end
