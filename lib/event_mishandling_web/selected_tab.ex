defmodule EventMishandlingWeb.SelectedTab do
  use EventMishandlingWeb, :verified_routes

  import Phoenix.Component, only: [assign_new: 3, assign: 3]

  import Phoenix.LiveView,
    only: [attach_hook: 4, detach_hook: 3, get_connect_params: 1, push_event: 3]

  @default_tab "settings_tab"
  @selected_tab_cookie_key "selected_tab"

  def fetch_selected_tab(conn, _opts) do
    selected_tab = Map.get(conn.cookies, @selected_tab_cookie_key, @default_tab)
    Plug.Conn.assign(conn, :selected_tab, selected_tab)
  end

  def on_mount(:default, params, _session, socket) do
    {:cont, assign_selected_tab(socket, params)}
  end

  defp assign_selected_tab(socket, params) do
    socket
    |> assign_new(:selected_tab, fn ->
      case params do
        params when is_map(params) ->
          socket
          |> get_connect_params()
          |> selected_tab_from_connect_params()

        :not_mounted_at_router ->
          @default_tab
      end
    end)
    |> attach_assign_selected_tab_hook()
  end

  defp selected_tab_from_connect_params(nil), do: @default_tab

  defp selected_tab_from_connect_params(params) when is_map(params),
    do: Map.get(params, "selected_tab", @default_tab)

  @one_year_in_seconds 60 * 60 * 24 * 365

  defp attach_assign_selected_tab_hook(socket) do
    socket
    |> detach_hook(:put_selected_tab, :handle_info)
    |> attach_hook(:put_selected_tab, :handle_info, fn
      {__MODULE__, :put_selected_tab, selected_tab}, socket ->
        cookie =
          Plug.Conn.Cookies.encode(@selected_tab_cookie_key, %{
            value: selected_tab,
            max_age: @one_year_in_seconds,
            secure: true,
            http_only: false,
            same_site: "strict"
          })

        {:halt,
         socket
         |> assign(:selected_tab, selected_tab)
         |> push_event("put_selected_tab", %{cookie: cookie})}

      _msg, socket ->
        {:cont, socket}
    end)
  end

  def put_selected_tab(socket, selected_tab) do
    send(self(), {__MODULE__, :put_selected_tab, selected_tab})

    socket
  end
end
