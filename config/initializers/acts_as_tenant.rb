ActsAsTenant.configure do |config|
  config.require_tenant = false # Set to false initially for setup
end

# Set the first company as the default tenant during console startup
Rails.application.configure do
  if Rails.env.development? && defined?(Rails::Console)
    ActiveSupport::Reloader.to_prepare do
      puts ">>> Setting ActsAsTenant.current_tenant = Company.first"
      ActsAsTenant.current_tenant = Company.first
      puts ">>> Current Tenant Set: #{ActsAsTenant.current_tenant.class} - #{ActsAsTenant.current_tenant&.name}"
    end
  end
end
