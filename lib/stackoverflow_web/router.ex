defmodule StackoverflowWeb.Router do
  use StackoverflowWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {StackoverflowWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StackoverflowWeb do
    pipe_through :browser

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/", PageController, :home
    get "/questions", PageController, :questions
  end

  # Other scopes may use custom stacks.
  # scope "/api", StackoverflowWeb do
  #   pipe_through :api
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:stackoverflow, :dev_routes) do

    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
