function funchead(cinfo,A,Rtype,slotnames,slottypes,doexport)
    str = []
    fname = cinfo.linetable[1].method

    #function declaration
    push!(str, string("(func \$",fname))
    if (doexport)
        push!(str, string(" (export \"",fname,"\")"))
    end
    paramtypes = getfield(A,3)
    for i=1:length(paramtypes)
        push!(str, string(" (param \$",slotnames[i+1]," ",type2str(paramtypes[i]),")"))
    end
    if !(Rtype == Nothing)
        push!(str,string(" (result ",type2str(Rtype),")"))
    end
    push!(str, "\n")

    #cinfo.slottypes have types and cinfo.slotnames have symbols for the variables used in the function
    #...but code_typed puts some special stuff in cinfo.slottypes and cinfo.slotnames if its an iterator variable
    #so modify them to contain type and symbol like normal so I dont have have special logic for them later 
    n=1+length(paramtypes)+1 #index of the first non-parameter slot (slotnames is for example [fname,param1,param2,slot1,slot2])
    N=length(slotnames)
    for i=n:N
        if isa(slottypes[i],Union) #aka iterator variable
            iteratortuple = getfield(slottypes[i],2)
            iteratortype = getfield(iteratortuple,3)[1]
            slotnames[i] = Symbol("_",i) #just pick something unique here
            slottypes[i] = iteratortype
        end 
    end

    #locals
    for i=n:N
        push!(str,string("(local \$",slotnames[i]," ",type2str(slottypes[i]),") "))
    end
    push!(str, "\n")
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