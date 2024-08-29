defmodule OrbShowcase.Widgets.Accordion do
  # Generated with AI: https://claude.ai/chat/2b6fb84f-4386-4326-90c0-9ec6ae3ef2fa

  use Orb
  use SilverOrb.StringBuilder

  global do
    @active_section 0
  end

  global :export_mutable do
    @id_suffix 1
    @section_count 3
  end

  defw accordion_id(), StringBuilder do
    build! do
      "accordion:"
      append!(decimal_u32: @id_suffix)
    end
  end

  defw section_id(index: I32), StringBuilder do
    build! do
      "section:"
      append!(decimal_u32: @id_suffix)
      "."
      append!(decimal_u32: index)
    end
  end

  defw toggle_section(index: I32) do
    if @active_section === index do
      @active_section = 0
    else
      @active_section = index
    end
  end

  defwp accordion_header(index: I32, title: StringBuilder), StringBuilder do
    build! do
      ~S|<h3>|
      ~S|<button id="|
      section_id(index)
      ~S|" aria-expanded="|

      if @active_section === index do
        "true"
      else
        "false"
      end

      ~S|" aria-controls="|
      section_id(index)
      ~S|-content" data-action="toggle_section:[|
      append!(decimal_u32: index)
      ~S|]">|
      title
      ~S|</button>|
      ~S|</h3>|
      "\n"
    end
  end

  defwp accordion_content(index: I32, content: StringBuilder), StringBuilder do
    build! do
      ~S|<div id="|
      section_id(index)
      ~S|-content" role="region" aria-labelledby="|
      section_id(index)
      ~S|"|

      if @active_section !== index do
        " hidden"
      end

      ~S|>|
      content
      ~S|</div>|
      "\n"
    end
  end

  defwp accordion_section(index: I32), StringBuilder do
    build! do
      accordion_header(index, section_title(index))
      accordion_content(index, section_content(index))
    end
  end

  defwp section_title(index: I32), StringBuilder do
    if index === 1 do
      "Section 1"
    else
      if index === 2 do
        "Section 2"
      else
        if index === 3 do
          "Section 3"
        else
          "Unknown Section"
        end
      end
    end
  end

  defwp section_content(index: I32), StringBuilder do
    if index === 1 do
      "Content for Section 1"
    else
      if index === 2 do
        "Content for Section 2"
      else
        if index === 3 do
          "Content for Section 3"
        else
          "Unknown Content"
        end
      end
    end
  end

  defw text_html(), StringBuilder do
    build! do
      "<lipid-accordion>\n"
      "<golden-orb>\n"
      ~s|<source type="application/wasm" src="/accordion.wasm">\n|
      ~S|<div class="accordion" id="|
      accordion_id()
      ~S|">|
      "\n"
      accordion_section(1)
      accordion_section(2)
      accordion_section(3)
      ~S|</div>|
      "\n"
      "</golden-orb>\n"
      "</lipid-accordion>\n"
    end
  end

  defw text_css(), StringBuilder do
    build! do
      ~S"""
      .accordion {
        border: 1px solid #ccc;
        border-radius: 4px;
      }
      .accordion h3 {
        margin: 0;
        padding: 10px;
        background-color: #f0f0f0;
      }
      .accordion button {
        width: 100%;
        text-align: left;
        padding: 10px;
        border: none;
        background: none;
        cursor: pointer;
      }
      .accordion [role="region"] {
        padding: 10px;
      }
      """
    end
  end
end
