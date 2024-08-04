defmodule OrbShowcase.Widgets.MenuButton do
  # See: https://www.w3.org/WAI/ARIA/apg/patterns/menu-button/examples/menu-button-actions-active-descendant/

  use Orb
  use SilverOrb.StringBuilder

  defmodule FocusEnum do
    def none(), do: 0
    def menu(), do: 1
    def button(), do: 2
  end

  global do
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
    @active_item_index > 0
  end

  defw open() do
    if @item_count > 0 do
      @active_item_index = 1
      @focus_enum = FocusEnum.menu()
    end
  end

  defw close() do
    @active_item_index = 0
    @focus_enum = FocusEnum.button()
  end

  defw toggle() do
    if @active_item_index do
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

    @focus_enum = FocusEnum.menu()
  end

  defw focus_previous_item() do
    focus_item(@active_item_index - 1)
  end

  defw focus_next_item() do
    focus_item(@active_item_index + 1)
  end

  defw button_id(), StringBuilder do
    build! do
      "menubutton:"
      append!(decimal_u32: @id_suffix)
    end
  end

  defw menu_id(), StringBuilder do
    build! do
      "menu:"
      append!(decimal_u32: @id_suffix)
    end
  end

  defw menu_item_id(index: I32), StringBuilder do
    build! do
      "menuitem:"
      append!(decimal_u32: @id_suffix)
      "."
      append!(decimal_u32: index)
    end
  end

  defwp button(), StringBuilder do
    build! do
      ~S|<button type="button" id="|
      button_id()
      ~S|" aria-haspopup="true" aria-expanded="|

      if open?() do
        "true"
      else
        "false"
      end

      ~S|" aria-controls="|
      menu_id()

      ~S|" data-action="toggle" data-keydown-arrow-down data-keydown-arrow-up="focus_previous_item">|

      "Click me"

      ~S|</button>|
    end
  end

  defwp menu_list(), StringBuilder, i: I32 do
    i = 1

    build! do
      ~S|<ul role="menu" id="|
      menu_id()
      ~S|" tabindex="-1" aria-labelledby="|
      button_id()
      ~S|" aria-activedescendant="|

      if @active_item_index > 0 do
        menu_item_id(@active_item_index)
      end

      ~S|" data-keydown-escape="close" data-keydown-arrow-up="focus_previous_item" data-keydown-arrow-down="focus_next_item"|

      if @active_item_index === 0 do
        " hidden"
      end

      ~S|>|
      "\n"

      loop EachItem, result: StringBuilder do
        menu_item(i)

        i = i + 1

        if i <= @item_count do
          EachItem.continue()
        end

        # EachItem.continue() when i <= @item_count
        # continue(EachItem) when i <= @item_count
      end

      ~S|</ul>|
      "\n"
    end
  end

  defwp menu_item(i: I32), StringBuilder do
    build! do
      ~S|<li role="menuitem" id="|
      menu_item_id(i)
      ~S|" tabindex="-1" data-action="select_item:[|
      append!(decimal_u32: i)
      ~S|]" data-pointerover="focus_item:[|
      append!(decimal_u32: i)
      ~S|]">|
      ~S|Action |
      append!(decimal_u32: i)
      ~S|</li>|
      "\n"
    end
  end

  # @export "text/html"
  defw text_html(), StringBuilder do
    build! do
      "<lipid-menu-button>\n"
      "<golden-orb>\n"
      ~s|<source type="application/wasm" src="/menu.wasm">\n|
      button()
      menu_list()
      "</golden-orb>\n"
      "</lipid-menu-button>\n"
    end
  end

  defw text_css(), StringBuilder do
    build! do
      ~S"""
      lipid-menu-button button { background-color: var(--LipidMenuButton-background); }
      """
    end
  end

  defw focus_id(), StringBuilder do
    build! do
      if @active_item_index > 0 do
        menu_item_id(@active_item_index)
      else
        if @focus_enum === 1 do
          menu_id()
        else
          if @focus_enum === 2 do
            button_id()
          else
            ""
          end
        end
      end
    end
  end

  defw application_javascript(), StringBuilder do
    build! do
      ~S"""
      // data-keydown-arrow-down
      """
    end
  end
end
