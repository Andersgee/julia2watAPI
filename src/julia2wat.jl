module julia2wat

using Base: CodeInfo, SlotNumber, GlobalRef, GotoNode, iterate
#using Core: , getfield
using Core: TypedSlot, SSAValue

include("ops.jl")
include("SSA.jl")
include("parser.jl")

function code_wat(str)
    result = eval(Meta.parse(str))
    
    ex=Meta.parse(str).args[end] #only lower the last expression in the code block.
    func = eval(ex.args[1])
    A = Base.typesof(eval(ex.args[2:end]...))
    cinfo, Rtype = code_typed(func, A; optimize=false, debuginfo=:none)[1]

    code = cinfo.code
    SSAtypes = cinfo.ssavaluetypes
    global slotnames = cinfo.slotnames

    modulestr_start = "(module \n"
    modulestr_end = ")"
    funcstr_start = funchead(cinfo,A,Rtype,slotnames)
    funcstr_end = ")\n"
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

    wat = stringifySSA(SSA)
    return join(vcat(modulestr_start,funcstr_start,wat,funcstr_end,modulestr_end))
end

end
