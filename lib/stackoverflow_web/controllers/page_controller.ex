defmodule StackoverflowWeb.PageController do
  use StackoverflowWeb, :controller
  alias Stackoverflow.Users

  plug :require_logged_in_user when action in [:questions, :search]
  plug :fetch_current_user

  defp fetch_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Users.get_user(user_id)
    assign(conn, :current_user, user)
  end

  defp require_logged_in_user(conn, _opts) do
    if get_session(conn, :user_id) do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def questions(conn, _params) do
    user_id = get_session(conn, :user_id)

    recent_questions =
      if user_id do
        Stackoverflow.RecentQuestions.get_recent_questions(user_id)
      else
        []
      end

    url =
      "https://api.stackexchange.com/2.3/questions?order=desc&sort=creation&site=stackoverflow"

    results =
      case HTTPoison.get(url, [], recv_timeout: 10_000) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Jason.decode!(body)["items"]
        _ ->
          []
      end

    count = length(results)

    render(conn, :questions, results: results, query: "", recent_questions: recent_questions, count: count)
  end

  def search(conn, %{"query" => query}) do
    user_id = get_session(conn, :user_id)

    url =
      "https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=relevance&q=#{URI.encode(query)}&site=stackoverflow"

    results =
      case HTTPoison.get(url, [], recv_timeout: 10_000) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Jason.decode!(body)["items"]
        _ ->
          []
      end

    # Store the searched question for the user
    if user_id do
      Stackoverflow.RecentQuestions.add_recent_question(user_id, %{
        title: query,
        link: nil,
        asked_at: DateTime.utc_now()
      })
    end

    recent_questions =
      if user_id do
        Stackoverflow.RecentQuestions.get_recent_questions(user_id)
      else
        []
      end

    count = length(results)

    render(conn, :questions, results: results, query: query, recent_questions: recent_questions, count: count)
  end
end
