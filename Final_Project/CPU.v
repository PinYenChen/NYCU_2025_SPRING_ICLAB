//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf; //[3:0]
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf; //[31:0]
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf; //[2:0]
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf; //[1:0]
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf; //[6:0]
output  reg [WRIT_NUMBER-1:0]                awvalid_m_inf; //[0:0]
input   wire [WRIT_NUMBER-1:0]                awready_m_inf; //[0:0]
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf; //[15:0]
output  reg [WRIT_NUMBER-1:0]                  wlast_m_inf; //[0:0]
output  reg [WRIT_NUMBER-1:0]                 wvalid_m_inf; //[0:0]
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf; //[0:0]
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf; //[3:0]
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf; //[1:0]
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf; //[0:0]
output  reg [WRIT_NUMBER-1:0]                 bready_m_inf; //[0:0]
// -----------------------------
// axi read address channel 0: instruction DRAM, 1: data DRAM
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf; //[7:0]
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf; //[63:0]
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf; //[13:0]
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf; //[5:0]
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf; //[3:0]
output  reg [DRAM_NUMBER-1:0]               arvalid_m_inf; //[1:0]
input   wire [DRAM_NUMBER-1:0]               arready_m_inf; //[1:0]
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf; //[7:0]
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf; //[31:0]
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf; //[3:0]
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf; //[1:0]
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf; //[1:0]
output  reg [DRAM_NUMBER-1:0]                 rready_m_inf; //[1:0]
// -----------------------------
//            fixed
// -----------------------------
assign awsize_m_inf = 3'b001;
assign awburst_m_inf = 2'b01;
assign awlen_m_inf = 7'b0;
assign awid_m_inf = 4'b0;

assign arid_m_inf = 8'b0;
assign arsize_m_inf = 6'b001001;
assign arburst_m_inf = 4'b0101;
assign arlen_m_inf = 14'b11111111111111; //{7'b128,7'b128}
//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;

reg [7:0] sram_addr;
reg [15:0] sram_in, sram_out;
reg web;

FINAL_256X16 cache(.A0(sram_addr[0]), .A1(sram_addr[1]), .A2(sram_addr[2]), .A3(sram_addr[3]), .A4(sram_addr[4]), .A5(sram_addr[5]), .A6(sram_addr[6]), .A7(sram_addr[7]), 
			 .DO0(sram_out[0]), .DO1(sram_out[1]), .DO2(sram_out[2]), .DO3(sram_out[3]), .DO4(sram_out[4]), .DO5(sram_out[5]), .DO6(sram_out[6]), .DO7(sram_out[7]), .DO8(sram_out[8]), .DO9(sram_out[9]), .DO10(sram_out[10]), .DO11(sram_out[11]), .DO12(sram_out[12]), .DO13(sram_out[13]), .DO14(sram_out[14]), .DO15(sram_out[15]), 
             .DI0(sram_in[0]), .DI1(sram_in[1]), .DI2(sram_in[2]), .DI3(sram_in[3]), .DI4(sram_in[4]), .DI5(sram_in[5]), .DI6(sram_in[6]), .DI7(sram_in[7]), .DI8(sram_in[8]), .DI9(sram_in[9]), .DI10(sram_in[10]), .DI11(sram_in[11]), .DI12(sram_in[12]), .DI13(sram_in[13]), .DI14(sram_in[14]), .DI15(sram_in[15]), 
             .CK(clk), .WEB(web), .OE(1'b1), .CS(1'b1));
typedef enum reg[3:0]{INST_HANDSHAKE = 0, INST_READ = 1, DATA_HANDSHAKE = 2, DATA_READ = 3, IF = 4, EXE = 5, MEM = 6, WRITE_HANDSHAKE = 7, WRITE = 8, WRITE_FINISH = 9, NEED_INST = 10, WAIT = 11}state;
state cur_state, nxt_state;
reg [6:0] in_cnt;
reg cnt_2;
reg [1:0] wait_cnt;
reg [7:0] tmp[0:1];

reg [2:0] opcode;
reg execute_inst;

reg [10:0] program_cnt, program_cnt_ns;
reg [10:0] data_addr;
reg [3:0] rs,rt,rd;
reg signed [15:0] rs_data, rt_data, write_back_data, st_data;
reg func;
reg signed [4:0] imm;
reg [3:0] tag_inst, tag_data;

reg signed[15:0] aluin1, aluin2;
reg signed [31:0] mult_out;
reg signed [15:0] alu_result;

reg [15:0] sram_out_d;
reg [10:0] sram_data_addr;
reg load_cnt;

reg io_stall_reg;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
    	cur_state <= INST_HANDSHAKE;
  	end
  	else begin
  	  cur_state <= nxt_state;
  	end
end

reg need_inst;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin	
		need_inst <= 0;
	end
	else begin
		if(cur_state == NEED_INST) begin
			need_inst <= 1;
		end
		else if (!io_stall_reg) need_inst <= 0;
	end
end

always @(*) begin
  	nxt_state = cur_state;
  	case(cur_state)
		INST_HANDSHAKE: begin
            if (arready_m_inf[1]) begin
                nxt_state = INST_READ; 
            end			
		end
		INST_READ:begin
			if (&sram_addr) begin //sram_addr == 255
				nxt_state =  need_inst ? IF : DATA_HANDSHAKE; //nxt_state =  need_inst ? IF : DATA_HANDSHAKE;
			end
		end
		DATA_HANDSHAKE: begin
			if (arready_m_inf[0]) begin
				nxt_state = DATA_READ;
			end
		end
		DATA_READ: begin
			if (sram_addr == 127 && !execute_inst) begin
				nxt_state = IF;
			end
			else if (sram_addr == 127 && execute_inst) begin
				nxt_state = WAIT;
			end
		end
		WAIT :nxt_state = MEM;
		NEED_INST: nxt_state = INST_HANDSHAKE;
		IF: begin
			if (wait_cnt[1]) begin
				if (sram_out_d[15:13] == 'b101) begin
					if (sram_out_d[11:8] != tag_inst)
						nxt_state = NEED_INST;
					else begin
						nxt_state = IF;
					end
				end
				else nxt_state = EXE;
			end
			/*
			(tag_inst == program_cnt[10:7])? IF : INST_HANDSHAKE;
			
			if(tag_inst != program_cnt[10:7]) begin
				nxt_state = INST_HANDSHAKE;
			end
			else begin
				if (wait_cnt[1]) begin
					next_state = ;
				end
			end
			*/
		end
		EXE: begin
			if (cnt_2) begin
				if (opcode[1:0] == 'b10) nxt_state = (alu_result[10:7] == tag_data)? MEM : DATA_HANDSHAKE; //load
				
				else nxt_state = (tag_inst == program_cnt[10:7])? IF : NEED_INST; // mult
			end
			else begin
				if (opcode[1:0] == 0 || (opcode == 1 &&!func)) nxt_state = (tag_inst == program_cnt[10:7])? IF : NEED_INST; //add sub slt beq
				else if (opcode[1:0] == 'b11) nxt_state = WRITE_HANDSHAKE; //store
				//else nxt_state = (tag_inst == program_cnt[10:7])? IF : NEED_INST; // add sub slt mult beq
				//else nxt_state = IF;			
			end
		end
		MEM: begin
			if (load_cnt) begin
				nxt_state = (tag_inst == program_cnt[10:7])? IF : NEED_INST;
				//nxt_state = IF;
			end
		end
		WRITE_HANDSHAKE: begin
			if (awready_m_inf) begin
				nxt_state = WRITE;
			end
		end
		WRITE: begin
            if(wready_m_inf) begin
				nxt_state = WRITE_FINISH;
			end
		end
		WRITE_FINISH: begin
			if(bvalid_m_inf)begin
				if (program_cnt[10:7] != tag_inst)
					nxt_state = NEED_INST;
				else begin
					nxt_state = IF;
				end
			end			
		end
  	endcase
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		execute_inst <= 0;
	end
	else begin 
		if (cur_state == IF) begin
			execute_inst <= 1;
		end
		else if (cur_state == INST_HANDSHAKE) begin
			execute_inst <= 0;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_cnt <= 0;
	end
	else begin
		if ((cur_state == INST_READ && rvalid_m_inf[1] || cur_state == DATA_READ && rvalid_m_inf[0]) ) begin //&& cnt_2 == 1
			in_cnt <= in_cnt + 1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cnt_2 <= 0;
	end
	else begin
		if (cur_state == EXE && nxt_state != IF) begin
			cnt_2 <= cnt_2 + 1;
		end
		else begin
			cnt_2 <= 0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		load_cnt <= 0;
	end
	else begin
		if (cur_state == MEM) begin
			load_cnt <= load_cnt + 1;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wait_cnt <= 0;
	end
	else begin
		if (cur_state == IF ) begin
			wait_cnt <= (wait_cnt[1])? 0: wait_cnt + 1;
		end
	end
end
// -------------------------------------------
//                 DRAM Read
// -------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		arvalid_m_inf <= 0;
	end
	else begin
		if (nxt_state == INST_HANDSHAKE) begin
			arvalid_m_inf [1] <= 1;
			arvalid_m_inf [0] <= 0;
		end
		else if (nxt_state == DATA_HANDSHAKE) begin
			arvalid_m_inf [0] <= 1;
			arvalid_m_inf [1] <= 0;
		end
		else begin
			arvalid_m_inf <= 0;
		end
	end
end
assign araddr_m_inf = {19'b0, 1'b1, program_cnt[10:7], 8'b0, 19'b0, 1'b1, data_addr[10:7], 8'b0};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rready_m_inf <= 0;
    end
    else begin
        if (nxt_state == INST_READ) begin
            rready_m_inf[1] <= 1;
			rready_m_inf[0] <= 0;
        end
        else if (nxt_state == DATA_READ) begin
            rready_m_inf[0] <= 1;
			rready_m_inf[1] <= 0;
        end
		else begin
			rready_m_inf <= 0;
		end
    end
end
// -------------------------------------------
//                   SRAM 
// -------------------------------------------
always @(posedge clk or negedge rst_n) begin
	//web = 1; // read
	if (!rst_n) begin
		web <= 1;
	end
	else begin
		if ((cur_state == INST_READ && sram_addr < 255 || cur_state == DATA_READ && sram_addr < 127)) begin
			web <= 0; // write
		end
		else if (cur_state == WRITE) begin
			web <= 0;
		end		
		else begin
			web <= 1;
		end
	end

end

always @(posedge clk or negedge rst_n) begin
	//sram_addr = 0;
	if (!rst_n) begin
		sram_addr <= 0;
	end
	else begin
		if (cur_state == INST_READ && nxt_state != IF)begin
			sram_addr <= {1'b1, in_cnt};
		end
		else if (cur_state == DATA_READ && nxt_state != IF && nxt_state != WAIT) begin
			sram_addr <= {1'b0, in_cnt};
		end
		else if (nxt_state == IF) begin
			sram_addr <= {1'b1, program_cnt_ns[6:0]}; //
		end	
		else if((cur_state == EXE && opcode == 3'b010) || nxt_state == WRITE) begin
			sram_addr <= {1'b0, sram_data_addr[6:0]};
		end	
		else if (cur_state == NEED_INST) begin
			sram_addr <= 0;
		end
		else if (sram_addr == 127 && execute_inst && nxt_state == WAIT) begin
			sram_addr <= {1'b0, sram_data_addr[6:0]};
		end
	end

	/*
	else if (cur_state == WRITE) begin // load
		sram_addr = {1'b0, data_addr[6:0]};
	end
	*/

end

always @(posedge clk or negedge rst_n) begin
	//sram_in = 0;
	if (!rst_n) begin
		sram_in <= 0;
	end
	else begin
		if (cur_state == INST_READ && rvalid_m_inf[1]) begin
			sram_in <= rdata_m_inf[31:16];
		end
		else if (cur_state == DATA_READ && rvalid_m_inf[0]) begin
			sram_in <= rdata_m_inf[15:0];
		end
		else if (!web && nxt_state == WRITE) begin
			sram_in <= rt_data;
		end
	end
end

always @(posedge clk) begin
	sram_out_d <= sram_out;
end
// ----------------------------------
//              pc
// ----------------------------------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		data_addr = 0;
	end
	else begin
		if (opcode[1] && cur_state == EXE) begin
			data_addr = aluin1 + aluin2;
		end
	end
end
assign sram_data_addr = aluin1 + aluin2;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) 	
		program_cnt <= 11'b0;
	else begin
		program_cnt <= program_cnt_ns;
	end
end
always @(*) begin
	program_cnt_ns = program_cnt;
	if (cur_state == IF && sram_out_d[15:13] == 'b101 && wait_cnt[1]) program_cnt_ns = sram_out_d[11:1]; // jump
	else if(cur_state == IF && wait_cnt[1])begin
		if(rs_data == rt_data && sram_out_d[15:13] == 'b100) begin
			program_cnt_ns = $signed({1'b0, program_cnt}) + 1 + $signed (sram_out_d[4:0]);
		end
		else begin
			program_cnt_ns = program_cnt + 1;
		end
	end
end
always @(posedge clk) begin
	if (cur_state == IF && wait_cnt[1]) begin
		opcode <= sram_out_d[15:13];
	end
	else if (cur_state == INST_READ) begin
		opcode <= 0;
	end
end
always @(posedge clk) begin
	if (cur_state == IF && wait_cnt[1]) begin
		rs <= sram_out_d[12:9];
	end
end
always @(posedge clk) begin
	if (cur_state == IF && wait_cnt[1]) begin
		rt <= sram_out_d[8:5];
	end
end
always @(posedge clk) begin
	if (cur_state == IF && wait_cnt[1]) begin
		rd <= sram_out_d[4:1];
	end
end
always @(posedge clk) begin
	if (cur_state == IF && wait_cnt[1]) begin
		func <= sram_out_d[0];
	end
end
/*
always @(posedge clk) begin
	if (cur_state == IF && wait_cnt[1]) begin
		imm <= sram_out_d[4:0];
	end
end
*/
always@(posedge clk)begin
	if(cur_state == DATA_READ) begin
		tag_data <= data_addr[10:7];
	end
end

always@(posedge clk)begin
	if(cur_state == INST_READ) begin
		tag_inst <= program_cnt[10:7];
	end
end
// -------------------------------------------
//                   EXE
// -------------------------------------------
always @(posedge clk) begin
	if (wait_cnt[1] && cur_state == IF) begin
		aluin1 <= rs_data;
	end
end
always @(posedge clk) begin
	if (wait_cnt[1] && cur_state == IF) begin
		if (sram_out_d[14]) begin
			aluin2 <= $signed(sram_out_d[4:0]);
		end
		else  aluin2 <= rt_data;
	end
end
always @(posedge clk) begin
	if (cur_state == EXE) begin
		/*
		if (opcode == 'b000) begin
			alu_result <= (func)? (aluin1 - aluin2): (aluin1 + aluin2);
		end
		else 
		*/
		alu_result <= aluin1 + aluin2;
	end
end

DW02_mult_2_stage #(16, 16) mult_inst(.A(aluin1), .B(aluin2), .TC(1'b1), .CLK(clk), .PRODUCT(mult_out));

// -------------------------------------------
//       Write back operate in IF state
// -------------------------------------------
always@(*) begin
	write_back_data = 0;
	if (opcode == 'b000) begin
		write_back_data = (func)? (aluin1 - aluin2): (aluin1 + aluin2);
	end
	else if (opcode[0]) begin
		write_back_data = func? mult_out: ((aluin1 < aluin2)? 1:0);
	end
end
// -------------------------------------------
//                 OUTPUT
// -------------------------------------------
always @(*) begin
	io_stall_reg = 1;
	if (cur_state == EXE && nxt_state == IF) begin //(opcode[2:1] == 'd0 || opcode == 'b100) && // rtype branch
		io_stall_reg = 0;
	end
	else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
		io_stall_reg = 0;
	end
	else if (cur_state == WRITE_FINISH && nxt_state == IF) begin // store
		io_stall_reg = 0; 
	end
	else if (cur_state == IF && nxt_state == IF && sram_out_d[15:13] == 'b101 && wait_cnt[1]) begin
		io_stall_reg = 0;
	end
	else if (nxt_state == NEED_INST) begin
		io_stall_reg = 0;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		IO_stall <= 1;
	end
	else begin
		IO_stall <= io_stall_reg;
	end
	
	
end
// -------------------------------------------
//                 DRAM Write
// -------------------------------------------
always @(*) begin
	awvalid_m_inf = 0;
	if (cur_state == WRITE_HANDSHAKE) begin
		awvalid_m_inf = 1;
	end
end

assign awaddr_m_inf = {19'b0, 1'b1, data_addr, 1'b0};

always @(*) begin
	bready_m_inf = 0;
	wvalid_m_inf = 0;
	if (cur_state == WRITE) begin
		wvalid_m_inf = 1;
		bready_m_inf = 1;
	end 
	else if (cur_state == WRITE_FINISH)begin
		bready_m_inf = 1;
	end
end

assign wdata_m_inf = st_data;

always @(*) begin
	wlast_m_inf = 0;
	if (cur_state == WRITE) begin //write 1 signal
		wlast_m_inf = 1;
	end
end
//--------------------------------------------
//                   core
// -------------------------------------------

/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r0  <= 0;
        core_r1  <= 0;
        core_r2  <= 0;
        core_r3  <= 0;
        core_r4  <= 0;
        core_r5  <= 0;
        core_r6  <= 0;
        core_r7  <= 0;
        core_r8  <= 0;
        core_r9  <= 0;
        core_r10 <= 0;
        core_r11 <= 0;
        core_r12 <= 0;
        core_r13 <= 0;
        core_r14 <= 0;
        core_r15 <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd0 : core_r0  <=  write_back_data;
    	        'd1 : core_r1  <=  write_back_data;
    	        'd2 : core_r2  <=  write_back_data;
    	        'd3 : core_r3  <=  write_back_data;
    	        'd4 : core_r4  <=  write_back_data;
    	        'd5 : core_r5  <=  write_back_data;
    	        'd6 : core_r6  <=  write_back_data;
    	        'd7 : core_r7  <=  write_back_data;
    	        'd8 : core_r8  <=  write_back_data;
    	        'd9 : core_r9  <=  write_back_data;
    	        'd10: core_r10  <= write_back_data;
    	        'd11: core_r11  <= write_back_data;
    	        'd12: core_r12  <= write_back_data;
    	        'd13: core_r13  <= write_back_data;
    	        'd14: core_r14  <= write_back_data;
    	        'd15: core_r15  <= write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd0 : core_r0  <=  write_back_data;
    	        'd1 : core_r1  <=  write_back_data;
    	        'd2 : core_r2  <=  write_back_data;
    	        'd3 : core_r3  <=  write_back_data;
    	        'd4 : core_r4  <=  write_back_data;
    	        'd5 : core_r5  <=  write_back_data;
    	        'd6 : core_r6  <=  write_back_data;
    	        'd7 : core_r7  <=  write_back_data;
    	        'd8 : core_r8  <=  write_back_data;
    	        'd9 : core_r9  <=  write_back_data;
    	        'd10: core_r10  <= write_back_data;
    	        'd11: core_r11  <= write_back_data;
    	        'd12: core_r12  <= write_back_data;
    	        'd13: core_r13  <= write_back_data;
    	        'd14: core_r14  <= write_back_data;
    	        'd15: core_r15  <= write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd0:  core_r0  <= sram_out_d; 
				'd1:  core_r1  <= sram_out_d;
				'd2:  core_r2  <= sram_out_d;
				'd3:  core_r3  <= sram_out_d;
				'd4:  core_r4  <= sram_out_d;
				'd5:  core_r5  <= sram_out_d;
				'd6:  core_r6  <= sram_out_d;
				'd7:  core_r7  <= sram_out_d;
				'd8:  core_r8  <= sram_out_d;
				'd9:  core_r9  <= sram_out_d;
				'd10: core_r10 <= sram_out_d;
				'd11: core_r11 <= sram_out_d;
				'd12: core_r12 <= sram_out_d;
				'd13: core_r13 <= sram_out_d;
				'd14: core_r14 <= sram_out_d;
				'd15: core_r15 <= sram_out_d;
			endcase	
		end
	end
end
*/
// the above version cause synthesis error(core_r15 == > z)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r0  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd0 : core_r0  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd0 : core_r0  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd0:  core_r0  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r1  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd1 : core_r1  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd1 : core_r1  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd1:  core_r1  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r2  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd2 : core_r2  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd2 : core_r2  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd2:  core_r2  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r3  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd3 : core_r3  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd3 : core_r3  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd3:  core_r3  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r4  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd4 : core_r4  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd4 : core_r4  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd4:  core_r4  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r5  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd5 : core_r5  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd5 : core_r5  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd5:  core_r5  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r6  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd6 : core_r6  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd6 : core_r6  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd6:  core_r6  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r7  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd7 : core_r7  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd7 : core_r7  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd7:  core_r7  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r8  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd8 : core_r8  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd8 : core_r8  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd8:  core_r8  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r9  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd9: core_r9  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd9 : core_r9  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd9:  core_r9  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r10  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd10: core_r10  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd10 : core_r10  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd10:  core_r10  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r11  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd11: core_r11  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd11 : core_r11  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd11:  core_r11  <= sram_out_d; 
			endcase	
		end
	end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r12  <= 0;
		core_r13  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd12: core_r12  <=  write_back_data;
				'd13: core_r13  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd12 : core_r12  <=  write_back_data;
				'd13 : core_r13  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd12:  core_r12  <= sram_out_d; 
				'd13:  core_r13  <= sram_out_d;

			endcase	
		end
	end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r13  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        'd13: core_r13  <=  write_back_data;
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        'd13 : core_r13  <=  write_back_data;
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd13:  core_r13  <= sram_out_d; 
			endcase	
		end
	end
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r14  <= 0;
		core_r15  <= 0;
    end
	else begin
		if (cur_state == EXE) begin
			if (opcode == 1 && func && cnt_2) begin // mult
				//i <= 1;
				case(rd)
    		        'd14: core_r14  <=  write_back_data;
					'd15: core_r15  <=  write_back_data;
				endcase
			end
			else if (opcode[2:1] == 0 && !cnt_2) begin // add sub slt
				case(rd)
    		        'd14 : core_r14  <=  write_back_data;
					'd15 : core_r15  <=  write_back_data;
				endcase			
			end
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				'd14:  core_r14  <= sram_out_d; 
				'd15:  core_r15  <= sram_out_d; 
			endcase	
		end
	end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r15  <= 0;
    end
	else begin
		if (opcode == 1 && func && cur_state == EXE && cnt_2) begin // mult
			//i <= 1;
			case(rd)
    	        
			endcase
		end
		else if (opcode[2:1] == 0 && cur_state == EXE && !cnt_2) begin // add sub slt
			case(rd)
    	        
			endcase			
		end
		else if (opcode[1:0] == 'b10 && cur_state == MEM && load_cnt) begin // load
			//i <= 0;
			case(rt)
				
			endcase	
		end
	end
end
*/
always@(*) begin
    case (rs)
        'd0 : rs_data = core_r0;
        'd1 : rs_data = core_r1;
        'd2 : rs_data = core_r2;
        'd3 : rs_data = core_r3;
        'd4 : rs_data = core_r4;
        'd5 : rs_data = core_r5;
        'd6 : rs_data = core_r6;
        'd7 : rs_data = core_r7;
        'd8 : rs_data = core_r8;
        'd9 : rs_data = core_r9;
        'd10: rs_data = core_r10;
        'd11: rs_data = core_r11;
        'd12: rs_data = core_r12;
        'd13: rs_data = core_r13;
        'd14: rs_data = core_r14;
        'd15: rs_data = core_r15;
    endcase
    if(cur_state == IF) begin
        case (sram_out_d[12:9]) 
            'd0 : rs_data = core_r0;
            'd1 : rs_data = core_r1;
            'd2 : rs_data = core_r2;
            'd3 : rs_data = core_r3;
            'd4 : rs_data = core_r4;
            'd5 : rs_data = core_r5;
            'd6 : rs_data = core_r6;
            'd7 : rs_data = core_r7;
            'd8 : rs_data = core_r8;
            'd9 : rs_data = core_r9;
            'd10: rs_data = core_r10;
            'd11: rs_data = core_r11;
            'd12: rs_data = core_r12;
            'd13: rs_data = core_r13;
            'd14: rs_data = core_r14;
            'd15: rs_data = core_r15;
        endcase
    end
end
always@(*) begin
    case (rt)
        'd0 : rt_data = core_r0;
        'd1 : rt_data = core_r1;
        'd2 : rt_data = core_r2;
        'd3 : rt_data = core_r3;
        'd4 : rt_data = core_r4;
        'd5 : rt_data = core_r5;
        'd6 : rt_data = core_r6;
        'd7 : rt_data = core_r7;
        'd8 : rt_data = core_r8;
        'd9 : rt_data = core_r9;
        'd10: rt_data = core_r10;
        'd11: rt_data = core_r11;
        'd12: rt_data = core_r12;
        'd13: rt_data = core_r13;
        'd14: rt_data = core_r14;
        'd15: rt_data = core_r15;
    endcase
    if(cur_state == IF) begin
        case (sram_out_d[8:5]) 
            'd0 : rt_data = core_r0;
            'd1 : rt_data = core_r1;
            'd2 : rt_data = core_r2;
            'd3 : rt_data = core_r3;
            'd4 : rt_data = core_r4;
            'd5 : rt_data = core_r5;
            'd6 : rt_data = core_r6;
            'd7 : rt_data = core_r7;
            'd8 : rt_data = core_r8;
            'd9 : rt_data = core_r9;
            'd10: rt_data = core_r10;
            'd11: rt_data = core_r11;
            'd12: rt_data = core_r12;
            'd13: rt_data = core_r13;
            'd14: rt_data = core_r14;
            'd15: rt_data = core_r15;
        endcase
    end
end
always@(posedge clk) begin
    case (rt)
        'd0 : st_data <= core_r0;
        'd1 : st_data <= core_r1;
        'd2 : st_data <= core_r2;
        'd3 : st_data <= core_r3;
        'd4 : st_data <= core_r4;
        'd5 : st_data <= core_r5;
        'd6 : st_data <= core_r6;
        'd7 : st_data <= core_r7;
        'd8 : st_data <= core_r8;
        'd9 : st_data <= core_r9;
        'd10: st_data <= core_r10;
        'd11: st_data <= core_r11;
        'd12: st_data <= core_r12;
        'd13: st_data <= core_r13;
        'd14: st_data <= core_r14;
        'd15: st_data <= core_r15;
    endcase
end
endmodule



















