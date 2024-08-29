defmodule OrbShowcaseWeb.GeneratorLive do
  use OrbShowcaseWeb, :live_view

  alias OrbShowcase.Generator.OpenAI

  alias OrbShowcaseWeb.Wasm.HTML, as: WasmHTML

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:output, nil)

    {:ok, socket}
  end

  defp default_prompt() do
    """
    An accordion menu with 3 items: apple, banana, pear.
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
      <output for="prompt_textbox" class="flex">
        <pre class="whitespace-pre-wrap"><%= @output %></pre>
      </output>
    </form>

    <pre class="whitespace-pre-wrap"><%= make_system_prompt() %></pre>

    <hr class="my-8" />

    <WasmHTML.html wasm={sample_wasm()} />

    <.output_wasm_html result={@output} />
    """
  end

  defp make_system_prompt() do
    menu_example = do_read_menu_example()
    navigation_example = sample_source()

    """
    You are generator of WebAssembly, using a DSL for Elixir called Orb.

    Note that Orb syntax is a DSL, not full Elixir. There is no `cond` or `case` (only `if`), no `while`. Variables must be declared with their type after the function argument definition, e.g. see `menu_list` declaring variable `i` of type `I32` by writing `i: I32`. Orb has only `===` not `==`. Prefer to hard-code items instead of using loops. There is no `put_elem`. Functions are define using a key-value syntax but they are passed just as values. `String` or `StringBuilder` cannot be passed as a value or function argument. Instead of making functions with dynamic strings, define separate functions multiple times for say each item. And I repeat there is no `case`, use `if` instead. Params can only be single integers or floats, so you can’t pass (i32 i32) as a param, or `Str` or `StringBuilder`. There is no need to generate a `text_css` function.

    Here is an example Orb module that renders static HTML for a navigation that is ARIA compliant.

    #{navigation_example}

    Here is an example Orb module that renders interactive HTML for a menu button that is ARIA compliant.

    #{menu_example}

    Please generate a new Orb module that renders ARIA-compliant interactive HTML for the stated problem. Name the Elixir module OrbShowcase.Widgets.Generated
    """
  end

  @impl Phoenix.LiveView
  def handle_event("submit", form_data, socket) do
    %{"prompt" => user_prompt} = form_data

    system_prompt = make_system_prompt()

    result = OpenAI.complete(user_prompt, system_prompt)

    # TODO: use assign_async

    socket =
      socket
      |> assign(:output, result)

    {:noreply, socket}
  end

  defp do_read_menu_example() do
    OrbShowcase.Widgets.Source.menu_button()
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
    <div :if={wasm = prompt_result_to_wasm(@result)}>
      <WasmHTML.html wasm={wasm} />
    </div>
    """
  end
end
