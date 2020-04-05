defmodule LiveGameWeb.Router do
  use LiveGameWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug LiveGameWeb.SessionPlug
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {LiveGameWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveGameWeb do
    pipe_through :browser

    live "/", Home
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveGameWeb do
  #   pipe_through :api
  # end
end
