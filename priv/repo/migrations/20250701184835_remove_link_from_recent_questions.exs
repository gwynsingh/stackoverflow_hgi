defmodule Stackoverflow.Repo.Migrations.RemoveLinkFromRecentQuestions do
  use Ecto.Migration

  def change do
    alter table(:recent_questions) do
      remove :link
    end
  end
end
