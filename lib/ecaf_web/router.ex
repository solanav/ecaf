defmodule EcafWeb.Router do
  use EcafWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {EcafWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EcafWeb do
    pipe_through :browser

    # Home
    live "/", FileLive.Index, :index
    #live "/files", FileLive.Index, :index
    live "/files/new", FileLive.Index, :new
    #live "/files/:id/edit", FileLive.Index, :edit

    #live "/files/:id", FileLive.Show, :show
    #live "/files/:id/show/edit", FileLive.Show, :edit
    # <span><%= link "Delete", to: "#", phx_click: "delete", phx_value_id: file.id, data: [confirm: "Are you sure?"] %></span>
  end
end
