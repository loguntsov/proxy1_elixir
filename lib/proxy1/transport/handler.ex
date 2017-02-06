defmodule Proxy1.Transport.Handler do
  @moduledoc false

  @type socket :: any

  @callback connect(server :: String.t, port :: Integer.pos_integer, opts :: [] ) :: { :ok, socket :: socket()} | { :error, reason :: term() }
  @callback close(socket :: socket ) :: :ok | {:error, reason :: any() }
  @callback send(socket :: socket, Binary :: String.t) :: :ok | {:error, reason :: any }
  @callback handle(message :: any) ::
    { :error, socket :: Socket, reason :: any } |
    { :data, socket :: Socket, binary :: String.t } |
    { :closed, socket :: Socket, reason :: any } |
    :unrecognized

  @callback ranch_transport() :: atom()
  @callback setopts(socket :: Socket, opts :: any) :: :ok

  def connect(module, server, port, opts) do
    module.connect(server, port, opts)
  end

  def close(module, socket) do
    module.close(socket)
  end

  def send(module, socket, binary) do
    module.send(socket, binary)
  end

  def handle(module, message) do
    module.handle(message)
  end

  def ranch_transport(module) do
    module.ranch_transport()
  end

  def setopts(module, socket, opts) do
    module.setopts(socket, opts)
  end

end
