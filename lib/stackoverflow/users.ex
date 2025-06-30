defmodule Stackoverflow.Users do
  alias Stackoverflow.Users.User
  alias Stackoverflow.Repo

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end
end
