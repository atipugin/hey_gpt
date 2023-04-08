# frozen_string_literal: true

module ActsAsService
  Result = Struct.new(:success?, :error, :data)

  private

  def t(key, opts = {})
    I18n.t(key, **opts.merge(scope: i18n_scope))
  end

  def i18n_scope
    [:services, self.class.name.underscore]
  end
end
