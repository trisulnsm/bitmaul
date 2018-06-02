DNP3_Function_Codes = 
{
   [5] = "DIRECT_OPERATE",
   [23] = "DELAY_MEASURE",
   [131] = "AUTHENTICATE_RESP",
   [8] = "IMMED_FREEZE_NR",
   [14] = "WARM_RESTART",
   [16] = "INITIALIZE_APPL",
   [3] = "SELECT",
   [25] = "OPEN_FILE",
   [4] = "OPERATE",
   [6] = "DIRECT_OPERATE_NR",
   [24] = "RECORD_CURRENT_TIME",
   [27] = "DELETE_FILE",
   [33] = "AUTHENTICATE_ERR",
   [7] = "IMMED_FREEZE",
   [15] = "INITIALIZE_DATA",
   [21] = "DISABLE_UNSOLICITED",
   [29] = "AUTHENTICATE_FILE",
   [30] = "ABORT_FILE",
   [0] = "CONFIRM",
   [17] = "START_APPL",
   [32] = "AUTHENTICATE_REQ",
   [19] = "SAVE_CONFIG",
   [11] = "FREEZE_AT_TIME",
   [12] = "FREEZE_AT_TIME_NR",
   [18] = "STOP_APPL",
   [20] = "ENABLE_UNSOLICITED",
   [22] = "ASSIGN_CLASS",
   [130] = "UNSOLICITED_RESPONSE",
   [13] = "COLD_RESTART",
   [28] = "GET_FILE_INFO",
   [26] = "CLOSE_FILE",
   [129] = "RESPONSE",
   [1] = "READ",
   [10] = "FREEZE_CLEAR_NR",
   [2] = "WRITE",
   [9] = "FREEZE_CLEAR",
   [31] = "ACTIVATE_CONFIG"
}

DNP_Group_Var_Bitlength  = {
	[1] = {
		[1] = 1,
		[2] = 8,
	},

	[2]= {
		[0]=0,
	},

	[10] = {
		[1] = 8,
		[2] = 8,
	},

	[20] = {
		[1] = 40,
		[2] = 24,
		[5] = 32,
		[6] = 16,

	},

	[21] = {
		[9]= 32,

	},

	[30] = {
		[3] = 32,

	}, 

	[52] = {
		[1]=16,
		[2]=16,

	},

	[60] = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
	}, 

	[80] = {
		[1] = 16,
	},

}


DNP3_RSC_Num_Objects_Functions = {

	-- 0 1-octet start and stop indexes.
	[0] = function(swbuf) 
		local start=swbuf:next_u8()
		local lend=swbuf:next_u8()
		return lend-start+1
	end,


	-- 1 2-octet start and stop indexes.
	[1] = function(swbuf) 
		local start=swbuf:next_u16()
		local lend=swbuf:next_u16()
		return lend-start+1
	end,

	-- 2 4-octet start and stop indexes.
	[2] = function(swbuf) 
		local start=swbuf:next_u32()
		local lend=swbuf:next_u32()
		return lend-start+1
	end,
	-- 3 1-octet start and stop virtual addresses.
	[3] = function(swbuf) 
		local start=swbuf:next_u8()
		local lend=swbuf:next_u8()
		return lend-start+1
	end,
	-- 4 2-octet start and stop virtual addresses.
	[4] = function(swbuf) 
		local start=swbuf:next_u8()
		local lend=swbuf:next_u8()
		return lend-start+1
	end,
	-- 5 4-octet start and stop virtual addresses.
	[5] = function(swbuf) 
		local start=swbuf:next_u8()
		local lend=swbuf:next_u8()
		return lend-start+1
	end,
	-- 6 No range field used. Implies all values.
	[6] = function(swbuf) 
		return 0 
	end,
	-- 7 1-octet count of objects.
	[7] = function(swbuf) 
		return swbuf:next_u8()  
	end,
	-- 8 2-octet count of objects.
	[8] = function(swbuf) 
		return swbuf:next_u16()  
	end,
	-- 9 4-octet count of objects.
	[9] = function(swbuf) 
		return swbuf:next_u32()  
	end,
}
