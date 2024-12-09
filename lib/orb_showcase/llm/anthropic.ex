defmodule OrbShowcase.LLM.Anthropic do
  @anthropic_version "2023-06-01"
  @anthropic_model "claude-3-5-sonnet-20241022"

  defp req() do
    api_key = System.get_env("ANTHROPIC_API_KEY") || raise "Env var ANTHROPIC_API_KEY must be set."

    Req.new(
      base_url: "https://api.anthropic.com",
      headers: [
        "x-api-key": api_key,
        "anthropic-version": @anthropic_version
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
      model: @anthropic_model,
      max_tokens: 1024,
      system: system_prompt,
      messages: [
        %{role: "user", content: message}
      ],
      temperature: 0.7
    }

    %{body: res_json} =
      req()
      |> Req.post!(url: "/v1/messages", json: req_json)

    %{"content" => [%{"text" => content}]} = res_json
    content
  end
end
