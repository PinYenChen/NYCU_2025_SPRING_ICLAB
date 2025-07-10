//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Two Head Attention
//   Author     		: Yu-Chi Lin (a6121461214.st12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : ATTN.v
//   Module Name : ATTN
//   Release version : V1.0 (Release Date: 2025-3)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


module ATTN(
    //Input Port
    clk,
    rst_n,

    in_valid,
    in_str,
    q_weight,
    k_weight,
    v_weight,
    out_weight,

    //Output Port
    out_valid,
    out
    );

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;
parameter sqare_root_2 = 32'b00111111101101010000010011110011;
/*
parameter IDLE = 3'd0;
parameter IN = 3'd1;
parameter CAL = 3'd2;
parameter OUT = 3'd3;
*/
typedef enum reg[1:0]{IDLE=2'd0,INPUT = 2'd1, SCORE = 2'd2}state;
state cur_state,nxt_state;

input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] in_str, q_weight, k_weight, v_weight, out_weight;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

integer i,j;
//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg out_valid_ns;
reg [inst_sig_width+inst_exp_width:0] out_ns;

reg [inst_sig_width+inst_exp_width:0] in_str_reg[0:4][0:3];
reg [inst_sig_width+inst_exp_width:0] in_str_reg_ns[0:4][0:3];
reg [inst_sig_width+inst_exp_width:0] qt_reg[0:3][0:3], kt_reg[0:3][0:3], vt_reg[0:3][0:3], outt_reg[0:3][0:3];
reg [inst_sig_width+inst_exp_width:0] qt_reg_ns[0:3][0:3], kt_reg_ns[0:3][0:3], vt_reg_ns[0:3][0:3], outt_reg_ns[0:3][0:3];
reg [inst_sig_width+inst_exp_width:0] score_reg_ns[0:4][0:4], score_reg[0:4][0:4];
reg [inst_sig_width+inst_exp_width:0] score1_reg_ns[0:4][0:4], score1_reg[0:4][0:4];

reg [2:0] in_col_cnt_ns,in_col_cnt;
reg [2:0] in_row_cnt_ns,in_row_cnt;
reg [2:0] row_cnt,row_cnt_ns,col_cnt,col_cnt_ns;

//reg [5:0] in_cnt, in_cnt_ns;
reg [5:0] cnt, cnt_ns; // cnt:0-63
reg [inst_sig_width+inst_exp_width:0] KT_reg_ns[0:3][0:4], KT_reg[0:3][0:4];
reg [inst_sig_width+inst_exp_width:0] Q_reg_ns[0:4][0:3], Q_reg[0:4][0:3];
reg [inst_sig_width+inst_exp_width:0] V_reg_ns[0:4][0:3], V_reg[0:4][0:3];
reg [inst_sig_width+inst_exp_width:0]head_ns[0:4][0:3], head[0:4][0:3];
//reg [3:0]counter_column, counter_row, counter_column_ns, counter_row_ns;
//reg [3:0]counter_column1, counter_row1,counter_column1_ns, counter_row1_ns;

//reg [inst_sig_width+inst_exp_width:0] R_reg_ns[0:4][0:3], R_reg[0:4][0:3]; // for check
//---------------------------------------------------------------------
// IPs
//---------------------------------------------------------------------
// ex.
//DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
//MUL1 ( .a(mul1_a), .b(mul1_b), .rnd(3'b000), .z(mul1_res), .status(mul_status1));
reg [inst_sig_width+inst_exp_width:0] mul1_a, mul1_b, mul1_res;
reg [inst_sig_width+inst_exp_width:0] mul1_a_ns, mul1_b_ns, mul1_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul2_a, mul2_b, mul2_res;
reg [inst_sig_width+inst_exp_width:0] mul2_a_ns, mul2_b_ns, mul2_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul3_a, mul3_b, mul3_res;
reg [inst_sig_width+inst_exp_width:0] mul3_a_ns, mul3_b_ns, mul3_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul4_a, mul4_b, mul4_res;
reg [inst_sig_width+inst_exp_width:0] mul4_a_ns, mul4_b_ns, mul4_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul5_a, mul5_b, mul5_res;
reg [inst_sig_width+inst_exp_width:0] mul5_a_ns, mul5_b_ns, mul5_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul6_a, mul6_b, mul6_res;
reg [inst_sig_width+inst_exp_width:0] mul6_a_ns, mul6_b_ns, mul6_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul7_a, mul7_b, mul7_res;
reg [inst_sig_width+inst_exp_width:0] mul7_a_ns, mul7_b_ns, mul7_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul8_a, mul8_b, mul8_res;
reg [inst_sig_width+inst_exp_width:0] mul8_a_ns, mul8_b_ns, mul8_res_ns;
reg [inst_sig_width+inst_exp_width:0] div1,div2,dived1,dived2,div1_res,div2_res,div1_res_ns,div2_res_ns, div1_ns,div2_ns, dived1_ns,dived2_ns;
reg [inst_sig_width+inst_exp_width:0] exp1_res,exp1_res_ns,exp1_ns,exp1;
reg [inst_sig_width+inst_exp_width:0] soft_denom, soft_denom1, soft_denom1_ns, soft_denom_ns;
reg [inst_sig_width+inst_exp_width:0] a1_exp,b1_exp,c1_exp,c1_exp_ns;
reg [inst_sig_width+inst_exp_width:0] c3,c3_ns;
reg [inst_sig_width+inst_exp_width:0] c6,c6_ns;
reg [inst_sig_width+inst_exp_width:0] a1,a2,a3,b1,b2,b3,c2,c1,a4,a5,b4,b5,a6,b6,c4,c5;
reg [inst_sig_width+inst_exp_width:0] temp_ns;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        soft_denom <= 0;
        soft_denom1 <= 0;
    end
    else begin
        soft_denom <= soft_denom_ns;
        soft_denom1 <= soft_denom1_ns;

    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div1 <= 0; div2 <= 0;
    end
    else begin
        div1 <= div1_ns; div2<= div2_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul1_a <= 0; mul1_b <= 0;
        mul2_a <= 0; mul2_b <= 0;
        mul3_a <= 0; mul3_b <= 0;
        mul4_a <= 0; mul4_b <= 0;
        mul5_a <= 0; mul5_b <= 0;
        mul6_a <= 0; mul6_b <= 0;
        mul7_a <= 0; mul7_b <= 0;
        mul8_a <= 0; mul8_b <= 0;
    end
    else begin
        mul1_a <= mul1_a_ns; mul1_b <= mul1_b_ns;
        mul2_a <= mul2_a_ns; mul2_b <= mul2_b_ns;
        mul3_a <= mul3_a_ns; mul3_b <= mul3_b_ns;
        mul4_a <= mul4_a_ns; mul4_b <= mul4_b_ns;
        mul5_a <= mul5_a_ns; mul5_b <= mul5_b_ns;
        mul6_a <= mul6_a_ns; mul6_b <= mul6_b_ns;
        mul7_a <= mul7_a_ns; mul7_b <= mul7_b_ns;
        mul8_a <= mul8_a_ns; mul8_b <= mul8_b_ns;        
    end
end
reg [inst_sig_width+inst_exp_width:0] mul9_a, mul9_b, mul9_res;
reg [inst_sig_width+inst_exp_width:0] mul9_a_ns, mul9_b_ns, mul9_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul10_a, mul10_b, mul10_res;
reg [inst_sig_width+inst_exp_width:0] mul10_a_ns, mul10_b_ns, mul10_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul11_a, mul11_b, mul11_res;
reg [inst_sig_width+inst_exp_width:0] mul11_a_ns, mul11_b_ns, mul11_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul12_a, mul12_b, mul12_res;
reg [inst_sig_width+inst_exp_width:0] mul12_a_ns, mul12_b_ns, mul12_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul13_a, mul13_b, mul13_res;
reg [inst_sig_width+inst_exp_width:0] mul13_a_ns, mul13_b_ns, mul13_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul14_a, mul14_b, mul14_res;
reg [inst_sig_width+inst_exp_width:0] mul14_a_ns, mul14_b_ns, mul14_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul15_a, mul15_b, mul15_res;
reg [inst_sig_width+inst_exp_width:0] mul15_a_ns, mul15_b_ns, mul15_res_ns;
reg [inst_sig_width+inst_exp_width:0] mul16_a, mul16_b, mul16_res;
reg [inst_sig_width+inst_exp_width:0] mul16_a_ns, mul16_b_ns, mul16_res_ns;
reg [inst_sig_width+inst_exp_width:0] div3,div4,dived3,dived4,div3_res,div4_res,div3_res_ns,div4_res_ns, div3_ns,div4_ns, dived3_ns,dived4_ns;
reg [inst_sig_width+inst_exp_width:0] exp2_res,exp2_res_ns,exp2_ns,exp2;
reg [inst_sig_width+inst_exp_width:0] soft_denom2, soft_denom3, soft_denom3_ns, soft_denom2_ns;
reg [inst_sig_width+inst_exp_width:0] a2_exp,b2_exp,c2_exp,c2_exp_ns;
reg [inst_sig_width+inst_exp_width:0] c9,c9_ns;
reg [inst_sig_width+inst_exp_width:0] c12,c12_ns;
reg [inst_sig_width+inst_exp_width:0] a7,a8,a9,b7,b8,b9,c8,c7,a10,a11,b10,b11,a12,b12,c10,c11;
reg [inst_sig_width+inst_exp_width:0] temp1_ns;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        soft_denom2 <= 0;
        soft_denom3 <= 0;
    end
    else begin
        soft_denom2 <= soft_denom2_ns;
        soft_denom3 <= soft_denom3_ns;

    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div3 <= 0; div4 <= 0;
    end
    else begin
        div3 <= div3_ns; div4<= div4_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul9_a <= 0; mul9_b <= 0;
        mul10_a <= 0; mul10_b <= 0;
        mul11_a <= 0; mul11_b <= 0;
        mul12_a <= 0; mul12_b <= 0;
        mul13_a <= 0; mul13_b <= 0;
        mul14_a <= 0; mul14_b <= 0;
        mul15_a <= 0; mul15_b <= 0;
        mul16_a <= 0; mul16_b <= 0;
    end
    else begin
        mul9_a <= mul9_a_ns; mul9_b <= mul9_b_ns;
        mul10_a <= mul10_a_ns; mul10_b <= mul10_b_ns;
        mul11_a <= mul11_a_ns; mul11_b <= mul11_b_ns;
        mul12_a <= mul12_a_ns; mul12_b <= mul12_b_ns;
        mul13_a <= mul13_a_ns; mul13_b <= mul13_b_ns;
        mul14_a <= mul14_a_ns; mul14_b <= mul14_b_ns;
        mul15_a <= mul15_a_ns; mul15_b <= mul15_b_ns;
        mul16_a <= mul16_a_ns; mul16_b <= mul16_b_ns;        
    end
end
//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        row_cnt <= 0;
        col_cnt <= 0;
    end
    else begin
        row_cnt <= row_cnt_ns;
        col_cnt <= col_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_row_cnt <= 0;
        in_col_cnt <= 0;
    end
    else begin
        in_row_cnt <= in_row_cnt_ns;
        in_col_cnt <= in_col_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<5;i++) begin
            for(j = 0;j<4;j++)
                head[i][j] <= 0;
        end
    end
    else begin
        for (i = 0;i<5;i++)
            for(j = 0;j<4;j++)
                head[i][j] <= head_ns[i][j];
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<5;i++) begin
            for(j = 0;j<4;j++)
                in_str_reg[i][j] <= 0;
        end
    end
    else begin
        for (i = 0;i<5;i++)
            for(j = 0;j<4;j++)
                in_str_reg[i][j] <= in_str_reg_ns[i][j];
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<4;i++) begin
            for (j = 0;j<4;j++)
                qt_reg[i][j] <= 0;
        end
    end
    else begin
        for (i = 0;i<4;i++) begin
            for (j = 0;j<4;j++)
            qt_reg[i][j] <= qt_reg_ns[i][j];
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<4;i++) begin
            for (j = 0;j<4;j++)
                kt_reg[i][j] <= 0;
        end
    end
    else begin
        for (i = 0;i<4;i++) begin
            for (j = 0;j<4;j++)
                kt_reg[i][j] <= kt_reg_ns[i][j];
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<4;i++) begin
            for (j = 0;j<4;j++)
                vt_reg[i][j] <= 0;
        end
    end
    else begin
        for (i = 0;i<4;i++) begin
            for (j = 0;j<4;j++)
                vt_reg[i][j] <= vt_reg_ns[i][j];
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<4;i++) begin
            for (j = 0;j<4;j++)
            outt_reg[i][j] <= 0;
        end
    end
    else begin
        for (i = 0;i<4;i++) begin
            for (j = 0;j<4;j++)
            outt_reg[i][j] <= outt_reg_ns[i][j];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state = IDLE;
    end
    else begin
        cur_state = nxt_state;
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_cnt <= 0;
    end
    else begin
        in_cnt <= in_cnt_ns;
    end
end
*/
always @(*) begin
    for (i = 0 ; i<5;i++) begin
        for ( j = 0; j<5;j++) begin
            score_reg_ns[i][j] = score_reg[i][j];
        end
    end
end
always @(*) begin
    for (i = 0 ; i<5;i++) begin
        for ( j = 0; j<5;j++) begin
            score1_reg_ns[i][j] = score1_reg[i][j];
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<4;i++) begin
            for (j = 0;j<5;j++) begin
                KT_reg[i][j] <= 0; 
            end
        end
    end
    else begin
        for (i = 0;i<4;i++) begin
            for (j = 0;j<5;j++) begin
                KT_reg[i][j] <= KT_reg_ns[i][j]; 
            end
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<5;i++) begin
            for (j = 0;j<4;j++) begin
                Q_reg[i][j] <= 0; 
            end
        end
    end
    else begin
        for (i = 0;i<5;i++) begin
            for (j = 0;j<4;j++) begin
                Q_reg[i][j] <= Q_reg_ns[i][j]; 
            end
        end
    end
end
// for check
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<5;i++) begin
            for (j = 0;j<4;j++) begin
                R_reg[i][j] <= 0; 
            end
        end
    end
    else begin
        for (i = 0;i<5;i++) begin
            for (j = 0;j<4;j++) begin
                R_reg[i][j] <= R_reg_ns[i][j]; 
            end
        end
    end
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<5;i++) begin
            for (j = 0;j<4;j++) begin
                V_reg[i][j] <= 0; 
            end
        end
    end
    else begin
        for (i = 0;i<5;i++) begin
            for (j = 0;j<4;j++) begin
                V_reg[i][j] <= V_reg_ns[i][j]; 
            end
        end
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_valid<=0;
    end
    else begin
        out_valid<=out_valid_ns;
    end
end
////////////////////////////////////
//        state transition
////////////////////////////////////
always @(*) begin
    case (cur_state) 
        IDLE: begin
            nxt_state = INPUT;
        end
        INPUT: begin
            if (cnt == 24) begin
                nxt_state = SCORE;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        /*
        CAL_KQ: begin
            if (cnt == 12) begin///////////////////////////////////////////////////////////////////
                nxt_state = SCORE;
            end
            else begin
                nxt_state = cur_state; 
            end
        end
        */
        SCORE : begin
            if (cnt == 58) begin
                nxt_state = IDLE;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        default: nxt_state = cur_state;
    endcase
end
////////////////////////////////////
//        reg control 
////////////////////////////////////
/*
always @(*) begin
    in_cnt_ns = in_cnt;
    if (cur_state == INPUT && in_valid) begin
        in_cnt_ns = in_cnt + 1;
    end
    else if (cur_state == INPUT && in_cnt != 0) begin
        in_cnt_ns = in_cnt + 1;
    end
    else if (cur_state == IDLE) begin
        in_cnt_ns = 0;
    end
end
*/
always @(*) begin
    for(i = 0;i<4;i++) begin
        for(j = 0;j<4;j++) begin
            kt_reg_ns[i][j] = kt_reg[i][j];
        end
    end
    if (cur_state == INPUT&& in_valid) begin
        kt_reg_ns[row_cnt][col_cnt] = k_weight;
    end
end
always @(*) begin
    for(i = 0;i<4;i++) begin
        for(j = 0;j<4;j++) begin
            qt_reg_ns[i][j] = qt_reg[i][j];
        end
    end
    if (cur_state == INPUT&& in_valid) begin
        qt_reg_ns[row_cnt][col_cnt]= q_weight;
    end
end
always @(*) begin
    for(i = 0;i<4;i++) begin
        for(j = 0;j<4;j++) begin
            vt_reg_ns[i][j] = vt_reg[i][j];
        end
    end
    if (cur_state == INPUT && in_valid) begin
        vt_reg_ns[row_cnt][col_cnt] = v_weight;
    end
end
always @(*) begin
    for(i = 0;i<4;i++) begin
        for(j = 0;j<4;j++) begin
            outt_reg_ns[i][j] = outt_reg[i][j];
        end
    end
    if (cur_state == INPUT&& in_valid) begin
        outt_reg_ns[row_cnt][col_cnt] = out_weight;
    end
end
always @(*) begin
    for(i = 0;i<5;i++) begin
        for(j = 0;j<4;j++) begin
            in_str_reg_ns[i][j] = in_str_reg[i][j];
        end
    end
    if (cur_state == INPUT&& in_valid) begin
        in_str_reg_ns[in_row_cnt][in_col_cnt] = in_str;
    end
end

always @(*) begin
    cnt_ns = cnt;
    if (cur_state == IDLE) begin
        cnt_ns = 0;
    end
    /*
    else if (cur_state == CAL_KQ && cnt != 12) begin //////////////////////////////////////////////////////////////////////
        cnt_ns = cnt + 1;
    end else if (cur_state == CAL_KQ && cnt == 12) begin//////////////////////////////////////////////////////////////////
        cnt_ns = 0; // for score state use
    end 
    */
    if (cur_state == INPUT && in_valid) begin
        cnt_ns = cnt + 1;
    end
    else if (cur_state == INPUT && cnt != 0 && cnt != 24) begin
        cnt_ns = cnt + 1;
    end
    else if (cur_state == INPUT && cnt == 24) begin
        cnt_ns = 0;
    end
    else if (cur_state == SCORE) begin
        cnt_ns = cnt+1;
    end 
end
always @(*) begin
    row_cnt_ns = row_cnt;
    if (cur_state == IDLE) begin
        row_cnt_ns = 0;
    end else if (cur_state == INPUT && row_cnt != 3 && in_valid) begin
        row_cnt_ns = row_cnt + 1;
    end else if (cur_state == INPUT && row_cnt == 3 && in_valid) begin
        row_cnt_ns = 0;
    end
end
always @(*) begin
    col_cnt_ns = col_cnt;
    if (cur_state == IDLE) begin
        col_cnt_ns = 0;
    end else if (cur_state == INPUT && row_cnt != 3 && in_valid) begin
        col_cnt_ns = col_cnt;
    end else if (cur_state == INPUT && row_cnt == 3 && in_valid) begin
        col_cnt_ns = col_cnt + 1;
    end else begin
        col_cnt_ns = 0;
    end
end
always @(*) begin
    in_row_cnt_ns = in_row_cnt;
    if (cur_state == IDLE) begin
        in_row_cnt_ns = 0;
    end else if (cur_state == INPUT && in_col_cnt == 3 && in_valid ) begin
        in_row_cnt_ns = in_row_cnt_ns + 1;
    end else if (cur_state == INPUT && in_col_cnt != 3 && in_valid) begin
        in_row_cnt_ns = in_row_cnt_ns;
    end else begin
        in_row_cnt_ns = 0;
    end
end
always @(*) begin
    in_col_cnt_ns = in_col_cnt;
    if (cur_state == IDLE) begin
        in_col_cnt_ns = 0;
    end else if (cur_state == INPUT && in_col_cnt == 3 && in_valid) begin
        in_col_cnt_ns = 0;
    end else if (cur_state == INPUT && in_col_cnt != 3 && in_valid) begin
        in_col_cnt_ns = in_col_cnt + 1;
    end
end
/*
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        counter_row<=0;
        counter_column<=0;
    end
    else begin
        counter_row <= counter_row_ns;
        counter_column <= counter_column_ns;

    end
end
*/
/*
always @(*) begin
    counter_column_ns = counter_column;
    counter_row_ns = counter_row;
    case(cur_state)
        IDLE: begin
            counter_row_ns = 0;
            counter_column_ns = 0;
        end
        
        CAL_KQ: begin
            if (counter_column == 1) begin
                counter_row_ns = counter_row + 1;
            end
            else begin
                counter_row_ns = counter_row;
            end
            if (counter_column == 0) begin
                counter_column_ns = 1;
            end
            else begin
                counter_column_ns = 0;
            end
        end
        
    endcase
end
*/
//cal k
always@(*)begin
    mul1_a_ns=mul1_a;
    mul2_a_ns=mul2_a;
    mul3_a_ns=mul3_a;
    mul4_a_ns=mul4_a;
              
    mul5_a_ns=mul5_a;
    mul6_a_ns=mul6_a;
    mul7_a_ns=mul7_a;
    mul8_a_ns=mul8_a;
    case(cur_state)
        INPUT: begin
            case(cnt) 
                4:begin mul1_a_ns = in_str_reg[0][0]; mul2_a_ns = in_str_reg[0][1]; mul3_a_ns = in_str_reg[0][2]; mul4_a_ns = in_str_reg[0][3]; end //00
                8:begin 
                    mul1_a_ns = in_str_reg[1][0]; mul2_a_ns = in_str_reg[1][1]; mul3_a_ns = in_str_reg[1][2]; mul4_a_ns = in_str_reg[1][3]; //10
                    mul5_a_ns = in_str_reg[1][0]; mul6_a_ns = in_str_reg[1][1]; mul7_a_ns = in_str_reg[1][2]; mul8_a_ns = in_str_reg[1][3]; //11
                end
                9: begin mul1_a_ns = in_str_reg[0][0]; mul2_a_ns = in_str_reg[0][1]; mul3_a_ns = in_str_reg[0][2]; mul4_a_ns = in_str_reg[0][3]; end //01
                12:begin 
                    mul1_a_ns = in_str_reg[2][0]; mul2_a_ns = in_str_reg[2][1]; mul3_a_ns = in_str_reg[2][2]; mul4_a_ns = in_str_reg[2][3]; //20
                    mul5_a_ns = in_str_reg[2][0]; mul6_a_ns = in_str_reg[2][1]; mul7_a_ns = in_str_reg[2][2]; mul8_a_ns = in_str_reg[2][3]; //21
                end                
                13:begin 
                    mul1_a_ns = in_str_reg[0][0]; mul2_a_ns = in_str_reg[0][1]; mul3_a_ns = in_str_reg[0][2]; mul4_a_ns = in_str_reg[0][3]; //02
                    mul5_a_ns = in_str_reg[1][0]; mul6_a_ns = in_str_reg[1][1]; mul7_a_ns = in_str_reg[1][2]; mul8_a_ns = in_str_reg[1][3]; //12
                end
                14:begin mul1_a_ns = in_str_reg[2][0]; mul2_a_ns = in_str_reg[2][1]; mul3_a_ns = in_str_reg[2][2]; mul4_a_ns = in_str_reg[2][3]; end //22   
                16,17:begin 
                    mul1_a_ns = in_str_reg[3][0]; mul2_a_ns = in_str_reg[3][1]; mul3_a_ns = in_str_reg[3][2]; mul4_a_ns = in_str_reg[3][3]; //30
                    mul5_a_ns = in_str_reg[3][0]; mul6_a_ns = in_str_reg[3][1]; mul7_a_ns = in_str_reg[3][2]; mul8_a_ns = in_str_reg[3][3]; //31
                end
                18:begin 
                    mul1_a_ns = in_str_reg[1][0]; mul2_a_ns = in_str_reg[1][1]; mul3_a_ns = in_str_reg[1][2]; mul4_a_ns = in_str_reg[1][3]; //13
                    mul5_a_ns = in_str_reg[2][0]; mul6_a_ns = in_str_reg[2][1]; mul7_a_ns = in_str_reg[2][2]; mul8_a_ns = in_str_reg[2][3]; //23
                end
                19:begin mul1_a_ns = in_str_reg[0][0]; mul2_a_ns = in_str_reg[0][1]; mul3_a_ns = in_str_reg[0][2]; mul4_a_ns = in_str_reg[0][3]; end //03 
                20,21:begin 
                    mul1_a_ns = in_str_reg[4][0]; mul2_a_ns = in_str_reg[4][1]; mul3_a_ns = in_str_reg[4][2]; mul4_a_ns = in_str_reg[4][3]; //40
                    mul5_a_ns = in_str_reg[4][0]; mul6_a_ns = in_str_reg[4][1]; mul7_a_ns = in_str_reg[4][2]; mul8_a_ns = in_str_reg[4][3]; //41
                end              
            endcase
        end
        /*
        CAL_KQ:begin
            mul1_a_ns=in_str_reg[counter_row][0];
            mul2_a_ns=in_str_reg[counter_row][1];
            mul3_a_ns=in_str_reg[counter_row][2];
            mul4_a_ns=in_str_reg[counter_row][3];
            
            mul5_a_ns=in_str_reg[counter_row][0];
            mul6_a_ns=in_str_reg[counter_row][1];
            mul7_a_ns=in_str_reg[counter_row][2];
            mul8_a_ns=in_str_reg[counter_row][3];
        end
        */
        SCORE: begin
            case(cnt) 
                0: begin 
                    mul1_a_ns = Q_reg[0][0]; mul2_a_ns = Q_reg[0][1];
                    mul3_a_ns = Q_reg[0][0]; mul4_a_ns = Q_reg[0][1];
                    mul5_a_ns = Q_reg[0][0]; mul6_a_ns = Q_reg[0][1];
                    mul7_a_ns = Q_reg[0][0]; mul8_a_ns = Q_reg[0][1];
                end
                1: begin
                    mul1_a_ns = Q_reg[0][0]; mul2_a_ns = Q_reg[0][1];
                    mul3_a_ns = Q_reg[1][0]; mul4_a_ns = Q_reg[1][1];
                    mul5_a_ns = Q_reg[1][0]; mul6_a_ns = Q_reg[1][1];
                    mul7_a_ns = Q_reg[1][0]; mul8_a_ns = Q_reg[1][1];
                end
                2: begin
                    mul1_a_ns = Q_reg[1][0]; mul2_a_ns = Q_reg[1][1];
                    mul3_a_ns = Q_reg[1][0]; mul4_a_ns = Q_reg[1][1];
                    mul5_a_ns = Q_reg[2][0]; mul6_a_ns = Q_reg[2][1];
                    mul7_a_ns = Q_reg[2][0]; mul8_a_ns = Q_reg[2][1];                    
                end
                3: begin
                    mul1_a_ns = Q_reg[2][0]; mul2_a_ns = Q_reg[2][1];
                    mul3_a_ns = Q_reg[2][0]; mul4_a_ns = Q_reg[2][1];
                    mul5_a_ns = Q_reg[2][0]; mul6_a_ns = Q_reg[2][1];
                    mul7_a_ns = Q_reg[3][0]; mul8_a_ns = Q_reg[3][1];                    
                end
                4: begin
                    mul1_a_ns = Q_reg[3][0]; mul2_a_ns = Q_reg[3][1];
                    mul3_a_ns = Q_reg[3][0]; mul4_a_ns = Q_reg[3][1];
                    mul5_a_ns = Q_reg[3][0]; mul6_a_ns = Q_reg[3][1];
                    mul7_a_ns = Q_reg[3][0]; mul8_a_ns = Q_reg[3][1];                    
                end
                5: begin
                    mul1_a_ns = Q_reg[4][0]; mul2_a_ns = Q_reg[4][1];
                    mul3_a_ns = Q_reg[4][0]; mul4_a_ns = Q_reg[4][1];
                    mul5_a_ns = Q_reg[4][0]; mul6_a_ns = Q_reg[4][1];
                    mul7_a_ns = Q_reg[4][0]; mul8_a_ns = Q_reg[4][1];                    
                end
                6: begin
                    mul1_a_ns = Q_reg[4][0]; mul2_a_ns = Q_reg[4][1];                  
                end
                //calculate V
                7: begin
                    mul1_a_ns = in_str_reg[0][0]; mul2_a_ns = in_str_reg[0][1];
                    mul3_a_ns = in_str_reg[0][2]; mul4_a_ns = in_str_reg[0][3];
                    mul5_a_ns = in_str_reg[0][0]; mul6_a_ns = in_str_reg[0][1];
                    mul7_a_ns = in_str_reg[0][2]; mul8_a_ns = in_str_reg[0][3];
                end
                8: begin
                    mul1_a_ns = in_str_reg[1][0]; mul2_a_ns = in_str_reg[1][1];
                    mul3_a_ns = in_str_reg[1][2]; mul4_a_ns = in_str_reg[1][3];
                    mul5_a_ns = in_str_reg[1][0]; mul6_a_ns = in_str_reg[1][1];
                    mul7_a_ns = in_str_reg[1][2]; mul8_a_ns = in_str_reg[1][3];
                end
                9: begin
                    mul1_a_ns = in_str_reg[2][0]; mul2_a_ns = in_str_reg[2][1];
                    mul3_a_ns = in_str_reg[2][2]; mul4_a_ns = in_str_reg[2][3];
                    mul5_a_ns = in_str_reg[2][0]; mul6_a_ns = in_str_reg[2][1];
                    mul7_a_ns = in_str_reg[2][2]; mul8_a_ns = in_str_reg[2][3];
                end
                10: begin
                    mul1_a_ns = in_str_reg[3][0]; mul2_a_ns = in_str_reg[3][1];
                    mul3_a_ns = in_str_reg[3][2]; mul4_a_ns = in_str_reg[3][3];
                    mul5_a_ns = in_str_reg[3][0]; mul6_a_ns = in_str_reg[3][1];
                    mul7_a_ns = in_str_reg[3][2]; mul8_a_ns = in_str_reg[3][3];
                end
                11: begin
                    mul1_a_ns = in_str_reg[4][0]; mul2_a_ns = in_str_reg[4][1];
                    mul3_a_ns = in_str_reg[4][2]; mul4_a_ns = in_str_reg[4][3];
                    mul5_a_ns = in_str_reg[4][0]; mul6_a_ns = in_str_reg[4][1];
                    mul7_a_ns = in_str_reg[4][2]; mul8_a_ns = in_str_reg[4][3];
                end
                26,27: begin
                    mul1_a_ns = score_reg[0][0]; mul2_a_ns = score_reg[0][1];
                    mul3_a_ns = score_reg[0][2]; mul4_a_ns = score_reg[0][3];
                    mul5_a_ns = score_reg[0][4];                     
                end
                28,29: begin
                    mul1_a_ns = score_reg[1][0]; mul2_a_ns = score_reg[1][1];
                    mul3_a_ns = score_reg[1][2]; mul4_a_ns = score_reg[1][3];
                    mul5_a_ns = score_reg[1][4];                     
                end
                30,31: begin
                    mul1_a_ns = score_reg[2][0]; mul2_a_ns = score_reg[2][1];
                    mul3_a_ns = score_reg[2][2]; mul4_a_ns = score_reg[2][3];
                    mul5_a_ns = score_reg[2][4];                     
                end
                32,33: begin
                    mul1_a_ns = score_reg[3][0]; mul2_a_ns = score_reg[3][1];
                    mul3_a_ns = score_reg[3][2]; mul4_a_ns = score_reg[3][3];
                    mul5_a_ns = score_reg[3][4];                     
                end
                35,36: begin
                    mul1_a_ns = score_reg[4][0]; mul2_a_ns = score_reg[4][1];
                    mul3_a_ns = score_reg[4][2]; mul4_a_ns = score_reg[4][3];
                    mul5_a_ns = div1_res; mul6_a_ns = head[0][0];
                    mul7_a_ns = head[0][1];                    
                end
                37,38,39: begin
                    mul6_a_ns = head[0][0]; mul7_a_ns = head[0][1];
                end
                40,41,42,43: begin
                    mul6_a_ns = head[1][0]; mul7_a_ns = head[1][1];
                end
                44,45,46,47: begin
                    mul6_a_ns = head[2][0]; mul7_a_ns = head[2][1];
                end
                48,49,50,51: begin
                    mul6_a_ns = head[3][0]; mul7_a_ns = head[3][1];
                end
                52,53,54,55: begin
                    mul6_a_ns = head[4][0]; mul7_a_ns = head[4][1];
                end
            endcase
        end
    endcase
end
always@(*)begin
    mul1_b_ns=mul1_b;
    mul2_b_ns=mul2_b;
    mul3_b_ns=mul3_b;
    mul4_b_ns=mul4_b;
        
    mul5_b_ns=mul5_b;
    mul6_b_ns=mul6_b;
    mul7_b_ns=mul7_b;
    mul8_b_ns=mul8_b;
    case(cur_state)
    /*
        CAL_KQ:begin
            mul1_b_ns=kt_reg[0][counter_column];
            mul2_b_ns=kt_reg[1][counter_column];
            mul3_b_ns=kt_reg[2][counter_column];
            mul4_b_ns=kt_reg[3][counter_column];
            
            mul5_b_ns=qt_reg[0][counter_column];
            mul6_b_ns=qt_reg[1][counter_column];
            mul7_b_ns=qt_reg[2][counter_column];
            mul8_b_ns=qt_reg[3][counter_column];
        end
    */
        INPUT:begin
            case(cnt) 
                4:begin mul1_b_ns = kt_reg[0][0]; mul2_b_ns = kt_reg[1][0]; mul3_b_ns = kt_reg[2][0]; mul4_b_ns = kt_reg[3][0]; end //00
                8:begin 
                    mul1_b_ns = kt_reg[0][0]; mul2_b_ns = kt_reg[1][0]; mul3_b_ns = kt_reg[2][0]; mul4_b_ns = kt_reg[3][0]; //10
                    mul5_b_ns = kt_reg[0][1]; mul6_b_ns = kt_reg[1][1]; mul7_b_ns = kt_reg[2][1]; mul8_b_ns = kt_reg[3][1]; //11
                end
                9:begin mul1_b_ns = kt_reg[0][1]; mul2_b_ns = kt_reg[1][1]; mul3_b_ns = kt_reg[2][1]; mul4_b_ns = kt_reg[3][1]; end //01
                12:begin 
                    mul1_b_ns = kt_reg[0][0]; mul2_b_ns = kt_reg[1][0]; mul3_b_ns = kt_reg[2][0]; mul4_b_ns = kt_reg[3][0]; //20
                    mul5_b_ns = kt_reg[0][1]; mul6_b_ns = kt_reg[1][1]; mul7_b_ns = kt_reg[2][1]; mul8_b_ns = kt_reg[3][1]; //21
                end                
                13:begin 
                    mul1_b_ns = kt_reg[0][2]; mul2_b_ns = kt_reg[1][2]; mul3_b_ns = kt_reg[2][2]; mul4_b_ns = kt_reg[3][2]; //02
                    mul5_b_ns = kt_reg[0][2]; mul6_b_ns = kt_reg[1][2]; mul7_b_ns = kt_reg[2][2]; mul8_b_ns = kt_reg[3][2]; //12
                end
                14:begin mul1_b_ns = kt_reg[0][2]; mul2_b_ns = kt_reg[1][2]; mul3_b_ns = kt_reg[2][2]; mul4_b_ns = kt_reg[3][2]; end //22 
                16:begin 
                    mul1_b_ns = kt_reg[0][0]; mul2_b_ns = kt_reg[1][0]; mul3_b_ns = kt_reg[2][0]; mul4_b_ns = kt_reg[3][0]; //30
                    mul5_b_ns = kt_reg[0][1]; mul6_b_ns = kt_reg[1][1]; mul7_b_ns = kt_reg[2][1]; mul8_b_ns = kt_reg[3][1]; //31
                end         
                17:begin 
                    mul1_b_ns = kt_reg[0][2]; mul2_b_ns = kt_reg[1][2]; mul3_b_ns = kt_reg[2][2]; mul4_b_ns = kt_reg[3][2]; //30
                    mul5_b_ns = kt_reg[0][3]; mul6_b_ns = kt_reg[1][3]; mul7_b_ns = kt_reg[2][3]; mul8_b_ns = kt_reg[3][3]; //31
                end 
                18:begin 
                    mul1_b_ns = kt_reg[0][3]; mul2_b_ns = kt_reg[1][3]; mul3_b_ns = kt_reg[2][3]; mul4_b_ns = kt_reg[3][3]; //13
                    mul5_b_ns = kt_reg[0][3]; mul6_b_ns = kt_reg[1][3]; mul7_b_ns = kt_reg[2][3]; mul8_b_ns = kt_reg[3][3]; //23
                end  
                19:begin 
                    mul1_b_ns = kt_reg[0][3]; mul2_b_ns = kt_reg[1][3]; mul3_b_ns = kt_reg[2][3]; mul4_b_ns = kt_reg[3][3]; //13
                end 
                20:begin 
                    mul1_b_ns = kt_reg[0][0]; mul2_b_ns = kt_reg[1][0]; mul3_b_ns = kt_reg[2][0]; mul4_b_ns = kt_reg[3][0]; //40
                    mul5_b_ns = kt_reg[0][1]; mul6_b_ns = kt_reg[1][1]; mul7_b_ns = kt_reg[2][1]; mul8_b_ns = kt_reg[3][1]; //41
                end         
                21:begin 
                    mul1_b_ns = kt_reg[0][2]; mul2_b_ns = kt_reg[1][2]; mul3_b_ns = kt_reg[2][2]; mul4_b_ns = kt_reg[3][2]; //40
                    mul5_b_ns = kt_reg[0][3]; mul6_b_ns = kt_reg[1][3]; mul7_b_ns = kt_reg[2][3]; mul8_b_ns = kt_reg[3][3]; //41
                end                      
            endcase
        end
        SCORE:begin
            case(cnt) 
                0: begin 
                    mul1_b_ns = KT_reg[0][0]; mul2_b_ns = KT_reg[1][0];
                    mul3_b_ns = KT_reg[0][1]; mul4_b_ns = KT_reg[1][1];
                    mul5_b_ns = KT_reg[0][2]; mul6_b_ns = KT_reg[1][2];
                    mul7_b_ns = KT_reg[0][3]; mul8_b_ns = KT_reg[1][3];
                end
                1:begin
                    mul1_b_ns = KT_reg[0][4]; mul2_b_ns = KT_reg[1][4];
                    mul3_b_ns = KT_reg[0][0]; mul4_b_ns = KT_reg[1][0];
                    mul5_b_ns = KT_reg[0][1]; mul6_b_ns = KT_reg[1][1];
                    mul7_b_ns = KT_reg[0][2]; mul8_b_ns = KT_reg[1][2];                    
                end
                2:begin
                    mul1_b_ns = KT_reg[0][3]; mul2_b_ns = KT_reg[1][3];
                    mul3_b_ns = KT_reg[0][4]; mul4_b_ns = KT_reg[1][4];
                    mul5_b_ns = KT_reg[0][0]; mul6_b_ns = KT_reg[1][0];
                    mul7_b_ns = KT_reg[0][1]; mul8_b_ns = KT_reg[1][1];                    
                end
                3:begin
                    mul1_b_ns = KT_reg[0][2]; mul2_b_ns = KT_reg[1][2];
                    mul3_b_ns = KT_reg[0][3]; mul4_b_ns = KT_reg[1][3];
                    mul5_b_ns = KT_reg[0][4]; mul6_b_ns = KT_reg[1][4];
                    mul7_b_ns = KT_reg[0][0]; mul8_b_ns = KT_reg[1][0];                    
                end
                4:begin
                    mul1_b_ns = KT_reg[0][1]; mul2_b_ns = KT_reg[1][1];
                    mul3_b_ns = KT_reg[0][2]; mul4_b_ns = KT_reg[1][2];
                    mul5_b_ns = KT_reg[0][3]; mul6_b_ns = KT_reg[1][3];
                    mul7_b_ns = KT_reg[0][4]; mul8_b_ns = KT_reg[1][4];                    
                end
                5:begin
                    mul1_b_ns = KT_reg[0][0]; mul2_b_ns = KT_reg[1][0];
                    mul3_b_ns = KT_reg[0][1]; mul4_b_ns = KT_reg[1][1];
                    mul5_b_ns = KT_reg[0][2]; mul6_b_ns = KT_reg[1][2];
                    mul7_b_ns = KT_reg[0][3]; mul8_b_ns = KT_reg[1][3];                    
                end
                6:begin
                    mul1_b_ns = KT_reg[0][4]; mul2_b_ns = KT_reg[1][4];                   
                end
                7,8,9,10,11:begin
                    mul1_b_ns = vt_reg[0][0]; mul2_b_ns = vt_reg[1][0];
                    mul3_b_ns = vt_reg[2][0]; mul4_b_ns = vt_reg[3][0];
                    mul5_b_ns = vt_reg[0][1]; mul6_b_ns = vt_reg[1][1];
                    mul7_b_ns = vt_reg[2][1]; mul8_b_ns = vt_reg[3][1];
                end
                26,28,30,32,35: begin
                    mul1_b_ns = V_reg[0][0]; mul2_b_ns = V_reg[1][0];
                    mul3_b_ns = V_reg[2][0]; mul4_b_ns = V_reg[3][0];
                    mul5_b_ns = V_reg[4][0];                     
                end
                27,29,31,33: begin
                    mul1_b_ns = V_reg[0][1]; mul2_b_ns = V_reg[1][1];
                    mul3_b_ns = V_reg[2][1]; mul4_b_ns = V_reg[3][1];
                    mul5_b_ns = V_reg[4][1];  
                end
                36: begin
                    mul1_b_ns = V_reg[0][1]; mul2_b_ns = V_reg[1][1];
                    mul3_b_ns = V_reg[2][1]; mul4_b_ns = V_reg[3][1];
                    mul5_b_ns = V_reg[4][1]; mul6_b_ns = outt_reg[0][0];
                    mul7_b_ns = outt_reg[1][0];                   
                end
                40,44,48,52: begin 
                    mul6_b_ns = outt_reg[0][0]; mul7_b_ns = outt_reg[1][0];
                end
                37,41,45,49,53: begin
                    mul6_b_ns = outt_reg[0][1]; mul7_b_ns = outt_reg[1][1];
                end
                38,42,46,50,54: begin
                    mul6_b_ns = outt_reg[0][2]; mul7_b_ns = outt_reg[1][2];
                end
                39,43,47,51,55: begin
                    mul6_b_ns = outt_reg[0][3]; mul7_b_ns = outt_reg[1][3];
                end


            endcase
        end
    endcase
    
end

always @(posedge clk) begin
    mul1_res <= mul1_res_ns;
    mul2_res <= mul2_res_ns;
    mul3_res <= mul3_res_ns;
    mul4_res <= mul4_res_ns;
    mul5_res <= mul5_res_ns;
    mul6_res <= mul6_res_ns;
    mul7_res <= mul7_res_ns;
    mul8_res <= mul8_res_ns;
end
always @(posedge clk) begin
    div1_res <= div1_res_ns;
    div2_res <= div2_res_ns;
end

//input of adder
always @(*) begin
    //write default
    a1 = 0; b1 = 0; a2 = 0; b2 = 0; a3 = 0; b3 = 0;
    case (cur_state) 
    /*
        CAL_KQ: begin a1 = mul1_res; b1 = mul2_res; a2 = mul3_res; b2 = mul4_res; a3 = c1; b3 = c2; end
    */
        INPUT: begin 
            case(cnt) 
                6,10,11,14,15,16,18,19,20,21,22,23:begin a1 = mul1_res; b1 = mul2_res; a2 = mul3_res; b2 = mul4_res; a3 = c1; b3 = c2; end
            endcase
        end
        SCORE:  begin
            case(cnt)
                2,3,4,5,6,7,8: begin a1 = mul1_res; b1 = mul2_res; a2 = mul3_res; b2 = mul4_res; end
                9,10,11,12,13: begin a1 = mul1_res; b1 = mul2_res; a2 = mul3_res; b2 = mul4_res; a3 = c1; b3 = c2;end
                28,29,30,31,32,33,34,35,37,38: begin a1 = mul1_res; b1 = mul2_res; a2 = mul3_res; b2 = mul4_res; a3 = c1; b3 = c2; end

            endcase
            end // for adding
    endcase
end
always @(*) begin
    //write default
    a4 = 0;a5 = 0;a6 = 0; b4 = 0; b5 = 0; b6 = 0;
    case (cur_state) 
    /*
        CAL_KQ: begin a4 = mul5_res; b4 = mul6_res; a5 = mul7_res; b5 = mul8_res; a6 = c4; b6 = c5; end*/
        INPUT: begin 
            case(cnt)
                10,14,15,18,19,20,22,23: begin a4 = mul5_res; b4 = mul6_res; a5 = mul7_res; b5 = mul8_res; a6 = c4; b6 = c5; end
            endcase
        end
        SCORE:  begin  
            case (cnt) 
                2,3,4,5,6,7,8: begin a4 = mul5_res; b4 = mul6_res; a5 = mul7_res; b5 = mul8_res;end
                9,10,11,12,13: begin a4 = mul5_res; b4 = mul6_res; a5 = mul7_res; b5 = mul8_res; a6 = c4; b6 = c5;end
                29,30,31,32,33,34,35,36: begin a4 = c3; b4 = temp_ns; end
                38,39: begin a4 = c3; b4 = temp_ns; a5 = mul6_res; b5 = mul7_res; end
                40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57: begin a5 = mul6_res; b5 = mul7_res; end
            endcase end
    endcase
end

always @(posedge clk) begin
    case (cur_state)
        SCORE: begin
            case(cnt)
                28,29,30,31,32,33,34,35,37,38: begin temp_ns <= mul5_res; end
            endcase
        end
    endcase
end
always @(*) begin
    for (i = 0;i<5;i++) begin
        for (j = 0;j<4;j++) begin
            head_ns[i][j] = head[i][j];
        end
    end
    case (cur_state)
        SCORE: begin
            case(cnt)
                29: begin head_ns[0][0] = c4; head_ns [0][2] = c10; end
                30: begin head_ns[0][1] = c4; head_ns [0][3] = c10; end
                31: begin head_ns[1][0] = c4; head_ns [1][2] = c10; end
                32: begin head_ns[1][1] = c4; head_ns [1][3] = c10; end
                33: begin head_ns[2][0] = c4; head_ns [2][2] = c10; end
                34: begin head_ns[2][1] = c4; head_ns [2][3] = c10; end
                35: begin head_ns[3][0] = c4; head_ns [3][2] = c10; end
                36: begin head_ns[3][1] = c4; head_ns [3][3] = c10; end
                38: begin head_ns[4][0] = c4; head_ns [4][2] = c10; end
                39: begin head_ns[4][1] = c4; head_ns [4][3] = c10; end
            endcase
        end
    endcase
end

always @(*) begin
    for (i = 0 ; i < 4; i++) begin
        for (j = 0;j <5 ;j++) begin
            KT_reg_ns[i][j] = KT_reg[i][j];
        end
    end
    for (i = 0 ; i < 5; i++) begin
        for (j = 0;j <4 ;j++) begin
            Q_reg_ns[i][j] = Q_reg[i][j];
        end
    end
    case(cur_state)
        INPUT:begin
            case(cnt)
                7:   begin KT_reg_ns[0][0] = c3; Q_reg_ns[0][0] = c9; end
                11:  begin KT_reg_ns[0][1] = c3; KT_reg_ns[1][1]= c6; Q_reg_ns[1][0] = c9; Q_reg_ns[1][1] = c12; end
                12:  begin KT_reg_ns[1][0] = c3; Q_reg_ns[0][1] = c9; end
                15:  begin KT_reg_ns[0][2] = c3; KT_reg_ns[1][2]= c6; Q_reg_ns[2][0] = c9; Q_reg_ns[2][1] = c12;end
                16:  begin KT_reg_ns[2][0] = c3; KT_reg_ns[2][1]= c6; Q_reg_ns[0][2] = c9; Q_reg_ns[1][2] = c12;end
                17:  begin KT_reg_ns[2][2] = c3; Q_reg_ns[2][2] = c9;end
                19:  begin KT_reg_ns[0][3] = c3; KT_reg_ns[1][3]= c6; Q_reg_ns[3][0] = c9; Q_reg_ns[3][1] = c12;end
                20:  begin KT_reg_ns[2][3] = c3; KT_reg_ns[3][3]= c6; Q_reg_ns[3][2] = c9; Q_reg_ns[3][3] = c12;end
                21:  begin KT_reg_ns[3][1] = c3; KT_reg_ns[3][2]= c6; Q_reg_ns[1][3] = c9; Q_reg_ns[2][3] = c12;end
                22:  begin KT_reg_ns[3][0] = c3; Q_reg_ns[0][3] = c9;end
                23:  begin KT_reg_ns[0][4] = c3; KT_reg_ns[1][4]= c6; Q_reg_ns[4][0] = c9; Q_reg_ns[4][1] = c12;end
                24:  begin KT_reg_ns[2][4] = c3; KT_reg_ns[3][4]= c6; Q_reg_ns[4][2] = c9; Q_reg_ns[4][3] = c12;end
            endcase
        end
    endcase 
end
always @(*) begin
    for (i = 0 ; i<5;i++) begin
        for (j = 0;j<4;j++) begin
            V_reg_ns[i][j] = V_reg[i][j]; 
        end
    end

    case(cur_state)

        SCORE:begin
            case(cnt)
                10:  begin V_reg_ns[0][0]= c3;V_reg_ns[0][1]= c6; V_reg_ns[0][2] = c9; V_reg_ns[0][3] = c12; end
                11:  begin V_reg_ns[1][0]= c3;V_reg_ns[1][1]= c6; V_reg_ns[1][2] = c9; V_reg_ns[1][3] = c12; end
                12:  begin V_reg_ns[2][0]= c3;V_reg_ns[2][1]= c6; V_reg_ns[2][2] = c9; V_reg_ns[2][3] = c12; end
                13:  begin V_reg_ns[3][0]= c3;V_reg_ns[3][1]= c6; V_reg_ns[3][2] = c9; V_reg_ns[3][3] = c12; end
                14:  begin V_reg_ns[4][0]= c3;V_reg_ns[4][1]= c6; V_reg_ns[4][2] = c9; V_reg_ns[4][3] = c12; end
            
            endcase
        end
    endcase 
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i = 0;i<5;i++) begin
            for(j = 0;j<5;j++) begin
                score_reg[i][j] <= 0;
            end
        end
    end
    else if (cur_state == SCORE) begin
        case(cnt)
            2: begin score_reg[0][0] <= c1; score_reg[0][1] <= c2; score_reg[0][2] <= c4; score_reg[0][3] <= c5; end
            3: begin score_reg[0][4] <= c1; score_reg[1][0] <= c2; score_reg[1][1] <= c4; score_reg[1][2] <= c5; end
            //from 4 -7 there are both result coming from div and also k*qt
            4: begin score_reg[1][3] <= c1; score_reg[1][4] <= c2; score_reg[2][0] <= c4; score_reg[2][1] <= c5; 
            score_reg[0][0] <= div1_res; score_reg[0][1] <= div2_res; end
            5: begin score_reg[2][2] <= c1; score_reg[2][3] <= c2; score_reg[2][4] <= c4; score_reg[3][0] <= c5; 
            score_reg[0][2] <= div1_res; score_reg[0][3] <= div2_res; end
            6: begin score_reg[3][1] <= c1; score_reg[3][2] <= c2; score_reg[3][3] <= c4; score_reg[3][4] <= c5;
            score_reg[0][4] <= div1_res; score_reg[1][0] <= div2_res; score_reg[0][0] <= exp1_res; end
            7: begin score_reg[4][0] <= c1; score_reg[4][1] <= c2; score_reg[4][2] <= c4; score_reg[4][3] <= c5;
            score_reg[1][1] <= div1_res; score_reg[1][2] <= div2_res; score_reg[0][1] <= exp1_res;end
            8: begin score_reg[4][4] <= c1; score_reg[1][3] <= div1_res; score_reg[1][4] <= div2_res; score_reg[0][2] <= exp1_res;end
            9:  begin score_reg[2][0] <= div1_res; score_reg[2][1] <= div2_res; score_reg[0][3] <= exp1_res; end 
            10: begin score_reg[2][2] <= div1_res; score_reg[2][3] <= div2_res; score_reg[0][4] <= exp1_res; end
            11: begin score_reg[2][4] <= div1_res; score_reg[3][0] <= div2_res; score_reg[1][0] <= exp1_res; end
            12: begin score_reg[3][1] <= div1_res; score_reg[3][2] <= div2_res; score_reg[1][1] <= exp1_res; end
            13: begin score_reg[3][3] <= div1_res; score_reg[3][4] <= div2_res; score_reg[1][2] <= exp1_res; end
            14: begin score_reg[4][0] <= div1_res; score_reg[4][1] <= div2_res; score_reg[1][3] <= exp1_res; end
            15: begin score_reg[4][2] <= div1_res; score_reg[4][3] <= div2_res; score_reg[1][4] <= exp1_res; end
            16: begin score_reg[4][4] <= div1_res; score_reg[2][0] <= exp1_res; score_reg[0][0] <= div2_res; end
            17: begin score_reg[2][1] <= exp1_res; score_reg[0][1] <= div1_res; score_reg[0][2] <= div2_res; end    
            18: begin score_reg[2][2] <= exp1_res; score_reg[0][3] <= div1_res; score_reg[0][4] <= div2_res; end

            19: begin score_reg[2][3] <= exp1_res; score_reg[1][0] <= div1_res; score_reg[1][1] <= div2_res; end  
            20: begin score_reg[2][4] <= exp1_res; score_reg[1][2] <= div1_res; score_reg[1][3] <= div2_res; end  
            21: begin score_reg[1][4] <= div1_res; score_reg[3][0] <= exp1_res; end  
            22: begin score_reg[3][1] <= exp1_res; end
            23: begin score_reg[2][0] <= div1_res; score_reg[2][1] <= div2_res; score_reg[3][2] <= exp1_res; end
            24: begin score_reg[2][2] <= div1_res; score_reg[2][3] <= div2_res; score_reg[3][3] <= exp1_res; end
            25: begin score_reg[2][4] <= div1_res; score_reg[3][4] <= exp1_res; end

            26: begin score_reg[4][0] <= exp1_res;  end
            27: begin score_reg[4][1] <= exp1_res;  end
            28: begin score_reg[4][2] <= exp1_res; score_reg[3][0] <= div1_res; score_reg[3][1] <= div2_res; end
 
            29: begin score_reg[4][3] <= exp1_res; score_reg[3][2] <= div1_res; score_reg[3][3] <= div2_res; end
            30: begin score_reg[4][4] <= exp1_res; score_reg[3][4] <= div1_res;end

            33: begin score_reg[4][0] <= div1_res; score_reg[4][1] <= div2_res; end 
            34: begin score_reg[4][2] <= div1_res; score_reg[4][3] <= div2_res; end
            35: begin score_reg[4][4] <= div1_res;  end
        endcase
    end
end
always @(*) begin
    exp1_ns = exp1;
    case (cur_state)
        SCORE: begin 
            case(cnt)
                4:  begin exp1_ns = div1_res; end
                5:  begin exp1_ns = score_reg[0][1]; end
                6:  begin exp1_ns = score_reg[0][2]; end
                7:  begin exp1_ns = score_reg[0][3]; end
                8:  begin exp1_ns = score_reg[0][4]; end
                9:  begin exp1_ns = score_reg[1][0]; end 
                10: begin exp1_ns = score_reg[1][1]; end 
                11: begin exp1_ns = score_reg[1][2]; end 
                12: begin exp1_ns = score_reg[1][3]; end 
                13: begin exp1_ns = score_reg[1][4]; end 
                14: begin exp1_ns = score_reg[2][0]; end 
                15: begin exp1_ns = score_reg[2][1]; end 
                16: begin exp1_ns = score_reg[2][2]; end 
                17: begin exp1_ns = score_reg[2][3]; end 
                18: begin exp1_ns = score_reg[2][4]; end 
                19: begin exp1_ns = score_reg[3][0]; end 
                20: begin exp1_ns = score_reg[3][1]; end 
                21: begin exp1_ns = score_reg[3][2]; end 
                22: begin exp1_ns = score_reg[3][3]; end 
                23: begin exp1_ns = score_reg[3][4]; end 
                24: begin exp1_ns = score_reg[4][0]; end 
                25: begin exp1_ns = score_reg[4][1]; end 
                26: begin exp1_ns = score_reg[4][2]; end 
                27: begin exp1_ns = score_reg[4][3]; end 
                28: begin exp1_ns = score_reg[4][4]; end 
            endcase
        end
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        exp1 <= 0;
        exp1_res <= 0;
    end
    else begin
        exp1 <= exp1_ns;
        exp1_res <= exp1_res_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c1_exp <= 0;
    end
    else begin
        c1_exp <= c1_exp_ns;
    end
end

always @(*) begin
    div1_ns = div1;
    div2_ns = div2;
    case(cur_state) 
        SCORE: begin
            case(cnt)
                2:  begin div1_ns = c1; div2_ns = c2 ; end
                3:  begin div1_ns = score_reg[0][2]; div2_ns = score_reg[0][3] ; end
                4:  begin div1_ns = score_reg[0][4]; div2_ns = score_reg[1][0] ; end
                5:  begin div1_ns = score_reg[1][1]; div2_ns = score_reg[1][2] ; end
                6:  begin div1_ns = score_reg[1][3]; div2_ns = score_reg[1][4] ; end
                7:  begin div1_ns = score_reg[2][0]; div2_ns = score_reg[2][1] ; end 
                8:  begin div1_ns = score_reg[2][2]; div2_ns = score_reg[2][3] ; end
                9:  begin div1_ns = score_reg[2][4]; div2_ns = score_reg[3][0] ; end
                10: begin div1_ns = score_reg[3][1]; div2_ns = score_reg[3][2] ; end
                11: begin div1_ns = score_reg[3][3]; div2_ns = score_reg[3][4] ; end
                12: begin div1_ns = score_reg[4][0]; div2_ns = score_reg[4][1] ; end
                13: begin div1_ns = score_reg[4][2]; div2_ns = score_reg[4][3] ; end
                //start to cal the output of softmax
                14: begin div1_ns = score_reg[4][4]; div2_ns = score_reg[0][0] ; end 
                15: begin div1_ns = score_reg[0][1]; div2_ns = score_reg[0][2] ; end
                16: begin div1_ns = score_reg[0][3]; div2_ns = score_reg[0][4] ; end

                17: begin div1_ns = score_reg[1][0]; div2_ns = score_reg[1][1] ; end
                18: begin div1_ns = score_reg[1][2]; div2_ns = score_reg[1][3] ; end
                19: begin div1_ns = score_reg[1][4]; end

                21: begin div1_ns = score_reg[2][0]; div2_ns = score_reg[2][1] ; end
                22: begin div1_ns = score_reg[2][2]; div2_ns = score_reg[2][3] ; end
                23: begin div1_ns = score_reg[2][4]; end

                26: begin div1_ns = score_reg[3][0]; div2_ns = score_reg[3][1] ; end
                27: begin div1_ns = score_reg[3][2]; div2_ns = score_reg[3][3] ; end
                28: begin div1_ns = score_reg[3][4]; end

                31: begin div1_ns = score_reg[4][0]; div2_ns = score_reg[4][1] ; end
                32: begin div1_ns = score_reg[4][2]; div2_ns = score_reg[4][3] ; end
                33: begin div1_ns = score_reg[4][4]; end

            endcase
        end
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dived1 <= 0;
        dived2 <= 0;
    end
    else begin
        dived1 <= dived1_ns;
        dived2 <= dived2_ns;
    end
end
//input of adder for exponential
always @(*) begin
    a1_exp = 0; b1_exp = 0;
    case (cur_state) 
        SCORE: begin
            case(cnt) 
                6,11,16,21,26: begin a1_exp = exp1_res; b1_exp = 0; end
                7,8,9,10,12,13,14,15,17,18,19,20,22,23,24,25,27,28,29,30: begin a1_exp = exp1_res; b1_exp = c1_exp; end
            endcase
        end
    endcase
end
always @(*) begin
    soft_denom_ns = soft_denom;
    case (cur_state)
        SCORE: begin
            case(cnt) 
                10: soft_denom_ns = c1_exp_ns; // save the result of denom of softmax, waiting cnt = 15 to do the division 
                20: soft_denom_ns = c1_exp_ns;
                30: soft_denom_ns = c1_exp_ns;

            endcase
        end 
    endcase
end
always @(*) begin
    soft_denom1_ns = soft_denom1;
    case (cur_state)
        SCORE: begin
            case(cnt)
            15: soft_denom1_ns = c1_exp_ns;
            25: soft_denom1_ns = c1_exp_ns;
            endcase
        end
    endcase
end

always @(*) begin
    dived1_ns = dived1;
    dived2_ns = dived2;
    case(cur_state) 
        SCORE: begin
            case(cnt)
                2,3,4,5,6,7,8,9,10,11,12,13:  begin dived1_ns = sqare_root_2; dived2_ns = sqare_root_2 ; end  
                14: begin dived1_ns = sqare_root_2; dived2_ns = soft_denom; end

                15,16: begin dived1_ns = soft_denom; dived2_ns = soft_denom; end //from 16 on, soft_denom_ns is free again
                17,18: begin dived1_ns = soft_denom1; dived2_ns = soft_denom1;end
                19: begin dived1_ns = soft_denom1; end

                21,22: begin dived1_ns = soft_denom; dived2_ns = soft_denom; end
                23: begin dived1_ns = soft_denom; end

                26,27: begin dived1_ns = soft_denom1; dived2_ns = soft_denom1;end
                28: begin dived1_ns = soft_denom1; end

                31,32: begin dived1_ns = soft_denom; dived2_ns = soft_denom; end
                33: begin dived1_ns = soft_denom; end                
            endcase
        end
    endcase
end
//output of adder
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c6 <= 0;
        c3 <= 0;
    end
    else begin
        c6 <= c6_ns;
        c3 <= c3_ns;
    end
end

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Div1( .a(div1), .b(dived1), .rnd(3'b0), .z(div1_res_ns), .status());
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Div2( .a(div2), .b(dived2), .rnd(3'b0), .z(div2_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL1 ( .a(mul1_a), .b(mul1_b), .rnd(3'b000), .z(mul1_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL2 ( .a(mul2_a), .b(mul2_b), .rnd(3'b000), .z(mul2_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL3 ( .a(mul3_a), .b(mul3_b), .rnd(3'b000), .z(mul3_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL4 ( .a(mul4_a), .b(mul4_b), .rnd(3'b000), .z(mul4_res_ns), .status());
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD1(.a(a1), .b(b1), .rnd(3'b000), .z(c1),.status() );
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD2(.a(a2), .b(b2), .rnd(3'b000), .z(c2),.status() );
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD3(.a(a3), .b(b3), .rnd(3'b000), .z(c3_ns),.status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL5 ( .a(mul5_a), .b(mul5_b), .rnd(3'b000), .z(mul5_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL6 ( .a(mul6_a), .b(mul6_b), .rnd(3'b000), .z(mul6_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL7 ( .a(mul7_a), .b(mul7_b), .rnd(3'b000), .z(mul7_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL8 ( .a(mul8_a), .b(mul8_b), .rnd(3'b000), .z(mul8_res_ns), .status());
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD4(.a(a4), .b(b4), .rnd(3'b000), .z(c4),.status() );
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD5(.a(a5), .b(b5), .rnd(3'b000), .z(c5),.status() );
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD6(.a(a6), .b(b6), .rnd(3'b000), .z(c6_ns),.status() );
DW_fp_exp  #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp_1(.a(exp1),.z(exp1_res_ns),.status());
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD_EXP(.a(a1_exp), .b(b1_exp), .rnd(3'b000), .z(c1_exp_ns),.status() );

////////////////////////////////////////////////
//              another head
////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c12 <= 0;
        c9 <= 0;
    end
    else begin
        c12 <= c12_ns;
        c9 <= c9_ns;
    end
end
/*
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        counter_row1 <= 0;
        counter_column1 <= 2;
    end
    else begin
        counter_row1 <= counter_row1_ns;
        counter_column1 <= counter_column1_ns;
    end
end
always @(*) begin
    counter_column1_ns = counter_column1;
    counter_row1_ns = counter_row1;
    case(cur_state)
        IDLE: begin counter_row1_ns = 0; counter_column1_ns = 2; end
        CAL_KQ: begin
            if (counter_column1 == 3) begin
                counter_row1_ns = counter_row1 + 1;
            end
            else begin
                counter_row1_ns = counter_row1;
            end
            if (counter_column1 == 2) begin
                counter_column1_ns = 3;
            end
            else begin
                counter_column1_ns = 2;
            end
        end
    endcase

end
*/
//cal k2
always@(*)begin
    mul9_a_ns=mul9_a;
    mul10_a_ns=mul10_a;
    mul11_a_ns=mul11_a;
    mul12_a_ns=mul12_a;
              
    mul13_a_ns=mul13_a;
    mul14_a_ns=mul14_a;
    mul15_a_ns=mul15_a;
    mul16_a_ns=mul16_a;
    case(cur_state)
    /*
        CAL_KQ:begin
            mul9_a_ns=in_str_reg[counter_row1][0];
            mul10_a_ns=in_str_reg[counter_row1][1];
            mul11_a_ns=in_str_reg[counter_row1][2];
            mul12_a_ns=in_str_reg[counter_row1][3];
            
            mul13_a_ns=in_str_reg[counter_row1][0];
            mul14_a_ns=in_str_reg[counter_row1][1];
            mul15_a_ns=in_str_reg[counter_row1][2];
            mul16_a_ns=in_str_reg[counter_row1][3];
        end
    */
        INPUT: begin
            case(cnt) 
                4:begin mul9_a_ns = in_str_reg[0][0]; mul10_a_ns = in_str_reg[0][1]; mul11_a_ns = in_str_reg[0][2]; mul12_a_ns = in_str_reg[0][3]; end //00
                8:begin 
                    mul9_a_ns = in_str_reg[1][0]; mul10_a_ns = in_str_reg[1][1]; mul11_a_ns = in_str_reg[1][2]; mul12_a_ns = in_str_reg[1][3]; //10
                    mul13_a_ns = in_str_reg[1][0]; mul14_a_ns = in_str_reg[1][1]; mul15_a_ns = in_str_reg[1][2]; mul16_a_ns = in_str_reg[1][3]; //11
                end
                9: begin mul9_a_ns = in_str_reg[0][0]; mul10_a_ns = in_str_reg[0][1]; mul11_a_ns = in_str_reg[0][2]; mul12_a_ns = in_str_reg[0][3]; end //01
                12:begin 
                    mul9_a_ns = in_str_reg[2][0]; mul10_a_ns = in_str_reg[2][1]; mul11_a_ns = in_str_reg[2][2]; mul12_a_ns = in_str_reg[2][3]; //20
                    mul13_a_ns = in_str_reg[2][0]; mul14_a_ns = in_str_reg[2][1]; mul15_a_ns = in_str_reg[2][2]; mul16_a_ns = in_str_reg[2][3]; //21
                end                
                13:begin 
                    mul9_a_ns = in_str_reg[0][0]; mul10_a_ns = in_str_reg[0][1]; mul11_a_ns = in_str_reg[0][2]; mul12_a_ns = in_str_reg[0][3]; //02
                    mul13_a_ns = in_str_reg[1][0]; mul14_a_ns = in_str_reg[1][1]; mul15_a_ns = in_str_reg[1][2]; mul16_a_ns = in_str_reg[1][3]; //12
                end
                14:begin mul9_a_ns = in_str_reg[2][0]; mul10_a_ns = in_str_reg[2][1]; mul11_a_ns = in_str_reg[2][2]; mul12_a_ns = in_str_reg[2][3]; end //22   
                16,17:begin 
                    mul9_a_ns = in_str_reg[3][0]; mul10_a_ns = in_str_reg[3][1]; mul11_a_ns = in_str_reg[3][2]; mul12_a_ns = in_str_reg[3][3]; //30
                    mul13_a_ns = in_str_reg[3][0]; mul14_a_ns = in_str_reg[3][1]; mul15_a_ns = in_str_reg[3][2]; mul16_a_ns = in_str_reg[3][3]; //31
                end
                18:begin 
                    mul9_a_ns = in_str_reg[1][0]; mul10_a_ns = in_str_reg[1][1]; mul11_a_ns = in_str_reg[1][2]; mul12_a_ns = in_str_reg[1][3]; //13
                    mul13_a_ns = in_str_reg[2][0]; mul14_a_ns = in_str_reg[2][1]; mul15_a_ns = in_str_reg[2][2]; mul16_a_ns = in_str_reg[2][3]; //23
                end
                19:begin mul9_a_ns = in_str_reg[0][0]; mul10_a_ns = in_str_reg[0][1]; mul11_a_ns = in_str_reg[0][2]; mul12_a_ns = in_str_reg[0][3]; end //03 
                20,21:begin 
                    mul9_a_ns = in_str_reg[4][0]; mul10_a_ns = in_str_reg[4][1]; mul11_a_ns = in_str_reg[4][2]; mul12_a_ns = in_str_reg[4][3]; //40
                    mul13_a_ns = in_str_reg[4][0]; mul14_a_ns = in_str_reg[4][1]; mul15_a_ns = in_str_reg[4][2]; mul16_a_ns = in_str_reg[4][3]; //41
                end              
            endcase
        end
        SCORE: begin
            case(cnt) 
                0: begin 
                    mul9_a_ns  = Q_reg[0][2]; mul10_a_ns = Q_reg[0][3];
                    mul11_a_ns = Q_reg[0][2]; mul12_a_ns = Q_reg[0][3];
                    mul13_a_ns = Q_reg[0][2]; mul14_a_ns = Q_reg[0][3];
                    mul15_a_ns = Q_reg[0][2]; mul16_a_ns = Q_reg[0][3];
                end
                1: begin
                    mul9_a_ns  = Q_reg[0][2]; mul10_a_ns = Q_reg[0][3];
                    mul11_a_ns = Q_reg[1][2]; mul12_a_ns = Q_reg[1][3];
                    mul13_a_ns = Q_reg[1][2]; mul14_a_ns = Q_reg[1][3];
                    mul15_a_ns = Q_reg[1][2]; mul16_a_ns = Q_reg[1][3];
                end
                2: begin
                    mul9_a_ns =  Q_reg[1][2]; mul10_a_ns = Q_reg[1][3];
                    mul11_a_ns = Q_reg[1][2]; mul12_a_ns = Q_reg[1][3];
                    mul13_a_ns = Q_reg[2][2]; mul14_a_ns = Q_reg[2][3];
                    mul15_a_ns = Q_reg[2][2]; mul16_a_ns = Q_reg[2][3];                    
                end
                3: begin
                    mul9_a_ns  = Q_reg[2][2]; mul10_a_ns = Q_reg[2][3];
                    mul11_a_ns = Q_reg[2][2]; mul12_a_ns = Q_reg[2][3];
                    mul13_a_ns = Q_reg[2][2]; mul14_a_ns = Q_reg[2][3];
                    mul15_a_ns = Q_reg[3][2]; mul16_a_ns = Q_reg[3][3];                    
                end
                4: begin
                    mul9_a_ns =  Q_reg[3][2]; mul10_a_ns = Q_reg[3][3];
                    mul11_a_ns = Q_reg[3][2]; mul12_a_ns = Q_reg[3][3];
                    mul13_a_ns = Q_reg[3][2]; mul14_a_ns = Q_reg[3][3];
                    mul15_a_ns = Q_reg[3][2]; mul16_a_ns = Q_reg[3][3];                    
                end
                5: begin
                    mul9_a_ns  = Q_reg[4][2]; mul10_a_ns = Q_reg[4][3];
                    mul11_a_ns = Q_reg[4][2]; mul12_a_ns = Q_reg[4][3];
                    mul13_a_ns = Q_reg[4][2]; mul14_a_ns = Q_reg[4][3];
                    mul15_a_ns = Q_reg[4][2]; mul16_a_ns = Q_reg[4][3];                    
                end
                6: begin
                    mul9_a_ns = Q_reg[4][2]; mul10_a_ns = Q_reg[4][3]; 
                end
                //calculate V
                7: begin
                    mul9_a_ns  = in_str_reg[0][0]; mul10_a_ns = in_str_reg[0][1];
                    mul11_a_ns = in_str_reg[0][2]; mul12_a_ns = in_str_reg[0][3];
                    mul13_a_ns = in_str_reg[0][0]; mul14_a_ns = in_str_reg[0][1];
                    mul15_a_ns = in_str_reg[0][2]; mul16_a_ns = in_str_reg[0][3];
                end
                8: begin
                    mul9_a_ns  = in_str_reg[1][0]; mul10_a_ns = in_str_reg[1][1];
                    mul11_a_ns = in_str_reg[1][2]; mul12_a_ns = in_str_reg[1][3];
                    mul13_a_ns = in_str_reg[1][0]; mul14_a_ns = in_str_reg[1][1];
                    mul15_a_ns = in_str_reg[1][2]; mul16_a_ns = in_str_reg[1][3];
                end
                9: begin
                    mul9_a_ns  = in_str_reg[2][0]; mul10_a_ns = in_str_reg[2][1];
                    mul11_a_ns = in_str_reg[2][2]; mul12_a_ns = in_str_reg[2][3];
                    mul13_a_ns = in_str_reg[2][0]; mul14_a_ns = in_str_reg[2][1];
                    mul15_a_ns = in_str_reg[2][2]; mul16_a_ns = in_str_reg[2][3];
                end
                10: begin
                    mul9_a_ns  = in_str_reg[3][0]; mul10_a_ns = in_str_reg[3][1];
                    mul11_a_ns = in_str_reg[3][2]; mul12_a_ns = in_str_reg[3][3];
                    mul13_a_ns = in_str_reg[3][0]; mul14_a_ns = in_str_reg[3][1];
                    mul15_a_ns = in_str_reg[3][2]; mul16_a_ns = in_str_reg[3][3];
                end
                11: begin
                    mul9_a_ns  = in_str_reg[4][0]; mul10_a_ns = in_str_reg[4][1];
                    mul11_a_ns = in_str_reg[4][2]; mul12_a_ns = in_str_reg[4][3];
                    mul13_a_ns = in_str_reg[4][0]; mul14_a_ns = in_str_reg[4][1];
                    mul15_a_ns = in_str_reg[4][2]; mul16_a_ns = in_str_reg[4][3];
                end
                26,27: begin
                    mul9_a_ns = score1_reg[0][0]; mul10_a_ns = score1_reg[0][1];
                    mul11_a_ns = score1_reg[0][2];mul12_a_ns = score1_reg[0][3];
                    mul13_a_ns = score1_reg[0][4];                     
                end
                28,29: begin
                    mul9_a_ns = score1_reg[1][0]; mul10_a_ns = score1_reg[1][1];
                    mul11_a_ns = score1_reg[1][2];mul12_a_ns = score1_reg[1][3];
                    mul13_a_ns = score1_reg[1][4];                     
                end
                30,31: begin
                    mul9_a_ns = score1_reg[2][0]; mul10_a_ns = score1_reg[2][1];
                    mul11_a_ns = score1_reg[2][2];mul12_a_ns = score1_reg[2][3];
                    mul13_a_ns = score1_reg[2][4];                     
                end
                32,33: begin
                    mul9_a_ns = score1_reg[3][0]; mul10_a_ns = score1_reg[3][1];
                    mul11_a_ns = score1_reg[3][2]; mul12_a_ns = score1_reg[3][3];
                    mul13_a_ns = score1_reg[3][4];                     
                end
                35: begin
                    mul9_a_ns = score1_reg[4][0]; mul10_a_ns = score1_reg[4][1];
                    mul11_a_ns = score1_reg[4][2]; mul12_a_ns = score1_reg[4][3];
                    mul13_a_ns = div3_res;                     
                end   
                36: begin
                    mul9_a_ns = score1_reg[4][0]; mul10_a_ns = score1_reg[4][1];
                    mul11_a_ns = score1_reg[4][2]; mul12_a_ns = score1_reg[4][3];
                    mul13_a_ns = div3_res; mul14_a_ns = head[0][2];
                    mul15_a_ns = head[0][3];
                end
                37,38,39: begin
                    mul14_a_ns = head[0][2]; mul15_a_ns = head[0][3];
                end
                40,41,42,43: begin
                    mul14_a_ns = head[1][2]; mul15_a_ns = head[1][3];
                end
                44,45,46,47: begin
                    mul14_a_ns = head[2][2]; mul15_a_ns = head[2][3];
                end 
                48,49,50,51: begin
                    mul14_a_ns = head[3][2]; mul15_a_ns = head[3][3];
                end     
                52,53,54,55: begin
                    mul14_a_ns = head[4][2]; mul15_a_ns = head[4][3];
                end        
            endcase
        end
    endcase
end
always@(*)begin
    mul9_b_ns=mul9_b;
    mul10_b_ns=mul10_b;
    mul11_b_ns=mul11_b;
    mul12_b_ns=mul12_b;
              
    mul13_b_ns=mul13_b;
    mul14_b_ns=mul14_b;
    mul15_b_ns=mul15_b;
    mul16_b_ns=mul16_b;
    case(cur_state)
    /*
        CAL_KQ:begin
            mul9_b_ns=kt_reg[0][counter_column1];
            mul10_b_ns=kt_reg[1][counter_column1];
            mul11_b_ns=kt_reg[2][counter_column1];
            mul12_b_ns=kt_reg[3][counter_column1];
            
            mul13_b_ns=qt_reg[0][counter_column1];
            mul14_b_ns=qt_reg[1][counter_column1];
            mul15_b_ns=qt_reg[2][counter_column1];
            mul16_b_ns=qt_reg[3][counter_column1];
        end
    */
        INPUT: begin
            case(cnt) 
                4:begin mul9_b_ns = qt_reg[0][0]; mul10_b_ns = qt_reg[1][0]; mul11_b_ns = qt_reg[2][0]; mul12_b_ns = qt_reg[3][0]; end //00
                8:begin 
                    mul9_b_ns = qt_reg[0][0]; mul10_b_ns = qt_reg[1][0]; mul11_b_ns = qt_reg[2][0]; mul12_b_ns = qt_reg[3][0]; //10
                    mul13_b_ns = qt_reg[0][1]; mul14_b_ns = qt_reg[1][1]; mul15_b_ns = qt_reg[2][1]; mul16_b_ns = qt_reg[3][1]; //11
                end
                9:begin mul9_b_ns = qt_reg[0][1]; mul10_b_ns = qt_reg[1][1]; mul11_b_ns = qt_reg[2][1]; mul12_b_ns = qt_reg[3][1]; end //01
                12:begin 
                    mul9_b_ns = qt_reg[0][0]; mul10_b_ns = qt_reg[1][0]; mul11_b_ns = qt_reg[2][0]; mul12_b_ns = qt_reg[3][0]; //20
                    mul13_b_ns = qt_reg[0][1]; mul14_b_ns = qt_reg[1][1]; mul15_b_ns = qt_reg[2][1]; mul16_b_ns = qt_reg[3][1]; //21
                end                
                13:begin 
                    mul9_b_ns = qt_reg[0][2]; mul10_b_ns = qt_reg[1][2]; mul11_b_ns = qt_reg[2][2]; mul12_b_ns = qt_reg[3][2]; //02
                    mul13_b_ns = qt_reg[0][2]; mul14_b_ns = qt_reg[1][2]; mul15_b_ns = qt_reg[2][2]; mul16_b_ns = qt_reg[3][2]; //12
                end
                14:begin mul9_b_ns = qt_reg[0][2]; mul10_b_ns = qt_reg[1][2]; mul11_b_ns = qt_reg[2][2]; mul12_b_ns = qt_reg[3][2]; end //22 
                16:begin 
                    mul9_b_ns = qt_reg[0][0]; mul10_b_ns = qt_reg[1][0]; mul11_b_ns = qt_reg[2][0]; mul12_b_ns = qt_reg[3][0]; //30
                    mul13_b_ns = qt_reg[0][1]; mul14_b_ns = qt_reg[1][1]; mul15_b_ns = qt_reg[2][1]; mul16_b_ns = qt_reg[3][1]; //31
                end         
                17:begin 
                    mul9_b_ns = qt_reg[0][2]; mul10_b_ns = qt_reg[1][2]; mul11_b_ns = qt_reg[2][2]; mul12_b_ns = qt_reg[3][2]; //30
                    mul13_b_ns = qt_reg[0][3]; mul14_b_ns = qt_reg[1][3]; mul15_b_ns = qt_reg[2][3]; mul16_b_ns = qt_reg[3][3]; //31
                end 
                18:begin 
                    mul9_b_ns = qt_reg[0][3]; mul10_b_ns = qt_reg[1][3]; mul11_b_ns = qt_reg[2][3]; mul12_b_ns = qt_reg[3][3]; //13
                    mul13_b_ns = qt_reg[0][3]; mul14_b_ns = qt_reg[1][3]; mul15_b_ns = qt_reg[2][3]; mul16_b_ns = qt_reg[3][3]; //23
                end  
                19:begin 
                    mul9_b_ns = qt_reg[0][3]; mul10_b_ns = qt_reg[1][3]; mul11_b_ns = qt_reg[2][3]; mul12_b_ns = qt_reg[3][3]; //13
                end 
                20:begin 
                    mul9_b_ns = qt_reg[0][0]; mul10_b_ns = qt_reg[1][0]; mul11_b_ns = qt_reg[2][0]; mul12_b_ns = qt_reg[3][0]; //40
                    mul13_b_ns = qt_reg[0][1]; mul14_b_ns = qt_reg[1][1]; mul15_b_ns = qt_reg[2][1]; mul16_b_ns = qt_reg[3][1]; //41
                end         
                21:begin 
                    mul9_b_ns = qt_reg[0][2]; mul10_b_ns = qt_reg[1][2]; mul11_b_ns = qt_reg[2][2]; mul12_b_ns = qt_reg[3][2]; //40
                    mul13_b_ns = qt_reg[0][3]; mul14_b_ns = qt_reg[1][3]; mul15_b_ns = qt_reg[2][3]; mul16_b_ns = qt_reg[3][3]; //41
                end                      
            endcase
        end
        SCORE:begin
            case(cnt) 
                0: begin 
                    mul9_b_ns  = KT_reg[2][0]; mul10_b_ns = KT_reg[3][0];
                    mul11_b_ns = KT_reg[2][1]; mul12_b_ns = KT_reg[3][1];
                    mul13_b_ns = KT_reg[2][2]; mul14_b_ns = KT_reg[3][2];
                    mul15_b_ns = KT_reg[2][3]; mul16_b_ns = KT_reg[3][3];
                end
                1:begin
                    mul9_b_ns  = KT_reg[2][4]; mul10_b_ns = KT_reg[3][4];
                    mul11_b_ns = KT_reg[2][0]; mul12_b_ns = KT_reg[3][0];
                    mul13_b_ns = KT_reg[2][1]; mul14_b_ns = KT_reg[3][1];
                    mul15_b_ns = KT_reg[2][2]; mul16_b_ns = KT_reg[3][2];                    
                end
                2:begin
                    mul9_b_ns  = KT_reg[2][3]; mul10_b_ns = KT_reg[3][3];
                    mul11_b_ns = KT_reg[2][4]; mul12_b_ns = KT_reg[3][4];
                    mul13_b_ns = KT_reg[2][0]; mul14_b_ns = KT_reg[3][0];
                    mul15_b_ns = KT_reg[2][1]; mul16_b_ns = KT_reg[3][1];                    
                end
                3:begin
                    mul9_b_ns  = KT_reg[2][2]; mul10_b_ns = KT_reg[3][2];
                    mul11_b_ns = KT_reg[2][3]; mul12_b_ns = KT_reg[3][3];
                    mul13_b_ns = KT_reg[2][4]; mul14_b_ns = KT_reg[3][4];
                    mul15_b_ns = KT_reg[2][0]; mul16_b_ns = KT_reg[3][0];                    
                end
                4:begin
                    mul9_b_ns  = KT_reg[2][1]; mul10_b_ns = KT_reg[3][1];
                    mul11_b_ns = KT_reg[2][2]; mul12_b_ns = KT_reg[3][2];
                    mul13_b_ns = KT_reg[2][3]; mul14_b_ns = KT_reg[3][3];
                    mul15_b_ns = KT_reg[2][4]; mul16_b_ns = KT_reg[3][4];                    
                end
                5:begin
                    mul9_b_ns  = KT_reg[2][0]; mul10_b_ns = KT_reg[3][0];
                    mul11_b_ns = KT_reg[2][1]; mul12_b_ns = KT_reg[3][1];
                    mul13_b_ns = KT_reg[2][2]; mul14_b_ns = KT_reg[3][2];
                    mul15_b_ns = KT_reg[2][3]; mul16_b_ns = KT_reg[3][3];                    
                end
                6:begin
                    mul9_b_ns  = KT_reg[2][4]; mul10_b_ns = KT_reg[3][4];                   
                end
                7,8,9,10,11:begin
                    mul9_b_ns  = vt_reg[0][2]; mul10_b_ns = vt_reg[1][2];
                    mul11_b_ns = vt_reg[2][2]; mul12_b_ns = vt_reg[3][2];
                    mul13_b_ns = vt_reg[0][3]; mul14_b_ns = vt_reg[1][3];
                    mul15_b_ns = vt_reg[2][3]; mul16_b_ns = vt_reg[3][3];
                end
                26,28,30,32,35: begin
                    mul9_b_ns = V_reg[0][2]; mul10_b_ns = V_reg[1][2];
                    mul11_b_ns = V_reg[2][2]; mul12_b_ns = V_reg[3][2];
                    mul13_b_ns = V_reg[4][2];                     
                end
                27,29,31,33: begin
                    mul9_b_ns = V_reg[0][3]; mul10_b_ns = V_reg[1][3];
                    mul11_b_ns = V_reg[2][3]; mul12_b_ns = V_reg[3][3];
                    mul13_b_ns = V_reg[4][3];                     
                end
                36: begin
                    mul9_b_ns = V_reg[0][3]; mul10_b_ns = V_reg[1][3];
                    mul11_b_ns = V_reg[2][3]; mul12_b_ns = V_reg[3][3];
                    mul13_b_ns = V_reg[4][3]; mul14_b_ns = outt_reg[2][0];
                    mul15_b_ns = outt_reg[3][0];                    
                end
                40,44,48,52: begin 
                    mul14_b_ns = outt_reg[2][0]; mul15_b_ns = outt_reg[3][0];
                end
                37,41,45,49,53: begin
                    mul14_b_ns = outt_reg[2][1]; mul15_b_ns = outt_reg[3][1];
                end
                38,42,46,50,54: begin
                    mul14_b_ns = outt_reg[2][2]; mul15_b_ns = outt_reg[3][2];
                end
                39,43,47,51,55: begin
                    mul14_b_ns = outt_reg[2][3]; mul15_b_ns = outt_reg[3][3];
                end
            endcase
        end
    endcase
end
always @(posedge clk) begin
    mul9_res <= mul9_res_ns;
    mul10_res <= mul10_res_ns;
    mul11_res <= mul11_res_ns;
    mul12_res <= mul12_res_ns;
    mul13_res <= mul13_res_ns;
    mul14_res <= mul14_res_ns;
    mul15_res <= mul15_res_ns;
    mul16_res <= mul16_res_ns;
end
always @(*) begin
    //write default
    a7 = 0; b7 = 0; a8 = 0; b8 = 0; a9 = 0; b9 = 0;
    case (cur_state) 
    /*
        CAL_KQ: begin a7 = mul9_res; b7 = mul10_res; a8 = mul11_res; b8 = mul12_res; a9 = c7; b9 = c8; end*/
        INPUT: begin 
            case(cnt) 
                6,10,11,14,15,16,18,19,20,21,22,23:begin a7 = mul9_res; b7 = mul10_res; a8 = mul11_res; b8 = mul12_res; a9 = c7; b9 = c8; end
            endcase
        end
        SCORE:  begin
            case(cnt)
                2,3,4,5,6,7,8: begin a7 = mul9_res; b7 = mul10_res; a8 = mul11_res; b8 = mul12_res; end
                9,10,11,12,13: begin a7 = mul9_res; b7 = mul10_res; a8 = mul11_res; b8 = mul12_res; a9 = c7; b9 = c8;end
                28,29,30,31,32,33,34,35,37,38: begin a7 = mul9_res; b7 = mul10_res; a8 = mul11_res; b8 = mul12_res; a9 = c7; b9 = c8; end
            endcase
        
            end // for adding
    endcase
end
always @(*) begin
    //write default
    a10 = 0; b10 = 0; a11 = 0; b11 = 0; a12 = 0; b12 = 0;
    case (cur_state) 
        /*CAL_KQ: begin a10 = mul13_res; b10 = mul14_res; a11 = mul15_res; b11 = mul16_res; a12 = c10; b12 = c11; end*/
        INPUT: begin 
            case(cnt)
                10,14,15,18,19,20,22,23: begin a10 = mul13_res; b10 = mul14_res; a11 = mul15_res; b11 = mul16_res; a12 = c10; b12 = c11; end
            endcase
        end
        SCORE:  begin  
            case (cnt) 
                2,3,4,5,6,7,8: begin a10 = mul13_res; b10 = mul14_res; a11 = mul15_res; b11 = mul16_res;end
                9,10,11,12,13: begin a10 = mul13_res; b10 = mul14_res; a11 = mul15_res; b11 = mul16_res; a12 = c10; b12 = c11;end
                29,30,31,32,33,34,35,36: begin a10 = c9; b10 = temp1_ns; end
                38,39: begin a10 = c9; b10 = temp1_ns; a11 = mul14_res; b11 = mul15_res; a12 = c5; b12 = c11; end
                40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57: begin a11 = mul14_res; b11 = mul15_res; a12 = c5; b12 = c11; end
            endcase end
    endcase
end
always @(posedge clk) begin
    case (cur_state)
        SCORE: begin
            case(cnt)
                28,29,30,31,32,33,34,35,37,38: begin temp1_ns <= mul13_res; end
            endcase
        end
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i = 0;i<5;i++) begin
            for(j = 0;j<5;j++) begin
                score1_reg[i][j] <= 0;
            end
        end
    end
    else if (cur_state == SCORE) begin
        case(cnt)
            2: begin score1_reg[0][0] <= c7; score1_reg[0][1] <= c8; score1_reg[0][2] <= c10; score1_reg[0][3] <= c11; end
            3: begin score1_reg[0][4] <= c7; score1_reg[1][0] <= c8; score1_reg[1][1] <= c10; score1_reg[1][2] <= c11; end
            //from 4 -7 there are both result coming from div and also k*qt
            4: begin score1_reg[1][3] <= c7; score1_reg[1][4] <= c8; score1_reg[2][0] <= c10; score1_reg[2][1] <= c11; 
            score1_reg[0][0] <= div3_res; score1_reg[0][1] <= div4_res; end
            5: begin score1_reg[2][2] <= c7; score1_reg[2][3] <= c8; score1_reg[2][4] <= c10; score1_reg[3][0] <= c11; 
            score1_reg[0][2] <= div3_res; score1_reg[0][3] <= div4_res; end
            6: begin score1_reg[3][1] <= c7; score1_reg[3][2] <= c8; score1_reg[3][3] <= c10; score1_reg[3][4] <= c11;
            score1_reg[0][4] <= div3_res; score1_reg[1][0] <= div4_res; score1_reg[0][0] <= exp2_res; end
            7: begin score1_reg[4][0] <= c7; score1_reg[4][1] <= c8; score1_reg[4][2] <= c10; score1_reg[4][3] <= c11;
            score1_reg[1][1] <= div3_res; score1_reg[1][2] <= div4_res; score1_reg[0][1] <= exp2_res;end
            8: begin score1_reg[4][4] <= c7; score1_reg[1][3] <= div3_res; score1_reg[1][4] <= div4_res; score1_reg[0][2] <= exp2_res;end
            
            9:  begin score1_reg[2][0] <= div3_res; score1_reg[2][1] <= div4_res; score1_reg[0][3] <= exp2_res; end 
            10: begin score1_reg[2][2] <= div3_res; score1_reg[2][3] <= div4_res; score1_reg[0][4] <= exp2_res; end
            11: begin score1_reg[2][4] <= div3_res; score1_reg[3][0] <= div4_res; score1_reg[1][0] <= exp2_res; end
            12: begin score1_reg[3][1] <= div3_res; score1_reg[3][2] <= div4_res; score1_reg[1][1] <= exp2_res; end
            13: begin score1_reg[3][3] <= div3_res; score1_reg[3][4] <= div4_res; score1_reg[1][2] <= exp2_res; end
            14: begin score1_reg[4][0] <= div3_res; score1_reg[4][1] <= div4_res; score1_reg[1][3] <= exp2_res; end
            15: begin score1_reg[4][2] <= div3_res; score1_reg[4][3] <= div4_res; score1_reg[1][4] <= exp2_res; end
            16: begin score1_reg[4][4] <= div3_res; score1_reg[2][0] <= exp2_res; score1_reg[0][0] <= div4_res; end
            
            17: begin score1_reg[2][1] <= exp2_res; score1_reg[0][1] <= div3_res; score1_reg[0][2] <= div4_res; end    
            18: begin score1_reg[2][2] <= exp2_res; score1_reg[0][3] <= div3_res; score1_reg[0][4] <= div4_res; end

            19: begin score1_reg[2][3] <= exp2_res; score1_reg[1][0] <= div3_res; score1_reg[1][1] <= div4_res; end  
            20: begin score1_reg[2][4] <= exp2_res; score1_reg[1][2] <= div3_res; score1_reg[1][3] <= div4_res; end  
            21: begin score1_reg[1][4] <= div3_res; score1_reg[3][0] <= exp2_res; end  
            22: begin score1_reg[3][1] <= exp2_res; end
            23: begin score1_reg[2][0] <= div3_res; score1_reg[2][1] <= div4_res; score1_reg[3][2] <= exp2_res; end
            24: begin score1_reg[2][2] <= div3_res; score1_reg[2][3] <= div4_res; score1_reg[3][3] <= exp2_res; end
            25: begin score1_reg[2][4] <= div3_res; score1_reg[3][4] <= exp2_res; end

            26: begin score1_reg[4][0] <= exp2_res;  end
            27: begin score1_reg[4][1] <= exp2_res;  end
            28: begin score1_reg[4][2] <= exp2_res; score1_reg[3][0] <= div3_res; score1_reg[3][1] <= div4_res; end
 
            29: begin score1_reg[4][3] <= exp2_res; score1_reg[3][2] <= div3_res; score1_reg[3][3] <= div4_res; end
            30: begin score1_reg[4][4] <= exp2_res; score1_reg[3][4] <= div3_res;end

            33: begin score1_reg[4][0] <= div3_res; score1_reg[4][1] <= div4_res; end 
            34: begin score1_reg[4][2] <= div3_res; score1_reg[4][3] <= div4_res; end
            35: begin score1_reg[4][4] <= div3_res;  end
            
        endcase
    end
end
always @(*) begin
    exp2_ns = exp2;
    case (cur_state)
        SCORE: begin 
            case(cnt)
                4:  begin exp2_ns = div3_res; end
                5:  begin exp2_ns = score1_reg[0][1]; end
                6:  begin exp2_ns = score1_reg[0][2]; end
                7:  begin exp2_ns = score1_reg[0][3]; end
                8:  begin exp2_ns = score1_reg[0][4]; end
                9:  begin exp2_ns = score1_reg[1][0]; end 
                10: begin exp2_ns = score1_reg[1][1]; end 
                11: begin exp2_ns = score1_reg[1][2]; end 
                12: begin exp2_ns = score1_reg[1][3]; end 
                13: begin exp2_ns = score1_reg[1][4]; end 
                14: begin exp2_ns = score1_reg[2][0]; end 
                15: begin exp2_ns = score1_reg[2][1]; end 
                16: begin exp2_ns = score1_reg[2][2]; end 
                17: begin exp2_ns = score1_reg[2][3]; end 
                18: begin exp2_ns = score1_reg[2][4]; end 
                19: begin exp2_ns = score1_reg[3][0]; end 
                20: begin exp2_ns = score1_reg[3][1]; end 
                21: begin exp2_ns = score1_reg[3][2]; end 
                22: begin exp2_ns = score1_reg[3][3]; end 
                23: begin exp2_ns = score1_reg[3][4]; end 
                24: begin exp2_ns = score1_reg[4][0]; end 
                25: begin exp2_ns = score1_reg[4][1]; end 
                26: begin exp2_ns = score1_reg[4][2]; end 
                27: begin exp2_ns = score1_reg[4][3]; end 
                28: begin exp2_ns = score1_reg[4][4]; end 
            endcase
        end
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        exp2 <= 0;
        exp2_res <= 0;
    end
    else begin
        exp2 <= exp2_ns;
        exp2_res <= exp2_res_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c2_exp <= 0;
    end
    else begin
        c2_exp <= c2_exp_ns;
    end
end
always @(*) begin
    dived3_ns = dived3;
    dived4_ns = dived4;
    case(cur_state) 
        SCORE: begin
            case(cnt)
                2,3,4,5,6,7,8,9,10,11,12,13:  begin dived3_ns = sqare_root_2; dived4_ns = sqare_root_2 ; end  
                14: begin dived3_ns = sqare_root_2; dived4_ns = soft_denom2; end

                15,16: begin dived3_ns = soft_denom2; dived4_ns = soft_denom2; end //from 16 on, soft_denom_ns is free again
                17,18: begin dived3_ns = soft_denom3; dived4_ns = soft_denom3;end
                19: begin dived3_ns = soft_denom3; end

                21,22: begin dived3_ns = soft_denom2; dived4_ns = soft_denom2; end
                23: begin dived3_ns = soft_denom2; end

                26,27: begin dived3_ns = soft_denom3; dived4_ns = soft_denom3;end
                28: begin dived3_ns = soft_denom3; end

                31,32: begin dived3_ns = soft_denom2; dived4_ns = soft_denom2; end
                33: begin dived3_ns = soft_denom2; end                
            endcase
        end
    endcase
end
always @(*) begin
    div3_ns = div3;
    div4_ns = div4;
    case(cur_state) 
        SCORE: begin
            case(cnt)
                2:  begin div3_ns = c7; div4_ns = c8 ; end
                3:  begin div3_ns = score1_reg[0][2]; div4_ns = score1_reg[0][3] ; end
                4:  begin div3_ns = score1_reg[0][4]; div4_ns = score1_reg[1][0] ; end
                5:  begin div3_ns = score1_reg[1][1]; div4_ns = score1_reg[1][2] ; end
                6:  begin div3_ns = score1_reg[1][3]; div4_ns = score1_reg[1][4] ; end
                7:  begin div3_ns = score1_reg[2][0]; div4_ns = score1_reg[2][1] ; end 
                8:  begin div3_ns = score1_reg[2][2]; div4_ns = score1_reg[2][3] ; end
                9:  begin div3_ns = score1_reg[2][4]; div4_ns = score1_reg[3][0] ; end
                10: begin div3_ns = score1_reg[3][1]; div4_ns = score1_reg[3][2] ; end
                11: begin div3_ns = score1_reg[3][3]; div4_ns = score1_reg[3][4] ; end
                12: begin div3_ns = score1_reg[4][0]; div4_ns = score1_reg[4][1] ; end
                13: begin div3_ns = score1_reg[4][2]; div4_ns = score1_reg[4][3] ; end
                //start to cal the output of softmax
                14: begin div3_ns = score1_reg[4][4]; div4_ns = score1_reg[0][0] ; end 
                15: begin div3_ns = score1_reg[0][1]; div4_ns = score1_reg[0][2] ; end
                16: begin div3_ns = score1_reg[0][3]; div4_ns = score1_reg[0][4] ; end

                17: begin div3_ns = score1_reg[1][0]; div4_ns = score1_reg[1][1] ; end
                18: begin div3_ns = score1_reg[1][2]; div4_ns = score1_reg[1][3] ; end
                19: begin div3_ns = score1_reg[1][4]; end

                21: begin div3_ns = score1_reg[2][0]; div4_ns = score1_reg[2][1] ; end
                22: begin div3_ns = score1_reg[2][2]; div4_ns = score1_reg[2][3] ; end
                23: begin div3_ns = score1_reg[2][4]; end

                26: begin div3_ns = score1_reg[3][0]; div4_ns = score1_reg[3][1] ; end
                27: begin div3_ns = score1_reg[3][2]; div4_ns = score1_reg[3][3] ; end
                28: begin div3_ns = score1_reg[3][4]; end

                31: begin div3_ns = score1_reg[4][0]; div4_ns = score1_reg[4][1] ; end
                32: begin div3_ns = score1_reg[4][2]; div4_ns = score1_reg[4][3] ; end
                33: begin div3_ns = score1_reg[4][4]; end

            endcase
        end
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dived3 <= 0;
        dived4 <= 0;
    end
    else begin
        dived3 <= dived3_ns;
        dived4 <= dived4_ns;
    end
end
always @(*) begin
    a2_exp = 0; b2_exp = 0;
    case (cur_state) 
        SCORE: begin
            case(cnt) 
                6,11,16,21,26: begin a2_exp = exp2_res; b2_exp = 0; end
                7,8,9,10,12,13,14,15,17,18,19,20,22,23,24,25,27,28,29,30: begin a2_exp = exp2_res; b2_exp = c2_exp; end
            endcase
        end
        
    endcase
end
always @(*) begin
    soft_denom2_ns = soft_denom2;
    case (cur_state)
        SCORE: begin
            case(cnt) 
                10: soft_denom2_ns = c2_exp_ns; // save the result of denom of softmax, waiting cnt = 15 to do the division 
                20: soft_denom2_ns = c2_exp_ns;
                30: soft_denom2_ns = c2_exp_ns;

            endcase
        end 
    endcase
end
always @(*) begin
    soft_denom3_ns = soft_denom3;
    case (cur_state)
        SCORE: begin
            case(cnt)
            15: soft_denom3_ns = c2_exp_ns;
            25: soft_denom3_ns = c2_exp_ns;
            endcase
        end
    endcase
end
always @(posedge clk) begin
    div3_res <= div3_res_ns;
    div4_res <= div4_res_ns;
end
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Div3( .a(div3), .b(dived3), .rnd(3'b0), .z(div3_res_ns), .status());
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) Div4( .a(div4), .b(dived4), .rnd(3'b0), .z(div4_res_ns), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL9 ( .a(mul9_a), .b(mul9_b), .rnd(3'b000), .z(mul9_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL10 ( .a(mul10_a), .b(mul10_b), .rnd(3'b000), .z(mul10_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL11 ( .a(mul11_a), .b(mul11_b), .rnd(3'b000), .z(mul11_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL12 ( .a(mul12_a), .b(mul12_b), .rnd(3'b000), .z(mul12_res_ns), .status());
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD7(.a(a7), .b(b7), .rnd(3'b000), .z(c7),.status() );
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD8(.a(a8), .b(b8), .rnd(3'b000), .z(c8),.status() );
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD9(.a(a9), .b(b9), .rnd(3'b000), .z(c9_ns),.status() );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL13 ( .a(mul13_a), .b(mul13_b), .rnd(3'b000), .z(mul13_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL14 ( .a(mul14_a), .b(mul14_b), .rnd(3'b000), .z(mul14_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL15 ( .a(mul15_a), .b(mul15_b), .rnd(3'b000), .z(mul15_res_ns), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) MUL16 ( .a(mul16_a), .b(mul16_b), .rnd(3'b000), .z(mul16_res_ns), .status());
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD10(.a(a10), .b(b10), .rnd(3'b000), .z(c10),.status() );
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD11(.a(a11), .b(b11), .rnd(3'b000), .z(c11),.status() );
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD12(.a(a12), .b(b12), .rnd(3'b000), .z(c12_ns),.status() );

DW_fp_exp  #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp_2(.a(exp2),.z(exp2_res_ns),.status());
DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD_EXP2(.a(a2_exp), .b(b2_exp), .rnd(3'b000), .z(c2_exp_ns),.status() );
/*
always @(*) begin
    for (i = 0;i<5;i++) begin
        for (j = 0;j<4;j++) begin
            R_reg_ns[i][j] = R_reg[i][j]; 
        end
    end
    case (cur_state) 
        SCORE:
            case(cnt)
                39:begin R_reg_ns[0][0] = c12; end
                40:begin R_reg_ns[0][1] = c12; end
                41:begin R_reg_ns[0][2] = c12; end
                42:begin R_reg_ns[0][3] = c12; end
                43:begin R_reg_ns[1][0] = c12; end
                44:begin R_reg_ns[1][1] = c12; end
                45:begin R_reg_ns[1][2] = c12; end
                46:begin R_reg_ns[1][3] = c12; end
                47:begin R_reg_ns[2][0] = c12; end
                48:begin R_reg_ns[2][1] = c12; end
                49:begin R_reg_ns[2][2] = c12; end
                50:begin R_reg_ns[2][3] = c12; end
                51:begin R_reg_ns[3][0] = c12; end
                52:begin R_reg_ns[3][1] = c12; end
                53:begin R_reg_ns[3][2] = c12; end
                54:begin R_reg_ns[3][3] = c12; end
                55:begin R_reg_ns[4][0] = c12; end
                56:begin R_reg_ns[4][1] = c12; end
                57:begin R_reg_ns[4][2] = c12; end
                58:begin R_reg_ns[4][3] = c12; end
            endcase
    endcase
end
*/
always @(*) begin
    if (cur_state == SCORE && cnt >= 39) begin
        out_valid_ns = 1;
    end
    else begin
        out_valid_ns = 0;
    end
end
always @(*) begin
    if (cur_state == SCORE && cnt >= 39) begin
        out_ns <= c12;
    end
    else begin
        out_ns <= 0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out <= 0;
    end
    else begin
        out <= out_ns;
    end
end


endmodule
