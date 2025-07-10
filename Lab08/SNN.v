// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on

module SNN(
	// Input signals
	clk,
	rst_n,
	cg_en,
	in_valid,
	img,
	ker,
	weight,

	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input in_valid;
input cg_en;
input [7:0] img;
input [7:0] ker;
input [7:0] weight;

output reg out_valid;
output reg [9:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
integer i,j;
genvar r,c;
//==============================================//
//           reg & wire declaration             //
//==============================================//
//reg [7:0] img1 [0:14], img1_ns [0:14];
reg [7:0] img1[0:5][0:5], img1_ns[0:5][0:5];
reg [7:0] ker_reg [0:8], ker_reg_ns [0:8];
reg [7:0] weight_reg [0:3], weight_reg_ns [0:3];
reg [7:0] fp1[0:15], fp1_ns[0:15]; 
reg [7:0] mp1[0:3];
reg [7:0] out1[0:3], out1_ns[0:3], out2[0:3], out2_ns[0:3];
//counter
reg [6:0] cnt, cnt_ns; 
typedef enum reg {IDLE = 0 ,INPUT_FP = 1}state;
state nxt_state, cur_state;
//==============================================//
//                  design                      //
//==============================================//
wire ker_reg_clk[0:8];
generate
	for(r = 0 ; r < 9; r = r+1)begin
		GATED_OR GATED_ker_reg (.CLOCK(clk), .SLEEP_CTRL( !(cnt == r) && cg_en), .RST_N(rst_n), .CLOCK_GATED(ker_reg_clk[r]));
		always@(posedge ker_reg_clk[r] )begin
			//if (cnt == r )begin
                ker_reg[r] <= ker_reg_ns[r] ;
            //end
		end
	end
endgenerate
always @(*) begin
	for (i = 0; i<9;i++) begin
		ker_reg_ns[i] = ker_reg[i];
	end
	if (cnt < 9) begin
		ker_reg_ns[cnt] = ker;
	end
end
wire weight_reg_clk [0:3];
generate
	for(r = 0 ; r < 4; r = r+1)begin
		GATED_OR GATED_weight_reg (.CLOCK(clk), .SLEEP_CTRL( !(cnt == r) && cg_en), .RST_N(rst_n), .CLOCK_GATED(weight_reg_clk[r]));
		always@(posedge weight_reg_clk[r])begin
			//if (cnt == r) begin
                weight_reg[r] <= weight_reg_ns[r] ;
            //end
		end
	end
endgenerate
always @(*) begin
	for (i = 0; i<4;i++) begin
		weight_reg_ns[i] = weight_reg[i];
	end
	if (cnt < 4) begin
		weight_reg_ns[cnt] = weight;
	end
end
// -------------------------
//      State Control
// -------------------------
/*
always @(*) begin
	nxt_state = cur_state;
	case(cur_state)
		IDLE: begin
			if (in_valid) begin
				nxt_state = INPUT_FP;
			end
			else begin
				nxt_state = cur_state;
			end
		end
		INPUT_FP: begin
			if (cnt == 76) begin  
				nxt_state = IDLE;
			end
		end 
	endcase
end
*/
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cnt <= 0;
	end
	else begin
		cnt <= cnt_ns;
	end
end
always @(*) begin
	if (in_valid || (cnt != 0 && cnt != 76)) begin //
		cnt_ns = cnt + 1;
	end
	else begin
		cnt_ns = 0;
	end
end
//wire state_clk;
//GATED_OR GATED_state (.CLOCK(clk), .SLEEP_CTRL(!(cur_state == IDLE || cnt == 76) && cg_en), .RST_N(rst_n), .CLOCK_GATED(state_clk));
/*
always @(posedge state_clk or negedge rst_n) begin
	if (!rst_n) begin
		cur_state <= IDLE;
	end
	else begin
		cur_state <= nxt_state;
	end
end
*/
wire image_clk [5:0][5:0];
generate
	for(r=0; r<6; r++)begin
    	for(c=0; c<6; c++) begin
			GATED_OR GATED_img (.CLOCK(clk), .SLEEP_CTRL(!(cnt == (6*r + c) || cnt == (6*r + c + 36)) && cg_en), .RST_N(rst_n), .CLOCK_GATED(image_clk[r][c]));
			always@(posedge image_clk[r][c])begin
				img1[r][c] <= img1_ns[r][c];
			end
		end
	end
endgenerate
always @(*) begin
	for(i = 0; i < 6; i++)begin
    	for(j = 0; j < 6; j++) begin
			img1_ns[i][j] = img1[i][j];
		end
	end
	case(cnt) 
    	0,  36: img1_ns [0][0] = img;
    	1,  37: img1_ns [0][1] = img;  
    	2,  38: img1_ns [0][2] = img;  
    	3,  39: img1_ns [0][3] = img;  
    	4,  40: img1_ns [0][4] = img;  
    	5,  41: img1_ns [0][5] = img;  
    	6,  42: img1_ns [1][0] = img;
    	7,  43: img1_ns [1][1] = img;
    	8,  44: img1_ns [1][2] = img;
    	9,  45: img1_ns [1][3] = img;
    	10, 46: img1_ns [1][4] = img;
    	11, 47: img1_ns [1][5] = img; 
    	12, 48: img1_ns [2][0] = img;
    	13, 49: img1_ns [2][1] = img;
    	14, 50: img1_ns [2][2] = img;
    	15, 51: img1_ns [2][3] = img;
		16, 52: img1_ns [2][4] = img;
		17, 53: img1_ns [2][5] = img; 
		18, 54: img1_ns [3][0] = img;
		19, 55: img1_ns [3][1] = img;
		20, 56: img1_ns [3][2] = img;
		21, 57: img1_ns [3][3] = img;
		22, 58: img1_ns [3][4] = img;
		23, 59: img1_ns [3][5] = img; 
		24,	60: img1_ns [4][0] = img;
		25,	61: img1_ns [4][1] = img;
		26,	62: img1_ns [4][2] = img;
		27,	63: img1_ns [4][3] = img;
		28, 64: img1_ns [4][4] = img;
		29, 65: img1_ns [4][5] = img;
		30, 66: img1_ns [5][0] = img;
		31, 67: img1_ns [5][1] = img;
		32, 68:	img1_ns [5][2] = img;
		33, 69:	img1_ns [5][3] = img;
		34, 70:	img1_ns [5][4] = img;
		35, 71:	img1_ns [5][5] = img;		
	endcase
end
//-----------------------------
//            MUL
//-----------------------------
reg [7:0] mula [0:8];
reg [7:0] mulb [0:8];
reg [15:0] mulres [0:8];

always @(*) begin
	mula[0] = 0;
  	case(cnt)
    	21,57: mula[0] = img1[0][0];
    	22,58: mula[0] = img1[0][1];
		23,59: mula[0] = img1[0][2];
		24,60: mula[0] = img1[0][3];
		25,61: mula[0] = img1[1][0]; 
		26,62: mula[0] = img1[1][1];
		27,63: mula[0] = img1[1][2];
		28,64: mula[0] = img1[1][3];
		29,65: mula[0] = img1[2][0];
		30,66: mula[0] = img1[2][1];
		31,67: mula[0] = img1[2][2];
		32,68: mula[0] = img1[2][3];
		33,69: mula[0] = img1[3][0];
		34,70: mula[0] = img1[3][1];
		35,71: mula[0] = img1[3][2];
		36,72: mula[0] = img1[3][3];
		default: begin
			mula[0] = cg_en ? 0 : cnt ;
		end
	endcase
end
always @(*) begin
	mula[1] = 0;
  	case(cnt)
    	21,57: mula[1] = img1[0][1];
    	22,58: mula[1] = img1[0][2];
		23,59: mula[1] = img1[0][3];
		24,60: mula[1] = img1[0][4];
		25,61: mula[1] = img1[1][1];
		26,62: mula[1] = img1[1][2];
		27,63: mula[1] = img1[1][3];
		28,64: mula[1] = img1[1][4];
		29,65: mula[1] = img1[2][1];
		30,66: mula[1] = img1[2][2];
		31,67: mula[1] = img1[2][3];
		32,68: mula[1] = img1[2][4];
		33,69: mula[1] = img1[3][1];
		34,70: mula[1] = img1[3][2];
		35,71: mula[1] = img1[3][3];
		36,72: mula[1] = img1[3][4];
		default: begin
			mula[1] = cg_en ? 0 : cnt ;
		end
	endcase
end
always @(*) begin
	mula[2] = 0;
  	case(cnt)
    	21,57: mula[2] = img1[0][2];
    	22,58: mula[2] = img1[0][3];
		23,59: mula[2] = img1[0][4];
		24,60: mula[2] = img1[0][5];
		25,61: mula[2] = img1[1][2];
		26,62: mula[2] = img1[1][3];
		27,63: mula[2] = img1[1][4];
		28,64: mula[2] = img1[1][5];
		29,65: mula[2] = img1[2][2];
		30,66: mula[2] = img1[2][3];
		31,67: mula[2] = img1[2][4];
		32,68: mula[2] = img1[2][5];
		33,69: mula[2] = img1[3][2];
		34,70: mula[2] = img1[3][3];
		35,71: mula[2] = img1[3][4];
		36,72: mula[2] = img1[3][5];
		default: begin
			mula[2] = cg_en ? 0 : cnt ;
		end
	endcase
end
always @(*) begin
	mula[3] = 0;
  	case(cnt)
    	21,57: mula[3] = img1[1][0];
    	22,58: mula[3] = img1[1][1];
		23,59: mula[3] = img1[1][2];
		24,60: mula[3] = img1[1][3];
		25,61: mula[3] = img1[2][0];
		26,62: mula[3] = img1[2][1];
		27,63: mula[3] = img1[2][2];
		28,64: mula[3] = img1[2][3];
		29,65: mula[3] = img1[3][0];
		30,66: mula[3] = img1[3][1];
		31,67: mula[3] = img1[3][2];
		32,68: mula[3] = img1[3][3];
		33,69: mula[3] = img1[4][0];
		34,70: mula[3] = img1[4][1];
		35,71: mula[3] = img1[4][2];
		36,72: mula[3] = img1[4][3];
		default: begin
			mula[3] = cg_en ? 0 : cnt ;
		end
	endcase
end
always @(*) begin
	mula[4] = 0;
  	case(cnt)
    	21,57: mula[4] = img1[1][1];
    	22,58: mula[4] = img1[1][2];
		23,59: mula[4] = img1[1][3];
		24,60: mula[4] = img1[1][4];
		25,61: mula[4] = img1[2][1];
		26,62: mula[4] = img1[2][2];
		27,63: mula[4] = img1[2][3];
		28,64: mula[4] = img1[2][4];
		29,65: mula[4] = img1[3][1];
		30,66: mula[4] = img1[3][2];
		31,67: mula[4] = img1[3][3];
		32,68: mula[4] = img1[3][4];
		33,69: mula[4] = img1[4][1];
		34,70: mula[4] = img1[4][2];
		35,71: mula[4] = img1[4][3];
		36,72: mula[4] = img1[4][4];
		default: begin
			mula[4] = cg_en ? 0 : cnt ;
		end
	endcase
end
always @(*) begin
	mula[5] = 0;
  	case(cnt)
    	21,57: mula[5] = img1[1][2];
    	22,58: mula[5] = img1[1][3];
		23,59: mula[5] = img1[1][4];
		24,60: mula[5] = img1[1][5];
		25,61: mula[5] = img1[2][2];
		26,62: mula[5] = img1[2][3];
		27,63: mula[5] = img1[2][4];
		28,64: mula[5] = img1[2][5];
		29,65: mula[5] = img1[3][2];
		30,66: mula[5] = img1[3][3];
		31,67: mula[5] = img1[3][4];
		32,68: mula[5] = img1[3][5];
		33,69: mula[5] = img1[4][2];
		34,70: mula[5] = img1[4][3];
		35,71: mula[5] = img1[4][4];
		36,72: mula[5] = img1[4][5];
		default: begin
			mula[5] = cg_en ? 0 : cnt ;
		end
	endcase
end
always @(*) begin
	mula[6] = 0;
  	case(cnt)
    	21,57: mula[6] = img1[2][0];
    	22,58: mula[6] = img1[2][1];
		23,59: mula[6] = img1[2][2];
		24,60: mula[6] = img1[2][3];
		25,61: mula[6] = img1[3][0];
		26,62: mula[6] = img1[3][1];
		27,63: mula[6] = img1[3][2];
		28,64: mula[6] = img1[3][3];
		29,65: mula[6] = img1[4][0];
		30,66: mula[6] = img1[4][1];
		31,67: mula[6] = img1[4][2];
		32,68: mula[6] = img1[4][3];
		33,69: mula[6] = img1[5][0];
		34,70: mula[6] = img1[5][1];
		35,71: mula[6] = img1[5][2];
		36,72: mula[6] = img1[5][3];
		default: begin
			mula[6] = cg_en ? 0 : cnt ;
		end
	endcase
end
always @(*) begin
	mula[7] = 0;
  	case(cnt)
    	21,57: mula[7] = img1[2][1];
    	22,58: mula[7] = img1[2][2];
		23,59: mula[7] = img1[2][3];
		24,60: mula[7] = img1[2][4];
		25,61: mula[7] = img1[3][1];
		26,62: mula[7] = img1[3][2];
		27,63: mula[7] = img1[3][3];
		28,64: mula[7] = img1[3][4];
		29,65: mula[7] = img1[4][1];
		30,66: mula[7] = img1[4][2];
		31,67: mula[7] = img1[4][3];
		32,68: mula[7] = img1[4][4];
		33,69: mula[7] = img1[5][1];
		34,70: mula[7] = img1[5][2];
		35,71: mula[7] = img1[5][3];
		36,72: mula[7] = img1[5][4];
		default: begin
			mula[7] = cg_en ? 0 : cnt; 
		end
	endcase
end
always @(*) begin
	mula[8] = 0;
  	case(cnt)
    	21,57: mula[8] = img1[2][2];
    	22,58: mula[8] = img1[2][3];
		23,59: mula[8] = img1[2][4];
		24,60: mula[8] = img1[2][5];
		25,61: mula[8] = img1[3][2];
		26,62: mula[8] = img1[3][3];
		27,63: mula[8] = img1[3][4];
		28,64: mula[8] = img1[3][5];
		29,65: mula[8] = img1[4][2];
		30,66: mula[8] = img1[4][3];
		31,67: mula[8] = img1[4][4];
		32,68: mula[8] = img1[4][5];
		33,69: mula[8] = img1[5][2];
		34,70: mula[8] = img1[5][3];
		35,71: mula[8] = img1[5][4];
		36,72: mula[8] = img1[5][5];
		default: begin
			mula[8] = cg_en ? 0 : cnt ;
		end
	endcase
end
always @(*) begin
	if ((cnt >= 21 && cnt <= 36) || (cnt >= 51 && cnt <= 72)) begin
		mulb[0] = ker_reg[0];
	end
	else begin
		mulb[0] = (cg_en ? 0 : cnt);
	end
end 
always @(*) begin
	if ((cnt >= 21 && cnt <= 36) || (cnt >= 51 && cnt <= 72)) begin
		mulb[1] = ker_reg[1];
	end
	else begin
		mulb[1] = (cg_en ? 0 : cnt);
	end
end 
always @(*) begin
	if ((cnt >= 21 && cnt <= 36) || (cnt >= 51 && cnt <= 72)) begin
		mulb[2] = ker_reg[2];
	end
	else begin
		mulb[2] = (cg_en ? 0 : cnt);
	end
end 
always @(*) begin
	if ((cnt >= 21 && cnt <= 36) || (cnt >= 51 && cnt <= 72)) begin
		mulb[3] = ker_reg[3];
	end
	else begin
		mulb[3] = (cg_en ? 0 : cnt);
	end
end 
always @(*) begin
	if ((cnt >= 21 && cnt <= 36) || (cnt >= 51 && cnt <= 72)) begin
		mulb[4] = ker_reg[4];
	end
	else begin
		mulb[4] = (cg_en ? 0 : cnt);
	end
end 
always @(*) begin
	if ((cnt >= 21 && cnt <= 36) || (cnt >= 51 && cnt <= 72)) begin
		mulb[5] = ker_reg[5];
	end
	else begin
		mulb[5] = (cg_en ? 0 : cnt);
	end
end 
always @(*) begin
	if ((cnt >= 21 && cnt <= 36) || (cnt >= 51 && cnt <= 72)) begin
		mulb[6] = ker_reg[6];
	end
	else begin
		mulb[6] = (cg_en ? 0 : cnt);
	end
end 
always @(*) begin
	if ((cnt >= 21 && cnt <= 36) || (cnt >= 51 && cnt <= 72)) begin
		mulb[7] = ker_reg[7];
	end
	else begin
		mulb[7] = (cg_en ? 0 : cnt);
	end
end 
always @(*) begin
	if ((cnt >= 21 && cnt <= 36) || (cnt >= 51 && cnt <= 72)) begin
		mulb[8] = ker_reg[8];
	end
	else begin
		mulb[8] = (cg_en ? 0 : cnt);
	end
end 

always @(*) begin
	mulres[0] = mula[0] * mulb[0];
	mulres[1] = mula[1] * mulb[1];
	mulres[2] = mula[2] * mulb[2];
	mulres[3] = mula[3] * mulb[3];
	mulres[4] = mula[4] * mulb[4];
	mulres[5] = mula[5] * mulb[5];
	mulres[6] = mula[6] * mulb[6];
	mulres[7] = mula[7] * mulb[7];
	mulres[8] = mula[8] * mulb[8];

end
reg [19:0] f_res_ns;
reg [19:0] add [0:6];

always @(*) begin
	add[0] = mulres[0] + mulres[1];
end
always @(*) begin
	add[1] = mulres[2] + mulres[3];
end
always @(*) begin
	add[2] = mulres[4] + mulres[5];
end
always @(*) begin
	add[3] = mulres[6] + mulres[7];
end
always @(*) begin
	add[4] = add[0] + add[1];
end
always @(*) begin
	add[5] = add[2] + add[3];
end
always @(*) begin
	add[6] = add[4] + add[5];
end

always @(*) begin
	f_res_ns  = add[6] + mulres[8];	
end

wire f_clk;
reg [19:0] f_res;
GATED_OR GATED_feature (.CLOCK(clk), .SLEEP_CTRL(! (cnt > 20 && cnt < 37 || cnt > 56 && cnt < 73) && cg_en), .RST_N(rst_n), .CLOCK_GATED(f_clk));

always@(posedge f_clk)begin
  	f_res <= f_res_ns;
end

//-----------------------------
//            DIV
//-----------------------------
reg [19:0] diva;
wire [7:0] divres;
always @(*) begin
	if ((cnt >= 22 && cnt <= 37) || (cnt >= 52 && cnt <= 73)) begin
		diva = f_res;
	end
	else begin
		diva = (cg_en ? 0 : cnt);
	end	
	
end

assign divres = diva/2295;

wire fp_clk[0:15];

generate
	for(r = 0; r < 16; r++)begin
		GATED_OR GATED_fmap (.CLOCK(clk), .SLEEP_CTRL((cnt != (22 + r) && cnt != (58 + r)) && cg_en), .RST_N(rst_n), .CLOCK_GATED(fp_clk[r]));
		always@(posedge fp_clk[r])begin
			if ((cnt == 22 + r) || (cnt == 58 + r)) begin
				fp1[r] <= divres;
			end
		end
	end
endgenerate

// MP
reg [7:0] cmp1, cmp2, cmp3, cmp4;
reg [7:0] result1, result2, result3;
always @(*) begin
	cmp1 = 0;
	cmp2 = 0;
	case(cnt)
		34,70: begin cmp1 = fp1[0];  cmp2 = fp1[1]; end
		35,71: begin cmp1 = fp1[2];  cmp2 = fp1[3]; end
		36,72: begin cmp1 = fp1[8];  cmp2 = fp1[9]; end
		37,73: begin cmp1 = fp1[10]; cmp2 = fp1[11]; end

	endcase
end
always @(*) begin
	cmp3 = 0;
	cmp4 = 0;
	case(cnt)
		34,70: begin cmp3 = fp1[4];  cmp4 = fp1[5]; end
		35,71: begin cmp3 = fp1[6];  cmp4 = fp1[7]; end
		36,72: begin cmp3 = fp1[12]; cmp4 = fp1[13]; end
		37,73: begin cmp3 = fp1[14]; cmp4 = divres; end
	endcase
end
always @(*) begin
	result1 = (cmp1 > cmp2) ?  cmp1 : cmp2;
end
always @(*) begin
	result2 = (cmp3 > cmp4) ?  cmp3 : cmp4;
end
always @(*) begin
	result3 = (result1 > result2) ? result1 : result2;
end
wire mp_clk [0:3];
generate
	for(r = 0; r < 4; r++)begin
		GATED_OR GATED_mp (.CLOCK(clk), .SLEEP_CTRL((cnt != (34 + r) && cnt != (70 + r)) && cg_en), .RST_N(rst_n), .CLOCK_GATED(mp_clk[r]));
		always@(posedge mp_clk[r])begin
			if ((cnt == 34 + r) || (cnt == 70 + r)) begin
				mp1[r] <= result3;
			end
		end
	end
endgenerate
// FC
reg [7:0] fc1_mula, fc1_mulb, fc2_mula, fc2_mulb;
reg [15:0] fcres [0:1];
reg [16:0] fctotal_ns, fctotal;
reg [7:0] fc;
always @(*) begin
	fc1_mula = 0;
	fc1_mulb = 0;
	case(cnt)
	35,71: begin fc1_mula = mp1[0]; fc1_mulb = weight_reg[0]; end //36,72
	36,72: begin fc1_mula = mp1[0]; fc1_mulb = weight_reg[1]; end //37,73
	37,73: begin fc1_mula = mp1[2]; fc1_mulb = weight_reg[0]; end //38,74
	38,74: begin fc1_mula = mp1[2]; fc1_mulb = weight_reg[1]; end //39,75
	endcase
end
always @(*) begin
	fc2_mula = 0;
	fc2_mulb = 0;
	case(cnt)
	35,71: begin fc2_mula = result3; fc2_mulb = weight_reg[2]; end
	36,72: begin fc2_mula = mp1[1]; fc2_mulb = weight_reg[3]; end
	37,73: begin fc2_mula = result3; fc2_mulb = weight_reg[2]; end
	38,74: begin fc2_mula = mp1[3]; fc2_mulb = weight_reg[3]; end
	endcase
end
always @(*) begin
	fcres[0] = fc1_mula * fc1_mulb;
	fcres[1] = fc2_mula * fc2_mulb;
end
always @(*) begin
	fctotal_ns = (fcres[0] + fcres[1]);
end
GATED_OR GATED_fc (.CLOCK(clk), .SLEEP_CTRL(! (cnt > 34 && cnt < 39 || cnt > 70 && cnt < 75) && cg_en), .RST_N(rst_n), .CLOCK_GATED(fc_clk));
always @(posedge fc_clk) begin
	fctotal <= fctotal_ns;
end
always @(*) begin
	fc = fctotal / 510 ;
end
// L1 
reg [7:0] lt, l_total, l_total_ns;
wire out1_clk [0:3];
wire out2_clk [0:3];
generate
	for(r = 0; r < 4; r++)begin
		GATED_OR GATED_out1 (.CLOCK(clk), .SLEEP_CTRL((cnt != (36 + r)) && cg_en), .RST_N(rst_n), .CLOCK_GATED(out1_clk[r]));
		always@(posedge out1_clk[r])begin
			if (cnt == 36 + r) begin
				out1[r] <= fc;
			end
		end
	end
endgenerate
generate
	for(r = 0; r < 4; r++)begin
		GATED_OR GATED_out2 (.CLOCK(clk), .SLEEP_CTRL((cnt != (72 + r)) && cg_en), .RST_N(rst_n), .CLOCK_GATED(out2_clk[r]));
		always@(posedge out2_clk[r])begin
			if (cnt == 72 + r) begin
				out2[r] <= fc;
			end
		end
	end
endgenerate
reg [7:0] l0, l1;
reg [7:0] cp1, cp2;
always @(*) begin
	case(cnt) 
	72: begin cp1 = out1[0]; cp2 = fc; end //72:
	73: begin cp1 = out1[1]; cp2 = fc; end //73:
	74: begin cp1 = out1[2]; cp2 = fc; end //74:
	75: begin cp1 = out1[3]; cp2 = fc; end //75:
	default : begin
		cp1 = cg_en ? 0 : cnt;
		cp2 = cg_en ? 0 : cnt;		
	end
	endcase
end
always @(*) begin
	/*
	case(cnt)
		72: begin l0 = out1[0]- out2[0]; l1 = out2[0] - out1[0]; end
		73: begin l0 = out1[1]- out2[1]; l1 = out2[1] - out1[1]; end
		74: begin l0 = out1[2]- out2[2]; l1 = out2[2] - out1[2]; end
		75: begin l0 = out1[3]- out2[3]; l1 = out2[3] - out1[3]; end
		default: begin
			l0 = cg_en ? 0 : cnt;
			l1 = cg_en ? 0 : cnt;
		end
	endcase
	*/
	l0 = cp1 - cp2; l1 = cp2 - cp1;
end
always @(*) begin
	lt = (cp1 > cp2)? l0 : l1;
	/*
	case(cnt)
		73: lt = (out1[0] > out2[0]) ? l0 : l1;
		74: lt = (out1[1] > out2[1]) ? l0 : l1;
		75: lt = (out1[2] > out2[2]) ? l0 : l1;
		76: lt = (out1[3] > out2[3]) ? l0 : l1;
	endcase
	*/
end
GATED_OR GATED_l_total (.CLOCK(clk), .SLEEP_CTRL(!( cnt == 0 ||(cnt >= 72 && cnt <= 75)) && cg_en), .RST_N(rst_n), .CLOCK_GATED(l_total_clk));
always @(posedge l_total_clk or negedge rst_n) begin
	if (!rst_n) begin
		l_total <= 0;
	end
	else begin
		l_total <= l_total_ns;
	end
end
always @(*) begin
	l_total_ns = l_total; 
	case(cnt)
		0: l_total_ns = 0;
		72,73,74,75: l_total_ns = l_total + lt;
	endcase
end

wire out_clk;
GATED_OR GATED_out (.CLOCK(clk), .SLEEP_CTRL(!(cnt == 75 || cnt == 76) && cg_en), .RST_N(rst_n), .CLOCK_GATED(out_clk));
always @(posedge out_clk or negedge rst_n) begin
	if (!rst_n) begin
		out_data <= 0;
	end
	else if (cnt == 75) begin 
		out_data <= (l_total_ns >= 16)? (l_total_ns) :0 ;
	end
	else begin
		out_data <= 0;
	end
end
always @(posedge out_clk or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 0;
	end
	else if (cnt == 75) begin 
		out_valid <= 1;
	end
	else begin
		out_valid <= 0;
	end
end


endmodule
