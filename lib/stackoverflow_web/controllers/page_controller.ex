defmodule StackoverflowWeb.PageController do
  use StackoverflowWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def questions(conn, _params) do
    url = "https://api.stackexchange.com/2.3/questions?order=desc&sort=creation&site=stackoverflow"
    results =
      case HTTPoison.get(url, [], recv_timeout: 10_000) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Jason.decode!(body)["items"]
        _ ->
          []
      end
    render(conn, :questions, results: results, query: "")
  end

  def search(conn, %{"query" => query}) do
    url = "https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=relevance&q=#{URI.encode(query)}&site=stackoverflow"
    results =
      case HTTPoison.get(url, [], recv_timeout: 10_000) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Jason.decode!(body)["items"]
        _ ->
          []
      end
    render(conn, :questions, results: results, query: query)
  end
end
