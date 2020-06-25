module julia2wat
# julia:
# HTTP.request("POST", "https://julia2wat.herokuapp.com/text", [("Content-Type", "text/plain")], """f(x)=x*7; f(3.1)""")
# js:
# https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest

using Base: CodeInfo, SlotNumber, GlobalRef, GotoNode, iterate
#using Core: , getfield
using Core: TypedSlot, SSAValue

include("ops.jl")
include("SSA.jl")
include("parser.jl")
include("builtinswat.jl")

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
    exs = Meta.parse("begin $str end")
    result = eval(exs) #if result errors the return "syntax error" or smth
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
    return join(vcat("(module\n", wat, wats...,")"),"\n")
end

end
