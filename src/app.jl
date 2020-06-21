using Genie, Genie.Router, Genie.Requests, Genie.Renderer.Json
include("julia2wat.jl")

function launchServer(port)

    Genie.config.run_as_server = true
    Genie.config.server_host = "0.0.0.0"
    Genie.config.server_port = port

    println("port set to $(port)")

    route("/") do
        julia2wat.code_wat("f(x)=x*5; f(3.0)")
    end


	route("/jsonpayload", method = POST) do
	  @show jsonpayload()
	  @show rawpayload()

	  json("Hello $(jsonpayload()["name"])")
	end

    Genie.AppServer.startup()
end

launchServer(parse(Int, ARGS[1]))


