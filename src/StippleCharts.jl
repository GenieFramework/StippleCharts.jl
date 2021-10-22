module StippleCharts

import Genie
import Stipple
using Stipple.Reexport

#===#

const COMPONENTS = [:apexchart => :VueApexCharts]

#===#

const assets_config = Genie.Assets.AssetsConfig(package = "StippleCharts.jl")

function deps() :: String
  Genie.Router.route(Genie.Assets.asset_path(assets_config, :js, file="apexcharts.min.js")) do
    Genie.Renderer.WebRenderable(
      Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="apexcharts.min.js")),
      :javascript) |> Genie.Renderer.respond
  end

  Genie.Router.route(Genie.Assets.asset_path(assets_config, :js, file="vue-apexcharts.min.js")) do
    Genie.Renderer.WebRenderable(
      Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="vue-apexcharts.min.js")),
      :javascript) |> Genie.Renderer.respond
  end

  string(
    Genie.Renderer.Html.script(src="$(Genie.Assets.asset_path(assets_config, :js, file="apexcharts.min.js"))"),
    Genie.Renderer.Html.script(src="$(Genie.Assets.asset_path(assets_config, :js, file="vue-apexcharts.min.js"))")
  )
end

#===#

include("Charts.jl")
@reexport using .Charts

function __init__()
  push!(Stipple.DEPS, deps)
end

end # module
