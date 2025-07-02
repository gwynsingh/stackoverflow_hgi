defmodule Stackoverflow.Repo.Migrations.CreateRecentQuestions do
  use Ecto.Migration

  def change do
    create table(:recent_questions) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :title, :string
      add :asked_at, :utc_datetime
      timestamps()
    end

    create index(:recent_questions, [:user_id])
    create unique_index(:recent_questions, [:user_id, :title])
  end
end
