module StippleApexCharts

using Revise

import Genie
import Stipple

#===#

const COMPONENTS = [:apexchart => :VueApexCharts]

#===#

function deps() :: String
  Genie.Router.route("/js/stipple/apexcharts.min.js") do
    Genie.Renderer.WebRenderable(
      read(joinpath(@__DIR__, "..", "files", "js", "apexcharts.min.js"), String),
      :javascript) |> Genie.Renderer.respond
  end

  Genie.Router.route("/js/stipple/vue-apexcharts.min.js") do
    Genie.Renderer.WebRenderable(
      read(joinpath(@__DIR__, "..", "files", "js", "vue-apexcharts.min.js"), String),
      :javascript) |> Genie.Renderer.respond
  end

  string(
    Genie.Renderer.Html.script(src="/js/stipple/apexcharts.min.js"),
    Genie.Renderer.Html.script(src="/js/stipple/vue-apexcharts.min.js")
  )
end

#===#

include("Plots.jl")

function __init__()
  push!(Stipple.DEPS, deps)
end

end # module
