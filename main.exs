Application.put_env(:sample, Example.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 5001],
  server: true,
  live_view: [signing_salt: "aaaaaaaa"],
  secret_key_base: String.duplicate("a", 64)
)

Mix.install([
  {:plug_cowboy, "~> 2.5"},
  {:jason, "~> 1.0"},
  {:phoenix, "~> 1.7"},
  # please test your issue using the latest version of LV from GitHub!
  {:phoenix_live_view, github: "phoenixframework/phoenix_live_view", branch: "main", override: true},
])

# build the LiveView JavaScript assets (this needs mix and npm available in your path!)
path = Phoenix.LiveView.__info__(:compile)[:source] |> Path.dirname() |> Path.join("../")
System.cmd("mix", ["deps.get"], cd: path, into: IO.binstream())
System.cmd("npm", ["install"], cd: Path.join(path, "./assets"), into: IO.binstream())
System.cmd("mix", ["assets.build"], cd: path, into: IO.binstream())

defmodule Example.ErrorView do
  def render(template, _), do: Phoenix.Controller.status_message_from_template(template)
end

defmodule Example.PanelLive do
  use Phoenix.LiveView, layout: {__MODULE__, :live}
  use Phoenix.VerifiedRoutes, endpoint: Example.Endpoint, router: Example.Router

  alias Phoenix.LiveView.JS

  def render("live.html", assigns) do
    ~H"""
    <script src="/assets/phoenix/phoenix.js"></script>
    <script src="/assets/phoenix_live_view/phoenix_live_view.js"></script>
    <script>
      let liveSocket = new window.LiveView.LiveSocket("/live", window.Phoenix.Socket)
      liveSocket.connect()
    </script>
    <style>
      * { font-size: 1.1em; }
    </style>
    <%= @inner_content %>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="w-screen">
      <div class="border-l flex flex-row">
        <div class="flex flex-col min-w-14 items-center">
          <.tab_button
            tab={:messages_tab}
            icon="hero-chat-bubble-bottom-center-text"
            text="Messages tab"
            live_action={@live_action}
            route={~p"/messages_tab"}
          />
          <.tab_button
            tab={:settings_tab}
            icon="hero-cog-6-tooth"
            text="Settings tab"
            live_action={@live_action}
            route={~p"/settings_tab"}
          />
        </div>

        <aside class="border border-black !w-[270px]">
          <div class="flex flex-col">
            <div :if={@live_action == :messages_tab}>
              <.live_component module={Example.MessagesTab} id="messages_tab" />
            </div>
            <div :if={@live_action == :settings_tab}>
              <.live_component module={Example.SettingsTab} id="settings_tab" />
            </div>
          </div>
        </aside>
      </div>
    </div>
    """
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp tab_button(assigns) do
    ~H"""
    <button
      type="button"
      class={["mb-4 mt-2", if(@live_action == @tab, do: "bg-gray-200")]}
      phx-click={JS.patch(@route)}
    >
      <%= @text %>
      <%!-- <.icon name={@icon} /> --%>
    </button>
    """
  end
end

defmodule Example.SettingsTab do
  use Phoenix.LiveComponent

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>Settings</div>
    """
  end
end

defmodule Example.MessagesTab do
  use Phoenix.LiveComponent

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
        module={Example.MessageComponent}
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

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <input
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value("text", @value)}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          "border-zinc-300 focus:border-zinc-400",
        ]}
      />
    </div>
    """
  end

  def handle_event("add_message_change", %{"new_message" => value}, socket) do
    {:noreply, assign(socket, :value, value)}
  end
end

defmodule Example.MessageComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div><%= @message %></div>
    """
  end
end

defmodule Example.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  scope "/", Example do
    pipe_through(:browser)

    live("/messages_tab", PanelLive, :messages_tab)
    live("/settings_tab", PanelLive, :settings_tab)
  end
end

defmodule Example.Endpoint do
  use Phoenix.Endpoint, otp_app: :sample
  socket("/live", Phoenix.LiveView.Socket)

  plug Plug.Static, from: {:phoenix, "priv/static"}, at: "/assets/phoenix"
  plug Plug.Static, from: {:phoenix_live_view, "priv/static"}, at: "/assets/phoenix_live_view"

  plug(Example.Router)
end

{:ok, _} = Supervisor.start_link([Example.Endpoint], strategy: :one_for_one)
Process.sleep(:infinity)
