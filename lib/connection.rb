require "fiber"
require "socket"

require "telemetry/logger"

require_relative "connection/connection"
require_relative "connection/connection/io_methods"

require_relative "connection/client"
require_relative "connection/reactor/dispatcher"
require_relative "connection/policy/cooperative"
require_relative "connection/policy/immediate"
require_relative "connection/reactor"
require_relative "connection/server"
require_relative "connection/server/client"
