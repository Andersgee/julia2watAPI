type2str(t) = (t <: AbstractFloat) ? "f32" : "i32";
itemtype(item) = type2str(typeof(item))

parseitems(ssa, items) = parseitem.((ssa,), items)
parseitem(ssa, item) = push!(ssa, item)
parseitem(ssa, item::SlotNumber) = push!(ssa, "(local.get \$$(slotnames[item.id]))")
parseitem(ssa, item::TypedSlot) = push!(ssa, "(local.get \$$(slotnames[item.id]))")
parseitem(ssa, item::Nothing) = push!(ssa, "(i32.const 0)")
parseitem(ssa, item::Number) = push!(ssa, "($(itemtype(item)).const $(item))")


function parseitem(ssa, item::Expr)
    if item.head != :(call)
        parsefunction(ssa, item.args, item.head) #function name in head, args in args
    elseif item.head == :(call) && isa(item.args[1],GlobalRef)
        parsefunction(ssa, item.args[2:end], item.args[1].name) #function name in args[1].name, args in args[2:end]
    else
        parseitems(ssa, item.args) #not a function call
    end
end

parsefunction(ssa, items, head) = specialfunc(ssa, items, head) || parsefunc(ssa, items, head)

###############################################################################

function parsefunc(ssa, items, head)
    Nitems = length(items)
    push!(ssa,"(")
    if (isa(ssatype,Type) && ssatype <: AbstractFloat && head in keys(f32ops))
        fname = f32ops[head][1]
        consumed = f32ops[head][2]

        if (head == :(-) && Nitems==1)
            push!(ssa, "f32.neg")
        else
            push!(ssa, fname)
            for i=1:Nitems-consumed
                push!(ssa,"($(fname)")
            end
        end
    elseif head in keys(i32ops)
        fname = i32ops[head][1]
        consumed = i32ops[head][2]

        push!(ssa, fname)
    else
        consumed = Nitems
        push!(ssa, "call \$$(head)")
    end

    for i=1:Nitems
        parseitem(ssa, items[i])
        if (i >= consumed)
            push!(ssa,")")
        end
    end
end

function funcargitem2type(item)
    #println("item: ",item)
    #println("typeof(item): ",typeof(item))
    
    if isa(item,SlotNumber)
        #println("item.id: ",item.id)
        #println("slottypes[item.id]: ",slottypes[item.id])
        return slottypes[item.id]
    elseif isa(item,Number)
        if (typeof(item) <: AbstractFloat)
            return Float64
        else
            return Int64
        end
    end
    return Float64
        
end
#=
function funcargitem2type(item)
    #to get types for code_typed on functions called within function
    if (typeof(item) <: AbstractFloat)
        return :(Float64)
    elseif isa(item,SlotNumber)

    
    type2str(t) = (t <: AbstractFloat) ? "f32" : "i32";
itemtype(item) = type2str(typeof(item))

parseitems(ssa, items) = parseitem.((ssa,), items)
parseitem(ssa, item) = push!(ssa, item)
parseitem(ssa, item::SlotNumber) = push!(ssa, "(local.get \$$(slotnames[item.id]))")
parseitem(ssa, item::TypedSlot) = push!(ssa, "(local.get \$$(slotnames[item.id]))")
parseitem(ssa, item::Nothing) = push!(ssa, "(i32.const 0)")
parseitem(ssa, item::Number) = push!(ssa, "($(itemtype(item)).const $(item))")

end
=#
function specialfunc(ssa, items, head)
    if (string(head) in keys(userfuncs))
        parsefunc(ssa, items, head)
        userfuncsargs[string(head)] = Tuple{funcargitem2type.(items)...}
        #println("slottypes: ",slottypes)
        #println("userfuncs head: ",head)
        #println("userfuncs items: ",items)
        return true
    elseif !(string(head) in ["return","=","iterate","gotoifnot",":","getfield","ifelse","setindex!"])
        return false
    #parse a few special functions manually in a somewhat hacky way
    elseif head == :(setindex!)
        push!(ssa, "call \$setindex") #without exclamation
        parseitems(ssa, items)
    elseif head == :(ifelse)
        push!(ssa, "(select")
        parseitem(ssa, items[2])
        parseitem(ssa, items[3])
        parseitem(ssa, items[1]) #ifelse(condition,a,b) => select(a,b,condition)
        push!(ssa, ")")
    elseif head == Symbol("return")
        if string(items[1]) != "Main.nothing"
            parseitems(ssa, items)
        end
    elseif head == :(=)
        push!(ssa, "local.set \$$(slotnames[items[1].id])")
        parseitems(ssa, items[2:end])
    elseif head == Symbol(":")
        iteratorstr = []
        if length(items)<3
            parseitem(iteratorstr, items[1])
            parseitem(iteratorstr, 1) #make :,1,N be saved as 1,1,N rather than 1,N
            parseitem(iteratorstr, items[2])
        else
            parseitems(iteratorstr, items) #iterator args without the colon
        end
        push!(ssa, iteratorstr)
    elseif head === :(iterate) && length(items) <2
        parseitem(ssa, SSA[items[1].id][1][1]) #get iterator startvalue aka 1 in 1:1:N
    elseif head == :(iterate)
        push!(ssa, "(call \$iterate")
        parseitems(ssa, SSA[items[1].id][1][1:3]) #get all iterator values aka 1,1,N in 1:1:N
        parseitems(ssa, items[2:end])
        push!(ssa, ")")
    elseif head == :(gotoifnot)
        push!(ssa, "br_if 1 (i32.eqz")
        parseitem(ssa, items[1])
        push!(ssa, ")")
    elseif head == Symbol("getfield")
        parseitem(ssa, items[1])
    end
    return true
end
