defmodule OrbShowcase.Widgets.USAStatesCombobox do
  alias SilverOrb.StringBuilder

  # See: https://www.w3.org/WAI/ARIA/apg/patterns/menu-button/examples/menu-button-actions-active-descendant/

  use Orb
  use SilverOrb.StringBuilder
  require SilverOrb.Arena

  use OrbShowcase.GoldenOrb.Combobox

  defmodule DataSource do
    defstruct count: 0, rows: [], stride: 0

    @usa_states_url "https://raw.githubusercontent.com/jasonong/List-of-US-States/master/states.csv"
    # @world_states_url "https://raw.githubusercontent.com/dr5hn/countries-states-cities-database/master/csv/states.csv"

    def usa_states_url(), do: @usa_states_url

    NimbleCSV.define(StatesCSV2, [])

    defp do_states_data() do
      {:ok, _} = Application.ensure_all_started(:req)

      data = Req.get!(@usa_states_url).body

      rows = StatesCSV2.parse_string(data)

      stride =
        for [state, _abbreviation] <- rows, reduce: 0 do
          max_so_far -> max(max_so_far, byte_size(state))
        end

      %__MODULE__{
        count: length(rows),
        rows: rows,
        stride: stride
      }
      |> dbg()
    end

    def states_data() do
      key = {__MODULE__, :states_csv}
      data = Process.get(key)

      if data do
        data
      else
        data = do_states_data()
        Process.put(key, data)
        data
      end
    end
  end

  # Currently used by StringBuilder
  # TODO: Change all uses of StringBuilder to Output.Str and Output.build!
  SilverOrb.Arena.def(Output, pages: 1)

  SilverOrb.Arena.def(States, pages: 1)

  # SilverOrb.defarena States do
  #   defmodule Lookup do
  #     def state_address_at_index(index) do
  #       states_data = DataSource.states_data()

  #       States.Values.start_byte_offset() + index * states_data.stride
  #     end
  #   end

  #   with states_data = DataSource.states_data() do
  #     for {[state, abbreviation], index} <- Enum.with_index(states_data.rows) do
  #       Memory.initial_data!(States.Values.start_byte_offset() + index * states_data.stride, state)
  #       # Memory.initial_data!(States.Lookup.state_address_at_index(index), state)
  #     end
  #   end
  # end

  defmodule States.Lookup do
    def state_address_at_index(index) do
      states_data = DataSource.states_data()

      States.Values.start_byte_offset() + index * states_data.stride
    end
  end

  with states_data = DataSource.states_data() do
    for {[state, abbreviation], index} <- Enum.with_index(states_data.rows) do
      Memory.initial_data!(States.Values.start_byte_offset() + index * states_data.stride, state)
      # Memory.initial_data!(States.Lookup.state_address_at_index(index), state)
    end
  end

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

  defwp state_at_index(index: I32), Str, start: I32.UnsafePointer do
    start = States.Values.start_byte_offset() + (index - 1) * DataSource.states_data().stride
    {start, trim_trailing_nul_bytes(start, DataSource.states_data().stride)}
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

  defwp state_at_index_matches_input?(index: I32), I32,
    state_ptr: I32.UnsafePointer,
    state_len: I32,
    input_ptr: I32.UnsafePointer,
    input_len: I32 do
    state_ptr = States.Values.start_byte_offset() + (index - 1) * DataSource.states_data().stride
    state_len = trim_trailing_nul_bytes(state_ptr, DataSource.states_data().stride)

    input_ptr = Input.Values.start_page_offset() * Orb.Memory.page_byte_size()

    input_len =
      trim_trailing_nul_bytes(
        input_ptr,
        (Input.Values.end_page_offset() - Input.Values.start_page_offset()) *
          Orb.Memory.page_byte_size()
      )

    if input_len === 0 do
      return(1)
    end

    if input_len > state_len or state_len === 0 do
      return(0)
    end

    loop EachChar do
      if ascii_to_lower(Memory.load!(I32.U8, state_ptr)) !==
           ascii_to_lower(Memory.load!(I32.U8, input_ptr)) do
        return(0)
      end

      state_ptr = state_ptr + 1
      input_ptr = input_ptr + 1
      input_len = input_len - 1

      EachChar.continue(if: input_len > 0)
    end

    1
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
    @item_count DataSource.states_data().count
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
    # TODO: Output.build! do
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

  defwp listbox(), StringBuilder, i: I32 do
    i = 1

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

      state_options()

      ~S|</ul>|
      "\n"
    end
  end

  defwp state_option(index: I32), StringBuilder do
    build! do
      if state_at_index_matches_input?(index) do
        ~S|<li role="option" id="|
        option_id(index)
        ~S|" aria-selected="|
        if index === @active_item_index, do: "true", else: "false"
        ~S|" data-action="select_item:[|
        append!(decimal_u32: index)
        ~S|]">|
        state_at_index(index)
        ~S|</li>|
        "\n"
      end
    end
  end

  defwp state_options(), StringBuilder, index: I32 do
    index = 1

    build! do
      loop EachState, result: StringBuilder do
        state_option(index)

        index = index + 1

        if index <= DataSource.states_data().count do
          EachState.continue()
        end
      end

      # TODO: need to surface locals from here to above.
      # loop index <- 1..DataSource.states_data().count do
      #   ~S|<li role="option" id="|
      #   option_id(index)
      #   ~S|" tabindex="-1" data-action="select_item:[|
      #   append!(decimal_u32: index)
      #   ~S|]">|
      #   state_at_index(index)
      #   ~S|</li>|
      #   "\n"
      # end
    end
  end

  # @export "text/html"
  defw text_html(), StringBuilder do
    build! do
      "<lipid-combobox>\n"
      "<golden-orb>\n"
      ~s|<source type="application/wasm" src="/usa_states_combobox.wasm">\n|
      label()
      input()
      button()
      listbox()
      "</golden-orb>\n"
      "</lipid-combobox>\n"
    end
  end
end
