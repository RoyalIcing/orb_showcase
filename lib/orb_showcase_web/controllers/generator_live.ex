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

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <form phx-submit="submit" class="space-y-8">
      <.input id="prompt_textbox" type="textarea" label="Prompt" name="prompt" value="" rows={10} />
      <.button type="submit">Generate</.button>
      <output for="prompt_textbox" class="flex">
        <pre class="whitespace-pre-wrap"><%= @output %></pre>
      </output>
    </form>

    <WasmHTML.html wasm={sample_wasm()} />
    """
  end

  @impl Phoenix.LiveView
  def handle_event("submit", form_data, socket) do
    %{"prompt" => user_prompt} = form_data

    example = do_read_menu_example()

    system_prompt = """
    You are generator of WebAssembly, using a DSL for Elixir called Orb.

    Here is an example Orb module that renders interactive HTML for a menu button that is ARIA compliant.
    #{example}

    Please generate a new Orb module that renders ARIA-compliant interactive HTML for the stated problem.
    """

    result = OpenAI.complete(user_prompt, system_prompt)

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

      defmodule FocusEnum do
        def none(), do: 0
        def menu(), do: 1
        def item(), do: 2
      end

      global do
        @active_item_index 0
        @focus_enum FocusEnum.none()
        @item_count 3
      end

      global :export_mutable do
        @id_suffix 1
      end

      defw open?(), I32 do
        @active_item_index > 0
      end

      defw focus_item(index: I32) do
        @active_item_index =
          if index > @item_count do
            i32(1)
          else
            if index <= 0 do
              @item_count
            else
              index
            end
          end

        @focus_enum = FocusEnum.item()
      end

      defw focus_previous_item() do
        focus_item(@active_item_index - 1)
      end

      defw focus_next_item() do
        focus_item(@active_item_index + 1)
      end

      defw nav_id(), StringBuilder do
        build! do
          "header-nav:"
          append!(decimal_u32: @id_suffix)
        end
      end

      defw nav_item_id(index: I32), StringBuilder do
        build! do
          "navitem:"
          append!(decimal_u32: @id_suffix)
          "."
          append!(decimal_u32: index)
        end
      end

      defwp navigation_menu(), StringBuilder, i: I32 do
        build! do
          ~S|<nav role="navigation" id="|
          nav_id()
          ~S|" aria-label="Main Navigation" tabindex="0" data-keydown-arrow-left="focus_previous_item" data-keydown-arrow-right="focus_next_item">|
          "\n"

          loop EachItem, result: StringBuilder do
            nav_item(i)

            i = i + 1

            if i <= @item_count do
              EachItem.continue()
            end
          end

          ~S|</nav>|
          "\n"
        end
      end

      defwp nav_item(i: I32), StringBuilder do
        build! do
          ~S|<a href="#item-|
          append!(decimal_u32: i)
          ~S|" id="|
          nav_item_id(i)
          ~S|" tabindex="-1" role="menuitem" data-action="select_item:[|
          append!(decimal_u32: i)
          ~S|]" data-pointerover="focus_item:[|
          append!(decimal_u32: i)
          ~S|]">|
          ~S|Navigation Item |
          append!(decimal_u32: i)
          ~S|</a>|
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

      defw focus_id(), StringBuilder do
        build! do
          if @active_item_index > 0 do
            nav_item_id(@active_item_index)
          else
            ""
          end
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
end
