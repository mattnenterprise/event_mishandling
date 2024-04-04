defmodule EventMishandlingWeb.PanelLive do
  use EventMishandlingWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="w-screen">
      <div class="border-l flex flex-row">
        <div class="flex flex-col min-w-14 items-center">
          <.tab_button
            tab={:messages_tab}
            icon="hero-chat-bubble-bottom-center-text"
            live_action={@live_action}
            route={~p"/messages_tab"}
          />
          <.tab_button
            tab={:settings_tab}
            icon="hero-cog-6-tooth"
            live_action={@live_action}
            route={~p"/settings_tab"}
          />
        </div>

        <aside class="border border-black !w-[270px]">
          <div class="flex flex-col">
            <div class={if @live_action != :messages_tab, do: "hidden"}>
              <.live_component module={EventMishandlingWeb.MessagesTab} id="messages_tab" />
            </div>
            <div class={if @live_action != :settings_tab, do: "hidden"}>
              <.live_component module={EventMishandlingWeb.SettingsTab} id="settings_tab" />
            </div>
          </div>
        </aside>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp tab_button(assigns) do
    ~H"""
    <button
      type="button"
      class={["mb-4 mt-2", if(@live_action == @tab, do: "bg-gray-200")]}
      phx-click={JS.patch(@route)}
    >
      <.icon name={@icon} />
    </button>
    """
  end
end
