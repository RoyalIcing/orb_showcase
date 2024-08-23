defmodule OrbShowcase.Widgets.CalendarGrid do
  # See: https://react-spectrum.adobe.com/react-aria/Calendar.html

  use Orb
  use SilverOrb.StringBuilder
  require SilverOrb.Arena

  alias OrbShowcase.SilverOrb.Gregorian
  Orb.include(OrbShowcase.SilverOrb.Gregorian)

  # Currently used by StringBuilder
  # TODO: Make StringBuilder use the last page.
  SilverOrb.Arena.def(Output, pages: 1)

  SilverOrb.Arena.def(States, pages: 1)

  global do
    @open? 0
    # Incremented when the focus has changed
    @focus_clock 0
    # Incremented when the HTML has changed
    @text_html_clock 0
  end

  global :export_mutable do
    @id_suffix 1
    # @yyyy_mm_dd 2024_08_21
    @year 2024
    @month 08
    @day 21
  end

  defw table_id(), StringBuilder do
    build! do
      "calendar:table:"
      append!(decimal_u32: @id_suffix)
    end
  end

  defw previous_month() do
    @month = @month - 1

    if @month === 0 do
      @year = @year - 1
      @month = 12
    end
  end

  defw next_month() do
    @month = @month + 1

    if @month > 12 do
      @year = @year + 1
      @month = 1
    end
  end

  defwp weekday(day: I32), StringBuilder do
    build! do
      ~S|<td role="gridcell">|
      append!(decimal_u32: day)
      ~S|</td>|
    end
  end

  defwp table(), StringBuilder, week_offset: I32, week_index: I32, weekday_index: I32 do
    week_offset = Gregorian.day_of_week(@year, @month, 1)

    build! do
      ~S|<table id="|
      table_id()
      ~S|" role="grid">|

      ~S|<thead aria-hidden="true"'><tr><th>M</th><th>Tu</th><th>W</th><th>Th</th><th>F</th><th>Sa</th><th>Su</th></tr></thead>|
      ~S|<tbody>|

      ~S|<tr>|

      week_index = 1

      loop EachWeek, result: StringBuilder do
        # weekday(week_index)
        weekday_index = 1

        # const("<tr>")

        loop EachWeekday, result: StringBuilder do
          # build! do
          if weekday_index === 1 do
            const("<tr>")
          end

          weekday(weekday_index)

          if weekday_index === 7 do
            const("</tr>")
          end

          # end

          weekday_index = weekday_index + 1

          if weekday_index <= 7 do
            EachWeekday.continue()
          end
        end

        week_index = week_index + 1

        if week_index <= 5 do
          EachWeek.continue()
        end
      end

      weekday_index = 1

      # loop EachWeekday, result: StringBuilder do
      #   weekday(weekday_index)

      #   weekday_index = weekday_index + 1

      #   if weekday_index <= 7 do
      #     EachWeekday.continue()
      #   end
      # end

      # loop weekday_index <- 1..7 do
      # end

      ~S|</tr>|

      ~S|</tbody>|
      ~S|</table>|
    end
  end

  defwp previous_month_button(), StringBuilder do
    build! do
      ~S|<button data-action="previous_month">Previous month</button>|
    end
  end

  defwp next_month_button(), StringBuilder do
    build! do
      ~S|<button data-action="next_month">Next month</button>|
    end
  end

  defw text_html(), StringBuilder do
    build! do
      "<lipid-calendar-grid>\n"
      "<golden-orb>\n"
      ~s|<source type="application/wasm" src="/calendar-grid.wasm">\n|
      ~S|<div>|
      append!(decimal_u32: @year)
      " "
      append!(decimal_u32: @month)
      ~S|</div>|
      ~S|<div>|
      previous_month_button()
      next_month_button()
      ~S|</div>|
      table()
      "</golden-orb>\n"
      "</lipid-calendar-grid>\n"
    end
  end
end
