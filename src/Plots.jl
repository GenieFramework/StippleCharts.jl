module Plots

using Revise
import DataFrames
import Genie, Stipple
import Genie.Renderer.Html: HTMLString, normal_element

using Stipple

export PlotOptions, PlotData, PlotSeries, plot

Genie.Renderer.Html.register_normal_element("apexchart", context = @__MODULE__)

Base.@kwdef mutable struct PlotOptions
  chart_animations_enabled::Bool = false
  chart_animations_easing::Symbol = :easeinout
  chart_animations_speed::Int = 800
  chart_background::String = "#fff"
  chart_font_family::String = "Helvetica, Arial, sans-serif"
  chart_fore_color::String = "#373d3f"
  chart_height::Union{Int,String} = "auto"
  chart_offset_x::Int = 0
  chart_offset_y::Int = 0
  chart_selection_enabled::Bool = true
  chart_selection_type::Symbol = :xy
  chart_sparkline_enabled::Bool = false
  chart_stacked::Bool = false
  chart_stack_type::String = "normal"
  chart_toolbar_show::Bool = false
  chart_type::Symbol = :line
  chart_width::Union{Int,String} = "100%"
  chart_zoom_enabled::Bool = true
  chart_zoom_type::Symbol = :xy
  colors::Vector{String} = ["#2E93fA", "#66DA26", "#546E7A", "#E91E63", "#FF9800"]
  data_labels_enabled::Bool = false
  fill_opacity::Float64 = 1.0
  grid_show::Bool = true
  labels::Vector{String} = String[]
  legend_show::Bool = true
  legend_position::Symbol = :bottom
  legend_font_size::String = "14px"
  legend_font_family::String = "Helvetica, Arial"
  no_data_text::String = ""
  plot_options_bar_horizontal::Bool = false
  plot_options_bar_ending_shape::Symbol = :flat
  plot_options_bar_column_width::String = "100%"
  plot_options_bar_data_labels_position::Symbol = :center
  plot_options_bubble_min_bubble_radius::Union{Int,Symbol} = :undefined
  plot_options_bubble_max_bubble_radius::Union{Int,Symbol} = :undefined
  stroke_curve::Symbol = :smooth
  stroke_show::Bool = true
  stroke_width::Int = 2
  stroke_colors::Vector{String} = String["transparent"]
  subtitle_text::String = ""
  subtitle_align::Symbol = :left
  subtitle_style_font_size::String = "12px"
  theme_mode::Symbol = :light
  theme_palette::Symbol = :palette1
  title_text::String = ""
  title_align::Symbol = :left
  title_margin::Int = 10
  title_style_font_size::String = "14px"
  title_style_font_weight::Union{Int,Symbol} = :bold
  title_style_color::String = "#263238"
  tooltip_enable::Bool = true
  xaxis_type::Symbol = :category
  xaxis_categories::Vector{String} = String[]
  xaxis_tick_amount::Union{Int,Float64,Symbol} = :undefined
  xaxis_max::Union{Int,Float64,Symbol} = :undefined
  xaxis_min::Union{Int,Float64,Symbol} = :undefined
  xaxis_labels_show::Bool = true
  yaxis_tick_amount::Union{Int,Float64,Symbol} = :undefined
  yaxis_max::Union{Int,Float64,Symbol} = :undefined
  yaxis_min::Union{Int,Float64,Symbol} = :undefined
  yaxis_labels_show::Bool = true
end

Base.@kwdef mutable struct PlotData{T<:Vector}
  data::T = T[]
  key::Union{Symbol,Nothing} = :data
end

function PlotData(data::DataFrames.DataFrame; key=:data)
  PlotData(key = key, data = [Array(r) for r in DataFrames.eachrow(data)])
end

function PlotData(data::Vector{T}) where {T}
  PlotData(data = data)
end

Base.@kwdef mutable struct PlotSeries
  name::String = ""
  plotdata::PlotData = PlotData()
end

function plot(fieldname::Symbol;
              options::Union{Symbol,Nothing} = nothing,
              args...) :: String

  k = (Symbol(":series"),)
  v = Any["$fieldname"]

  if options !== nothing
    k = (k..., Symbol("options!"))
    push!(v, options)
  end

  Genie.Renderer.Html.div() do
    apexchart(; args..., NamedTuple{k}(v)...)
  end
end

#===#

function Base.parse(::Type{Vector{PlotSeries}}, d::Vector{Any})
  [PlotSeries(name = x["name"], data = x["data"]) for x in d]
end

function Base.parse(::Type{PlotSeries}, x::Dict{String,Any})
  PlotSeries(name = x["name"], data = x["data"])
end

function Base.parse(::Type{PlotData}, x::Vector{Any})
  PlotData(x)
end

#===#

function Stipple.watch(vue_app_name::String, fieldtype::R{PlotSeries}, fieldname::Symbol, channel::String, model::M)::String where {M<:ReactiveModel}
  string(vue_app_name, raw".\$watch('", fieldname, "', function(newVal, oldVal){

  });\n\n")
end

#===#

function Stipple.render(pd::PlotData{T}, fieldname::Union{Symbol,Nothing} = nothing) where {T<:Vector}
  pd.key === nothing ? pd.data : [Dict(pd.key => pd.data)]
end

function Stipple.render(pdv::Vector{PlotData{T}}, fieldname::Union{Symbol,Nothing} = nothing) where {T<:Vector}
  [Dict(pd.key => pd.data) for pd in pdv]
end

function Stipple.render(ps::PlotSeries, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(:name => ps.name, ps.plotdata.key => ps.plotdata.data)
end

function Stipple.render(psv::Vector{PlotSeries}, fieldname::Union{Symbol,Nothing} = nothing)
  [Dict(:name => ps.name, ps.plotdata.key => ps.plotdata.data) for ps in psv]
end

function Stipple.render(po::PlotOptions, fieldname::Union{Symbol,Nothing} = nothing)
  val = Dict(
    :chart => Dict(
      :animations => Dict(
        :enabled => po.chart_animations_enabled,
        :easing => po.chart_animations_easing,
        :speed => po.chart_animations_speed
      ),
      :background => po.chart_background,
      :fontFamily => po.chart_font_family,
      :foreColor => po.chart_fore_color,
      :height => po.chart_height,
      :offsetX => po.chart_offset_x,
      :offsetY => po.chart_offset_y,
      :selection => Dict(
        :enabled => po.chart_selection_enabled,
        :type => po.chart_selection_type
      ),
      :sparkline => Dict(
        :enabled => po.chart_sparkline_enabled
      ),
      :stacked => po.chart_stacked,
      :stackType => po.chart_stack_type,
      :toolbar => Dict(
        :show => po.chart_toolbar_show
      ),
      :type => po.chart_type,
      :width => po.chart_width,
      :zoom => Dict(
        :enabled => po.chart_zoom_enabled,
        :type => po.chart_zoom_type
      )
    ),
    :colors => po.colors,
    :dataLabels => Dict(
      :enabled => po.data_labels_enabled
    ),
    :fill => Dict(
      :opacity => po.fill_opacity
    ),
    :grid => Dict(
      :show => po.grid_show
    ),
    :labels => po.labels,
    :legend => Dict(
      :position => po.legend_position,
      :fontFamily => po.legend_font_family,
      :fontSize => po.legend_font_size,
      :show => po.legend_show
    ),
    :noData => Dict(
      :text => po.no_data_text
    ),
    :plotOptions => Dict(
      :bar => Dict(
        :horizontal => po.plot_options_bar_horizontal,
        :endingShape => po.plot_options_bar_ending_shape,
        :columnWidth => po.plot_options_bar_column_width,
        :dataLabels => Dict(
          :position => po.plot_options_bar_data_labels_position
        )
      ),
      :bubble => Dict(
        :minBubbleRadius => po.plot_options_bubble_min_bubble_radius,
        :maxBubbleRadius => po.plot_options_bubble_max_bubble_radius
      )
    ),
    :stroke => Dict(
      :curve => po.stroke_curve,
      :show => po.stroke_show,
      :width => po.stroke_width,
      :colors => po.stroke_colors
    ),
    :subtitle => Dict(
      :align => po.subtitle_align,
      :text => po.subtitle_text,
      :style => Dict(
        :fontSize => po.subtitle_style_font_size
      )
    ),
    :theme => Dict(
      :mode => po.theme_mode,
      :palette => po.theme_palette
    ),
    :title => Dict(
      :text => po.title_text,
      :align => po.title_align,
      :margin => po.title_margin,
      :style => Dict(
        :color => po.title_style_color,
        :fontSize => po.title_style_font_size,
        :fontWeight => po.title_style_font_weight
      )
    ),
    :tooltip => Dict(
      :enable => po.tooltip_enable
    ),
    :xaxis => Dict(
      :categories => po.xaxis_categories,
      :tickAmount => po.xaxis_tick_amount,
      :type => po.xaxis_type,
      :max => po.xaxis_max,
      :min => po.xaxis_min,
      :labels => Dict(
        :show => po.xaxis_labels_show
      )
    ),
    :yaxis => Dict(
      :tickAmount => po.yaxis_tick_amount,
      :max => po.yaxis_max,
      :min => po.yaxis_min,
      :labels => Dict(
        :show => po.yaxis_labels_show
      )
    )
  )

  replace(Genie.Renderer.Json.JSONParser.json(val), "\"undefined\""=>"undefined")
end

# #===#


end