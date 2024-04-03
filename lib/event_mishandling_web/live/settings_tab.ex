defmodule EventMishandlingWeb.SettingsTab do
  use EventMishandlingWeb, :live_component

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>Settings</div>
    """
  end
end
