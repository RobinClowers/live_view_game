defmodule LiveGameWeb.SessionPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    conn
    |> get_session("id")
    |> case do
      nil -> put_session(conn, "id", UUID.uuid4())
      _ -> conn
    end
  end
end
