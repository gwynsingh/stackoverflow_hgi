defmodule Stackoverflow.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :hashed_password, :string

      timestamps(type: :utc_datetime)
    end
  end
end
