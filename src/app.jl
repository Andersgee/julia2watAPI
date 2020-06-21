using Genie
using Genie.Router
include("julia2wat.jl")

function launchServer(port)

    Genie.config.run_as_server = true
    Genie.config.server_host = "0.0.0.0"
    Genie.config.server_port = port

    println("port set to $(port)")

    route("/") do
        julia2wat.greet()
    end

    Genie.AppServer.startup()
end

launchServer(parse(Int, ARGS[1]))


