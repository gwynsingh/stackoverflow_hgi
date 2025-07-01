defmodule StackoverflowWeb.SessionController do
  use StackoverflowWeb, :controller
  alias Stackoverflow.Users

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    user = Users.get_user_by_email(email)

    cond do
      user && check_password(user, password) ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Logged in successfully.")
        |> redirect(to: "/")

      true ->
        conn
        |> put_flash(:error, "Invalid email or password.")
        |> render("new.html")
    end
  end

  defp check_password(user, password) do
    # Hash the input password and compare to stored hash
    Stackoverflow.Users.hash_password(password) == user.hashed_password
  end
end
