defmodule EventMishandlingWeb.Panel do
  use EventMishandlingWeb, :live_view

  require Logger

  on_mount EventMishandlingWeb.SelectedTab

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="h-full w-screen">
      <div class="border-on-primary-black-focus border-l border-b bg-white flex flex-row h-full">
        <div class="flex flex-col min-w-14 items-center">
          <.tab_button
            tab="messages_tab"
            icon="hero-chat-bubble-bottom-center-text"
            selected_tab={@selected_tab}
          />
          <.tab_button tab="settings_tab" icon="hero-cog-6-tooth" selected_tab={@selected_tab} />
        </div>

        <aside class="border border-black !w-[270px]">
          <div class="h-full flex flex-col">
            <div :if={@selected_tab == "messages_tab"}>
              <.live_component module={EventMishandlingWeb.MessagesTab} id="messages_tab" />
            </div>
            <div :if={@selected_tab == "settings_tab"}>
              <.live_component module={EventMishandlingWeb.SettingsTab} id="settings_tab" />
            </div>
          </div>
        </aside>
      </div>
    </div>
    """
  end

  defp tab_button(assigns) do
    ~H"""
    <button
      type="button"
      class={["mb-4 mt-2 focus:outline-none", if(@selected_tab == @tab, do: "bg-gray-200")]}
      phx-click={JS.push("select_tab", value: %{tab: @tab})}
    >
      <.icon name={@icon} />
    </button>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("select_tab", %{"tab" => tab}, socket) do
    {:noreply, EventMishandlingWeb.SelectedTab.put_selected_tab(socket, tab)}
  end
end
