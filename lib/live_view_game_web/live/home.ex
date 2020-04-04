defmodule LiveGameWeb.Home do
  use Phoenix.LiveView

  def mount(_params, session, socket) do
    {:ok, assign(socket, [])}
  end
end
