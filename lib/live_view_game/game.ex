defmodule LiveGame.Game do
  use GenServer
  require Logger

  @initial_state %{
    players: %{}
  }

  def initial_state, do: @initial_state

  def start_link(state) do
    Logger.info("Starting game server: #{inspect(state)}")
    GenServer.start_link(__MODULE__, state, name: CurrentGame)
  end

  def init(state) do
    Logger.info("Init game server: #{inspect(state)}")
    {:ok, state}
  end

  def get_state do
    GenServer.call(CurrentGame, "get_state")
  end

  def update_state(state) do
    GenServer.call(CurrentGame, {"update_state", state})
  end

  def handle_call("get_state", _from, state) do
    Logger.info("Event get_state: #{inspect(state)}")
    {:reply, {:ok, state}, state}
  end

  def handle_call({"update_state", new_state}, _from, state) do
    Logger.info("Event update_state: #{inspect(new_state)}")
    {:reply, {:ok, new_state}, new_state}
  end
end
