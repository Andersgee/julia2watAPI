module julia2wat
# julia:
# textpost = """f(x)=x*7; f(3.1)"""
# using HTTP
# HTTP.request("POST", "https://julia2wat.herokuapp.com/text", [("Content-Type", "text/plain")], textpost)

using Base: CodeInfo, SlotNumber, GlobalRef, GotoNode, iterate
using Core: TypedSlot, SSAValue

include("builtinswat.jl")
include("ops.jl")
include("SSA.jl")
include("parser.jl")

function userfuncsDict(exs)
    funcs=[]
    for i=1:length(exs.args)-1 #skip last expression
        if isa(exs.args[i],Expr)
            push!(funcs, exs.args[i])
        end
    end
    names = [string(funcs[i].args[1].args[1]) for i=1:length(funcs)]
    return Dict(names .=> funcs)
end

function funcA2wat(func, A; doexport=false)
    cinfo, Rtype = code_typed(func, A; optimize=false, debuginfo=:none)[1]

    code = cinfo.code
    SSAtypes = cinfo.ssavaluetypes
    global slotnames = cinfo.slotnames
    global slottypes = cinfo.slottypes
    funcstr_start = funchead(cinfo,A,Rtype,slotnames,slottypes,doexport)
    global SSA = []
    global ssatype = ""
    for i=1:length(code)
        ssatype = SSAtypes[i]
        ssa=[]
        parseitem(ssa, code[i])
        push!(SSA, ssa)
    end
    inlineSSA(SSA)
    insertBB(SSA)
    return join(vcat(funcstr_start, stringifySSA(SSA), ")\n"))
end

function code_wat(str)
    exs = Meta.parse("begin $str \nend")
    try
        result = eval(exs)
    catch e
        return ";;Error: $(e)"
    end
    result = eval(exs)

    if !(isa(result,Number) || isa(result,Nothing))
        return ";;Nope... Webassembly functions can only return single numbers (or nothing)\n;;However, you can modify arrays (aka memory) inside functions."
    end

    global userfuncs = userfuncsDict(exs)
    global userfuncsargs = Dict()
    global builtins = Dict()
    #user supplied args for last expression
    func = eval(userfuncs[string(exs.args[end].args[1])])
    A = Tuple{[typeof(eval(exs.args[end].args[i])) for i=2:length(exs.args[end].args)]...}
    wat = funcA2wat(func, A, doexport=true)

    wats = []
    for fname in keys(userfuncsargs)
        func = eval(userfuncs[fname])
        A = userfuncsargs[fname]
        push!(wats, funcA2wat(func, A))
    end

    for fname in keys(builtins)
        push!(wats, builtinswat[fname])
    end
    evalresult = isa(result,Nothing) ? "" : "\n;;evaluated by Julia to: $(result)"
    return join(vcat("""(module\n(memory (import "imports" "memory") 1)\n""", wat, wats...,")",evalresult),"\n")
end

end
