defmodule LiveGameWeb.PageController do
  use LiveGameWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
