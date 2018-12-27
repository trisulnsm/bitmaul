-- mrumap.lua
-- operations like  LUA table lookup but pop_oldest()  is O(1) 
-- 

local MruMap = {

	put=function(tbl,k,v)
		return tbl:push_front(tbl:newnode(k,v))
	end,

	get=function(tbl,k)

		print("asking for "..k)
		
		local wrap = tbl.basetable[k]
		if wrap==nil then return nil end
		tbl:erase(wrap)
		tbl:push_front(wrap)
		return wrap.data
	end,

	delete=function(tbl,k)
		local wrap = tbl.basetable[k]
		if wrap==nil then return nil end
		tbl:erase(wrap)
		tbl.basetable[k]=nil 
		wrap=nil 
	end,

	delete_lru=function(tbl)
		local wrap = tbl:pop_back()
		if wrap==nil then return nil end
		tbl.basetable[wrap.k]=nil 
		wrap=nil 
	end,

	pop_back=function(tbl)
		if tbl._size>0 then 
			local  wrap = tbl_Tail;
			tbl._Tail = tbl._Tail.p;
			if tbl._Tail then  _Tail.n=nil end
			tbl._size=tbl._size-1
			return ret;
		else
			return nil
		end
	end,


	newnode=function(k,v)
		return {
			data=v, k=k, p=nil, n=nil
		}
	end,


	push_front=function(tbl,n) 
		if n==tbl._Head and n==tbl._Tail then return end 

        if tbl._Head then 
            tbl._Head.p=n;
		end

        n.p=nil;
        n.n=tbl_Head;
        tbl._Head=n;
        if tbl._Tail==nil then 
            tbl._Tail=_Head;
		end
        tbl._size=tbl._size+1
		return n
	end,


	erase=function(tbl,n)
		if tbl._size==0 then return end

		if n.p or n.n then
			if n.p then
				n.p.n=n.n
			else
				tbl._Head=n.n
			end
			if n.n then
				n.n.p=n.p
			else
				tbl._Tail=n.p
			end
			tbl._size=tbl._size-1
		elseif n==tbl._Head and n==tbl._Tail then 
			tbl.reset()
		end


		return n
	end,

    reset=function()
        tbl._size=0;
        tbl._Head=nil;
        tbl._Tail=nil;
	end
}

local smt = {
    __index = function(table,key)
    	return MruMap.get(table,key)
	end,
}


local mrumap  = { 

   new = function( ) 
       return setmetatable(  {
          basetable={},
		  _Head=nil,
		  _Tail=nil,
		  _size=0
        },smt)
    end
} 


local tst  = mrumap.new()

print(tst["hi"])

