defmodule OrbShowcase.Widgets.Accordion.HotDogStand do
  use Orb
  use SilverOrb.StringBuilder

  global do
	@active_section 0
  end

  global :export_mutable do
	@id_suffix 1
  end

  defw accordion_id(), StringBuilder do
	build! do
	  "accordion:"
	  append!(decimal_u32: @id_suffix)
	end
  end

  defw header_id(index: I32), StringBuilder do
	build! do
	  "header:"
	  append!(decimal_u32: @id_suffix)
	  "."
	  append!(decimal_u32: index)
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

  defwp accordion_section(index: I32, title: I32), StringBuilder do
	build! do
	  ~S|<h3>|
	  ~S|<button aria-expanded="|
	  if @active_section === index do
		"true"
	  else
		"false"
	  end
	  ~S|" class="accordion-trigger" aria-controls="|
	  section_id(index)
	  ~S|" id="|
	  header_id(index)
	  ~S|" data-action="toggle_section:[|
	  append!(decimal_u32: index)
	  ~S|]">|
	  if title === i32(1) do
		"Spring"
	  end
	  if title === i32(2) do
		"Summer"
	  end
	  if title === i32(3) do
		"Fall"
	  end
	  if title === i32(4) do
		"Winter"
	  end
	  ~S|</button>|
	  ~S|</h3>|
	  ~S|<div id="|
	  section_id(index)
	  ~S|" role="region" aria-labelledby="|
	  header_id(index)
	  ~S|"|
	  if @active_section !== index do
		" hidden"
	  end
	  ~S|>|
	  if title === i32(1) do
		"Flowers bloom and birds return."
	  end
	  if title === i32(2) do
		"Warm days and outdoor activities."
	  end
	  if title === i32(3) do
		"Leaves change color and fall from trees."
	  end
	  if title === i32(4) do
		"Snow falls and temperatures drop."
	  end
	  ~S|</div>|
	  "\n"
	end
  end

  defwp debug_state(), StringBuilder do
	build! do
	  ~S|<pre aria-hidden="true">Active Section: |
	  append!(decimal_u32: @active_section)
	  ~S|</pre>|
	  "\n"
	end
  end

  defw text_css(), StringBuilder do
	build! do
	  ~S|<style>|
	  "lipid-accordion {"
	  "  display: block;"
	  "  background: yellow;"
	  "  color: black;"
	  "  padding: 1rem;"
	  "}"
	  ".accordion-trigger {"
	  "  width: 100%;"
	  "  background: red;"
	  "  color: white;"
	  "  padding: 0.5rem;"
	  "  border: 3px solid black;"
	  "  margin: 0.25rem 0;"
	  "}"
	  ".accordion-trigger[aria-expanded='true'] {"
	  "  background: white;"
	  "  color: red;"
	  "}"
	  "pre {"
	  "  background: black;"
	  "  color: yellow;"
	  "  padding: 0.5rem;"
	  "  margin-top: 1rem;"
	  "}"
	  ~S|</style>|
	  "\n"
	end
  end

  defw text_html(), StringBuilder do
	build! do
	  "<lipid-accordion>\n"
	  "<golden-orb>\n"
	  ~s|<source type="application/wasm" src="/accordion-hot-dog-stand.wasm">\n|
	  text_css()
	  ~S|<div class="accordion" role="presentation">|
	  "\n"
	  accordion_section(i32(1), i32(1))
	  accordion_section(i32(2), i32(2))
	  accordion_section(i32(3), i32(3))
	  accordion_section(i32(4), i32(4))
	  ~S|</div>|
	  "\n"
	  debug_state()
	  "</golden-orb>\n"
	  "</lipid-accordion>\n"
	end
  end

  defw focus_id(), Str do
	""
  end
end