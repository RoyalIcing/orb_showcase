defmodule OrbShowcaseWeb.GeneratorLive do
  use OrbShowcaseWeb, :live_view

  alias OrbShowcase.LLM.OpenAI
  alias OrbShowcase.LLM.Anthropic

  alias OrbShowcaseWeb.Wasm.HTML, as: WasmHTML

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:output_async, nil)

    {:ok, socket}
  end

  defp default_prompt() do
    style_hot_dog_stand = "Include a style tag to style controls like Windows hot dog stand."
    style_aqua = "Include a style tag to style controls like Mac OS X Panther."
    
    """
    An accordion menu with 3 items: apple, banana, pear. Include a pre with the current state of globals. #{style_aqua}
    """
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <form phx-submit="submit" class="space-y-8">
      <.input
        id="prompt_textbox"
        type="textarea"
        label="Prompt"
        name="prompt"
        value={default_prompt()}
        rows={3}
      />
      <.button type="submit">Generate</.button>
      <.async_result :let={output} :if={@output_async} assign={@output_async}>
        <:loading>Generating...</:loading>
        <:failed :let={failure}>We couldn’t generate your module. {inspect(failure)}</:failed>
        <%= if output do %>
          <details>
            <summary>Source</summary>
            <pre class="whitespace-pre-wrap"><%= output %></pre>
          </details>
        <% end %>
      </.async_result>
    </form>

    <pre hidden class="whitespace-pre-wrap"><%= make_system_prompt() %></pre>

    <hr class="my-8" />

    <div :if={false}>
      <WasmHTML.html wasm={orb_source_to_wasm(OrbShowcase.Widgets.Source.menu_button() |> String.replace("OrbShowcase.Widgets.MenuButton", "OrbShowcase.Widgets.Generated"))} />
      <WasmHTML.html wasm={sample_wasm()} />
    </div>

    <.output_wasm_html :if={output_async = @output_async} result={output_async.result} />
    """
  end

  defp make_system_prompt() do
    navigation_example = sample_source()

    """
    You are generator of WebAssembly, using a DSL for Elixir called Orb.

  Note that Orb syntax is a DSL, not full Elixir. There is no `cond` or `case` (only `if`), no `while`. Variables must be declared with their type after the function argument definition, e.g. see `menu_list` declaring variable `i` of type `I32` by writing `i: I32`. Orb has only `===` not `==`. Prefer to hard-code items instead of using loops. There is no `put_elem`. Functions are define using a key-value syntax but they are passed just as values. `String` or `StringBuilder` cannot be passed as a value or function argument. Instead of making functions with dynamic strings, define separate functions multiple times for say each item. And I repeat there is no `case`, use `if` instead. Params can only be single integers or floats, so you can’t pass (i32 i32) as a param, or `Str` or `StringBuilder`. That is, you cannot call a defw function passing in a string or the result of `build!`, instead pass identifying integers and conditionally render inside your function’s `build!` based on the integer, or have separate dedicated functions. You can’t concat strings/binaries with <>. There is no need to generate a `text_css` function unless styles are asked for. Scope styles to the top level element so things like pre aren’t styled globally.

    Here is an example Orb module that renders static HTML for a navigation that is ARIA compliant.

    #{navigation_example}

    Here is an example Orb module that renders interactive HTML for a menu button that is ARIA compliant.

    #{OrbShowcase.Widgets.Source.menu_button()}
    
    Here is an example Orb module that renders interactive HTML for tabs that is ARIA compliant.

    #{OrbShowcase.Widgets.Source.tabs()}

    Please generate a new Orb module that renders ARIA-compliant interactive HTML for the stated problem. Name the Elixir module OrbShowcase.Widgets.Generated
    
    Instead of the <source> linking to a path link to a hash: <source type="application/wasm" src="#wasmBase64">
    
    Only generate Elixir code, start with defmodule and have no other surrounding commentary.
    """
  end

  @impl Phoenix.LiveView
  def handle_event("submit", form_data, socket) do
    %{"prompt" => user_prompt} = form_data

    socket =
      socket
      |> assign_async(:output_async, fn ->
        result = anthropic(user_prompt)
        IO.puts(result)
        {:ok, %{output_async: result}}
      end, reset: true)

    {:noreply, socket}
  end

  defp ollama(user_prompt) do
    system_prompt = make_system_prompt()
    client = Ollama.init()
    
    {:ok, result} = Task.async_stream(0..1, fn _ ->
      {:ok, %{"response" => result}} = Ollama.completion(client, [
        # model: "llama3.2",
        model: "qwen2.5-coder:32b",
        prompt: system_prompt <> "\n\n" <> user_prompt
      ]) |> dbg()
      _ = prompt_result_to_wasm(result)
      result
    end, timeout: 60_000, on_timeout: :kill_task)
    |> Stream.reject(&match?({:exit, _}, &1))
    |> Enum.at(0)
    
    result
  end
  
  defp anthropic(user_prompt) do
    system_prompt = make_system_prompt()
    Anthropic.complete(user_prompt, system_prompt)
  end

  defp sample_source() do
    ~S"""
    defmodule OrbShowcase.Widgets.HeaderNavigation do
      use Orb
      use SilverOrb.StringBuilder

      global :export_mutable do
        @id_suffix 1
      end

      defw nav_id(), StringBuilder do
        build! do
          "header-nav:"
          append!(decimal_u32: @id_suffix)
        end
      end

      defwp navigation_menu(), StringBuilder do
        build! do
          ~S|<nav role="navigation" id="|
          nav_id()
          ~S|" aria-label="Main Navigation" tabindex="0" data-keydown-arrow-left="focus_previous_item" data-keydown-arrow-right="focus_next_item">|
          "\n"

          nav_item_open()
          "Features"
          nav_item_close()

          nav_item_open()
          "Pricing"
          nav_item_close()

          nav_item_open()
          "Sign In"
          nav_item_close()

          ~S|</nav>|
          "\n"
        end
      end

      defwp nav_item_open(), StringBuilder do
        build! do
          ~S|<li><a href="#todo">|
          "\n"
        end
      end

      defwp nav_item_close(), StringBuilder do
        build! do
          ~S|</a></li>|
          "\n"
        end
      end

      defw text_html(), StringBuilder do
        build! do
          "<lipid-header-navigation>\n"
          "<golden-orb>\n"
          ~s|<source type="application/wasm" src="/header_navigation.wasm">\n|
          navigation_menu()
          "</golden-orb>\n"
          "</lipid-header-navigation>\n"
        end
      end
    end
    """
  end

  defp sample_wat() do
    sample_source()
    |> Code.string_to_quoted()
    |> case do
      {:ok, quoted} ->
        Code.eval_quoted(quoted)
        mod = OrbShowcase.Widgets.HeaderNavigation
        Orb.to_wat(mod)

      {:error, {meta, message_info, token}} ->
        IO.inspect({meta, message_info, token})
        ""
    end
  end

  defp sample_wasm() do
    sample_wat()
    |> case do
      "" ->
        ""

      wat ->
        wat |> OrbShowcase.WasmRegistry.wat_to_wasm()
    end
  end

  defp prompt_result_to_wasm(nil), do: nil

  defp prompt_result_to_wasm("defmodule " <> _ = source) do
    orb_source_to_wasm(source)
  end
  
  defp prompt_result_to_wasm(result) do
    [_, "elixir\n" <> source, _] = String.split(result, "```")

    orb_source_to_wasm(source)
  end

  defp orb_source_to_wasm(source) when is_binary(source) do
    source
    |> dbg()
    |> Code.string_to_quoted()
    |> case do
      {:ok, quoted} ->
        Code.eval_quoted(quoted)
        mod = OrbShowcase.Widgets.Generated
        Orb.to_wat(mod)

      {:error, {meta, message_info, token}} ->
        IO.inspect({meta, message_info, token}, label: "Compile ERROR")
        ""
    end
    |> dbg()
    |> case do
      "" ->
        nil

      wat ->
        wat |> OrbShowcase.WasmRegistry.wat_to_wasm()
    end
  end

  defp output_wasm_html(assigns) do
    ~H"""
    <div :if={wasm = prompt_result_to_wasm(@result)} class="p-4 bg-white text-black">
      <script id="wasmBase64" type="application/wasm;base64"><%= Base.encode64(wasm) %></script>
      <WasmHTML.html wasm={wasm} />
    </div>
    """
  end
end
