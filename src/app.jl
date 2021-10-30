using Genie, Genie.Router, Genie.Requests, Genie.Renderer.Json
using WebAssemblyText

function launchServer(port)
  Genie.config.run_as_server = true
  Genie.config.server_host = "0.0.0.0"
  Genie.config.server_port = port
  Genie.config.cors_allowed_origins = ["*"]
  Genie.config.server_handle_static_files = true

  println("port set to $(port)")

  route("/") do
      serve_static_file("index.html")
  end

	route("/jsonpayload", method = POST) do
	  @show jsonpayload()
	  @show rawpayload()

	  json("Hello $(jsonpayload()["name"])")
	end

  route("/text", method = POST) do
	  jlstring2wat(rawpayload())
  end

  route("/text_barebone", method = POST) do
	  jlstring2wat_barebone(rawpayload())
  end
  
  Genie.AppServer.startup()
end

launchServer(parse(Int, ARGS[1]))


