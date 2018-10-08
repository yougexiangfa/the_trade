require 'active_support/configurable'

module RailsTrade
  include ActiveSupport::Configurable

  configure do |config|
    config.admin_class = 'Admin::BaseController'
    config.my_class = 'My::BaseController'
    config.default_currency = 'CNY'
    config.disabled_models = []
  end

end