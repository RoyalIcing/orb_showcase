defmodule OrbShowcase.GoldenOrb.Combobox do
  alias SilverOrb.StringBuilder

  # See: https://www.w3.org/WAI/ARIA/apg/patterns/menu-button/examples/menu-button-actions-active-descendant/

  use Orb
  use SilverOrb.StringBuilder
  require SilverOrb.Arena

  defmacro __using__(_opts) do
    quote do
      Orb.include(unquote(__MODULE__))
    end
  end

  # Currently used by StringBuilder
  # TODO: Make StringBuilder use the last page.
  SilverOrb.Arena.def(Output, pages: 1)

  defwp trim_trailing_nul_bytes(start: I32.UnsafePointer, max_length: I32), I32, i: I32 do
    loop EachChar do
      if Memory.load!(I32.U8, start + i) === 0 do
        return(i)
      end

      i = i + 1

      EachChar.continue(if: i < max_length)
    end

    max_length
  end

  SilverOrb.Arena.def(Input, pages: 1)

  defw input_range(), Str do
    {
      Input.Values.start_page_offset() * Orb.Memory.page_byte_size(),
      (Input.Values.end_page_offset() - Input.Values.start_page_offset()) *
        Orb.Memory.page_byte_size()
    }
  end

  defwp input_used_range(), Str, ptr: I32.UnsafePointer, max_length: I32 do
    ptr = Input.Values.start_page_offset() * Orb.Memory.page_byte_size()

    max_length =
      (Input.Values.end_page_offset() - Input.Values.start_page_offset()) *
        Orb.Memory.page_byte_size()

    {
      ptr,
      trim_trailing_nul_bytes(ptr, max_length)
    }
  end

  defwp ascii_to_lower(char: I32.U8), I32.U8 do
    if char >= ?A &&& char <= ?Z do
      char + 32
    else
      char
    end
  end

  defmodule FocusEnum do
    def none(), do: 0
    def menu(), do: 1
    def input(), do: 2
  end

  global do
    @open? 0
    @active_item_index 0
    @focus_enum FocusEnum.none()
    # Incremented when the focus has changed
    @focus_clock 0
    # Incremented when the HTML has changed
    @text_html_clock 0
  end

  global :export_mutable do
    @id_suffix 1
    @item_count 3
  end

  defw open?(), I32 do
    @open?
  end

  defw open() do
    if @item_count > 0 do
      @open? = 1
      @focus_enum = FocusEnum.input()
    end
  end

  defw close() do
    @open? = 0
    @active_item_index = 0
    @focus_enum = FocusEnum.input()
  end

  defw toggle() do
    if open?() do
      close()
    else
      open()
    end
  end

  defw focus_item(index: I32), item_count: I32 do
    item_count = Orb.Instruction.Global.Get.new(I32, :item_count)

    @active_item_index =
      if index > item_count do
        i32(1)
      else
        if index <= 0 do
          item_count
        else
          index
        end
      end

    @open? = 1
    @focus_enum = FocusEnum.input()
  end

  defw focus_previous_item() do
    focus_item(@active_item_index - 1)
  end

  defw focus_next_item() do
    focus_item(@active_item_index + 1)
  end

  defw input_id(), StringBuilder do
    build! do
      "input:"
      append!(decimal_u32: @id_suffix)
    end
  end

  defw button_id(), StringBuilder do
    build! do
      "menubutton:"
      append!(decimal_u32: @id_suffix)
    end
  end

  defw listbox_id(), StringBuilder do
    build! do
      "menu:"
      append!(decimal_u32: @id_suffix)
    end
  end

  defw option_id(index: I32), StringBuilder do
    build! do
      "menuitem:"
      append!(decimal_u32: @id_suffix)
      "."
      append!(decimal_u32: index)
    end
  end

  defwp label(), StringBuilder do
    build! do
      ~S|<label for="|
      input_id()
      ~S|">|

      "State"

      ~S|</label>|
    end
  end

  defwp input(), StringBuilder do
    build! do
      ~S|<input type="text" role="combobox" aria-autocomplete="list" id="|
      input_id()
      ~S|" aria-expanded="|

      if open?(), do: "true", else: "false"

      ~S|" aria-controls="|
      listbox_id()

      ~S|" value="|
      input_used_range()

      ~S|" data-action="open" data-input-write="input_range" data-keydown-arrow-down="focus_next_item" data-keydown-arrow-up="focus_previous_item">|
    end
  end

  defwp button(), StringBuilder do
    build! do
      ~S|<button type="button" id="|
      button_id()
      ~S|" tabindex="-1" aria-label="Open" aria-haspopup="true" aria-expanded="|

      if open?(), do: "true", else: "false"

      ~S|" aria-controls="|
      listbox_id()

      ~S|" data-action="toggle">|

      ~S|<hero-icon class="hero-chevron-down-solid size-4"></hero-icon>|

      ~S|</button>|
    end
  end

  defwp listbox_start(), StringBuilder do
    build! do
      ~S|<ul role="listbox" id="|
      listbox_id()
      ~S|" tabindex="-1" aria-labelledby="|
      button_id()
      ~S|" aria-activedescendant="|

      if @active_item_index > 0 do
        option_id(@active_item_index)
      end

      ~S|" data-keydown-escape="close" data-keydown-arrow-up="focus_previous_item" data-keydown-arrow-down="focus_next_item"|

      if open?() === 0 do
        " hidden"
      end

      ~S|>|
      "\n"
    end
  end

  defwp listbox_end(), StringBuilder do
    build! do
      ~S|</ul>|
      "\n"
    end
  end

  # defwp listbox(), StringBuilder do
  #   build! do
  #     ~S|<ul role="listbox" id="|
  #     listbox_id()
  #     ~S|" tabindex="-1" aria-labelledby="|
  #     button_id()
  #     ~S|" aria-activedescendant="|

  #     if @active_item_index > 0 do
  #       option_id(@active_item_index)
  #     end

  #     ~S|" data-keydown-escape="close" data-keydown-arrow-up="focus_previous_item" data-keydown-arrow-down="focus_next_item"|

  #     if open?() === 0 do
  #       " hidden"
  #     end

  #     ~S|>|
  #     "\n"

  #     state_options()

  #     ~S|</ul>|
  #     "\n"
  #   end
  # end

  defwp option_start(index: I32), StringBuilder do
    build! do
      ~S|<li role="option" id="|
      option_id(index)
      ~S|" aria-selected="|
      if index === @active_item_index, do: "true", else: "false"
      ~S|" data-action="select_item:[|
      append!(decimal_u32: index)
      ~S|]">|
    end
  end

  defwp option_end(index: I32), StringBuilder do
    build! do
      ~S|</li>|
      "\n"
    end
  end

  # defwp state_options(), StringBuilder, index: I32 do
  #   index = 1

  #   build! do
  #     loop EachState, result: StringBuilder do
  #       state_option(index)

  #       index = index + 1

  #       if index <= DataSource.states_data().count do
  #         EachState.continue()
  #       end
  #     end
  #   end
  # end

  # defwp state_options(), StringBuilder do
  #   StringBuilder.build_begin!()

  #   inline for {[state, abbreviation], index} <- Enum.with_index(DataSource.states_data().rows) do
  #     wasm do
  #       ~S|<li role="option" id="|
  #       option_id(index)
  #       ~S|" tabindex="-1" data-action="select_item:[|
  #       append!(decimal_u32: index)
  #       ~S|]">|
  #       state
  #       " "
  #       abbreviation
  #       ~S|</li>|
  #       "\n"
  #     end
  #     |> then(fn instructions ->
  #       %{instructions | body: instructions.body |> Enum.map(&StringBuilder.build_item/1) }
  #     end)
  #   end
  #   |> Orb.InstructionSequence.new()

  #   StringBuilder.build_done!()
  # end

  # @export "text/html"
  # defw text_html(), StringBuilder do
  #   build! do
  #     "<lipid-combobox>\n"
  #     "<golden-orb>\n"
  #     ~s|<source type="application/wasm" src="/combobox.wasm">\n|
  #     label()
  #     input()
  #     button()
  #     listbox()
  #     "</golden-orb>\n"
  #     "</lipid-combobox>\n"
  #   end
  # end

  defw focus_id(), StringBuilder do
    build! do
      if @active_item_index > 0 do
        input_id()
        # option_id(@active_item_index)
        ""
      else
        if @focus_enum === 1 do
          listbox_id()
        else
          if @focus_enum === 2 do
            input_id()
          else
            ""
          end
        end
      end
    end
  end
end
