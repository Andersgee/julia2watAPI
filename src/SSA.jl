function funchead(cinfo,A,Rtype,slotnames,slottypes,doexport)
    str = []
    fname = cinfo.linetable[1].method
    push!(str, string("(func \$",fname))
    if (doexport)
        push!(str, string(" (export \"",fname,"\")"))
    end
    paramtypes = getfield(A,3)
    for i=1:length(paramtypes)
        push!(str, string(" (param \$",slotnames[i+1]," ",type2str(paramtypes[i]),")"))
    end
    if !(Rtype == Nothing)
        push!(str,string(" (result ",type2str(Rtype),")\n"))
    else
        push!(str, "\n")
    end

    for i=2+length(paramtypes):length(slotnames)
        if isa(slottypes[i],Union)
            iteratortuple = getfield(slottypes[i],2)
            iteratortype = getfield(iteratortuple,3)[1]
            push!(str, string("(local \$","_",i," ",type2str(iteratortype),") "))
            slotnames[i] = Symbol("_",i)
            slottypes[i] = iteratortype
        else
            push!(str,string("(local \$",slotnames[i]," ",type2str(slottypes[i]),") "))
        end 
    end
    return join(str)
end

function stringifySSA(SSA)
    v = []
    for i=1:length(SSA)
        #print("%",i," ")
        for j=1:length(SSA[i])
            push!(v, string(SSA[i][j]," "))
        end
        if length(SSA[i])>0
            push!(v, "\n")
        end
    end
    return join(v)
end

function inlineSSA(SSA)
    #prune iterator vectors
    for i=1:length(SSA), j=1:length(SSA[i])
        if isa(SSA[i][j],AbstractArray)
    		SSA[i][j] = ""
    	end
    end
    
    used=[]
    #copy paste from SSA
    for i=1:length(SSA), j=1:length(SSA[i])
        if isa(SSA[i][j],SSAValue)
            target = SSA[i][j].id
            SSA[i][j] = join(SSA[target]," ")
            push!(used, target)
            
        end
    end

    #delete used SSA (do after so copy paste can work multiple times)
    for i=1:length(SSA)
        if (i in used)
            SSA[i] = ""
        end
    end

    #add parenthesis
    for i=1:length(SSA)
    	if length(SSA[i]) > 1
    		SSA[i] = vcat("(",SSA[i],")")
    	end
    end
    
end

function insertBB(SSA)
    for i=1:length(SSA)
        if length(SSA[i])>0 && isa(SSA[i][1],GotoNode)
            #target = SSA[i][1].label
            target = SSA[i][1].label - 1 #get rid of the extra "skip loop" check julia does by starting 1 index earlier and replacing it 
            SSA[target] = [string("(block (loop ;;startloop_",target)]
            SSA[i] = [string("(br 0))) ;;endloop_",target)]
        end
    end
end