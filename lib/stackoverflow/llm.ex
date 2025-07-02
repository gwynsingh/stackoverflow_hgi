defmodule Stackoverflow.LLM do
  @moduledoc false

  @openai_api_url "https://api.openai.com/v1/chat/completions"
  @model "gpt-3.5-turbo-0125"

  def sort_questions_by_relevance(user_query, questions) do
    prompt = build_prompt(user_query, questions)
    api_key = System.get_env("OPENAI_API_KEY")

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]

    body =
      Jason.encode!(%{
        model: @model,
        messages: [
          %{role: "system", content: system_prompt()},
          %{role: "user", content: prompt}
        ],
        temperature: 0.0
      })

    case HTTPoison.post(@openai_api_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: resp_body}} ->
        parse_llm_response(resp_body, questions)

      {:ok, %HTTPoison.Response{status_code: code, body: resp_body}} ->
        IO.inspect({:error, code, resp_body}, label: "OpenAI error")
        questions

      {:error, err} ->
        IO.inspect(err, label: "HTTP error")
        questions
    end
  end

  defp build_prompt(user_query, questions) do
    questions_text =
      questions
      |> Enum.with_index(1)
      |> Enum.map(fn {q, idx} ->
        "#{idx}. #{q["title"]}\n"
      end)
      |> Enum.join("\n\n")

    "User Query: #{user_query}\n\nQuestions:\n#{questions_text}\n\nPlease return the most relevant order as a list of numbers (e.g., [3,1,2,...]) based on the user's query."
  end

  defp system_prompt do
    "You are an AI assistant that sorts StackOverflow questions by relevance to the user's query. Return only a JSON array of the sorted question indices (1-based).
    Criteria for sorting:
      - A combination of the question title, number of votes and number of answers
      - The question with the most votes and answers should be first
      - The question with the most votes should be second
      - The question with the most answers should be third
      - Rest are sorted by title relevance.
    "
  end

  defp parse_llm_response(resp_body, questions) do
    with {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} <-
           Jason.decode(resp_body),
         cleaned_content <-
           content
           |> String.replace(~r/^```json\n|^```|```$/, "")
           |> String.trim(),
         {:ok, indices} <- Jason.decode(cleaned_content) do
      indices
      |> Enum.map(&Enum.at(questions, &1 - 1))
    else
      _ ->
        IO.inspect(resp_body, label: "Failed to parse LLM response")
        questions
    end
  end
end
