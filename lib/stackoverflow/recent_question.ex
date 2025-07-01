defmodule Stackoverflow.RecentQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recent_questions" do
    field :title, :string
    field :asked_at, :utc_datetime
    belongs_to :user, Stackoverflow.Users.User, foreign_key: :user_id
    timestamps()
  end

  @doc false
  def changeset(recent_question, attrs) do
    recent_question
    |> cast(attrs, [:user_id, :title, :asked_at])
    |> validate_required([:user_id, :title, :asked_at])
  end
end
