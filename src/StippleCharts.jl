module StippleCharts

import Genie
import Stipple

using Stipple.Reexport

#===#

const COMPONENTS = [:apexchart => :VueApexCharts]

#===#

const assets_config = Genie.Assets.AssetsConfig(package = "StippleCharts.jl")

function deps() :: Vector{String}
  if ! Genie.Assets.external_assets(Stipple.assets_config)

    Genie.Router.route(Genie.Assets.asset_route(assets_config, :js, file="apexcharts.min")) do
      Genie.Renderer.WebRenderable(
        Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="apexcharts.min.js")),
        :javascript) |> Genie.Renderer.respond
    end

    Genie.Router.route(Genie.Assets.asset_route(assets_config, :js, file="vue-apexcharts.min")) do
      Genie.Renderer.WebRenderable(
        Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="vue-apexcharts.min.js")),
        :javascript) |> Genie.Renderer.respond
    end

  end

  [
    Genie.Renderer.Html.script(src="$(Genie.Assets.asset_path(assets_config, :js, file="apexcharts.min"))"),
    Genie.Renderer.Html.script(src="$(Genie.Assets.asset_path(assets_config, :js, file="vue-apexcharts.min"))")
  ]
end

#===#

include("Charts.jl")
@reexport using .Charts

function __init__()
  Stipple.deps!(@__MODULE__, deps)
end

end # module
