defmodule OrbShowcase.Generator.OpenAI do
  # @gpt_model "gpt-4o-mini"
  @gpt_model "gpt-4o-2024-05-13"

  defp req() do
    api_key = System.get_env("OPENAI_API_KEY") || raise "Env var OPENAI_API_KEY must be set."

    Req.new(
      base_url: "https://api.openai.com",
      headers: [
        authorization: "Bearer #{api_key}"
      ],
      connect_options: [
        timeout: 60_000,
        protocols: [:http2]
      ],
      receive_timeout: 60_000
    )
  end

  def complete(message, system_prompt \\ "") do
    req_json = %{
      model: @gpt_model,
      messages: [
        %{role: "system", content: system_prompt},
        %{role: "user", content: message}
      ],
      temperature: 0.7
    }

    %{body: res_json} =
      req()
      |> Req.post!(url: "/v1/chat/completions", json: req_json)

    %{"choices" => [%{"message" => %{"content" => content}}]} = res_json
    content
  end
end
