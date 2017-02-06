defmodule Proxy1.RanchProtocol do
  @moduledoc false

  alias Proxy1.RanchProtocol, as: RanchProtocol

  require Logger
  use GenServer

  alias Proxy1.Transport.Handler, as: Handler

  defstruct [
    :received_socket,
    :received_transport,
    :ranch_transport,
    :send_socket,
    :send_transport,
    :send_server,
    :send_port
  ]

  def start_link(ref, socket, transport, opts), do:
	  {:ok, :proc_lib.spawn_link(__MODULE__, :init, [{ref, socket, transport, opts}])}

  def init({ref, socket, transport, opts}) do
    %{
      listen_transport: listen_transport,
      connect_server: server,
      connect_port: port,
      connect_transport: send_transport
    } = opts
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [active: :once])

    { :ok, send_socket } = Handler.connect(send_transport, server, port, [])

    state = %RanchProtocol{
      received_socket: socket,
      received_transport: listen_transport,
      ranch_transport: transport,
      send_transport: send_transport,
      send_socket: send_socket,
      send_server: server,
      send_port: port
    }
    :gen_server.enter_loop(__MODULE__, [], state)
  end

  def handle_info(msg, state) do
    %RanchProtocol{
      send_transport: send_transport,
      send_socket: send_socket,
      received_transport: receive_transport,
      received_socket: received_socket
    } = state

    receiver_result = case Handler.handle(receive_transport, msg) do
      { :data, socket0, data0} when socket0 === received_socket ->
        handle_received_socket_receive_data(data0, state)
      { :error, socket0, _reason0} when socket0 === received_socket ->
        { :stop, state }
      { :closed, socket0, _ } when socket0 === received_socket ->
        { :stop, state }
      _ -> :undefined
    end

    send_result = case Handler.handle(send_transport, msg) do
      { :data, socket1, data1} when socket1 === send_socket ->
        handle_send_socket_received_data(data1, state);
      { :error, socket1, _reason1} when socket1 === send_socket ->
        { :stop, state }
      { :closed, socket1, _ } when socket1 === send_socket ->
        { :stop, state }
      _ -> :undefined
    end

    { action, new_state } = case { send_result, receiver_result } do
      { :undefined, :undefined } ->
        Logger.info "Unknown info message ~p ~p", [ msg: msg, state: state ]
        { :ok, state };
      { :undefined, _ } -> receiver_result;
      { _, :undefined } -> send_result;
      { _, _ } -> raise(WrongLogic, [ send_result, receiver_result ])
    end
    case action do
      :ok -> { :noreply, new_state }
      :stop -> { :stop, :normal, new_state }
    end
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

## Internal

  defp handle_received_socket_receive_data(data, state) do
    Logger.info(">>> " <> data, [ data: data])
    :ok = Handler.send(state.send_transport, state.send_socket, data)
    { :ok, state }
  end

  defp handle_send_socket_received_data(data, state) do
    Logger.info("<<< " <> data, [ data: data ])
    :ok = Handler.send(state.received_transport, state.received_socket, data)
    { :ok, state }
  end

end
