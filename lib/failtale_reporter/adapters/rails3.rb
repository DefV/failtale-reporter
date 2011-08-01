
module FailtaleReporter

  def self.force_public(flag=nil)
    @force_public = flag unless flag.nil?
    @force_public
  end
  
   def self.enabled(flag=nil)
    @enabled = flag unless flag.nil?
    @enabled
  end
  
end

module FailtaleReporter::Adapters::Rails3

  IGNORED_EXCEPTIONS = ['ActiveRecord::RecordNotFound',
                        'ActionController::RoutingError',
                        'ActionController::InvalidAuthenticityToken',
                        'ActiveSupport::MessageVerifier::InvalidSignature']

  IGNORED_EXCEPTIONS.map!{|e| eval(e) rescue nil }.compact!
  IGNORED_EXCEPTIONS.freeze

  def self.included(target)
    FailtaleReporter.configure do |config|
      config.ignored_exceptions IGNORED_EXCEPTIONS
      config.default_reporter "rails"
      config.application_root Rails.root
      config.information_collector do |error, controller|
        env = error.environment
        env = env.merge(controller.request.env)

        env.delete('action_controller.rescue.response')
        env.delete('action_controller.rescue.request')
        env.delete('rack.request.form_vars')
        env.delete('rack.request')
        env.delete('rack.request.cookie_hash')
        error.environment = env
      end
    end
  end

  def rescue_with_handler(exception)
    FailtaleReporter.report(exception, self) unless is_private? or !FailtaleReporter.enabled
    super
  end

protected

  def is_private?
    !FailtaleReporter.force_public and %w(development test).include?(Rails.env)
  end

end

::ActionController::Base.send :include, FailtaleReporter::Adapters::Rails3