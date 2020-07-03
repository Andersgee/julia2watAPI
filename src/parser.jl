type2str(t) = (t <: AbstractFloat) ? "f32" : "i32";
wasmtype(item) = type2str(typeof(item))

parseitems(ssa, items) = parseitem.((ssa,), items)
parseitem(ssa, item) = push!(ssa, item)
parseitem(ssa, item::SlotNumber) = push!(ssa, "(local.get \$$(slotnames[item.id]))")
parseitem(ssa, item::TypedSlot) = push!(ssa, "(local.get \$$(slotnames[item.id]))")
parseitem(ssa, item::Nothing) = push!(ssa, "(i32.const 0)")
parseitem(ssa, item::Number) = push!(ssa, "($(wasmtype(item)).const $(item))")

function parseitem(ssa, item::Core.Compiler.Const)
    if !(isa(item.val,Expr) && string(item.val.args[1]) == "julia2wat.nothing")
        parseitem(ssa, item.val)
    end
end


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
            consumed=1
            push!(ssa, "f32.neg")
        else
            if head == :(^)
                imports["pow"] = """(func \$pow (import "imports" "pow") (param f32) (result f32))"""
            end
            push!(ssa, fname)
            for i=1:Nitems-consumed
                push!(ssa,"($(fname)")
            end
        end
    elseif (ssatype==Array{Float64,2} && head in keys(f32vecops))
        fname = f32vecops[head][1]
        consumed = f32vecops[head][2]
        push!(ssa, fname)
    elseif head in keys(i32ops)
        fname = i32ops[head][1]
        consumed = i32ops[head][2]

        if head == :(^)
            imports["powi"] = """(func \$powi (import "imports" "powi") (param f32) (result i32))"""
        end

        push!(ssa, fname)
    else
        #this is last resort of parser and just puts call $funcname
        #funcname can be either a builtin julia function such as sin exp log etc or a userdefined function
        #however, stuff like println("a") or mul(y,w,x) solo on a line should not have extra bracket around them in .wat
        #detect this situation by checking if ssatype == Any.
        #also, if its not a userdefined or a custom builtins wat function; put a string in imports
        #otherwise just do the normal parsing
        noextraparen = ssatype == Any #string(head) == "println" || string(head) == "printvec"
        consumed = Nitems
        if noextraparen
            pop!(ssa) #remove the added paren
            push!(ssa, "call \$$(head)")
            parseitems(ssa, items)
        else
            push!(ssa, "call \$$(head)")
            parseitems(ssa, items)
            push!(ssa, ")")
        end

        #how to know the return types of imports? must be some way.. TODO
        if !(head in keys(builtinswat) || head in keys(userfuncs))
            importstr = []
            push!(importstr, """(func \$$(head) (import "imports" "$(head)") """)
            for i=1:Nitems
                push!(importstr, "(param f32) ") #not sure how to get the types for this
            end
            if head == :(println) #dont return anything from this particular import
                push!(importstr, ")")
            elseif head == :(zeros) || head == :(rand) || head == :(randn)
                push!(importstr, "(result i32))")
            else
                push!(importstr, "(result f32))")
            end
            imports[string(head)] = join(importstr)
        end
        return
    end

    for i=1:Nitems
        parseitem(ssa, items[i])
        if (i >= consumed)
            push!(ssa,")")
        end
    end
end

function item2type(item)
    if isa(item,SlotNumber)
        return slottypes[item.id]
    elseif isa(item,Number)
        if (typeof(item) <: AbstractFloat)
            return Float64
        else
            return Int
        end
    elseif isa(item,SSAValue)
        return ssavaluetypes[item.id]
    else
        #println("itemtype else: ",item)
        #this is probably Core.Compiler.Const
    end
    return Int
end

function specialfunc(ssa, items, head)
    if (head in keys(userfuncs))
        parsefunc(ssa, items, head) #parse like normal
        println("head in userfuncs:", head)

        #func = eval(userfuncs[head])
        #A = Tuple{item2type.(items)...}
        #WATS[head] = funcA2wat(func, A)
        argsforlater[head] = Tuple{item2type.(items)...}
        #WATS[head] = funcA2wat(eval(userfuncs[head]), Tuple{item2type.(items)...})
        return true
    elseif !(string(head) in ["length","return","=","iterate","gotoifnot",":","getfield","ifelse","setindex!","getindex"])
        return false
    #parse a few special functions manually in a somewhat hacky way
    elseif head == :(length)
        push!(ssa, "(i32.trunc_f32_s (f32.load ")
        parseitem(ssa, items[1])
        push!(ssa, ") )")
    elseif head == :(setindex!)
        push!(ssa, "call \$setindex") #without exclamation
        parseitems(ssa, items)
        builtins[head] = true
        #println("setindex items: ",items)
    elseif head == :(ifelse)
        #ifelse(condition,a,b) or condition ? a : b => wat: select(a,b,condition)
        push!(ssa, "(select")
        parseitem(ssa, items[2])
        parseitem(ssa, items[3])
        parseitem(ssa, items[1])
        push!(ssa, ")")
    elseif head == Symbol("return")
        if !(string(items[1]) == "Main.julia2wat.nothing" || string(items[1]) == "julia2wat.nothing")
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
        builtins[head] = true
    elseif head == :(gotoifnot)
        push!(ssa, "br_if 1 (i32.eqz")
        parseitem(ssa, items[1])
        push!(ssa, ")")
    elseif head == Symbol("getfield")
        parseitem(ssa, items[1])
    elseif head == Symbol("getindex")
        parsefunc(ssa, items, head) #parse like normal
        builtins[head] = true
    end
    return true
end
