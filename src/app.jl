using Genie, Genie.Router, Genie.Requests, Genie.Renderer.Json
include("julia2wat.jl")

function launchServer(port)

    Genie.config.run_as_server = true
    Genie.config.server_host = "0.0.0.0"
    Genie.config.server_port = port
    Genie.config.cors_allowed_origins = ["*"]
    Genie.config.server_handle_static_files = true

    println("port set to $(port)")

    route("/") do
        #julia2wat.code_wat("f(x)=x*588; f(3.0)")
        serve_static_file("index.html")
    end


	route("/jsonpayload", method = POST) do
	  @show jsonpayload()
	  @show rawpayload()

	  json("Hello $(jsonpayload()["name"])")
	end

  route("/text", method = POST) do
    str = rawpayload()
	  julia2wat.code_wat("begin $str end")
  end
  
  Genie.AppServer.startup()
end

launchServer(parse(Int, ARGS[1]))


