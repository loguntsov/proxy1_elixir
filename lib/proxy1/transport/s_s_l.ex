defmodule Proxy1.Transport.SSL do
  @moduledoc false

  @behaviour Proxy1.Transport.Handler

  def connect(server, port, opts), do:
    :ssl.connect(:erlang.binary_to_list(server), port, [mode: :binary, active: :once] ++ opts)

  def close(socket), do:
    :ssl.close(socket)

  def send(socket, binary), do:
    :ssl.send(socket, binary)

  def handle({:ssl, socket, data}) do
    :ssl.setopts(socket, [active: :once])
    { :data, socket, data }
  end

  def handle({:ssl_closed, socket}), do:
    { :closed, socket, :undefined }

  def handle({:ssl_error, socket, reason}), do:
    { :error, socket, reason }

  def handle(_), do: :unrecognized

  def ranch_transport(), do: :ranch_tcp

  def setopts(socket, opts), do:
    :inet.setopts(socket, opts)

end
