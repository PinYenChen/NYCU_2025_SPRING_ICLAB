//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Midterm Proejct            : MRA  
//   Author                     : Lin-Hung, Lai
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : MRA.v
//   Module Name : MRA
//   Release version : V2.0 (Release Date: 2023-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module MRA(
	// CHIP IO
	clk            	,	
	rst_n          	,	
	in_valid       	,	
	frame_id        ,	
	net_id         	,	  
	loc_x          	,	  
    loc_y         	,
	cost	 		,		
	busy         	,

    // AXI4 IO
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
	   rready_m_inf,
	
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
	   bready_m_inf 
);

// ===============================================================
//  					Input / Output 
// ===============================================================

// << CHIP io port with system >>
input 			  	clk,rst_n;
input 			   	in_valid;
input  [4:0] 		frame_id;
input  [3:0]       	net_id;     
input  [5:0]       	loc_x; 
input  [5:0]       	loc_y; 
output reg [13:0] 	cost;
output reg          busy;       
  
// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       Your AXI-4 interface could be designed as a bridge in submodule,
	   therefore I declared output of AXI as wire.  
	   Ex: AXI4_interface AXI4_INF(...);
*/
parameter ID_WIDTH = 4, ADDR_WIDTH = 32, DATA_WIDTH = 128; 
// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)	axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire[1:0]             arburst_m_inf;
output wire[2:0]              arsize_m_inf;
output wire[7:0]               arlen_m_inf;
output reg                   arvalid_m_inf;
input  wire                  arready_m_inf;
output reg  [ADDR_WIDTH-1:0]  araddr_m_inf;
// ------------------------
// (2)	axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output reg                    rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1) 	axi write address channel 
output wire[ID_WIDTH-1:0]       awid_m_inf;
output wire[1:0]             awburst_m_inf;
output wire[2:0]              awsize_m_inf;
output wire[7:0]               awlen_m_inf;
output reg                   awvalid_m_inf;
input  wire                  awready_m_inf;
output reg  [ADDR_WIDTH-1:0]  awaddr_m_inf;
// -------------------------
// (2)	axi write data channel 
output reg                    wvalid_m_inf;
input  wire                   wready_m_inf;
output reg [DATA_WIDTH-1:0]    wdata_m_inf;
output reg                     wlast_m_inf;
// -------------------------
// (3)	axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output reg                    bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------
reg map_web;
reg weight_web;
//reg [127:0]m_ns, w_ns, m,w ;
reg [127:0] map_out, map_in, weight_out, weight_in;
reg[6:0] map_addr, weight_addr;
// SRAM_map
MIDTERM_128 Map( .A0(map_addr[0]), .A1(map_addr[1]), .A2(map_addr[2]), .A3(map_addr[3]), .A4(map_addr[4]), .A5(map_addr[5]), .A6(map_addr[6]), 
						.DO0(map_out[0]), .DO1(map_out[1]), .DO2(map_out[2]), .DO3(map_out[3]), .DO4(map_out[4]), .DO5(map_out[5]), .DO6(map_out[6]), .DO7(map_out[7]), .DO8(map_out[8]), .DO9(map_out[9]), .DO10(map_out[10]), .DO11(map_out[11]), .DO12(map_out[12]), .DO13(map_out[13]), .DO14(map_out[14]), .DO15(map_out[15]), .DO16(map_out[16]), .DO17(map_out[17]), .DO18(map_out[18]), .DO19(map_out[19]), .DO20(map_out[20]), .DO21(map_out[21]), .DO22(map_out[22]), .DO23(map_out[23]), .DO24(map_out[24]), .DO25(map_out[25]), .DO26(map_out[26]), .DO27(map_out[27]), .DO28(map_out[28]), .DO29(map_out[29]), .DO30(map_out[30]), .DO31(map_out[31]), .DO32(map_out[32]), .DO33(map_out[33]), .DO34(map_out[34]), .DO35(map_out[35]), .DO36(map_out[36]), .DO37(map_out[37]), .DO38(map_out[38]), .DO39(map_out[39]), .DO40(map_out[40]), .DO41(map_out[41]), .DO42(map_out[42]), .DO43(map_out[43]), .DO44(map_out[44]), .DO45(map_out[45]), .DO46(map_out[46]), .DO47(map_out[47]), .DO48(map_out[48]), .DO49(map_out[49]), .DO50(map_out[50]), .DO51(map_out[51]), .DO52(map_out[52]), .DO53(map_out[53]), .DO54(map_out[54]), .DO55(map_out[55]), .DO56(map_out[56]), .DO57(map_out[57]), .DO58(map_out[58]), .DO59(map_out[59]), .DO60(map_out[60]), .DO61(map_out[61]), .DO62(map_out[62]), .DO63(map_out[63]), .DO64(map_out[64]), .DO65(map_out[65]), .DO66(map_out[66]), .DO67(map_out[67]), .DO68(map_out[68]), .DO69(map_out[69]), .DO70(map_out[70]), .DO71(map_out[71]), .DO72(map_out[72]), .DO73(map_out[73]), .DO74(map_out[74]), .DO75(map_out[75]), .DO76(map_out[76]), .DO77(map_out[77]), .DO78(map_out[78]), .DO79(map_out[79]), .DO80(map_out[80]), .DO81(map_out[81]), .DO82(map_out[82]), .DO83(map_out[83]), .DO84(map_out[84]), .DO85(map_out[85]), .DO86(map_out[86]), .DO87(map_out[87]), .DO88(map_out[88]), .DO89(map_out[89]), .DO90(map_out[90]), .DO91(map_out[91]), .DO92(map_out[92]), .DO93(map_out[93]), .DO94(map_out[94]), .DO95(map_out[95]), .DO96(map_out[96]), .DO97(map_out[97]), .DO98(map_out[98]), .DO99(map_out[99]), .DO100(map_out[100]), .DO101(map_out[101]), .DO102(map_out[102]), .DO103(map_out[103]), .DO104(map_out[104]), .DO105(map_out[105]), .DO106(map_out[106]), .DO107(map_out[107]), .DO108(map_out[108]), .DO109(map_out[109]), .DO110(map_out[110]), .DO111(map_out[111]), .DO112(map_out[112]), .DO113(map_out[113]), .DO114(map_out[114]), .DO115(map_out[115]), .DO116(map_out[116]), .DO117(map_out[117]), .DO118(map_out[118]), .DO119(map_out[119]), .DO120(map_out[120]), .DO121(map_out[121]), .DO122(map_out[122]), .DO123(map_out[123]), .DO124(map_out[124]), .DO125(map_out[125]), .DO126(map_out[126]), .DO127(map_out[127]), 
						.DI0(map_in[0]), .DI1(map_in[1]), .DI2(map_in[2]), .DI3(map_in[3]), .DI4(map_in[4]), .DI5(map_in[5]), .DI6(map_in[6]), .DI7(map_in[7]), .DI8(map_in[8]), .DI9(map_in[9]), .DI10(map_in[10]), .DI11(map_in[11]), .DI12(map_in[12]), .DI13(map_in[13]), .DI14(map_in[14]), .DI15(map_in[15]), .DI16(map_in[16]), .DI17(map_in[17]), .DI18(map_in[18]), .DI19(map_in[19]), .DI20(map_in[20]), .DI21(map_in[21]), .DI22(map_in[22]), .DI23(map_in[23]), .DI24(map_in[24]), .DI25(map_in[25]), .DI26(map_in[26]), .DI27(map_in[27]), .DI28(map_in[28]), .DI29(map_in[29]), .DI30(map_in[30]), .DI31(map_in[31]), .DI32(map_in[32]), .DI33(map_in[33]), .DI34(map_in[34]), .DI35(map_in[35]), .DI36(map_in[36]), .DI37(map_in[37]), .DI38(map_in[38]), .DI39(map_in[39]), .DI40(map_in[40]), .DI41(map_in[41]), .DI42(map_in[42]), .DI43(map_in[43]), .DI44(map_in[44]), .DI45(map_in[45]), .DI46(map_in[46]), .DI47(map_in[47]), .DI48(map_in[48]), .DI49(map_in[49]), .DI50(map_in[50]), .DI51(map_in[51]), .DI52(map_in[52]), .DI53(map_in[53]), .DI54(map_in[54]), .DI55(map_in[55]), .DI56(map_in[56]), .DI57(map_in[57]), .DI58(map_in[58]), .DI59(map_in[59]), .DI60(map_in[60]), .DI61(map_in[61]), .DI62(map_in[62]), .DI63(map_in[63]), .DI64(map_in[64]), .DI65(map_in[65]), .DI66(map_in[66]), .DI67(map_in[67]), .DI68(map_in[68]), .DI69(map_in[69]), .DI70(map_in[70]), .DI71(map_in[71]), .DI72(map_in[72]), .DI73(map_in[73]), .DI74(map_in[74]), .DI75(map_in[75]), .DI76(map_in[76]), .DI77(map_in[77]), .DI78(map_in[78]), .DI79(map_in[79]), .DI80(map_in[80]), .DI81(map_in[81]), .DI82(map_in[82]), .DI83(map_in[83]), .DI84(map_in[84]), .DI85(map_in[85]), .DI86(map_in[86]), .DI87(map_in[87]), .DI88(map_in[88]), .DI89(map_in[89]), .DI90(map_in[90]), .DI91(map_in[91]), .DI92(map_in[92]), .DI93(map_in[93]), .DI94(map_in[94]), .DI95(map_in[95]), .DI96(map_in[96]), .DI97(map_in[97]), .DI98(map_in[98]), .DI99(map_in[99]), .DI100(map_in[100]), .DI101(map_in[101]), .DI102(map_in[102]), .DI103(map_in[103]), .DI104(map_in[104]), .DI105(map_in[105]), .DI106(map_in[106]), .DI107(map_in[107]), .DI108(map_in[108]), .DI109(map_in[109]), .DI110(map_in[110]), .DI111(map_in[111]), .DI112(map_in[112]), .DI113(map_in[113]), .DI114(map_in[114]), .DI115(map_in[115]), .DI116(map_in[116]), .DI117(map_in[117]), .DI118(map_in[118]), .DI119(map_in[119]), .DI120(map_in[120]), .DI121(map_in[121]), .DI122(map_in[122]), .DI123(map_in[123]), .DI124(map_in[124]), .DI125(map_in[125]), .DI126(map_in[126]), .DI127(map_in[127]), 
						.CK(clk), .WEB(map_web), .OE(1'b1), .CS(1'b1));

// SRAM_weight
MIDTERM_128 Weight(	.A0(weight_addr[0]), .A1(weight_addr[1]), .A2(weight_addr[2]), .A3(weight_addr[3]), .A4(weight_addr[4]), .A5(weight_addr[5]), .A6(weight_addr[6]), 
						.DO0(weight_out[0]), .DO1(weight_out[1]), .DO2(weight_out[2]), .DO3(weight_out[3]), .DO4(weight_out[4]), .DO5(weight_out[5]), .DO6(weight_out[6]), .DO7(weight_out[7]), .DO8(weight_out[8]), .DO9(weight_out[9]), .DO10(weight_out[10]), .DO11(weight_out[11]), .DO12(weight_out[12]), .DO13(weight_out[13]), .DO14(weight_out[14]), .DO15(weight_out[15]), .DO16(weight_out[16]), .DO17(weight_out[17]), .DO18(weight_out[18]), .DO19(weight_out[19]), .DO20(weight_out[20]), .DO21(weight_out[21]), .DO22(weight_out[22]), .DO23(weight_out[23]), .DO24(weight_out[24]), .DO25(weight_out[25]), .DO26(weight_out[26]), .DO27(weight_out[27]), .DO28(weight_out[28]), .DO29(weight_out[29]), .DO30(weight_out[30]), .DO31(weight_out[31]), .DO32(weight_out[32]), .DO33(weight_out[33]), .DO34(weight_out[34]), .DO35(weight_out[35]), .DO36(weight_out[36]), .DO37(weight_out[37]), .DO38(weight_out[38]), .DO39(weight_out[39]), .DO40(weight_out[40]), .DO41(weight_out[41]), .DO42(weight_out[42]), .DO43(weight_out[43]), .DO44(weight_out[44]), .DO45(weight_out[45]), .DO46(weight_out[46]), .DO47(weight_out[47]), .DO48(weight_out[48]), .DO49(weight_out[49]), .DO50(weight_out[50]), .DO51(weight_out[51]), .DO52(weight_out[52]), .DO53(weight_out[53]), .DO54(weight_out[54]), .DO55(weight_out[55]), .DO56(weight_out[56]), .DO57(weight_out[57]), .DO58(weight_out[58]), .DO59(weight_out[59]), .DO60(weight_out[60]), .DO61(weight_out[61]), .DO62(weight_out[62]), .DO63(weight_out[63]), .DO64(weight_out[64]), .DO65(weight_out[65]), .DO66(weight_out[66]), .DO67(weight_out[67]), .DO68(weight_out[68]), .DO69(weight_out[69]), .DO70(weight_out[70]), .DO71(weight_out[71]), .DO72(weight_out[72]), .DO73(weight_out[73]), .DO74(weight_out[74]), .DO75(weight_out[75]), .DO76(weight_out[76]), .DO77(weight_out[77]), .DO78(weight_out[78]), .DO79(weight_out[79]), .DO80(weight_out[80]), .DO81(weight_out[81]), .DO82(weight_out[82]), .DO83(weight_out[83]), .DO84(weight_out[84]), .DO85(weight_out[85]), .DO86(weight_out[86]), .DO87(weight_out[87]), .DO88(weight_out[88]), .DO89(weight_out[89]), .DO90(weight_out[90]), .DO91(weight_out[91]), .DO92(weight_out[92]), .DO93(weight_out[93]), .DO94(weight_out[94]), .DO95(weight_out[95]), .DO96(weight_out[96]), .DO97(weight_out[97]), .DO98(weight_out[98]), .DO99(weight_out[99]), .DO100(weight_out[100]), .DO101(weight_out[101]), .DO102(weight_out[102]), .DO103(weight_out[103]), .DO104(weight_out[104]), .DO105(weight_out[105]), .DO106(weight_out[106]), .DO107(weight_out[107]), .DO108(weight_out[108]), .DO109(weight_out[109]), .DO110(weight_out[110]), .DO111(weight_out[111]), .DO112(weight_out[112]), .DO113(weight_out[113]), .DO114(weight_out[114]), .DO115(weight_out[115]), .DO116(weight_out[116]), .DO117(weight_out[117]), .DO118(weight_out[118]), .DO119(weight_out[119]), .DO120(weight_out[120]), .DO121(weight_out[121]), .DO122(weight_out[122]), .DO123(weight_out[123]), .DO124(weight_out[124]), .DO125(weight_out[125]), .DO126(weight_out[126]), .DO127(weight_out[127]), 
						.DI0(weight_in[0]), .DI1(weight_in[1]), .DI2(weight_in[2]), .DI3(weight_in[3]), .DI4(weight_in[4]), .DI5(weight_in[5]), .DI6(weight_in[6]), .DI7(weight_in[7]), .DI8(weight_in[8]), .DI9(weight_in[9]), .DI10(weight_in[10]), .DI11(weight_in[11]), .DI12(weight_in[12]), .DI13(weight_in[13]), .DI14(weight_in[14]), .DI15(weight_in[15]), .DI16(weight_in[16]), .DI17(weight_in[17]), .DI18(weight_in[18]), .DI19(weight_in[19]), .DI20(weight_in[20]), .DI21(weight_in[21]), .DI22(weight_in[22]), .DI23(weight_in[23]), .DI24(weight_in[24]), .DI25(weight_in[25]), .DI26(weight_in[26]), .DI27(weight_in[27]), .DI28(weight_in[28]), .DI29(weight_in[29]), .DI30(weight_in[30]), .DI31(weight_in[31]), .DI32(weight_in[32]), .DI33(weight_in[33]), .DI34(weight_in[34]), .DI35(weight_in[35]), .DI36(weight_in[36]), .DI37(weight_in[37]), .DI38(weight_in[38]), .DI39(weight_in[39]), .DI40(weight_in[40]), .DI41(weight_in[41]), .DI42(weight_in[42]), .DI43(weight_in[43]), .DI44(weight_in[44]), .DI45(weight_in[45]), .DI46(weight_in[46]), .DI47(weight_in[47]), .DI48(weight_in[48]), .DI49(weight_in[49]), .DI50(weight_in[50]), .DI51(weight_in[51]), .DI52(weight_in[52]), .DI53(weight_in[53]), .DI54(weight_in[54]), .DI55(weight_in[55]), .DI56(weight_in[56]), .DI57(weight_in[57]), .DI58(weight_in[58]), .DI59(weight_in[59]), .DI60(weight_in[60]), .DI61(weight_in[61]), .DI62(weight_in[62]), .DI63(weight_in[63]), .DI64(weight_in[64]), .DI65(weight_in[65]), .DI66(weight_in[66]), .DI67(weight_in[67]), .DI68(weight_in[68]), .DI69(weight_in[69]), .DI70(weight_in[70]), .DI71(weight_in[71]), .DI72(weight_in[72]), .DI73(weight_in[73]), .DI74(weight_in[74]), .DI75(weight_in[75]), .DI76(weight_in[76]), .DI77(weight_in[77]), .DI78(weight_in[78]), .DI79(weight_in[79]), .DI80(weight_in[80]), .DI81(weight_in[81]), .DI82(weight_in[82]), .DI83(weight_in[83]), .DI84(weight_in[84]), .DI85(weight_in[85]), .DI86(weight_in[86]), .DI87(weight_in[87]), .DI88(weight_in[88]), .DI89(weight_in[89]), .DI90(weight_in[90]), .DI91(weight_in[91]), .DI92(weight_in[92]), .DI93(weight_in[93]), .DI94(weight_in[94]), .DI95(weight_in[95]), .DI96(weight_in[96]), .DI97(weight_in[97]), .DI98(weight_in[98]), .DI99(weight_in[99]), .DI100(weight_in[100]), .DI101(weight_in[101]), .DI102(weight_in[102]), .DI103(weight_in[103]), .DI104(weight_in[104]), .DI105(weight_in[105]), .DI106(weight_in[106]), .DI107(weight_in[107]), .DI108(weight_in[108]), .DI109(weight_in[109]), .DI110(weight_in[110]), .DI111(weight_in[111]), .DI112(weight_in[112]), .DI113(weight_in[113]), .DI114(weight_in[114]), .DI115(weight_in[115]), .DI116(weight_in[116]), .DI117(weight_in[117]), .DI118(weight_in[118]), .DI119(weight_in[119]), .DI120(weight_in[120]), .DI121(weight_in[121]), .DI122(weight_in[122]), .DI123(weight_in[123]), .DI124(weight_in[124]), .DI125(weight_in[125]), .DI126(weight_in[126]), .DI127(weight_in[127]), 
						.CK(clk), .WEB(weight_web), .OE(1'b1), .CS(1'b1));


// ------------------------------------
//            State Control
// ------------------------------------
typedef enum reg[3:0] {
    IDLE             = 4'd0,
    //INPUT            = 4'd1,
    HAND_MAP         = 4'd1,
    DRAM_SRAM_MAP    = 4'd2,
    HAND_WEIGHT      = 4'd3,
    DRAM_SRAM_WEIGHT = 4'd4,
    FILL             = 4'd5,
    TRACE_BEGIN      = 4'd6,
    TRACE            = 4'd7,
	CLEAN            = 4'd8,
    HAND_WRITEB      = 4'd9,
    WRITEB           = 4'd10,
    END_WRITE        = 4'd11
    //OUT              = 4'd15
} state;
state cur_state, nxt_state;
// ------------------------------------
//            Reg Declaration
// ------------------------------------
integer i,j;
reg [6:0] dram_r_cnt, dram_r_cnt_ns;
reg [3:0] net_id_reg[0:14], net_id_reg_ns[0:14];
reg [5:0] locx_reg[0:29], locy_reg[0:29], locx_reg_ns[0:29], locy_reg_ns[0:29];
reg [4:0] frame_id_reg, frame_id_reg_ns;
reg [1:0] map_reg[0:63][0:63], map_reg_ns[0:63][0:63];
reg [5:0] tracex,tracey;
reg [5:0] tracex_ns, tracey_ns;
reg [13:0] cost_reg, cost_reg_ns;

// ------------------------------------
//           counter
// ------------------------------------
reg [4:0] in_cnt, in_cnt_ns;
reg [1:0] wave_cnt, wave_cnt_ns;
//reg wait_cnt, wait_cnt_ns;
// ------------------------------------
//           Sequential Reset
// ------------------------------------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cur_state <= IDLE;
	end
	else begin
		cur_state <= nxt_state;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_cnt <= 0;
	end
	else begin
		in_cnt <= in_cnt_ns;
	end
end
/*
always @(posedge clk or negedge rst_n) begin
	
	if (!rst_n) begin
		tracex <= 0;
		tracey <= 0;
	end
	
	else begin
		tracex <= tracex_ns;
		tracey <= tracey_ns;
	end
end
*/
/*
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wave_cnt <= 0;
	end
	else begin
		wave_cnt <= wave_cnt_ns;
	end
end
*/

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		frame_id_reg <= 0;
	end
	else begin
		frame_id_reg <= frame_id_reg_ns;
	end
end
/*
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		dram_r_cnt <= 0; 
	end
	else begin
		dram_r_cnt <= dram_r_cnt_ns;
	end
end
*/
always @(posedge clk or negedge rst_n) begin
	
	if (!rst_n) begin
		for (i = 0; i < 15; i++) begin
			net_id_reg[i] <= 0;
		end
		for (i = 0; i < 30; i++) begin
			locx_reg[i] <= 0;
			locy_reg[i] <= 0;
		end
	end
	
	else begin
		for (i = 0; i < 15; i++) begin
			net_id_reg[i] <= net_id_reg_ns[i];
		end
		for (i = 0; i < 30; i++) begin
			locx_reg[i] <= locx_reg_ns[i];
			locy_reg[i] <= locy_reg_ns[i];
		end
	end
end
/*
always @(posedge clk or rst_n) begin
	
	if (!rst_n) begin
		for (i = 0; i < 64; i++) begin
			for (j = 0; j < 64; j++) begin
				map_reg[i][j] <= 0;
			end
		end

	end
	
	else begin
		for (i = 0; i < 64; i++) begin
			for (j = 0; j < 64; j++) begin
				map_reg[i][j] <= map_reg_ns[i][j];
			end
		end
	end
end
*/
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cost <= 0;
	end
	else begin
		cost <= cost_reg;
	end
end 
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cost_reg <= 0;
	end
	else begin
		cost_reg <= cost_reg_ns;
	end
end
// ------------------------------------
//           State Control
// ------------------------------------
always @(*) begin
	nxt_state = cur_state;
	case(cur_state) 
		IDLE: begin
			if (in_valid) begin
				nxt_state = HAND_MAP;
			end
			else begin
				nxt_state = IDLE;
			end
		end
		/*
		INPUT: begin
			if (!in_valid && in_cnt != 0) begin
				nxt_state = HAND_MAP;
			end
			else begin
				nxt_state = cur_state;
			end
		end
		*/
		HAND_MAP: begin
			if (arready_m_inf) begin
				nxt_state = DRAM_SRAM_MAP;
			end
			else begin
				nxt_state = cur_state;
			end
		end
		DRAM_SRAM_MAP: begin
			if (&dram_r_cnt) begin
				nxt_state = HAND_WEIGHT;
			end
			else begin
				nxt_state = cur_state;
			end	
		end
		HAND_WEIGHT: begin
			if (arready_m_inf) begin
				nxt_state = DRAM_SRAM_WEIGHT;
			end
			else begin
				nxt_state = cur_state;
			end
		end
		DRAM_SRAM_WEIGHT: begin
			if (&dram_r_cnt) begin
				nxt_state = FILL;
			end
			else begin
				nxt_state = cur_state;
			end	
		end
		FILL: begin
			if (map_reg[locy_reg[1]][locx_reg[1]][1] == 1) begin // sink originally 0, change to 2 or 3, means that fill is ending
				nxt_state = TRACE_BEGIN;
			end
			else begin
				nxt_state = cur_state;
			end
		end
		TRACE_BEGIN: begin
			/*
			if (wait_cnt == 1) begin
			*/
			nxt_state = TRACE;
			/*
			end
			else begin
				nxt_state = TRACE_BEGIN;
			end
			*/
		end
		
		TRACE: begin
			if (tracex != locx_reg[0] || tracey != locy_reg[0]) begin
				nxt_state = TRACE_BEGIN;
			end
			else if ((tracex == locx_reg[0] && tracey == locy_reg[0])&& (net_id_reg[1] != 0)) begin
				nxt_state = CLEAN;
			end
			else if ((tracex == locx_reg[0] && tracey == locy_reg[0])&& (net_id_reg[1] == 0)) begin
				nxt_state = HAND_WRITEB;
			end
			else begin
				nxt_state = cur_state;
			end
		end
		CLEAN: begin
			nxt_state = FILL;
		end
		HAND_WRITEB: begin
			if (awready_m_inf) begin
				nxt_state = WRITEB;
			end
			else begin
				nxt_state = cur_state;
			end
		end
		WRITEB: begin
			if (dram_r_cnt != 0) begin // 0
				nxt_state = cur_state;
			end
			else begin
				nxt_state = END_WRITE;
			end
		end
		END_WRITE: begin
			if(bvalid_m_inf == 1)begin
				nxt_state = IDLE;
			end
		end
		/*
		OUT: begin
			nxt_state = IDLE;
		end
		*/
		
	endcase

end
// ------------------------------------
//               INPUT
// ------------------------------------
always @(*) begin
	if (in_valid) begin //(cur_state == INPUT || cur_state == IDLE) && in_valid
		frame_id_reg_ns = frame_id;
	end
	else begin
		frame_id_reg_ns = frame_id_reg;
	end
end
always @(*) begin
	for (i = 0; i < 30; i++) begin
		locx_reg_ns[i] = locx_reg[i];
		locy_reg_ns[i] = locy_reg[i];
	end	

	if (in_valid) begin
		locx_reg_ns[in_cnt] = loc_x;
		locy_reg_ns[in_cnt] = loc_y;
	end
	else if(cur_state == IDLE)begin
		for (i = 0; i < 30; i++) begin
			locx_reg_ns[i] = 0;
			locy_reg_ns[i] = 0;
		end	
	end
		// ------------------------
		//          CLEAN
		//-------------------------	
	else if (cur_state == CLEAN) begin
		for (i = 0; i < 28; i++) begin
			locx_reg_ns[i] = locx_reg[i+2];
			locy_reg_ns[i] = locy_reg[i+2];
		end
		locx_reg_ns[29] = 0;locx_reg_ns[28] = 0;
		locy_reg_ns[29] = 0;locy_reg_ns[28] = 0;		
	end
end
always @(*) begin
	if (in_valid) begin
		in_cnt_ns = in_cnt + 1;
	end
	else if (cur_state == IDLE) begin
		in_cnt_ns = 0;
	end
	else begin
		in_cnt_ns = in_cnt;
	end	
end
always @(*) begin
	for (i = 0; i < 15; i++) begin
		net_id_reg_ns[i] = net_id_reg[i];
	end
	if (in_valid) begin
		case(in_cnt) 
			0 : net_id_reg_ns[0]  = net_id;
			2 : net_id_reg_ns[1]  = net_id;
			4 : net_id_reg_ns[2]  = net_id;
			6 : net_id_reg_ns[3]  = net_id;
			8 : net_id_reg_ns[4]  = net_id;
			10: net_id_reg_ns[5]  = net_id;
			12: net_id_reg_ns[6]  = net_id;
			14: net_id_reg_ns[7]  = net_id;
			16: net_id_reg_ns[8]  = net_id;
			18: net_id_reg_ns[9]  = net_id;
			20: net_id_reg_ns[10] = net_id;
			22: net_id_reg_ns[11] = net_id;
			24: net_id_reg_ns[12] = net_id;
			26: net_id_reg_ns[13] = net_id;
			28: net_id_reg_ns[14] = net_id;
		endcase
	end
	
		// ------------------------
		//          CLEAN
		//-------------------------	
	else if (cur_state == CLEAN) begin
		for (i = 0; i< 14; i++) begin
			net_id_reg_ns[i] = net_id_reg[i+1];
		end	
		net_id_reg_ns[14] = 0;
	end
end
// ----------------------------------------
//                DRAM read
// ----------------------------------------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		dram_r_cnt <= 0;
	end
	else if ((rvalid_m_inf)||wready_m_inf) begin
		dram_r_cnt <= dram_r_cnt + 1;
	end
	//else if ((cur_state == DRAM_SRAM_MAP || cur_state == DRAM_SRAM_WEIGHT)&& dram_r_cnt == 127 && rvalid_m_inf) begin
	//	dram_r_cnt_ns = 0;
	//end
	else if (cur_state == HAND_WEIGHT || cur_state == IDLE) begin
		dram_r_cnt <= 0;
	end
	else if (cur_state == HAND_WRITEB) begin
		dram_r_cnt <= 1; // 1
	end
	/*
	else if (cur_state == WRITEB) begin
		if (wready_m_inf) begin
			dram_r_cnt_ns = dram_r_cnt + 1;
		end
		else begin
			dram_r_cnt_ns = dram_r_cnt;
		end
	end
	*/
	else begin
		dram_r_cnt <= dram_r_cnt;
	end
end
// ------------------------
//   AXI fixed signals
// ------------------------
assign awid_m_inf = 4'd0;
assign awburst_m_inf = 2'b01;
assign awsize_m_inf = 3'b100;
assign awlen_m_inf = 8'd127;

assign arid_m_inf = 4'd0;
assign arburst_m_inf = 2'b01;
assign arsize_m_inf = 3'b100;
assign arlen_m_inf = 8'd127;
// ------------------------------

always @(*) begin
	araddr_m_inf = 0;
	if (cur_state == HAND_MAP) begin
		araddr_m_inf = {16'h1, frame_id_reg[4:0], 11'b0}; // frame << 11 
	end
	else if (cur_state == HAND_WEIGHT) begin
		araddr_m_inf = {16'h2, frame_id_reg[4:0], 11'b0}; // frame << 11 
	end
end
always @(*) begin
	arvalid_m_inf = 0;
	if (cur_state == HAND_MAP || cur_state == HAND_WEIGHT) begin
		arvalid_m_inf = 1;
	end
end
always @(*) begin
	rready_m_inf = 0;
	if(cur_state == DRAM_SRAM_MAP || cur_state == DRAM_SRAM_WEIGHT) begin
		rready_m_inf = 1;
	end
end
// ----------------------------------------
//                DRAM write
// ----------------------------------------
always @(*) begin
	awvalid_m_inf = 0;
	if (cur_state == HAND_WRITEB) begin
		awvalid_m_inf = 1;
	end
	
end
always @(*) begin
	//awaddr_m_inf = 0;
	//if (cur_state == HAND_WRITEB) begin
	awaddr_m_inf = {16'h1, frame_id_reg[4:0], 11'b0};
	//end
end
always @(*) begin
	bready_m_inf = 0;
	wvalid_m_inf = 0;
	if (cur_state == WRITEB) begin
		wvalid_m_inf = 1;
		bready_m_inf = 1;
	end 
	else if (cur_state == END_WRITE)begin
		bready_m_inf = 1;
	end
end
always @(*) begin
	//wdata_m_inf = 0;
	//if (cur_state == WRITEB) begin
		wdata_m_inf = map_out;
	//end
end
always @(*) begin
	wlast_m_inf = 0;
	if (cur_state == WRITEB && dram_r_cnt == 0) begin
		wlast_m_inf = 1;
	end
end
// ----------------------------------------
//                 SRAM map
// ----------------------------------------
always @(*) begin
	map_addr = 0;
	if (cur_state == DRAM_SRAM_MAP && rvalid_m_inf)begin //&& rvalid_m_inf
		map_addr = dram_r_cnt;
	end
	else if (cur_state == TRACE_BEGIN||cur_state==TRACE) begin
		
		if (tracex[5] == 0) begin
			map_addr = tracey << 1; 
		end
		else begin
			map_addr = (tracey <<1) + 1;
		end
		
		//map_addr = {tracey, tracex[5]};
	end
	/*
	else if(cur_state==TRACE)begin
		map_addr=0;
	end
	else if (cur_state == HAND_WEIGHT) begin
		map_addr = 0; // find first data in sram
	end
	*/
	else if (wready_m_inf && cur_state == WRITEB) begin //&& cur_state == WRITEB
		map_addr = dram_r_cnt;
	end

end
reg [6:0]site_to_devise;
always @(*) begin
	site_to_devise = (((tracex[4:0]+1) * 4) - 1);
	map_in = 0;
	if (cur_state == DRAM_SRAM_MAP && rvalid_m_inf)begin // && rvalid_m_inf
		map_in = rdata_m_inf; // write into sram
	end
	else if (cur_state == TRACE) begin
		//map_in[tracey<<2:tracey<<2 + 3] = net_id_reg[0]; // overflow
		map_in = map_out;
		//if (tracex < 32) begin
		//site_to_devise = (((tracex[4:0]+1) * 4) - 1);
			/*
		end
		else begin
		    site_to_devise = 130- ((tracex[4:0] * 4) - 1);
		end
		*/
		map_in[site_to_devise -: 4] = net_id_reg[0];
		
	end
end
always @(*) begin
	map_web = 1;
	if ((cur_state == DRAM_SRAM_MAP && rvalid_m_inf)||cur_state == TRACE)begin // (&& rvalid_m_inf)
		map_web = 0; // from dram to sram
	end
	/*
	else if (cur_state == TRACE_BEGIN) begin
		map_web = 1;
	end
	*/
	//else if (cur_state == TRACE) begin
	//	map_web = 0; // from reg to sram
	//end
end
/*
always @(*) begin
	m_ns = map_out;
end
*/
// ----------------------------------------
//               SRAM weight
// ----------------------------------------
always @(*) begin
	weight_addr = 0;
	if (cur_state == DRAM_SRAM_WEIGHT && rvalid_m_inf)begin //&& rvalid_m_inf
		weight_addr = dram_r_cnt;
	end
	else if (cur_state == TRACE_BEGIN) begin
		
		if (tracex[5] == 0) begin
			weight_addr = tracey << 1; 
		end
		else begin
			weight_addr = (tracey <<1) + 1;
		end
		
		//weight_addr = {tracey, tracex[5]};
	end
end
always @(*) begin
	weight_in = 0;
	if (cur_state == DRAM_SRAM_WEIGHT && rvalid_m_inf)begin //&& rvalid_m_inf
		weight_in = rdata_m_inf; // write into sram
	end
end

always @(*) begin
	weight_web = 1;
		if (cur_state == DRAM_SRAM_WEIGHT && rvalid_m_inf)begin // && rvalid_m_inf
			weight_web = 0; // write into sram
		end
end
// ------------------------------------
//                  MAP
//-------------------------------------
/*
always @(*) begin
	wave_cnt_ns = wave_cnt;
	/*
	if (cur_state == IDLE || cur_state == CLEAN) begin
		wave_cnt_ns = 1;
	end
	else if (cur_state == FILL && map_reg_ns[locy_reg[1]][locx_reg[1]][1] != 1)begin
		wave_cnt_ns = wave_cnt + 1;
	end
	else if (cur_state == FILL && map_reg_ns[locy_reg[1]][locx_reg[1]][1] == 1) begin
		wave_cnt_ns = wave_cnt -1 ;
	end
	else if (cur_state == TRACE_BEGIN) begin
		wave_cnt_ns = wave_cnt;
	end 
	else if (cur_state == TRACE) begin
		wave_cnt_ns = wave_cnt - 1;
	end
	else begin
		wave_cnt_ns = wave_cnt;
	end
	*/
/*	
	case(cur_state)
		IDLE: begin
			wave_cnt_ns = 1;
		end
		FILL: begin
			if(map_reg[locy_reg[1]][locx_reg[1]][1] != 1)
				wave_cnt_ns = wave_cnt + 1;
			else 
				wave_cnt_ns = wave_cnt - 2;
		end
		TRACE: begin
			wave_cnt_ns = wave_cnt - 1;
		end
		CLEAN: begin
			wave_cnt_ns = 1;
		end
	endcase
end
*/
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wave_cnt <= 0;
	end
	else begin
	case(cur_state)
		IDLE: begin
			wave_cnt <= 1;
		end
		FILL: begin
			if(map_reg[locy_reg[1]][locx_reg[1]][1] != 1)
				wave_cnt <= wave_cnt + 1;
			else 
				wave_cnt <= wave_cnt - 2;
		end
		TRACE: begin
			wave_cnt <= wave_cnt - 1;
		end
		CLEAN: begin
			wave_cnt <= 1;
		end
	endcase
	end
end
//wire left_up, right_up, right_down, left_down;
always @(posedge clk) begin
	/*
	for (i = 0;i<64;i++) begin
		for (j = 0;j<64;j++) begin
			map_reg[i][j] <= map_reg[i][j];
		end
	end
	*/
	/*
if (!rst_n) begin
	for (i = 0;i<64;i++) begin
		for (j = 0;j<64;j++) begin
			map_reg[i][j] <= 0;
		end
	end	
end
else begin
*/
	case(cur_state)
		DRAM_SRAM_MAP: begin
			//if(rready_m_inf)begin
				if (dram_r_cnt[0] == 0) begin // even number means to put it in the left side
					for(i = 0;i<32;i++) begin
						// ex map_addr = 00000010 row is 1 
						//[4*(i+1) - 1 : 4*i]
						if (rdata_m_inf[4*i+3 -: 4] != 0)begin
							map_reg[map_addr[6:1]][i] <= 1;
						end
						else begin
							map_reg[map_addr[6:1]][i] <= 0;
						end
					end
				end
				else begin // odd num : right side
					for(i = 0;i<32;i++) begin
						// put 32 datas at once
						if (rdata_m_inf[4*i+3 -: 4] != 0)begin
							map_reg[map_addr[6:1]][i+32] <= 1;
						end
						else begin
							map_reg[map_addr[6:1]][i+32] <= 0;
						end
					end
				end
			//end
		end
		DRAM_SRAM_WEIGHT: begin
			map_reg[locy_reg[0]][locx_reg[0]] <= 2; // 2 means the source
			map_reg[locy_reg[1]][locx_reg[1]] <= 0; // 0 means the sink
			// for the first point
		end
		FILL: begin
			for (i = 1; i<63;i++) begin
				for (j = 1;j<63;j++) begin
					if (map_reg[i][j] == 0 && (map_reg[i][j+1][1] == 1 || map_reg[i][j-1][1] == 1 || map_reg[i+1][j][1] == 1 || map_reg[i-1][j][1] == 1)) begin
						// before is 0 and its neighborhood are 2 or 3 
						map_reg[i][j] <= {1'b1, wave_cnt[1]};
					end
				end
			end
			//up
			for (j = 1;j<63;j++) begin // check down left right
				if (map_reg[0][j] == 0 && (map_reg[0][j+1][1] == 1 || map_reg[0][j-1][1] == 1 || map_reg[1][j][1] == 1)) begin
					map_reg[0][j] <= {1'b1, wave_cnt[1]};
				end
			end
			//down
			for (j = 1;j<63;j++) begin // check up left right
				if (map_reg[63][j] == 0 && (map_reg[63][j+1][1] == 1 || map_reg[63][j-1][1] == 1 || map_reg[62][j][1] == 1)) begin
					map_reg[63][j] <= {1'b1, wave_cnt[1]};
				end
			end
			//left 
			for (i = 1;i<63;i++) begin // check up down right
				if (map_reg[i][0] == 0 && (map_reg[i][1][1] == 1 || map_reg[i+1][0][1] == 1 || map_reg[i-1][0][1] == 1)) begin
					map_reg[i][0] <= {1'b1, wave_cnt[1]};
				end
			end
			//right
			for (i = 1;i<63;i++) begin // check up down left
				if (map_reg[i][63] == 0 && (map_reg[i][62][1] == 1 || map_reg[i+1][63][1] == 1 || map_reg[i-1][63][1] == 1)) begin
					map_reg[i][63] <= {1'b1, wave_cnt[1]};
				end
			end
			//corners
			if (map_reg[0][0] == 0 && (map_reg[0][1][1] == 1 || map_reg[1][0][1] == 1))begin
				map_reg[0][0] <= {1'b1, wave_cnt[1]};
			end
			if (map_reg[0][63] == 0 && (map_reg[0][62][1] == 1 || map_reg[1][63][1] == 1))begin
				map_reg[0][63] <= {1'b1, wave_cnt[1]};
			end		
			if (map_reg[63][63] == 0 && (map_reg[63][62][1] == 1 || map_reg[62][63][1] == 1))begin
				map_reg[63][63] <= {1'b1, wave_cnt[1]};
			end
			if (map_reg[63][0] == 0 && (map_reg[62][0][1] == 1 || map_reg[63][1][1] == 1))begin
				map_reg[63][0] <= {1'b1, wave_cnt[1]};
			end
		end
		TRACE_BEGIN: begin
			map_reg[tracey][tracex] <= 1;
		end
		CLEAN: begin
			for (i = 0 ; i <64 ; i++) begin
				for (j = 0 ; j < 64; j++) begin
					if (map_reg[i][j][1] == 1) begin
						map_reg[i][j] <= 0;
					end
				end
			end
			map_reg[locy_reg[2]][locx_reg[2]] <= 2; // 2 means the source
			map_reg[locy_reg[3]][locx_reg[3]] <= 0; // 0 means the sink		
		end
	endcase
//end
end

//assign left_up = (map_reg[0][1][1] == 1 || map_reg[1][0][1] == 1);
//assign right_up = (map_reg[0][62][1] == 1 || map_reg[1][63][1] == 1);
//assign right_down = (map_reg[63][62][1] == 1 || map_reg[62][63][1] == 1);
//assign left_down = (map_reg[62][0][1] == 1 || map_reg[63][1][1] == 1);
// ------------------------------------
//               TRACE
//-------------------------------------
reg dir_up, dir_down, dir_right;

always @(posedge clk or negedge rst_n) begin
	//tracex <= tracex;
	//tracey <= tracey;
	/*
	if(cur_state==IDLE)begin
		tracex<=0;
		tracey<=0;
	end
	*/
	
	if (!rst_n) begin
		tracex <= 0;
		tracey <= 0;		
	end
	
	else if (cur_state == FILL) begin
		tracex <= locx_reg[1];
		tracey <= locy_reg[1];
		//as soon as it come in the trace it can start
	end
	
	else if (cur_state == TRACE) begin
		
		if (dir_down) begin
			tracey <= tracey + 1;
			tracex <= tracex;			
		end
		else if (dir_up) begin
			tracey <= tracey - 1;
			tracex <= tracex;			
		end
		else if (dir_right) begin
			tracey <= tracey;
			tracex <= tracex + 1;			
		end
		else begin
			tracey <= tracey;
			tracex <= tracex - 1;			
		end
		
		/*
		if (tracey != 63 && map_reg[tracey+1][tracex] == {1'b1, wave_cnt[1]}) begin
			tracey <= tracey + 1;
			tracex <= tracex;
		end
		else if (tracey != 0 && map_reg[tracey-1][tracex] == {1'b1, wave_cnt[1]}) begin
			tracey <= tracey - 1;
			tracex <= tracex;
		end
		else if (tracex != 63 && map_reg[tracey][tracex+1] == {1'b1, wave_cnt[1]}) begin
			tracey <= tracey;
			tracex <= tracex + 1;
		end
		else if (tracex != 0 && map_reg[tracey][tracex-1] == {1'b1, wave_cnt[1]}) begin
			tracey <= tracey;
			tracex <= tracex - 1;
		end
		*/
	end
end

// STEP 1: direction decoding 
always @(*) begin
	dir_up    = (tracey != 0   && map_reg[tracey-1][tracex] == {1'b1, wave_cnt[1]});
	dir_down  = (tracey != 63  && map_reg[tracey+1][tracex] == {1'b1, wave_cnt[1]});
	//dir_left  = (tracex != 0   && map[tracey][tracex-1] == {1'b1, wave_cnt[1]});
	dir_right = (tracex != 63  && map_reg[tracey][tracex+1] == {1'b1, wave_cnt[1]});
end

// notice that map can simutaneously be write into sram but to read weight from sram spend more cycle to get the value

// ------------------------------------
//          COST during TRACE
//-------------------------------------
reg [4:0] idx;
reg [3:0] selected_weight;
always @(*) begin
	//site_to_get = (tracex[4:0] * 4) - 1;
	idx = 0;
	selected_weight = 0;
	cost_reg_ns = cost_reg;
	if (cur_state == IDLE) begin
		cost_reg_ns = 0;
	end
	else if (cur_state == TRACE && ((tracex != locx_reg[1] || tracey != locy_reg[1]) && (tracex != locx_reg[0] || tracey != locy_reg[0]))) begin
		//don't add sink
		idx = tracex[4:0];
		selected_weight = weight_out[idx*4 +: 4];
		cost_reg_ns = cost_reg + selected_weight;

	end
end
// ----------------------------
//             OUT
//-----------------------------
reg busy_ns;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		busy <= 0; 
	end
	else begin
		busy <= busy_ns;
	end
end
always @(*) begin
	if (cur_state == IDLE || bvalid_m_inf || in_valid) begin
		busy_ns = 0;
	end
	else begin //if (cur_state == WRITEB && dram_r_cnt == 127)
		busy_ns = 1;
	end
	/*
	else if (in_valid) begin
		busy_ns = 0;
	end
	else begin
		busy_ns = 1;
	end
	*/
end
endmodule
/*
always @(*) begin
	for (i = 0;i<64;i++) begin
		for (j = 0;j<64;j++) begin
			map_reg_ns[i][j] = map_reg[i][j];
		end
	end
	case(cur_state)
		DRAM_SRAM_MAP: begin
			//if(rready_m_inf)begin
				if (dram_r_cnt[0] == 0) begin // even number means to put it in the left side
					for(i = 0;i<32;i++) begin
						// ex map_addr = 00000010 row is 1 
						//[4*(i+1) - 1 : 4*i]
						if (rdata_m_inf[4*i+3 -: 4] != 0)begin
							map_reg_ns[map_addr[6:1]][i] = 1;
						end
						else begin
							map_reg_ns[map_addr[6:1]][i] = 0;
						end
					end
				end
				else begin // odd num : right side
					for(i = 0;i<32;i++) begin
						// put 32 datas at once
						if (rdata_m_inf[4*i+3 -: 4] != 0)begin
							map_reg_ns[map_addr[6:1]][i+32] = 1;
						end
						else begin
							map_reg_ns[map_addr[6:1]][i+32] = 0;
						end
					end
				end
			//end
		end
		DRAM_SRAM_WEIGHT: begin
			map_reg_ns[locy_reg[0]][locx_reg[0]] = 2; // 2 means the source
			map_reg_ns[locy_reg[1]][locx_reg[1]] = 0; // 0 means the sink
			// for the first point
		end
		FILL: begin
			for (i = 1; i<63;i++) begin
				for (j = 1;j<63;j++) begin
					if (map_reg[i][j] == 0 && (map_reg[i][j+1][1] == 1 || map_reg[i][j-1][1] == 1 || map_reg[i+1][j][1] == 1 || map_reg[i-1][j][1] == 1)) begin
						// before is 0 and its neighborhood are 2 or 3 
						map_reg_ns[i][j] = {1'b1, wave_cnt[1]};
					end
				end
			end
			//up
			for (j = 1;j<63;j++) begin // check down left right
				if (map_reg[0][j] == 0 && (map_reg[0][j+1][1] == 1 || map_reg[0][j-1][1] == 1 || map_reg[0][j][1] == 1)) begin
					map_reg_ns[0][j] = {1'b1, wave_cnt[1]};
				end
			end
			//down
			for (j = 1;j<63;j++) begin // check up left right
				if (map_reg[63][j] == 0 && (map_reg[63][j+1][1] == 1 || map_reg[63][j-1][1] == 1 || map_reg[62][j][1] == 1)) begin
					map_reg_ns[63][j] = {1'b1, wave_cnt[1]};
				end
			end
			//left 
			for (i = 1;i<63;i++) begin // check up down right
				if (map_reg[i][0] == 0 && (map_reg[i][1][1] == 1 || map_reg[i+1][0][1] == 1 || map_reg[i-1][0][1] == 1)) begin
					map_reg_ns[i][0] = {1'b1, wave_cnt[1]};
				end
			end
			//right
			for (i = 1;i<63;i++) begin // check up down left
				if (map_reg[i][63] == 0 && (map_reg[i][62][1] == 1 || map_reg[i+1][63][1] == 1 || map_reg[i-1][63][1] == 1)) begin
					map_reg_ns[i][63] = {1'b1, wave_cnt[1]};
				end
			end
			//corners
			if (map_reg[0][0] == 0 && (map_reg[0][1][1] == 1 || map_reg[1][0][1] == 1))begin
				map_reg_ns[0][0] = {1'b1, wave_cnt[1]};
			end
			if (map_reg[0][63] == 0 && (map_reg[0][62][1] == 1 || map_reg[1][63][1] == 1))begin
				map_reg_ns[0][63] = {1'b1, wave_cnt[1]};
			end		
			if (map_reg[63][63] == 0 && (map_reg[63][62][1] == 1 || map_reg[62][63][1] == 1))begin
				map_reg_ns[63][63] = {1'b1, wave_cnt[1]};
			end
			if (map_reg[63][0] == 0 && (map_reg[62][0][1] == 1 || map_reg[63][1][1] == 1))begin
				map_reg_ns[63][0] = {1'b1, wave_cnt[1]};
			end
		end
		TRACE_BEGIN: begin
			map_reg_ns[tracey][tracex] = 1;
		end
		CLEAN: begin
			for (i = 0 ; i <64 ; i++) begin
				for (j = 0 ; j < 64; j++) begin
					if (map_reg[i][j][1] == 1) begin
						map_reg_ns[i][j] = 0;
					end
				end
			end
			map_reg_ns[locy_reg[2]][locx_reg[2]] = 2; // 2 means the source
			map_reg_ns[locy_reg[3]][locx_reg[3]] = 0; // 0 means the sink		
		end
	endcase
end
*/
