# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Stackoverflow.Repo.insert!(%Stackoverflow.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Stackoverflow.Users

email = "johndoe@example.com"
password = "password"
name = "John Doe"

case Users.get_user_by_email(email) do
  nil ->
    {:ok, _user} = Users.create_user(%{"email" => email, "hashed_password" => password, "name" => name})
    IO.puts("Seeded user: #{email} / #{password}")
  _user ->
    IO.puts("User #{email} already exists, skipping seeding.")
end
