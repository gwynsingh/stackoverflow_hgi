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

  def questions(conn, params) do
    user_id = get_session(conn, :user_id)
    token = get_session(conn, :results_token)
    query = get_session(conn, :query) || ""

    cache = Stackoverflow.ResultCache.get(token) || %{}
    results =
      case params["sort"] do
        "ai" -> cache[:ai_sorted_results] || []
        _ -> cache[:results] || []
      end

    recent_questions =
      if user_id do
        Stackoverflow.RecentQuestions.get_recent_questions(user_id)
      else
        []
      end

    count = length(results)

    render(conn, :questions, results: results, query: query, recent_questions: recent_questions, count: count, sort: params["sort"] || "relevance")
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

    ai_sorted_results =
      if length(results) > 0 do
        Stackoverflow.LLM.sort_questions_by_relevance(query, results)
      else
        []
      end

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

    # Generate a unique token for this search
    token = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
    Stackoverflow.ResultCache.put(token, %{results: results, ai_sorted_results: ai_sorted_results})

    conn
    |> put_session(:results_token, token)
    |> put_session(:query, query)
    |> render(:questions, results: results, query: query, recent_questions: recent_questions, count: count)
  end

  def ai_sort(conn, _params) do
    token = get_session(conn, :results_token)
    query = get_session(conn, :query) || ""
    user_id = get_session(conn, :user_id)

    cache = Stackoverflow.ResultCache.get(token) || %{}
    results = cache[:ai_sorted_results] || []

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
