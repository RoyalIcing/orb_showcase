defmodule OrbShowcase.Widgets.Tabs do
  # https://claude.ai/chat/3ab2c042-8732-4e3d-a5b1-f9a1876e2a73
  use Orb
  use SilverOrb.StringBuilder

  global do
    @active_tab_index 1
  end

  global :export_mutable do
    @id_suffix 1
  end

  defw tab_list_id(), StringBuilder do
    build! do
      "tab-list:"
      append!(decimal_u32: @id_suffix)
    end
  end

  defw tab_id(index: I32), StringBuilder do
    build! do
      "tab:"
      append!(decimal_u32: @id_suffix)
      "."
      append!(decimal_u32: index)
    end
  end

  defw tab_panel_id(index: I32), StringBuilder do
    build! do
      "tab-panel:"
      append!(decimal_u32: @id_suffix)
      "."
      append!(decimal_u32: index)
    end
  end

  defw activate_tab(index: I32) do
    if index >= 1 &&& index <= 3 do
      @active_tab_index = index
    end
  end

  defw focus_previous_tab() do
    activate_tab(
      if @active_tab_index === 1 do
        i32(3)
      else
        @active_tab_index - 1
      end
    )
  end

  defw focus_next_tab() do
    activate_tab(
      if @active_tab_index === 3 do
        i32(1)
      else
        @active_tab_index + 1
      end
    )
  end

  defwp tab_item(index: I32), StringBuilder do
    build! do
      ~S|<li role="presentation">|
      ~S|<button role="tab" id="|
      tab_id(index)
      ~S|" aria-selected="|

      if @active_tab_index === index do
        "true"
      else
        "false"
      end

      ~S|" aria-controls="|
      tab_panel_id(index)
      ~S|" tabindex="|

      if @active_tab_index === index do
        "0"
      else
        "-1"
      end

      ~S|" data-action="activate_tab:[|
      append!(decimal_u32: index)

      ~S|]" data-keydown-arrow-left="focus_previous_tab" data-keydown-arrow-right="focus_next_tab">|

      if index === i32(1) do
        "Profile"
      end

      if index === i32(2) do
        "Billing"
      end

      if index === i32(3) do
        "Invite"
      end

      ~S|</button>|
      ~S|</li>|
      "\n"
    end
  end

  defwp tab_panel(index: I32), StringBuilder do
    build! do
      ~S|<div role="tabpanel" id="|
      tab_panel_id(index)
      ~S|" aria-labelledby="|
      tab_id(index)
      ~S|" tabindex="0"|

      if @active_tab_index !== index do
        ~S| hidden|
      end

      ~S|>|

      if index === i32(1) do
        "Profile settings content goes here."
      end

      if index === i32(2) do
        "Billing information content goes here."
      end

      if index === i32(3) do
        "Invite friends content goes here."
      end

      ~S|</div>|
      "\n"
    end
  end

  defw text_html(), StringBuilder do
    build! do
      "<lipid-tabs>\n"
      "<golden-orb>\n"
      ~s|<source type="application/wasm" src="/tabs.wasm">\n|
      ~S|<div class="tabs">|
      "\n"
      ~S|<ul role="tablist" id="|
      tab_list_id()
      ~S|" aria-label="Account Settings">|
      "\n"
      tab_item(i32(1))
      tab_item(i32(2))
      tab_item(i32(3))
      ~S|</ul>|
      "\n"
      tab_panel(i32(1))
      tab_panel(i32(2))
      tab_panel(i32(3))
      ~S|</div>|
      "\n"
      "</golden-orb>\n"
      "</lipid-tabs>\n"
    end
  end

  defw focus_id(), Str do
    ""
  end
end
