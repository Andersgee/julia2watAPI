module julia2wat
	greet() = "Hello from module"

	function code_wat(str, args)
		cinfo, R = code_typed(eval(Meta.parse(str)), Base.typesof(args...), optimize=true)[1]
		return string(cinfo.code)
	end
end	