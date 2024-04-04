defmodule EventMishandlingWeb.MessagesTab do
  use EventMishandlingWeb, :live_component

  def update(assigns, socket) do
    {
      :ok,
      assign(socket, id: assigns.id, value: "")
    }
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <.live_component
        module={EventMishandlingWeb.MessageComponent}
        id="some_unique_message_id"
        message="Example message"
      />
      <form
        id="full_add_message_form"
        class="flex flex-col"
        phx-change="add_message_change"
        phx-submit="add_message"
        phx-target="#full_add_message_form"
      >
        <.input id="new_message_input" name="new_message" class="mt-2" value={@value} />
      </form>
    </div>
    """
  end

  def handle_event("add_message_change", %{"new_message" => value}, socket) do
    {:noreply, assign(socket, :value, value)}
  end
end
