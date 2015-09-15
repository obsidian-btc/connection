require "fiber"
require "socket"

require "telemetry/logger"

require_relative "connection/proxy"
require_relative "connection/proxy/io_methods"

require_relative "connection/client"
require_relative "connection/reactor/dispatcher"
require_relative "connection/policy"
require_relative "connection/policy/cooperative"
require_relative "connection/policy/cooperative/action"
require_relative "connection/policy/cooperative/action/accept"
require_relative "connection/policy/cooperative/action/gets"
require_relative "connection/policy/cooperative/action/puts"
require_relative "connection/policy/cooperative/action/read"
require_relative "connection/policy/cooperative/action/write"
require_relative "connection/policy/cooperative/timer"
require_relative "connection/policy/immediate"
require_relative "connection/reactor"
require_relative "connection/server"
require_relative "connection/server/client"
