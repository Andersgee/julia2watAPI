module julia2wat

using Core: CodeInfo, SlotNumber, SSAValue, IntrinsicFunction, MethodInstance, PhiNode, GotoNode
include("parser.jl")
include("ops.jl")
include("utils.jl")


greet() = "Hello from module"

function code_wat(str)
	result = eval(Meta.parse(str))
	
	ex=Meta.parse(str).args[end] #only lower the last expression in the code block.
	cinfo, R = code_typed(eval(ex.args[1]), Base.typesof(eval(ex.args[2:end]...)), optimize=true)[1]
	return string(cinfo.code)
end

end	