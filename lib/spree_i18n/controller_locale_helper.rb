module SpreeI18n
  # Overrides the Spree::Core::ControllerHelpers::Common logic so that only
  # supported locales defined by Spree::Conf[:supported_locales] can actually
  # be set
  #
  # The fact this logic is in a single module also helps to apply a custom
  # locale on the spree/api context since api base controller inherits from
  # MetalController instead of Spree::BaseController
  module ControllerLocaleHelper
    extend ActiveSupport::Concern
    included do
      before_filter :set_user_language

      private
        def set_user_language
          I18n.locale = if session.key?(:locale) && Spree::Config.supported_locales.include?(session[:locale])
            session[:locale]
          else
            Rails.application.config.i18n.default_locale
          end
        end
    end
  end
end
