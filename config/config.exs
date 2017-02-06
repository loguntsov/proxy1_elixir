# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :info

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

config :proxy1,
  connect_transport: Proxy1.Transport.SSL, # Transport of outgoing connections. Allows values: proxy1_ssl_transport, proxy1_tcp_transport
  connect_server: "ya.ru", # Server for oungoing conection
  connect_port: 443, # Port for outgoing connections.
  listen_transport: Proxy1.Transport.TCP, # Transport of incomming connections. Allows values: proxy1_ssl_transport, proxy1_tcp_transport
  listen_port: 8081 # Port for incomming connections

# You can configure for your application as:
#
#     config :proxy1, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:proxy1, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
