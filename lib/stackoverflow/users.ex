defmodule Stackoverflow.Users do
  alias Stackoverflow.Users.User
  alias Stackoverflow.Repo

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def create_user(attrs) do
    attrs = Map.update!(attrs, "hashed_password", &hash_password/1)
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def hash_password(password) do
    :crypto.hash(:sha256, password) |> Base.encode16()
  end

  def get_user(id) do
    Repo.get(User, id)
  end
end
