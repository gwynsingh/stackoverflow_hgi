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
    redirect(conn, to: "/questions")
  end

  def questions(conn, params) do
    user_id = get_session(conn, :user_id)
    query = params["q"] || ""

    {results, ai_sorted_results} =
      if query != "" do
        url = "https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=relevance&q=#{URI.encode(query)}&site=stackoverflow"
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
            asked_at: DateTime.utc_now()
          })
        end
        {results, ai_sorted_results}
      else
        {[], []}
      end

    recent_questions =
      if user_id do
        Stackoverflow.RecentQuestions.get_recent_questions(user_id)
      else
        []
      end

    # Fetch hot questions for sidebar
    hot_url = "https://api.stackexchange.com/2.3/questions?order=desc&sort=hot&site=stackoverflow&pagesize=5"
    hot_questions =
      case HTTPoison.get(hot_url, [], recv_timeout: 10_000) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          case Jason.decode(body) do
            {:ok, %{"items" => items}} when is_list(items) -> items
            _ -> []
          end
        _ ->
          []
      end

    count = length(results)

    results_to_render =
      case params["sort"] do
        "ai" -> ai_sorted_results
        _ -> results
      end

    render(conn, :questions, results: results_to_render, query: query, recent_questions: recent_questions, count: count, sort: params["sort"] || "relevance", hot_questions: hot_questions)
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
