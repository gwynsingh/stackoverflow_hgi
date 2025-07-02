defmodule Stackoverflow.RecentQuestions do
  import Ecto.Query
  alias Stackoverflow.Repo
  alias Stackoverflow.RecentQuestion

  def add_recent_question(user_id, attrs) do
    Repo.insert(
      %RecentQuestion{}
      |> RecentQuestion.changeset(Map.put(attrs, :user_id, user_id)),
      on_conflict: [set: [asked_at: attrs[:asked_at] || attrs["asked_at"]]],
      conflict_target: [:user_id, :title]
    )

    ids_to_delete =
      from(q in RecentQuestion,
        where: q.user_id == ^user_id,
        order_by: [desc: q.asked_at],
        offset: 5,
        select: q.id
      )
      |> Repo.all()

    from(q in RecentQuestion, where: q.id in ^ids_to_delete)
    |> Repo.delete_all()
  end

  def get_recent_questions(user_id) do
    from(q in RecentQuestion,
      where: q.user_id == ^user_id,
      order_by: [desc: q.asked_at],
      limit: 5
    )
    |> Repo.all()
  end
end
