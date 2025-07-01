defmodule Stackoverflow.RecentQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recent_questions" do
    field :title, :string
    field :link, :string
    field :asked_at, :utc_datetime
    belongs_to :user, Stackoverflow.Users.User
    timestamps()
  end

  def changeset(recent_question, attrs) do
    recent_question
    |> cast(attrs, [:user_id, :title, :link, :asked_at])
    |> validate_required([:user_id, :title, :link, :asked_at])
  end
end
