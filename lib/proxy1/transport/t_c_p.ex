defmodule Proxy1.Transport.TCP do
  @moduledoc false

  @behaviour Proxy1.Transport.Handler

  def connect(server, port, opts), do:
    :gen_tcp.connect(:erlang.binary_to_list(server), port, [mode: :binary, active: :once] ++ opts)

  def close(socket), do:
    :gen_tcp.close(socket)

  def send(socket, binary), do:
    :gen_tcp.send(socket, binary)

  def handle({:tcp, socket, data}) do
    :inet.setopts(socket, [active: :once])
    { :data, socket, data }
  end

  def handle({:tcp_closed, socket}), do:
    { :closed, socket, :undefined }

  def handle({:tcp_error, socket, reason}), do:
    { :error, socket, reason }

  def handle(_), do: :unrecognized

  def ranch_transport(), do: :ranch_tcp

  def setopts(socket, opts), do:
    :inet.setopts(socket, opts)

end
