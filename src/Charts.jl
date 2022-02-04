module Charts

using Genie, Stipple

import DataFrames
import Genie.Renderer.Html: HTMLString, normal_element, register_normal_element
import Stipple: Undefined, UNDEFINED


export PlotOptions, PlotData, PlotSeries, plot

register_normal_element("apexchart", context = @__MODULE__)

"""
  PlotOptions
A data structure representing the plot options.
"""
Base.@kwdef mutable struct PlotOptions
  chart_animations_enabled::Bool = false
  chart_animations_easing::Union{String,Symbol} = :easeinout
  chart_animations_speed::Int = 800
  chart_background::String = "#fff"
  chart_font_family::String = "Helvetica, Arial, sans-serif"
  chart_fore_color::String = "#373d3f"
  chart_height::Union{Int,String} = "auto"
  chart_offset_x::Int = 0
  chart_offset_y::Int = 0
  chart_selection_enabled::Bool = true
  chart_selection_type::Union{String,Symbol} = :xy
  chart_sparkline_enabled::Bool = false
  chart_stacked::Bool = false
  chart_stack_type::String = "normal"
  chart_toolbar_show::Bool = false
  chart_type::Union{String,Symbol} = :line
  chart_width::Union{Int,String} = "100%"
  chart_zoom_enabled::Bool = true
  chart_zoom_type::Union{String,Symbol} = :xy

  colors::Union{Vector{String},Undefined} = ["#2E93fA", "#66DA26", "#0A557A", "#E91E63", "#FF9800"]

  data_labels_enabled::Bool = false

  fill_opacity::Union{Int,Float64} = 1.0

  grid_row_colors::Union{Vector{String},Undefined} = ["#EEEEEE", "transparent"]
  grid_row_opacity::Union{Int,Float64} = 1.0
  grid_show::Bool = true
  grid_xaxis_lines_show::Bool = false
  grid_yaxis_lines_show::Bool = false

  labels::Vector{String} = String[]
  legend_show::Bool = true
  legend_position::Union{String,Symbol} = :bottom
  legend_font_size::String = "14px"
  legend_font_family::String = "Helvetica, Arial"

  no_data_text::String = ""

  plot_options_area_fill_to::Union{String,Symbol} = :origin

  plot_options_bar_border_radius::Int = 0
  plot_options_bar_column_width::String = "100%"
  plot_options_bar_data_labels_position::Union{String,Symbol} = :center
  plot_options_bar_ending_shape::Union{String,Symbol} = :flat
  plot_options_bar_horizontal::Bool = false

  plot_options_bubble_min_bubble_radius::Union{Int,Undefined} = UNDEFINED
  plot_options_bubble_max_bubble_radius::Union{Int,Undefined} = UNDEFINED

  plot_options_pie_size::Union{Int,Undefined} = UNDEFINED
  plot_options_pie_start_angle::Int = 0
  plot_options_pie_end_angle::Int = 360
  plot_options_pie_expand_on_click::Bool = true
  plot_options_pie_offset_x::Int = 0
  plot_options_pie_offset_y::Int = 0
  plot_options_pie_custom_scale::Int = 1
  plot_options_pie_data_labels_offset::Int = 0
  plot_options_pie_data_labels_min_angle_to_show_label::Int = 10
  plot_options_pie_donut_size::Union{Int,String} = 65
  plot_options_pie_donut_background::String = "transparent"
  plot_options_pie_donut_labels_show::Bool = false
  plot_options_pie_donut_labels_name::Dict = Dict()
  plot_options_pie_donut_labels_value::Dict = Dict()
  plot_options_pie_donut_labels_total::Dict = Dict()

  stroke_curve::Union{String,Symbol,Vector{String},Vector{Symbol}} = :smooth
  stroke_show::Bool = true
  stroke_width::Union{Int,Vector{Int}} = 2
  stroke_colors::Vector{String} = colors

  subtitle_text::String = ""
  subtitle_align::Union{String,Symbol} = :left
  subtitle_style_font_size::String = "12px"

  theme_mode::Union{String,Symbol} = :light
  theme_palette::Union{String,Symbol} = :palette1

  title_text::String = ""
  title_align::Union{String,Symbol} = :left
  title_margin::Int = 10
  title_style_font_family::Union{String,Undefined} = UNDEFINED
  title_style_font_size::String = "14px"
  title_style_font_weight::Union{Int,Symbol,String} = :bold
  title_style_color::String = "#263238"

  tooltip_enable::Bool = true

  xaxis_categories::Union{Vector{String},Vector{Float64}} = String[]
  xaxis_decimals_in_float::Union{Int,Undefined} = UNDEFINED
  xaxis_labels_show::Bool = true
  xaxis_max::Union{Int,Float64,String,Undefined} = UNDEFINED
  xaxis_min::Union{Int,Float64,String,Undefined} = UNDEFINED
  xaxis_tick_amount::Union{Int,Float64,String,Undefined} = UNDEFINED
  xaxis_tick_placement::Union{String,Symbol} = :between # :on
  xaxis_type::Union{String,Symbol} = :category

  yaxis_decimals_in_float::Union{Int,Undefined} = UNDEFINED
  yaxis_labels_show::Bool = true
  yaxis_max::Union{Int,Float64,String,Undefined} = UNDEFINED
  yaxis_min::Union{Int,Float64,String,Undefined} = UNDEFINED
  yaxis_show::Bool = true
  yaxis_tick_amount::Union{Int,Float64,String,Undefined} = UNDEFINED

  extra_properties::Dict = Dict()
  extra_options::Dict = Dict()
end

"""
  PlotData
A data structure storing data for plotting.
"""
Base.@kwdef mutable struct PlotData{T<:Vector}
  data::T = T[]
  key::Union{Symbol,Nothing} = :data
end

function PlotData(data::DataFrames.DataFrame; key=:data)
  PlotData(key = key, data = [Array(r) for r in DataFrames.eachrow(data)])
end

"""
  PlotData(data)
Transform initial data in PlotData struct.

 # Examples
 ```jldoctest
 julia> vector = [1, 2, 3, 4];

 julia> PlotData(vector)
PlotData{Vector{Int64}}([1, 2, 3, 4], :data)
```
"""
function PlotData(data::Vector{T}) where {T}
  PlotData(data = data)
end

function PlotData(data...) where {T}
  PlotData([data...])
end

"""
  PlotSeries
A data structure to store PlotData struct with name.
"""
Base.@kwdef mutable struct PlotSeries
  name::String = ""
  plotdata::PlotData = PlotData(Any[])
end

function plot(fieldname::Union{Symbol,String};
              options::Union{Symbol,Nothing} = nothing,
              args...) :: String

  k = (Symbol(":series"),)
  v = Any["$fieldname"]

  if options !== nothing
    k = (k..., Symbol("options!"))
    push!(v, options)
  end

  apexchart(; args..., NamedTuple{k}(v)...)
end

#===#

function Base.parse(::Type{Vector{PlotSeries}}, d::Vector{Any})
  [PlotSeries(name = x["name"], data = x["data"]) for x in d]
end

function Base.parse(::Type{PlotSeries}, x::Dict{String,Any})
  PlotSeries(name = x["name"], data = x["data"])
end

function Base.convert(::Type{Vector{PlotSeries}}, a::Vector{Dict{String,Any}})
  [parse(PlotSeries, x) for x in a]
end

function Base.parse(::Type{Dict{String,Any}}, ::PlotSeries)
  # TODO: not implemented
end

function Base.parse(::Type{PlotData}, x::Vector{Any})
  PlotData(x)
end

function Base.parse(::Type{PlotOptions}, ::Dict{String,Any})
  # error("Not implemented") # todo: add parser
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
    # chart
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

    # grid
    :grid => Dict(
      :show => po.grid_show,
      :row => Dict(
        :colors => po.grid_row_colors,
        :opacity => po.grid_row_opacity
      ),
      :xaxis => Dict(
        :lines => Dict(
          :show => po.grid_xaxis_lines_show
        )
      ),
      :yaxis => Dict(
        :lines => Dict(
          :show => po.grid_yaxis_lines_show
        )
      )
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
        :fontFamily => po.title_style_font_family,
        :fontSize => po.title_style_font_size,
        :fontWeight => po.title_style_font_weight
      )
    ),

    :tooltip => Dict(
      :enable => po.tooltip_enable
    ),

    :xaxis => Dict(
      :categories => po.xaxis_categories,
      :decimalsInFloat => po.xaxis_decimals_in_float,
      :tickAmount => po.xaxis_tick_amount,
      :tickPlacement => po.xaxis_tick_placement,
      :type => po.xaxis_type,
      :max => po.xaxis_max,
      :min => po.xaxis_min,
      :labels => Dict(
        :show => po.xaxis_labels_show
      )
    ),

    :yaxis => Dict(
      :decimalsInFloat => po.yaxis_decimals_in_float,
      :labels => Dict(
        :show => po.yaxis_labels_show
      ),
      :max => po.yaxis_max,
      :min => po.yaxis_min,
      :show => po.yaxis_show,
      :tickAmount => po.yaxis_tick_amount,
    )
  )

  isempty(po.extra_properties) || (val = recursive_merge(val, po.extra_properties))

  plot_options = if po.chart_type == :area
    Dict(
      :area => Dict(
        :fillTo => po.plot_options_area_fill_to
      )
    )
  elseif po.chart_type == :bar
    Dict(
      :bar => Dict(
        :borderRadius => po.plot_options_bar_border_radius,
        :columnWidth => po.plot_options_bar_column_width,
        :dataLabels => Dict(
          :position => po.plot_options_bar_data_labels_position
        ),
        :endingShape => po.plot_options_bar_ending_shape,
        :horizontal => po.plot_options_bar_horizontal
      )
    )
  elseif po.chart_type == :bubble
    Dict(
      :bubble => Dict(
        :minBubbleRadius => po.plot_options_bubble_min_bubble_radius,
        :maxBubbleRadius => po.plot_options_bubble_max_bubble_radius
      )
    )
  elseif po.chart_type == :pie
    Dict(
      :pie => Dict(
        :size  => po.plot_options_pie_size,
        :startAngle => po.plot_options_pie_start_angle,
        :endAngle   => po.plot_options_pie_end_angle,
        :expandOnClick => po.plot_options_pie_expand_on_click,
        :offsetX    => po.plot_options_pie_offset_x,
        :offsetY    => po.plot_options_pie_offset_y,
        :customScale  => po.plot_options_pie_custom_scale,
        :dataLabels => Dict(
          :offset   => po.plot_options_pie_data_labels_offset,
          :minAngleToShowLabel => po.plot_options_pie_data_labels_min_angle_to_show_label
        ),
        :donut => Dict(
          :size => endswith(string(po.plot_options_pie_donut_size) |> strip, '%') ?
                    string(po.plot_options_pie_donut_size) |> strip :
                    (string(po.plot_options_pie_donut_size) |> strip) * "%",
          :background => po.plot_options_pie_donut_background,
          :labels => Dict(
            :show => po.plot_options_pie_donut_labels_show,
            :name => po.plot_options_pie_donut_labels_name,
            :value => po.plot_options_pie_donut_labels_value,
            :total => po.plot_options_pie_donut_labels_total
          )
        ),
      )
    )
  else
    Dict()
  end

  plot_options = recursive_merge(plot_options, get(po.extra_properties, :plotOptions, Dict()))
  isempty(po.extra_options) || (plot_options = recursive_merge(plot_options, po.extra_options))
  isempty(plot_options) || (val[:plotOptions] = plot_options)

  val
end

# #===#

recursive_merge(x::AbstractDict...) = merge(recursive_merge, x...)
recursive_merge(x...) = x[end]


end
