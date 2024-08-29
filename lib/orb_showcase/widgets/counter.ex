defmodule OrbShowcase.Widgets.Counter do
  # https://claude.ai/chat/3b0729cb-258c-4837-bfb9-41a9b2b96c31
  use Orb
  use SilverOrb.StringBuilder

  global do
    @count 0
  end

  global :export_mutable do
    @id_suffix 1
  end

  defw increment() do
    @count = @count + 1
  end

  defw decrement() do
    @count = @count - 1
  end

  defw counter_id(), StringBuilder do
    build! do
      "counter:"
      append!(decimal_u32: @id_suffix)
    end
  end

  defwp render_button(label: I32, action: I32), StringBuilder do
    build! do
      ~S|<button type="button" data-action="|

      if action === 1 do
        "increment"
      else
        "decrement"
      end

      ~S|">|

      if label === 1 do
        "+"
      else
        "-"
      end

      ~S|</button>|
      "\n"
    end
  end

  defwp render_count(), StringBuilder do
    build! do
      ~S|<span id="|
      counter_id()
      ~S|" aria-live="polite">|
      append!(decimal_i32: @count)
      ~S|</span>|
      "\n"
    end
  end

  defw text_html(), StringBuilder do
    build! do
      "<lipid-counter>\n"
      "<golden-orb>\n"
      ~s|<source type="application/wasm" src="/counter.wasm">\n|
      ~S|<div class="counter-widget">|
      "\n"
      # Decrement button
      render_button(2, 2)
      render_count()
      # Increment button
      render_button(1, 1)
      ~S|</div>|
      "\n"
      "</golden-orb>\n"
      "</lipid-counter>\n"
    end
  end
end
