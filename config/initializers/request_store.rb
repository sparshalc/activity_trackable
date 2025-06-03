Rails.application.configure do
  config.middleware.use RequestStore::Middleware
end
