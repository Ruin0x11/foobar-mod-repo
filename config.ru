# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

if Rails.env.development?
  use ActionDispatch::Static, "./server"
end

run Rails.application
