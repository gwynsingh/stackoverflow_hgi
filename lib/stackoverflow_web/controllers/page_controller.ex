defmodule StackoverflowWeb.PageController do
  use StackoverflowWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def questions(conn, _params) do
    render(conn, :questions)
  end
end
