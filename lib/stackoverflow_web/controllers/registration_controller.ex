defmodule StackoverflowWeb.RegistrationController do
  use StackoverflowWeb, :controller
  alias Stackoverflow.Users

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email, "password" => password, "name" => name}) do
    case Users.create_user(%{"email" => email, "hashed_password" => password, "name" => name}) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Account created successfully. Please log in.")
        |> redirect(to: "/login")
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not create account. Please check your input.")
        |> render("new.html")
    end
  end
end
