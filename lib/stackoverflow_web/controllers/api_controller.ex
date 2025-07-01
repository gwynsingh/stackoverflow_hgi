defmodule StackoverflowWeb.ApiController do
  use StackoverflowWeb, :controller

  def search(conn, %{"query" => query}) do
    url = "https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=relevance&q=#{URI.encode(query)}&site=stackoverflow"
    case HTTPoison.get(url, [], recv_timeout: 10_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        json(conn, Jason.decode!(body))
      _ ->
        conn
        |> put_status(:bad_gateway)
        |> json(%{error: "Failed to fetch from Stack Overflow"})
    end
  end
end
