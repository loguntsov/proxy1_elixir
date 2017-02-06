defmodule Proxy1.App do
  @moduledoc false

  use Application
  @app :proxy1

  def start(_type, _args) do

    listen_transport = env(:listen_transport)
    listen_port = env(:listen_port)

    {:ok, _} = :ranch.start_listener(:proxy, 1, listen_transport |> Proxy1.Transport.Handler.ranch_transport, [port: listen_port], Proxy1.RanchProtocol, %{
      listen_transport: listen_transport,
      connect_server: env(:connect_server),
      connect_port: env(:connect_port),
      connect_transport: env(:connect_transport),
    })

    { :ok, pid } = Proxy1.App.Sup.start_link()
    { :ok, pid }
  end

  def env(key) do
    { :ok, value } = :application.get_env(@app, key)
    value
  end

  defmodule Sup do
    @moduledoc false

    use Supervisor

    def start_link() do
      Supervisor.start_link(__MODULE__, [])
    end

    def init([]) do
      children = [ ]

      supervise(children, strategy: :one_for_one)
    end
  end

end