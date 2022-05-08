defmodule Snownix.Helpers.Model do
  @date_formats ["%Y-%m-%d", "%Y-%d-%m", "%m-%d-%Y", "%Y/%m/%d", "%Y/%d/%m", "%m/%d/%Y"]
  @fiscal_years [
    %{title: "January-February", id: "1-2"},
    %{title: "February-March", id: "2-3"},
    %{title: "March-April", id: "3-4"},
    %{title: "April-May", id: "4-5"},
    %{title: "May-June", id: "5-6"},
    %{title: "June-July", id: "6-7"},
    %{title: "July-August", id: "7-8"},
    %{title: "August-September", id: "8-9"},
    %{title: "September-October", id: "9-10"},
    %{title: "October-November", id: "10-11"},
    %{title: "November-December", id: "11-12"},
    %{title: "December-January", id: "12-1"}
  ]

  @boolean [true, false]

  def booleans(), do: @boolean

  def fiscal_years(), do: @fiscal_years
  def date_formats(), do: @date_formats

  def countries(), do: Snownix.Geo.countries_list()

  def currencies(), do: Money.Currency.all() |> Enum.map(fn {name, _} -> Atom.to_string(name) end)

  def timezones(), do: TzExtra.time_zone_identifiers()
end
