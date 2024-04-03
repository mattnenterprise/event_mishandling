defmodule EventMishandlingWeb.MessageComponent do
  use EventMishandlingWeb, :live_component

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div><%= @message %></div>
    """
  end
end
