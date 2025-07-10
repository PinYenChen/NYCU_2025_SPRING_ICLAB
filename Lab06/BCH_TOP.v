//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2025
//		Version		: v1.0
//   	File Name   : BCH_TOP.v
//   	Module Name : BCH_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "Division_IP.v"
//synopsys translate_on

module BCH_TOP(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_syndrome, 
    // Output signals
    out_valid, 
	out_location
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [3:0] in_syndrome;

output reg out_valid;
output reg [3:0] out_location;

// ===============================================================
// Reg & Wire Declaration
// ===============================================================
typedef enum reg[2:0]{IDLE = 3'd0, INPUT = 3'd1, DIVIDE = 3'd2, CAL = 3'd3, SEARCH = 3'd4, OUT = 3'd5}state;
state cur_state, nxt_state;
integer i;
reg [2:0] in_cnt, in_cnt_ns;
reg [23:0] syndrome_reg, syndrome_reg_ns;
reg [27:0] dividend,dividend_ns;
reg [27:0] divisor, divisor_ns;
reg [27:0] q,q_ns;
reg [27:0] sigma[0:2],sigma_ns[0:2];
reg [27:0] omega[0:2],omega_ns[0:2];
reg [27:0] tmp_sigma, tmp_sigma_ns;
reg [27:0] tmp_omega, tmp_omega_ns;
//reg [1:0] find_cnt, find_cnt_ns;
//reg [3:0] search_cnt, search_cnt_ns;
//reg [15:0] chien,chien_ns;
//reg [3:0] out0,out1,out2,out3,out4,out5,out6,out7,out8,out9,out10,out11,out12,out13,out14;
reg num_cnt, num_cnt_ns;
reg [3:0] out_reg_ns[0:2], out_reg[0:2];
reg out_valid_ns;
reg [1:0] print_cnt, print_cnt_ns;
reg [1:0] cal_cnt, cal_cnt_ns;
reg [3:0] atoi[0:15], atoi_ns[0:15],itoa[0:15],itoa_ns[0:15];
reg [3:0] sub_sigma_a1, sub_sigma_b1, sub_sigma_out1;
reg [3:0] sub_omega_a1, sub_omega_b1, sub_omega_out1;
reg [3:0] sub_sigma_a2, sub_sigma_b2, sub_sigma_out2;
reg [3:0] sub_omega_a2, sub_omega_b2, sub_omega_out2;
reg [3:0] sub_sigma_a3, sub_sigma_b3, sub_sigma_out3;
reg [3:0] sub_omega_a3, sub_omega_b3, sub_omega_out3;
reg [3:0] sub_sigma_a4, sub_sigma_b4, sub_sigma_out4;
reg [3:0] sub_omega_a4, sub_omega_b4, sub_omega_out4;
reg [3:0] sub_sigma_a5, sub_sigma_b5, sub_sigma_out5;
reg [3:0] sub_omega_a5, sub_omega_b5, sub_omega_out5;
reg [3:0] sub_sigma_a6, sub_sigma_b6, sub_sigma_out6;
reg [3:0] sub_omega_a6, sub_omega_b6, sub_omega_out6;
reg [3:0] sub_sigma_a7, sub_sigma_b7, sub_sigma_out7;
reg [3:0] sub_omega_a7, sub_omega_b7, sub_omega_out7; 
reg [27:0] sig_mul_ns, ome_mul_ns;
reg [27:0] ome_wire, sig_wire;
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        chien <= 0;
    end
    else begin
        chien <= chien_ns;
    end
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cal_cnt <= 0;
    end
    else begin
        cal_cnt <= cal_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<3;i++) begin
            out_reg[i] <= 15;
        end
    end
    else begin
        for (i = 0;i<3;i++) begin
            out_reg[i] <= out_reg_ns[i];
        end        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        num_cnt <= 0;
    end
    else begin
        num_cnt <= num_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        print_cnt <= 0;
    end
    else begin
        print_cnt <= print_cnt_ns;
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        find_cnt <= 0;
    end
    else begin
        find_cnt <= find_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        search_cnt <= 0;
    end
    else begin
        search_cnt <= search_cnt_ns;
    end
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sigma[0] <= {28{1'b1}};
        sigma[1] <= 28'hffffff0; // initial 1;
        sigma[2] <= {28{1'b1}};
    end
    else begin
        for (i = 0;i<3;i++) begin
            sigma[i] <= sigma_ns[i];
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        omega[0] <= 28'h0ffffff; // initial (x^6);
        omega[1] <= 28'h0ffffff; // initial (x^6);
        omega[2] <= {28{1'b1}};
    end
    else begin
        for (i = 0;i<3;i++) begin
            omega[i] <= omega_ns[i];
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tmp_sigma <= 0;
    end
    else begin
        tmp_sigma <= tmp_sigma_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tmp_omega <= 0;
    end
    else begin
        tmp_omega <= tmp_omega_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        syndrome_reg <= 0;
    end
    else begin
        syndrome_reg <= syndrome_reg_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dividend <= 0;
    end
    else begin
        dividend <= dividend_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        q <= 0;
    end
    else begin
        q <= q_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        divisor <= 0;
    end
    else begin
        divisor <= divisor_ns;
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
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state <= IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end
// =====================================================
always @(*) begin
    nxt_state = cur_state;
    case(cur_state) 
        IDLE: nxt_state = INPUT;
        INPUT: begin
            if (in_cnt == 6) begin
                nxt_state = DIVIDE;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        DIVIDE: nxt_state = CAL;
        CAL: begin
            //if (cal_cnt == 2) begin
            //if (sig_wire[27:16] == 12'hfff && ome_wire[27:12] == 16'hffff) begin
            if (ome_wire[27:12] == 16'hffff) begin
                nxt_state = SEARCH;
            end
            else begin
                nxt_state = DIVIDE;
            end
            //end
            /*
            else begin
                nxt_state = cur_state;
            end
            */
        end
        SEARCH: begin
            //if (find_cnt == 3 || search_cnt == 14) begin
            nxt_state = OUT;
                /*
            end
            else begin
                nxt_state = cur_state;
            end
            */
        end
        OUT: begin
            if (print_cnt == 3) begin
                nxt_state = IDLE;
            end
            else begin
                nxt_state = cur_state;
            end
        end
    endcase
end

always @(*) begin
    in_cnt_ns = in_cnt;
    if (cur_state == INPUT) begin
        if (in_valid) begin
            in_cnt_ns = in_cnt + 1;
        end
        else begin
            in_cnt_ns = in_cnt;
        end
    end
    else if (cur_state == IDLE) begin
        in_cnt_ns = 0;
    end
end
always @(*) begin
    syndrome_reg_ns = syndrome_reg;
    if (cur_state == INPUT) begin
        if (in_valid) begin
            case(in_cnt) 
                0: syndrome_reg_ns [3 : 0] = in_syndrome;
                1: syndrome_reg_ns [7 : 4] = in_syndrome;
                2: syndrome_reg_ns [11: 8] = in_syndrome;
                3: syndrome_reg_ns [15: 12] = in_syndrome;
                4: syndrome_reg_ns [19: 16] = in_syndrome;
                5: syndrome_reg_ns [23: 20] = in_syndrome;
            endcase
        end
    end
end
always @(*) begin
    dividend_ns = dividend;
    if (cur_state == INPUT) begin
        dividend_ns = 28'h0ffffff; // initial (x^6)
    end
    else if (cur_state == CAL) begin
        //if (cal_cnt == 2) begin
        //if (sig_wire[27:16] != 12'hfff || ome_wire[27:12] != 16'hffff) begin
        if (ome_wire[27:12] != 16'hffff) begin
            dividend_ns = omega[1];
        end
        //end
    end
end
always @(*) begin
    divisor_ns = divisor;
    if (cur_state == INPUT && in_cnt == 6) begin
        divisor_ns = syndrome_reg;
        divisor_ns[27:24] = 4'b1111;
    end
    else if (cur_state == CAL) begin
            if (ome_wire[27:12] != 16'hffff) begin
                divisor_ns = ome_wire;
            end
    end
end

/*
always @(*) begin
    cal_cnt_ns = cal_cnt;
    if (cur_state == DIVIDE) begin
        cal_cnt_ns = 0;
    end
    else if (cur_state == CAL) begin
        cal_cnt_ns = cal_cnt + 1;
    end
end
*/

always @(*) begin
    ome_wire = 0;
    sig_wire = 0;
    for (i = 0;i<3;i++) begin
        sigma_ns[i] = sigma[i];
        omega_ns[i] = omega[i];
    end    

    if (cur_state == IDLE) begin
        omega_ns[0] = 28'h0ffffff; // initial (x^6);
        omega_ns[1] = 28'h0ffffff; // initial (x^6);
        omega_ns[2] = {28{1'b1}};
        sigma_ns[0] = {28{1'b1}};
        sigma_ns[1] = 28'hffffff0; // initial 1;
        sigma_ns[2] = {28{1'b1}};
    end
    else if (cur_state == INPUT) begin
        omega_ns[1][27:24] = 4'b1111;
        if (in_valid) begin
            case(in_cnt) 
            0: omega_ns[1][3:0] = in_syndrome;
            1: omega_ns[1][7:4] = in_syndrome;
            2: omega_ns[1][11:8] = in_syndrome;
            3: omega_ns[1][15:12] = in_syndrome;
            4: omega_ns[1][19:16] = in_syndrome;
            5: omega_ns[1][23:20] = in_syndrome;
            endcase
        end
    end
    else if (cur_state == CAL) begin
        /*
        case(cal_cnt)
            1: begin
            */
            sig_wire[3:0] = sub_sigma_out1;
            ome_wire[3:0] = sub_omega_out1;
            sig_wire[7:4] = sub_sigma_out2;
            ome_wire[7:4] = sub_omega_out2;
            sig_wire[11:8] = sub_sigma_out3;
            ome_wire[11:8] = sub_omega_out3;
            sig_wire[15:12] = sub_sigma_out4;
            ome_wire[15:12] = sub_omega_out4;
            sig_wire[19:16] = sub_sigma_out5;
            ome_wire[19:16] = sub_omega_out5;
            sig_wire[23:20] = sub_sigma_out6;
            ome_wire[23:20] = sub_omega_out6;
            sig_wire[27:24] = sub_sigma_out7;
            ome_wire[27:24] = sub_omega_out7;
            //end
            //2: begin
            if (ome_wire[27:12] != 16'hffff) begin // need to do iteration again
                sigma_ns[2] = 0;
                sigma_ns[1] = sig_wire;
                sigma_ns[0] = sigma[1];
                omega_ns[2] = 0;
                omega_ns[1] = ome_wire;
                omega_ns[0] = omega[1];
            end
            else begin
                sigma_ns[2] = sig_wire;
                sigma_ns[1] = sigma[1];
                sigma_ns[0] = sigma[0];
                omega_ns[2] = ome_wire;
                omega_ns[1] = omega[1];
                omega_ns[0] = omega[0];                
            end
            /*end
        endcase
        */
    end
end

always @(*) begin
    sub_sigma_a1 = 0; sub_sigma_b1 = 0;
    sub_omega_a1 = 0; sub_omega_b1 = 0;
    sub_sigma_a2 = 0; sub_sigma_b2 = 0;
    sub_omega_a2 = 0; sub_omega_b2 = 0;
    sub_sigma_a3 = 0; sub_sigma_b3 = 0;
    sub_omega_a3 = 0; sub_omega_b3 = 0;
    sub_sigma_a4 = 0; sub_sigma_b4 = 0;
    sub_omega_a4 = 0; sub_omega_b4 = 0;
    sub_sigma_a5 = 0; sub_sigma_b5 = 0;
    sub_omega_a5 = 0; sub_omega_b5 = 0;
    sub_sigma_a6 = 0; sub_sigma_b6 = 0;
    sub_omega_a6 = 0; sub_omega_b6 = 0;
    sub_sigma_a7 = 0; sub_sigma_b7 = 0;
    sub_omega_a7 = 0; sub_omega_b7 = 0; 
  
    if (cur_state == CAL) begin
        //if (cal_cnt == 1) begin
        sub_sigma_a1 = tmp_sigma_ns[3:0]; sub_sigma_b1 = sigma[0][3:0]; 
        sub_omega_a1 = tmp_omega_ns[3:0]; sub_omega_b1 = omega[0][3:0]; 
        sub_sigma_a2 = tmp_sigma_ns[7:4]; sub_sigma_b2 = sigma[0][7:4]; 
        sub_omega_a2 = tmp_omega_ns[7:4]; sub_omega_b2 = omega[0][7:4]; 
        sub_sigma_a3 = tmp_sigma_ns[11:8]; sub_sigma_b3 = sigma[0][11:8]; 
        sub_omega_a3 = tmp_omega_ns[11:8]; sub_omega_b3 = omega[0][11:8]; 
        sub_sigma_a4 = tmp_sigma_ns[15:12]; sub_sigma_b4 = sigma[0][15:12]; 
        sub_omega_a4 = tmp_omega_ns[15:12]; sub_omega_b4 = omega[0][15:12]; 
        sub_sigma_a5 = tmp_sigma_ns[19:16]; sub_sigma_b5 = sigma[0][19:16]; 
        sub_omega_a5 = tmp_omega_ns[19:16]; sub_omega_b5 = omega[0][19:16]; 
        sub_sigma_a6 = tmp_sigma_ns[23:20]; sub_sigma_b6 = sigma[0][23:20]; 
        sub_omega_a6 = tmp_omega_ns[23:20]; sub_omega_b6 = omega[0][23:20]; 
        sub_sigma_a7 = tmp_sigma_ns[27:24]; sub_sigma_b7 = sigma[0][27:24]; 
        sub_omega_a7 = tmp_omega_ns[27:24]; sub_omega_b7 = omega[0][27:24]; 
        //end
    end
end
subtractor sub_sigma1 (.A(sub_sigma_a1), .B(sub_sigma_b1), .out(sub_sigma_out1)) ;
subtractor sub_omega1 (.A(sub_omega_a1), .B(sub_omega_b1), .out(sub_omega_out1)) ;
subtractor sub_sigma2 (.A(sub_sigma_a2), .B(sub_sigma_b2), .out(sub_sigma_out2)) ;
subtractor sub_omega2 (.A(sub_omega_a2), .B(sub_omega_b2), .out(sub_omega_out2)) ;
subtractor sub_sigma3 (.A(sub_sigma_a3), .B(sub_sigma_b3), .out(sub_sigma_out3)) ;
subtractor sub_omega3 (.A(sub_omega_a3), .B(sub_omega_b3), .out(sub_omega_out3)) ;
subtractor sub_sigma4 (.A(sub_sigma_a4), .B(sub_sigma_b4), .out(sub_sigma_out4)) ;
subtractor sub_omega4 (.A(sub_omega_a4), .B(sub_omega_b4), .out(sub_omega_out4)) ;
subtractor sub_sigma5 (.A(sub_sigma_a5), .B(sub_sigma_b5), .out(sub_sigma_out5)) ;
subtractor sub_omega5 (.A(sub_omega_a5), .B(sub_omega_b5), .out(sub_omega_out5)) ;
subtractor sub_sigma6 (.A(sub_sigma_a6), .B(sub_sigma_b6), .out(sub_sigma_out6)) ;
subtractor sub_omega6 (.A(sub_omega_a6), .B(sub_omega_b6), .out(sub_omega_out6)) ;
subtractor sub_sigma7 (.A(sub_sigma_a7), .B(sub_sigma_b7), .out(sub_sigma_out7)) ;
subtractor sub_omega7 (.A(sub_omega_a7), .B(sub_omega_b7), .out(sub_omega_out7)) ;



/*
always @(*) begin
    find_cnt_ns = find_cnt;
    if (cur_state == IDLE) begin
        find_cnt_ns = 0;
    end
    else if (cur_state == SEARCH) begin
        //if find, find_cnt_ns = find_cnt + 1;
            if (out3 == 4'b0) begin
                find_cnt_ns = find_cnt + 1;
            end
    end
end
*/
/*
always @(*) begin
    for (i = 0 ;i<3;i++) begin
        out_reg_ns[i] = out_reg[i];
    end
    if (cur_state == SEARCH) begin
        if (out3 == 4'b0) begin
            out_reg_ns[find_cnt] = search_cnt;    
        end
    end
    else if (cur_state == IDLE)begin
        for (i = 0 ;i<3;i++) begin
            out_reg_ns[i] = 15;
        end        
    end
end

always @(*) begin
    search_cnt_ns = search_cnt;
    if (cur_state == SEARCH && search_cnt < 15) begin
        search_cnt_ns = search_cnt + 1;
    end
    else if (cur_state == SEARCH && search_cnt == 15) begin
        search_cnt_ns = search_cnt;
    end
    else if (cur_state == IDLE) begin
        search_cnt_ns = 0;
    end
end
*/
/*
always @(*) begin
    num_cnt_ns = num_cnt;
    if (cur_state == SEARCH) begin
        num_cnt_ns = num_cnt + 1;
    end
    else if(cur_state == IDLE) begin
        num_cnt_ns = 0;
    end
end
*/
/*
reg[3:0] search[0:42];
reg[3:0] search_sub3,search_sub2;

reg[5:0] search_cnt_3;
reg[4:0] search_cnt_2;
always@(*)begin
    search_cnt_3 = search_cnt + search_cnt + search_cnt;
    if(search_cnt_3>=15&&search_cnt_3<30)begin
        search_sub3 = search_cnt_3-15;
    end
    else if(search_cnt_3>=30)begin
        search_sub3 = search_cnt_3-30;
    end
    else begin
        search_sub3 = search_cnt_3;
    end

    search_cnt_2 = search_cnt << 1;
    if(search_cnt_2>=15)begin
        search_sub2 = search_cnt_2-15;
    end
    else begin
        search_sub2=search_cnt_2;
    end
end
always @(*) begin

    chien_ns = chien;
    out3 = 0;
    if (cur_state == SEARCH) begin
        if (sigma[2][15:12] == 15) chien_ns[15:12] = 15;
        else begin
            if (search_sub3 > sigma[2][15:12]) begin
                chien_ns[15:12] = 15 + sigma[2][15:12] - search_sub3;
            end
            else begin
                chien_ns[15:12] = sigma[2][15:12] - search_sub3;
            end
        end
        if (sigma[2][11:8] == 15) chien_ns[11:8] = 15;
        else begin
            if (search_sub2 > sigma[2][11:8]) begin
                chien_ns[11:8] = 15 + sigma[2][11:8] - search_sub2;
            end
            else begin
                chien_ns[11:8] = sigma[2][11:8] - search_sub2;
            end
        end
        if (sigma[2][7:4] == 15) chien_ns[7:4] = 15;
        else begin
            if (search_cnt > sigma[2][7:4]) begin
                chien_ns[7:4] = 15 + sigma[2][7:4] - (search_cnt);
            end
            else begin
                chien_ns[7:4] = sigma[2][7:4] - (search_cnt) ;
            end
        end
        if (sigma[2][3:0] == 15) chien_ns[3:0] = 15;
        else begin
            chien_ns[3:0] = sigma[2][3:0];
        end
        out3 = atoi[chien_ns[3:0]] ^ atoi[chien_ns[7:4]] ^ atoi[chien_ns[11:8]] ^ atoi[chien_ns[15:12]];
    end
end
*/
reg find0;
reg [2:0] find1, find2,find3,find4,find5,find6,find7,find8,find9,find10,find11,find12,find13,find14;
reg[15:0] chien_ns , chien8_ns;
reg[15:0] chien1_ns, chien9_ns;
reg[15:0] chien2_ns, chien10_ns;
reg[15:0] chien3_ns, chien11_ns;
reg[15:0] chien4_ns, chien12_ns;
reg[15:0] chien5_ns, chien13_ns;
reg[15:0] chien6_ns, chien14_ns;
reg[15:0] chien7_ns;
  
always @(*) begin
    for (i = 0 ; i<3; i++) begin
        out_reg_ns [i] = out_reg[i]; 
    end
    chien_ns = 0;  chien8_ns = 0;
    chien1_ns = 0; chien9_ns = 0;
    chien2_ns = 0; chien10_ns = 0;
    chien3_ns = 0; chien11_ns = 0;
    chien4_ns = 0; chien12_ns = 0;
    chien5_ns = 0; chien13_ns = 0;
    chien6_ns = 0; chien14_ns = 0;
    chien7_ns = 0;  
    find0 = 0; find8 = 0;
    find1 = 0; find9 = 0;
    find2 = 0; find10 = 0;
    find3 = 0; find11 = 0;
    find4 = 0; find12 = 0;
    find5 = 0; find13 = 0;
    find6 = 0; //find14 = 0;
    find7 = 0;
    if (cur_state == IDLE) begin
        for (i = 0 ; i<3; i++) begin
            out_reg_ns [i] = 15; 
        end        
    end   
    else if (cur_state == SEARCH) begin
// ================================
//              check 0
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien_ns[15:12] = 15;
        end
        else begin
            chien_ns[15:12] = sigma[2][15:12];
        end
        if (sigma[2][11:8] == 15) begin
            chien_ns[11:8] = 15;
        end
        else begin
            chien_ns[11:8] = sigma[2][11:8];
        end
        if (sigma[2][7:4] == 15) begin
            chien_ns[7:4] = 15;
        end
        else begin
            chien_ns[7:4] = sigma[2][7:4];
        end
        if (sigma[2][3:0] == 15) begin
            chien_ns[3:0] = 15;
        end
        else begin
            chien_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien_ns[3:0]] ^ atoi[chien_ns[7:4]] ^ atoi[chien_ns[11:8]] ^ atoi[chien_ns[15:12]]) == 0) begin
            out_reg_ns[0] = 0;
            find0 = 1;
        end
        else begin
            out_reg_ns[0] = 15;
            find0 = 0;
        end
// ================================
//              check 1
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien1_ns[15:12] = 15;
        end
        else begin
            if (3 > sigma[2][15:12]) begin
                chien1_ns[15:12] = 12 + sigma[2][15:12]; //15-3
            end
            else begin
                chien1_ns[15:12] = sigma[2][15:12] - 3;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien1_ns[11:8] = 15;
        end
        else begin
            if (2 > sigma[2][11:8]) begin
                chien1_ns[11:8] = 13 + sigma[2][11:8]; //15-2
            end
            else begin
                chien1_ns[11:8] = sigma[2][11:8] - 2;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien1_ns[7:4] = 15;
        end
        else begin
            if (1 > sigma[2][7:4]) begin
                chien1_ns[7:4] = 15 + sigma[2][7:4] - 1;
            end
            else begin
                chien1_ns[7:4] = sigma[2][7:4] - 1 ;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien1_ns[3:0] = 15;
        end
        else begin
            chien1_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien1_ns[3:0]] ^ atoi[chien1_ns[7:4]] ^ atoi[chien1_ns[11:8]] ^ atoi[chien1_ns[15:12]]) == 0) begin
            out_reg_ns[find0] = 1;
            find1 = find0 + 1;
        end
        else begin
            out_reg_ns[find0] = 15;
            find1 = find0;
        end
// ================================
//              check 2
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien2_ns[15:12] = 15;
        end
        else begin
            if (6 > sigma[2][15:12]) begin
                chien2_ns[15:12] = 15 + sigma[2][15:12] - 6; //15-3
            end
            else begin
                chien2_ns[15:12] = sigma[2][15:12] - 6;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien2_ns[11:8] = 15;
        end
        else begin
            if (4 > sigma[2][11:8]) begin
                chien2_ns[11:8] = 15 + sigma[2][11:8] - 4; //15-4
            end
            else begin
                chien2_ns[11:8] = sigma[2][11:8] - 4;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien2_ns[7:4] = 15;
        end
        else begin
            if (2 > sigma[2][7:4]) begin
                chien2_ns[7:4] = 15 + sigma[2][7:4] - 2;
            end
            else begin
                chien2_ns[7:4] = sigma[2][7:4] - 2 ;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien2_ns[3:0] = 15;
        end
        else begin
            chien2_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien2_ns[3:0]] ^ atoi[chien2_ns[7:4]] ^ atoi[chien2_ns[11:8]] ^ atoi[chien2_ns[15:12]]) == 0) begin
            out_reg_ns[find1] = 2;
            find2 = find1 + 1;
        end
        else begin
            out_reg_ns[find1] = 15;
            find2 = find1;
        end
// ================================
//              check 3
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien3_ns[15:12] = 15;
        end
        else begin
            if (9 > sigma[2][15:12]) begin
                chien3_ns[15:12] = 15 + sigma[2][15:12] - 9; //15-3
            end
            else begin
                chien3_ns[15:12] = sigma[2][15:12] - 9;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien3_ns[11:8] = 15;
        end
        else begin
            if (6 > sigma[2][11:8]) begin
                chien3_ns[11:8] = 15 + sigma[2][11:8] - 6; //15-4
            end
            else begin
                chien3_ns[11:8] = sigma[2][11:8] - 6;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien3_ns[7:4] = 15;
        end
        else begin
            if (3 > sigma[2][7:4]) begin
                chien3_ns[7:4] = 15 + sigma[2][7:4] - 3;
            end
            else begin
                chien3_ns[7:4] = sigma[2][7:4] - 3 ;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien3_ns[3:0] = 15;
        end
        else begin
            chien3_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien3_ns[3:0]] ^ atoi[chien3_ns[7:4]] ^ atoi[chien3_ns[11:8]] ^ atoi[chien3_ns[15:12]]) == 0) begin
            out_reg_ns[find2] = 3;
            find3 = find2 + 1;
        end
        else begin
            out_reg_ns[find2] = 15;
            find3 = find2;
        end
// ================================
//              check 4
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien4_ns[15:12] = 15;
        end
        else begin
            if (12 > sigma[2][15:12]) begin
                chien4_ns[15:12] = 15 + sigma[2][15:12] - 12; //15-3
            end
            else begin
                chien4_ns[15:12] = sigma[2][15:12] - 12;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien4_ns[11:8] = 15;
        end
        else begin
            if (8 > sigma[2][11:8]) begin
                chien4_ns[11:8] = 15 + sigma[2][11:8] - 8; //15-4
            end
            else begin
                chien4_ns[11:8] = sigma[2][11:8] - 8;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien4_ns[7:4] = 15;
        end
        else begin
            if (4 > sigma[2][7:4]) begin
                chien4_ns[7:4] = 15 + sigma[2][7:4] - 4;
            end
            else begin
                chien4_ns[7:4] = sigma[2][7:4] - 4 ;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien4_ns[3:0] = 15;
        end
        else begin
            chien4_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien4_ns[3:0]] ^ atoi[chien4_ns[7:4]] ^ atoi[chien4_ns[11:8]] ^ atoi[chien4_ns[15:12]]) == 0) begin
            out_reg_ns[find3] = 4;
            find4 = find3 + 1;
        end
        else begin
            out_reg_ns[find3] = 15;
            find4 = find3;
        end
// ================================
//              check 5
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien5_ns[15:12] = 15;
        end
        else begin
            /*
            if (12 > sigma[2][15:12]) begin
                chien5_ns[15:12] = 15 + sigma[2][15:12] - 12; //15-3
            end
            else begin*/
            chien5_ns[15:12] = sigma[2][15:12];
            //end
        end
        if (sigma[2][11:8] == 15) begin
            chien5_ns[11:8] = 15;
        end
        else begin
            if (10 > sigma[2][11:8]) begin
                chien5_ns[11:8] = 15 + sigma[2][11:8] - 10; //15-4
            end
            else begin
                chien5_ns[11:8] = sigma[2][11:8] - 10;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien5_ns[7:4] = 15;
        end
        else begin
            if (5 > sigma[2][7:4]) begin
                chien5_ns[7:4] = 15 + sigma[2][7:4] - 5;
            end
            else begin
                chien5_ns[7:4] = sigma[2][7:4] - 5 ;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien5_ns[3:0] = 15;
        end
        else begin
            chien5_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien5_ns[3:0]] ^ atoi[chien5_ns[7:4]] ^ atoi[chien5_ns[11:8]] ^ atoi[chien5_ns[15:12]]) == 0) begin
            out_reg_ns[find4] = 5;
            find5 = find4 + 1;
        end
        else begin
            out_reg_ns[find4] = 15;
            find5 = find4;
        end
// ================================
//              check 6
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien6_ns[15:12] = 15;
        end
        else begin
            if (3 > sigma[2][15:12]) begin
                chien6_ns[15:12] = 15 + sigma[2][15:12] - 3; //15-3
            end
            else begin
            chien6_ns[15:12] = sigma[2][15:12] - 3;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien6_ns[11:8] = 15;
        end
        else begin
            if (12 > sigma[2][11:8]) begin
                chien6_ns[11:8] = 15 + sigma[2][11:8] - 12; //15-4
            end
            else begin
                chien6_ns[11:8] = sigma[2][11:8] - 12;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien6_ns[7:4] = 15;
        end
        else begin
            if (6 > sigma[2][7:4]) begin
                chien6_ns[7:4] = 15 + sigma[2][7:4] - 6;
            end
            else begin
                chien6_ns[7:4] = sigma[2][7:4] - 6;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien6_ns[3:0] = 15;
        end
        else begin
            chien6_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien6_ns[3:0]] ^ atoi[chien6_ns[7:4]] ^ atoi[chien6_ns[11:8]] ^ atoi[chien6_ns[15:12]]) == 0) begin
            out_reg_ns[find5] = 6;
            find6 = find5 + 1;
        end
        else begin
            out_reg_ns[find5] = 15;
            find6 = find5;
        end
// ================================
//              check 7
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien7_ns[15:12] = 15;
        end
        else begin
            if (6 > sigma[2][15:12]) begin
                chien7_ns[15:12] = 15 + sigma[2][15:12] - 6; //15-3
            end
            else begin
            chien7_ns[15:12] = sigma[2][15:12] - 6;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien7_ns[11:8] = 15;
        end
        else begin
            if (14 > sigma[2][11:8]) begin
                chien7_ns[11:8] = 15 + sigma[2][11:8] - 14; //15-4
            end
            else begin
                chien7_ns[11:8] = sigma[2][11:8] - 14;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien7_ns[7:4] = 15;
        end
        else begin
            if (7 > sigma[2][7:4]) begin
                chien7_ns[7:4] = 15 + sigma[2][7:4] - 7;
            end
            else begin
                chien7_ns[7:4] = sigma[2][7:4] - 7;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien7_ns[3:0] = 15;
        end
        else begin
            chien7_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien7_ns[3:0]] ^ atoi[chien7_ns[7:4]] ^ atoi[chien7_ns[11:8]] ^ atoi[chien7_ns[15:12]]) == 0) begin
            out_reg_ns[find6] = 7;
            find7 = find6 + 1;
        end
        else begin
            out_reg_ns[find6] = 15;
            find7 = find6;
        end
// ================================
//              check 8
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien8_ns[15:12] = 15;
        end
        else begin
            if (9 > sigma[2][15:12]) begin
                chien8_ns[15:12] = 15 + sigma[2][15:12] - 9; //15-3
            end
            else begin
            chien8_ns[15:12] = sigma[2][15:12] - 9;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien8_ns[11:8] = 15;
        end
        else begin
            if (1 > sigma[2][11:8]) begin
                chien8_ns[11:8] = 15 + sigma[2][11:8] - 1; //15-4
            end
            else begin
                chien8_ns[11:8] = sigma[2][11:8] - 1;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien8_ns[7:4] = 15;
        end
        else begin
            if (8 > sigma[2][7:4]) begin
                chien8_ns[7:4] = 15 + sigma[2][7:4] - 8;
            end
            else begin
                chien8_ns[7:4] = sigma[2][7:4] - 8;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien8_ns[3:0] = 15;
        end
        else begin
            chien8_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien8_ns[3:0]] ^ atoi[chien8_ns[7:4]] ^ atoi[chien8_ns[11:8]] ^ atoi[chien8_ns[15:12]]) == 0) begin
            out_reg_ns[find7] = 8;
            find8 = find7 + 1;
        end
        else begin
            out_reg_ns[find7] = 15;
            find8 = find7;
        end
// ================================
//              check 9
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien9_ns[15:12] = 15;
        end
        else begin
            if (12 > sigma[2][15:12]) begin
                chien9_ns[15:12] = 15 + sigma[2][15:12] - 12; //15-3
            end
            else begin
            chien9_ns[15:12] = sigma[2][15:12] - 12;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien9_ns[11:8] = 15;
        end
        else begin
            if (3 > sigma[2][11:8]) begin
                chien9_ns[11:8] = 15 + sigma[2][11:8] - 3; //15-4
            end
            else begin
                chien9_ns[11:8] = sigma[2][11:8] - 3;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien9_ns[7:4] = 15;
        end
        else begin
            if (9 > sigma[2][7:4]) begin
                chien9_ns[7:4] = 15 + sigma[2][7:4] - 9;
            end
            else begin
                chien9_ns[7:4] = sigma[2][7:4] - 9;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien9_ns[3:0] = 15;
        end
        else begin
            chien9_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien9_ns[3:0]] ^ atoi[chien9_ns[7:4]] ^ atoi[chien9_ns[11:8]] ^ atoi[chien9_ns[15:12]]) == 0) begin
            out_reg_ns[find8] = 9;
            find9 = find8 + 1;
        end
        else begin
            out_reg_ns[find8] = 15;
            find9 = find8;
        end
// ================================
//              check 10
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien10_ns[15:12] = 15;
        end
        else begin
            /*
            if (12 > sigma[2][15:12]) begin
                chien10_ns[15:12] = 15 + sigma[2][15:12] - 12; //15-3
            end
            else begin
            */
            chien10_ns[15:12] = sigma[2][15:12];
            //end
        end
        if (sigma[2][11:8] == 15) begin
            chien10_ns[11:8] = 15;
        end
        else begin
            if (5 > sigma[2][11:8]) begin
                chien10_ns[11:8] = 15 + sigma[2][11:8] - 5; //15-4
            end
            else begin
                chien10_ns[11:8] = sigma[2][11:8] - 5;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien10_ns[7:4] = 15;
        end
        else begin
            if (10 > sigma[2][7:4]) begin
                chien10_ns[7:4] = 15 + sigma[2][7:4] - 10;
            end
            else begin
                chien10_ns[7:4] = sigma[2][7:4] - 10;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien10_ns[3:0] = 15;
        end
        else begin
            chien10_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien10_ns[3:0]] ^ atoi[chien10_ns[7:4]] ^ atoi[chien10_ns[11:8]] ^ atoi[chien10_ns[15:12]]) == 0) begin
            out_reg_ns[find9] = 10;
            find10 = find9 + 1;
        end
        else begin
            out_reg_ns[find9] = 15;
            find10 = find9;
        end
// ================================
//              check 11
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien11_ns[15:12] = 15;
        end
        else begin
            if (3 > sigma[2][15:12]) begin
                chien11_ns[15:12] = 15 + sigma[2][15:12] - 3; //15-3
            end
            else begin
            chien11_ns[15:12] = sigma[2][15:12] - 3;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien11_ns[11:8] = 15;
        end
        else begin
            if (7 > sigma[2][11:8]) begin
                chien11_ns[11:8] = 15 + sigma[2][11:8] - 7; //15-4
            end
            else begin
                chien11_ns[11:8] = sigma[2][11:8] - 7;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien11_ns[7:4] = 15;
        end
        else begin
            if (11 > sigma[2][7:4]) begin
                chien11_ns[7:4] = 15 + sigma[2][7:4] - 11;
            end
            else begin
                chien11_ns[7:4] = sigma[2][7:4] - 11;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien11_ns[3:0] = 15;
        end
        else begin
            chien11_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien11_ns[3:0]] ^ atoi[chien11_ns[7:4]] ^ atoi[chien11_ns[11:8]] ^ atoi[chien11_ns[15:12]]) == 0) begin
            out_reg_ns[find10] = 11;
            find11 = find10 + 1;
        end
        else begin
            out_reg_ns[find10] = 15;
            find11 = find10;
        end
// ================================
//              check 12
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien12_ns[15:12] = 15;
        end
        else begin
            if (6 > sigma[2][15:12]) begin
                chien12_ns[15:12] = 15 + sigma[2][15:12] - 6; //15-3
            end
            else begin
            chien12_ns[15:12] = sigma[2][15:12] - 6;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien12_ns[11:8] = 15;
        end
        else begin
            if (9 > sigma[2][11:8]) begin
                chien12_ns[11:8] = 15 + sigma[2][11:8] - 9; //15-4
            end
            else begin
                chien12_ns[11:8] = sigma[2][11:8] - 9;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien12_ns[7:4] = 15;
        end
        else begin
            if (12 > sigma[2][7:4]) begin
                chien12_ns[7:4] = 15 + sigma[2][7:4] - 12;
            end
            else begin
                chien12_ns[7:4] = sigma[2][7:4] - 12;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien12_ns[3:0] = 15;
        end
        else begin
            chien12_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien12_ns[3:0]] ^ atoi[chien12_ns[7:4]] ^ atoi[chien12_ns[11:8]] ^ atoi[chien12_ns[15:12]]) == 0) begin
            out_reg_ns[find11] = 12;
            find12 = find11 + 1;
        end
        else begin
            out_reg_ns[find11] = 15;
            find12 = find11;
        end
// ================================
//              check 13
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien13_ns[15:12] = 15;
        end
        else begin
            if (9 > sigma[2][15:12]) begin
                chien13_ns[15:12] = 15 + sigma[2][15:12] - 9; //15-3
            end
            else begin
            chien13_ns[15:12] = sigma[2][15:12] - 9;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien13_ns[11:8] = 15;
        end
        else begin
            if (11 > sigma[2][11:8]) begin
                chien13_ns[11:8] = 15 + sigma[2][11:8] - 11; //15-4
            end
            else begin
                chien13_ns[11:8] = sigma[2][11:8] - 11;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien13_ns[7:4] = 15;
        end
        else begin
            if (13 > sigma[2][7:4]) begin
                chien13_ns[7:4] = 15 + sigma[2][7:4] - 13;
            end
            else begin
                chien13_ns[7:4] = sigma[2][7:4] - 13;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien13_ns[3:0] = 15;
        end
        else begin
            chien13_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien13_ns[3:0]] ^ atoi[chien13_ns[7:4]] ^ atoi[chien13_ns[11:8]] ^ atoi[chien13_ns[15:12]]) == 0) begin
            out_reg_ns[find12] = 13;
            find13 = find12 + 1;
        end
        else begin
            out_reg_ns[find12] = 15;
            find13 = find12;
        end
// ================================
//              check 14
// ================================ 
        if (sigma[2][15:12] == 15) begin
            chien14_ns[15:12] = 15;
        end
        else begin
            if (12 > sigma[2][15:12]) begin
                chien14_ns[15:12] = 15 + sigma[2][15:12] - 12; //15-3
            end
            else begin
            chien14_ns[15:12] = sigma[2][15:12] - 12;
            end
        end
        if (sigma[2][11:8] == 15) begin
            chien14_ns[11:8] = 15;
        end
        else begin
            if (13 > sigma[2][11:8]) begin
                chien14_ns[11:8] = 15 + sigma[2][11:8] - 13; //15-4
            end
            else begin
                chien14_ns[11:8] = sigma[2][11:8] - 13;
            end
        end
        if (sigma[2][7:4] == 15) begin
            chien14_ns[7:4] = 15;
        end
        else begin
            if (14 > sigma[2][7:4]) begin
                chien14_ns[7:4] = 15 + sigma[2][7:4] - 14;
            end
            else begin
                chien14_ns[7:4] = sigma[2][7:4] - 14;
            end
        end
        if (sigma[2][3:0] == 15) begin
            chien14_ns[3:0] = 15;
        end
        else begin
            chien14_ns[3:0] = sigma[2][3:0];
        end
        if ((atoi[chien14_ns[3:0]] ^ atoi[chien14_ns[7:4]] ^ atoi[chien14_ns[11:8]] ^ atoi[chien14_ns[15:12]]) == 0) begin
            out_reg_ns[find13] = 14;
            //find14 = find13 + 1;
        end
        else begin
            out_reg_ns[find13] = 15;
            //find14 = find13;
        end                            
    end

end

always @(*) begin
    if (cur_state == OUT || cur_state == SEARCH) begin
        print_cnt_ns = print_cnt + 1;
    end
    else if (cur_state == IDLE) begin
        print_cnt_ns = 0;
    end
    else begin
        print_cnt_ns = print_cnt;
    end
end
always @(*) begin
    if ((cur_state == OUT && print_cnt < 3) || cur_state == SEARCH )begin
        out_valid_ns = 1;
    end
    else begin
        out_valid_ns = 0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_location <= 0;
    end 
    else if (cur_state == OUT && print_cnt <3 || cur_state == SEARCH) begin
        out_location <= out_reg_ns[print_cnt];
    end 
    else begin
        out_location <= 0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else begin
        out_valid <= out_valid_ns;
    end
end

always @(*) begin
    tmp_omega_ns = tmp_omega;
    tmp_sigma_ns = tmp_sigma;
    if (cur_state == CAL) begin
        //if (cal_cnt == 0) begin
        tmp_omega_ns = ome_mul_ns;
        tmp_sigma_ns = sig_mul_ns;
        //end
    end
end

multiplier_28bit sigma_mul(.a(q),.b(sigma[1]),.atoi(atoi), .itoa(itoa), .product(sig_mul_ns));
multiplier_28bit omega_mul(.a(q),.b(omega[1]),.atoi(atoi), .itoa(itoa), .product(ome_mul_ns));
Division_IP #(.IP_WIDTH(7)) soIP (.IN_Dividend(dividend),.IN_Divisor(divisor),.OUT_Quotient(q_ns));

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0 ; i<16;i++) begin
            atoi[i] <= 0;
        end
    end
    else begin
        for (i = 0 ; i<16;i++) begin
            atoi[i] <= atoi_ns[i];
        end
    end
end
always @(*) begin
    if (cur_state == IDLE )begin
        atoi_ns[0] = 1; atoi_ns[1] = 2; atoi_ns[3] = 8; atoi_ns[4] = 3; atoi_ns[5] = 6; atoi_ns[6] = 12; atoi_ns[7] = 11; atoi_ns[8] = 5;
        atoi_ns[9] = 10; atoi_ns[10] = 7; atoi_ns[11] = 14; atoi_ns[12] = 15; atoi_ns[13] = 13; atoi_ns[14] = 9; atoi_ns[15] = 0; atoi_ns[2] = 4;
    end
    else begin
        for (i = 0 ; i<16;i++) begin
            atoi_ns[i] = atoi[i];
        end        
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0 ; i<16;i++) begin
            itoa[i] <= 0;
        end
    end
    else begin
        for (i = 0 ; i<16;i++) begin
            itoa[i] <= itoa_ns[i];
        end
    end
end
always @(*) begin
    if (cur_state == IDLE )begin
        itoa_ns[0] = 15; itoa_ns[1] = 0; itoa_ns[2] = 1; itoa_ns[3] = 4; itoa_ns[4] = 2; itoa_ns[5] = 8; itoa_ns[6] = 5; itoa_ns[7] = 10;
        itoa_ns[8] = 3; itoa_ns[9] = 14; itoa_ns[10] = 9; itoa_ns[11] = 7; itoa_ns[12] = 6; itoa_ns[13] = 13; itoa_ns[14] = 11; itoa_ns[15]=12;
    end
    else begin
        for (i = 0 ; i<16;i++) begin
            itoa_ns[i] = itoa[i];
        end        
    end
end

endmodule

module multiplier_28bit(
    input  [27:0] a,       
    input  [27:0] b,
    input [3:0] atoi[0:15],  
    input [3:0] itoa[0:15],    
    output reg [27:0] product
);
    integer i;
    reg [27:0] a_shift[0:6];
    reg [27:0] partial[0:6];
    reg [3:0] real_partial0_0;
    reg [3:0] real_partial0_1;
    reg [3:0] real_partial0_2;
    reg [3:0] real_partial0_3;
    reg [3:0] real_partial0_4;
    reg [3:0] real_partial0_5;
    reg [3:0] real_partial0_6;
    reg [3:0] real_partial1_1;
    reg [3:0] real_partial1_2;
    reg [3:0] real_partial1_3;
    reg [3:0] real_partial1_4;
    reg [3:0] real_partial1_5;
    reg [3:0] real_partial1_6;
    reg [3:0] real_partial2_2;
    reg [3:0] real_partial2_3;
    reg [3:0] real_partial2_4;
    reg [3:0] real_partial2_5;
    reg [3:0] real_partial2_6;
    reg [3:0] real_partial3_3;
    reg [3:0] real_partial3_4;
    reg [3:0] real_partial3_5;
    reg [3:0] real_partial3_6;
    reg [3:0] real_partial4_4;
    reg [3:0] real_partial4_5;
    reg [3:0] real_partial4_6;
    reg [3:0] real_partial5_5;
    reg [3:0] real_partial5_6;
    reg [3:0] real_partial6_6;
    reg [27:0]real_product;
    wire [3:0] b0 = b[3:0]; 
    wire [3:0] b1 = b[7:4];
    wire [3:0] b2 = b[11:8];
    wire [3:0] b3 = b[15:12];
    wire [3:0] b4 = b[19:16];    
    wire [3:0] b5 = b[23:20];
    wire [3:0] b6 = b[27:24];

    always @(*) begin
        a_shift[0] = a;
        if (a_shift[0][27:24] + b0 >= 15 && a_shift[0][27:24] != 15 && b0 != 15)
            partial[0][27:24] = a_shift[0][27:24] - 15 + b0;
        else if (a_shift[0][27:24] + b0 < 15 && a_shift[0][27:24] != 15 && b0 != 15)
            partial[0][27:24] = a_shift[0][27:24] + b0;
        else
            partial[0][27:24] = 15;

        if (a_shift[0][23:20] + b0 >= 15 && a_shift[0][23:20] != 15 && b0 != 15)
            partial[0][23:20] = a_shift[0][23:20] - 15 + b0;
        else if (a_shift[0][23:20] + b0 < 15 && a_shift[0][23:20] != 15 && b0 != 15)
            partial[0][23:20] = a_shift[0][23:20] + b0;
        else
            partial[0][23:20] = 15;

        if (a_shift[0][19:16] + b0 >= 15 && a_shift[0][19:16] != 15 && b0 != 15)
            partial[0][19:16] = a_shift[0][19:16] - 15 + b0;
        else if (a_shift[0][19:16] + b0 < 15 && a_shift[0][19:16] != 15 && b0 != 15)
            partial[0][19:16] = a_shift[0][19:16] + b0;
        else
            partial[0][19:16] = 15;

        if (a_shift[0][15:12] + b0 >= 15 && a_shift[0][15:12] != 15 && b0 != 15)
            partial[0][15:12] = a_shift[0][15:12] - 15 + b0;
        else if (a_shift[0][15:12] + b0 < 15 && a_shift[0][15:12] != 15 && b0 != 15)
            partial[0][15:12] = a_shift[0][15:12] + b0;
        else
            partial[0][15:12] = 15; 

        if (a_shift[0][11:8] + b0 >= 15 && a_shift[0][11:8] != 15 && b0 != 15)
            partial[0][11:8] = a_shift[0][11:8] - 15 + b0;
        else if (a_shift[0][11:8] + b0 < 15 && a_shift[0][11:8] != 15 && b0 != 15)
            partial[0][11:8] = a_shift[0][11:8] + b0;
        else
            partial[0][11:8] = 15;  

        if (a_shift[0][7:4] + b0 >= 15 && a_shift[0][7:4] != 15 && b0 != 15)
            partial[0][7:4] = a_shift[0][7:4] - 15 + b0;
        else if (a_shift[0][7:4] + b0 < 15 && a_shift[0][7:4] != 15 && b0 != 15)
            partial[0][7:4] = a_shift[0][7:4] + b0;
        else
            partial[0][7:4] = 15;  

        if (a_shift[0][3:0] + b0 >= 15 && a_shift[0][3:0] != 15 && b0 != 15)
            partial[0][3:0] = a_shift[0][3:0] - 15 + b0;
        else if (a_shift[0][3:0] + b0 < 15 && a_shift[0][3:0] != 15 && b0 != 15)
            partial[0][3:0] = a_shift[0][3:0] + b0;
        else
            partial[0][3:0] = 15; 
    end
    always @(*) begin
        a_shift[1] = a<<4;
        if (a_shift[1][27:24] + b1 >= 15 && a_shift[1][27:24] != 15 && b1 != 15)
            partial[1][27:24] = a_shift[1][27:24] - 15 + b1;
        else if (a_shift[1][27:24] + b1 < 15 && a_shift[1][27:24] != 15 && b1 != 15)
            partial[1][27:24] = a_shift[1][27:24] + b1;
        else
            partial[1][27:24] = 15;

        if (a_shift[1][23:20] + b1 >= 15 && a_shift[1][23:20] != 15 && b1 != 15)
            partial[1][23:20] = a_shift[1][23:20] - 15 + b1;
        else if (a_shift[1][23:20] + b1 < 15 && a_shift[1][23:20] != 15 && b1 != 15)
            partial[1][23:20] = a_shift[1][23:20] + b1;
        else
            partial[1][23:20] = 15;

        if (a_shift[1][19:16] + b1 >= 15 && a_shift[1][19:16] != 15 && b1 != 15)
            partial[1][19:16] = a_shift[1][19:16] - 15 + b1;
        else if (a_shift[1][19:16] + b1 < 15 && a_shift[1][19:16] != 15 && b1 != 15)
            partial[1][19:16] = a_shift[1][19:16] + b1;
        else
            partial[1][19:16] = 15;

        if (a_shift[1][15:12] + b1 >= 15 && a_shift[1][15:12] != 15 && b1 != 15)
            partial[1][15:12] = a_shift[1][15:12] - 15 + b1;
        else if (a_shift[1][15:12] + b1 < 15 && a_shift[1][15:12] != 15 && b1 != 15)
            partial[1][15:12] = a_shift[1][15:12] + b1;
        else
            partial[1][15:12] = 15; 

        if (a_shift[1][11:8] + b1 >= 15 && a_shift[1][11:8] != 15 && b1 != 15)
            partial[1][11:8] = a_shift[1][11:8] - 15 + b1;
        else if (a_shift[1][11:8] + b1 < 15 && a_shift[1][11:8] != 15 && b1 != 15)
            partial[1][11:8] = a_shift[1][11:8] + b1;
        else
            partial[1][11:8] = 15;  

        if (a_shift[1][7:4] + b1 >= 15 && a_shift[1][7:4] != 15 && b1 != 15)
            partial[1][7:4] = a_shift[1][7:4] - 15 + b1;
        else if (a_shift[1][7:4] + b1 < 15 && a_shift[1][7:4] != 15 && b1 != 15)
            partial[1][7:4] = a_shift[1][7:4] + b1;
        else
            partial[1][7:4] = 15;  

        partial[1][3:0] = 15; 
    end
    always @(*) begin
        a_shift[2] = a<<8;
        if (a_shift[2][27:24] + b2 >= 15 && a_shift[2][27:24] != 15 && b2 != 15)
            partial[2][27:24] = a_shift[2][27:24] - 15 + b2;
        else if (a_shift[2][27:24] + b2 < 15 && a_shift[2][27:24] != 15 && b2 != 15)
            partial[2][27:24] = a_shift[2][27:24] + b2;
        else
            partial[2][27:24] = 15;

        if (a_shift[2][23:20] + b2 >= 15 && a_shift[2][23:20] != 15 && b2 != 15)
            partial[2][23:20] = a_shift[2][23:20] - 15 + b2;
        else if (a_shift[2][23:20] + b2 < 15 && a_shift[2][23:20] != 15 && b2 != 15)
            partial[2][23:20] = a_shift[2][23:20] + b2;
        else
            partial[2][23:20] = 15;

        if (a_shift[2][19:16] + b2 >= 15 && a_shift[2][19:16] != 15 && b2 != 15)
            partial[2][19:16] = a_shift[2][19:16] - 15 + b2;
        else if (a_shift[2][19:16] + b2 < 15 && a_shift[2][19:16] != 15 && b2 != 15)
            partial[2][19:16] = a_shift[2][19:16] + b2;
        else
            partial[2][19:16] = 15;

        if (a_shift[2][15:12] + b2 >= 15 && a_shift[2][15:12] != 15 && b2 != 15)
            partial[2][15:12] = a_shift[2][15:12] - 15 + b2;
        else if (a_shift[2][15:12] + b2 < 15 && a_shift[2][15:12] != 15 && b2 != 15)
            partial[2][15:12] = a_shift[2][15:12] + b2;
        else
            partial[2][15:12] = 15; 

        if (a_shift[2][11:8] + b2 >= 15 && a_shift[2][11:8] != 15 && b2 != 15)
            partial[2][11:8] = a_shift[2][11:8] - 15 + b2;
        else if (a_shift[2][11:8] + b2 < 15 && a_shift[2][11:8] != 15 && b2 != 15)
            partial[2][11:8] = a_shift[2][11:8] + b2;
        else
            partial[2][11:8] = 15;  
        partial[2][7:0] = 8'hff;  
    end
    always @(*) begin
        a_shift[3] = a<<12;
        if (a_shift[3][27:24] + b3 >= 15 && a_shift[3][27:24] != 15 && b3 != 15)
            partial[3][27:24] = a_shift[3][27:24] - 15 + b3;
        else if (a_shift[3][27:24] + b3 < 15 && a_shift[3][27:24] != 15 && b3 != 15)
            partial[3][27:24] = a_shift[3][27:24] + b3;
        else
            partial[3][27:24] = 15;

        if (a_shift[3][23:20] + b3 >= 15 && a_shift[3][23:20] != 15 && b3 != 15)
            partial[3][23:20] = a_shift[3][23:20] - 15 + b3;
        else if (a_shift[3][23:20] + b3 < 15 && a_shift[3][23:20] != 15 && b3 != 15)
            partial[3][23:20] = a_shift[3][23:20] + b3;
        else
            partial[3][23:20] = 15;

        if (a_shift[3][19:16] + b3 >= 15 && a_shift[3][19:16] != 15 && b3 != 15)
            partial[3][19:16] = a_shift[3][19:16] - 15 + b3;
        else if (a_shift[3][19:16] + b3 < 15 && a_shift[3][19:16] != 15 && b3 != 15)
            partial[3][19:16] = a_shift[3][19:16] + b3;
        else
            partial[3][19:16] = 15;

        if (a_shift[3][15:12] + b3 >= 15 && a_shift[3][15:12] != 15 && b3 != 15)
            partial[3][15:12] = a_shift[3][15:12] - 15 + b3;
        else if (a_shift[3][15:12] + b3 < 15 && a_shift[3][15:12] != 15 && b3 != 15)begin
            partial[3][15:12] = a_shift[3][15:12] + b3;
            
        end
        else begin
            partial[3][15:12] = 15;  
            
        end
        partial[3][11:0] = 12'hfff;  
    end

    always @(*) begin
        a_shift[4] = a<<16;
        if (a_shift[4][27:24] + b4 >= 15 && a_shift[4][27:24] != 15 && b4 != 15)
            partial[4][27:24] = a_shift[4][27:24] - 15 + b4;
        else if (a_shift[4][27:24] + b4 < 15 && a_shift[4][27:24] != 15 && b4 != 15)
            partial[4][27:24] = a_shift[4][27:24] + b4;
        else
            partial[4][27:24] = 15;

        if (a_shift[4][23:20] + b4 >= 15 && a_shift[4][23:20] != 15 && b4 != 15)
            partial[4][23:20] = a_shift[4][23:20] - 15 + b4;
        else if (a_shift[4][23:20] + b4 < 15 && a_shift[4][23:20] != 15 && b4 != 15)
            partial[4][23:20] = a_shift[4][23:20] + b4;
        else
            partial[4][23:20] = 15;

        if (a_shift[4][19:16] + b4 >= 15 && a_shift[4][19:16] != 15 && b4 != 15)
            partial[4][19:16] = a_shift[4][19:16] - 15 + b4;
        else if (a_shift[4][19:16] + b4 < 15 && a_shift[4][19:16] != 15 && b4 != 15)
            partial[4][19:16] = a_shift[4][19:16] + b4;
        else
            partial[4][19:16] = 15;
 
        partial[4][15:0] = 16'hffff;  
    end
    always @(*) begin
        a_shift[5] = a<<20;
        if (a_shift[5][27:24] + b5 >= 15 && a_shift[5][27:24] != 15 && b5 != 15)
            partial[5][27:24] = a_shift[5][27:24] - 15 + b5;
        else if (a_shift[5][27:24] + b5 < 15 && a_shift[5][27:24] != 15 && b5 != 15)
            partial[5][27:24] = a_shift[5][27:24] + b5;
        else
            partial[5][27:24] = 15;

        if (a_shift[5][23:20] + b5 >= 15 && a_shift[5][23:20] != 15 && b5 != 15)
            partial[5][23:20] = a_shift[5][23:20] - 15 + b5;
        else if (a_shift[5][23:20] + b5 < 15 && a_shift[5][23:20] != 15 && b5 != 15)
            partial[5][23:20] = a_shift[5][23:20] + b5;
        else
            partial[5][23:20] = 15;
 
        partial[5][19:0] = 20'hfffff;  
    end
    always @(*) begin
        a_shift[6] = a<<24;
        if (a_shift[6][27:24] + b6 >= 15 && a_shift[6][27:24] != 15 && b6 != 15)
            partial[6][27:24] = a_shift[6][27:24] - 15 + b6;
        else if (a_shift[6][27:24] + b6 < 15 && a_shift[6][27:24] != 15 && b6 != 15)
            partial[6][27:24] = a_shift[6][27:24] + b6;
        else
            partial[6][27:24] = 15;
 
        partial[6][23:0] = 24'hffffff;  
    end
    always @(*) begin
        real_partial0_0 = atoi[partial[0][3:0]];
        real_partial0_1 = atoi[partial[0][7:4]];
        real_partial0_2 = atoi[partial[0][11:8]];
        real_partial0_3 = atoi[partial[0][15:12]];
        real_partial0_4 = atoi[partial[0][19:16]];
        real_partial0_5 = atoi[partial[0][23:20]];
        real_partial0_6 = atoi[partial[0][27:24]];

        real_partial1_1 = atoi[partial[1][7:4]];
        real_partial1_2 = atoi[partial[1][11:8]];
        real_partial1_3 = atoi[partial[1][15:12]];
        real_partial1_4 = atoi[partial[1][19:16]];
        real_partial1_5 = atoi[partial[1][23:20]];
        real_partial1_6 = atoi[partial[1][27:24]];  

        real_partial2_2 = atoi[partial[2][11:8]];
        real_partial2_3 = atoi[partial[2][15:12]];
        real_partial2_4 = atoi[partial[2][19:16]];
        real_partial2_5 = atoi[partial[2][23:20]];
        real_partial2_6 = atoi[partial[2][27:24]];  

        real_partial3_3 = atoi[partial[3][15:12]];
        real_partial3_4 = atoi[partial[3][19:16]];
        real_partial3_5 = atoi[partial[3][23:20]];
        real_partial3_6 = atoi[partial[3][27:24]];  

        real_partial4_4 = atoi[partial[4][19:16]];
        real_partial4_5 = atoi[partial[4][23:20]];
        real_partial4_6 = atoi[partial[4][27:24]];  

        real_partial5_5 = atoi[partial[5][23:20]];
        real_partial5_6 = atoi[partial[5][27:24]];      

        real_partial6_6 = atoi[partial[6][27:24]];
    end   
    always@(*)begin
        real_product[3:0]   = real_partial0_0;
        real_product[7:4]   = real_partial0_1 ^ real_partial1_1;
        real_product[11:8]  = real_partial0_2 ^ real_partial1_2 ^ real_partial2_2 ;
        real_product[15:12] = real_partial0_3 ^ real_partial1_3 ^ real_partial2_3 ^ real_partial3_3 ;
        real_product[19:16] = real_partial0_4 ^ real_partial1_4 ^ real_partial2_4 ^ real_partial3_4 ^ real_partial4_4;
        real_product[23:20] = real_partial0_5 ^ real_partial1_5 ^ real_partial2_5 ^ real_partial3_5 ^ real_partial4_5 ^ real_partial5_5;
        real_product[27:24] = real_partial0_6 ^ real_partial1_6 ^ real_partial2_6 ^ real_partial3_6 ^ real_partial4_6 ^ real_partial5_6 ^ real_partial6_6;
    end
    always@(*)begin
        product[3:0]  =itoa[real_product[3:0]  ];
        product[7:4]  =itoa[real_product[7:4]  ];
        product[11:8] =itoa[real_product[11:8] ];
        product[15:12]=itoa[real_product[15:12]];
        product[19:16]=itoa[real_product[19:16]];
        product[23:20]=itoa[real_product[23:20]];
        product[27:24]=itoa[real_product[27:24]];

    end
endmodule
    /*
    power_to_actual p_to_a1(.power(partial[0][3:0]),.actual(real_partial0_0));
    power_to_actual p_to_a2(.power(partial[0][7:4]),.actual(real_partial0_1));
    power_to_actual p_to_a3(.power(partial[0][11:8]),.actual(real_partial0_2));
    power_to_actual p_to_a4(.power(partial[0][15:12]),.actual(real_partial0_3));
    power_to_actual p_to_a5(.power(partial[0][19:16]),.actual(real_partial0_4));
    power_to_actual p_to_a6(.power(partial[0][23:20]),.actual(real_partial0_5));
    power_to_actual p_to_a7(.power(partial[0][27:24]),.actual(real_partial0_6));

    power_to_actual p_to_a8(.power(partial[1][7:4]),.actual(real_partial1_1));
    power_to_actual p_to_a9(.power(partial[1][11:8]),.actual(real_partial1_2));
    power_to_actual p_to_a10(.power(partial[1][15:12]),.actual(real_partial1_3));
    power_to_actual p_to_a11(.power(partial[1][19:16]),.actual(real_partial1_4));
    power_to_actual p_to_a12(.power(partial[1][23:20]),.actual(real_partial1_5));
    power_to_actual p_to_a13(.power(partial[1][27:24]),.actual(real_partial1_6));

    power_to_actual p_to_a14(.power(partial[2][11:8]),.actual(real_partial2_2));
    power_to_actual p_to_a15(.power(partial[2][15:12]),.actual(real_partial2_3));
    power_to_actual p_to_a16(.power(partial[2][19:16]),.actual(real_partial2_4));
    power_to_actual p_to_a17(.power(partial[2][23:20]),.actual(real_partial2_5));
    power_to_actual p_to_a18(.power(partial[2][27:24]),.actual(real_partial2_6));
    
    power_to_actual p_to_a19(.power(partial[3][15:12]),.actual(real_partial3_3));
    power_to_actual p_to_a20(.power(partial[3][19:16]),.actual(real_partial3_4));
    power_to_actual p_to_a21(.power(partial[3][23:20]),.actual(real_partial3_5));
    power_to_actual p_to_a22(.power(partial[3][27:24]),.actual(real_partial3_6));

    power_to_actual p_to_a23(.power(partial[4][19:16]),.actual(real_partial4_4));
    power_to_actual p_to_a24(.power(partial[4][23:20]),.actual(real_partial4_5));
    power_to_actual p_to_a25(.power(partial[4][27:24]),.actual(real_partial4_6));

    power_to_actual p_to_a26(.power(partial[5][23:20]),.actual(real_partial5_5));
    power_to_actual p_to_a27(.power(partial[5][27:24]),.actual(real_partial5_6));

    power_to_actual p_to_a28(.power(partial[6][27:24]),.actual(real_partial6_6));
    */
/*
module power_to_actual(
    input [3:0]power,
    output [3:0]actual
);
case (power)
        0: actual = 4'd1;
        1: actual = 4'd2;
        2: actual = 4'd4;
        3: actual = 4'd8;
        4: actual = 4'd3;
        5: actual = 4'd6;
        6: actual = 4'd12;
        7: actual = 4'd11;
        8: actual = 4'd5;
        9: actual = 4'd10;
        10:actual = 4'd7;
        11:actual = 4'd14;
        12:actual = 4'd15;
        13:actual = 4'd13; 
        14:actual = 4'd9;
        15:actual = 4'd0;
    endcase
endmodule
module actual_to_power(
    input [3:0]actual,
    output [3:0]power
);
case (actual)
    0:  out = 4'd15;
    1:  out = 4'd0;
    2:  out = 4'd1;
    3:  out = 4'd4;
    4:  out = 4'd2;
    5:  out = 4'd8;
    6:  out = 4'd5;
    7:  out = 4'd10;
    8:  out = 4'd3;
    9:  out = 4'd14;
    10: out = 4'd9;
    11: out = 4'd7;
    12: out = 4'd6; 
    13: out = 4'd13;
    14: out = 4'd11;
    15: out = 4'd12;
endcase
endmodule
*/
/*
module multiplier_28bit(
    input  [27:0] a,       
    input  [27:0] b,      
    output [27:0] product
);
    reg [27:0] a_shift[0:6];
    reg [27:0] partial[0:6];
    integer j;
    reg[3:0] b_par[0:6];
always @(*)begin
    for (j = 0; j < 7; j = j + 1) begin 
        a_shift[j] = a << (4*j);
        a_shift[j] [4*(j+1)-1:0] = {4*(j+1){1'b1}};
        if (a_shift[j][27:24] + b[4*(j+1)-1:4*j] >= 15 && a_shift[j][27:24] != 15 && b[4*(j+1)-1:4*j] !=15) begin
            partial[j][27:24] = a_shift[j][27:24]- 15 + b[4*(j+1)-1:4*j] ;
        end
        else if (a_shift[j][27:24] + b[4*(j+1)-1:4*j] < 15 && a_shift[j][27:24] != 15 && b[4*(j+1)-1:4*j] !=15)begin
            partial[j][27:24] = a_shift[j][27:24] + b[4*(j+1)-1:4*j] ;
        end
        else begin
            partial[j][27:24] = 15;
        end

        if (a_shift[j][23:20] + b[4*(j+1)-1:4*j] >= 15 && a_shift[j][23:20] != 15 && b[4*(j+1)-1:4*j] !=15) begin
            partial[j][23:20] = a_shift[j][23:20]- 15 + b[4*(j+1)-1:4*j] ;
        end
        else if (a_shift[j][23:20] + b[4*(j+1)-1:4*j] < 15 && a_shift[j][23:20] != 15 && b[4*(j+1)-1:4*j] !=15)begin
            partial[j][23:20] = a_shift[j][23:20] + b[4*(j+1)-1:4*j] ;
        end
        else begin
            partial[j][23:20] = 15;
        end

        if (a_shift[j][19:16] + b[4*(j+1)-1:4*j] >= 15 && a_shift[j][19:16] != 15 && b[4*(j+1)-1:4*j] !=15) begin
            partial[j][19:16] = a_shift[j][19:16]- 15 + b[4*(j+1)-1:4*j] ;
        end
        else if (a_shift[j][19:16] + b[4*(j+1)-1:4*j] < 15 && a_shift[j][19:16] != 15 && b[4*(j+1)-1:4*j] !=15)begin
            partial[j][19:16] = a_shift[j][19:16] + b[4*(j+1)-1:4*j] ;
        end
        else begin
            partial[j][19:16] = 15;
        end

        if (a_shift[j][15:12] + b[4*(j+1)-1:4*j] >= 15 && a_shift[j][15:12] != 15 && b[4*(j+1)-1:4*j] !=15) begin
            partial[j][15:12] = a_shift[j][15:12]- 15 + b[4*(j+1)-1:4*j] ;
        end
        else if (a_shift[j][15:12] + b[4*(j+1)-1:4*j] < 15 && a_shift[j][15:12] != 15 && b[4*(j+1)-1:4*j] !=15)begin
            partial[j][15:12] = a_shift[j][15:12] + b[4*(j+1)-1:4*j] ;
        end
        else begin
            partial[j][15:12] = 15;
        end

        if (a_shift[j][11:8] + b[4*(j+1)-1:4*j] >= 15 && a_shift[j][11:8] != 15 && b[4*(j+1)-1:4*j] !=15) begin
            partial[j][11:8] = a_shift[j][11:8]- 15 + b[4*(j+1)-1:4*j] ;
        end
        else if (a_shift[j][11:8] + b[4*(j+1)-1:4*j] < 15 && a_shift[j][11:8] != 15 && b[4*(j+1)-1:4*j] !=15)begin
            partial[j][11:8] = a_shift[j][11:8] + b[4*(j+1)-1:4*j] ;
        end
        else begin
            partial[j][11:8] = 15;
        end

        if (a_shift[j][7:4] + b[4*(j+1)-1:4*j] >= 15 && a_shift[j][7:4] != 15 && b[4*(j+1)-1:4*j] !=15) begin
            partial[j][7:4] = a_shift[j][7:4]- 15 + b[4*(j+1)-1:4*j] ;
        end
        else if (a_shift[j][7:4] + b[4*(j+1)-1:4*j] < 15 && a_shift[j][7:4] != 15 && b[4*(j+1)-1:4*j] !=15)begin
            partial[j][7:4] = a_shift[j][7:4] + b[4*(j+1)-1:4*j] ;
        end
        else begin
            partial[j][7:4] = 15;
        end
        if (a_shift[j][3:0] + b[4*(j+1)-1:4*j] >= 15 && a_shift[j][3:0] != 15 && b[4*(j+1)-1:4*j] !=15) begin
            partial[j][3:0] = a_shift[j][3:0]- 15 + b[4*(j+1)-1:4*j] ;
        end
        else if (a_shift[j][3:0] + b[4*(j+1)-1:4*j] < 15 && a_shift[j][3:0] != 15 && b[4*(j+1)-1:4*j] !=15)begin
            partial[j][3:0] = a_shift[j][3:0] + b[4*(j+1)-1:4*j] ;
        end
        else begin
            partial[j][3:0] = 15;
        end
    end
end
    always @(*) begin
        product = partial[0] + partial[1] + partial[2] + partial[3] +
                     partial[4] + partial[5] + partial[6];
    end
endmodule
*/