module MVDM(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    in_data,
    // output signals
    out_valid,
    out_sad
    );

input clk;
input rst_n;
input in_valid;
input in_valid2;
input [11:0] in_data;

output reg out_valid;
output reg out_sad;
//=======================================================
//                   MEM & MEM WIRE
//=======================================================
reg WEB_L0, WEB_L1;
reg WEB_L0_ns, WEB_L1_ns;
reg [10:0]addr0, addr1;
reg [10:0]addr0_ns, addr1_ns;
reg [63:0]DI_L0, DO_L0, DI_L1, DO_L1;

L0 L0_MEM(
    .A0(addr0[0]),.A1(addr0[1]),.A2(addr0[2]),.A3(addr0[3]),.A4(addr0[4]),.A5(addr0[5]),.A6(addr0[6]),.A7(addr0[7]),.A8(addr0[8]),.A9(addr0[9]),
    .A10(addr0[10]),
    .DI0(DI_L0[0]),.DI1(DI_L0[1]),.DI2(DI_L0[2]),.DI3(DI_L0[3]),.DI4(DI_L0[4]),.DI5(DI_L0[5]),.DI6(DI_L0[6]),.DI7(DI_L0[7]),.DI8(DI_L0[8]),.DI9(DI_L0[9]),
    .DI10(DI_L0[10]),.DI11(DI_L0[11]),.DI12(DI_L0[12]),.DI13(DI_L0[13]),.DI14(DI_L0[14]),.DI15(DI_L0[15]),.DI16(DI_L0[16]),.DI17(DI_L0[17]),.DI18(DI_L0[18]),.DI19(DI_L0[19]),
    .DI20(DI_L0[20]),.DI21(DI_L0[21]),.DI22(DI_L0[22]),.DI23(DI_L0[23]),.DI24(DI_L0[24]),.DI25(DI_L0[25]),.DI26(DI_L0[26]),.DI27(DI_L0[27]),.DI28(DI_L0[28]),.DI29(DI_L0[29]),
    .DI30(DI_L0[30]),.DI31(DI_L0[31]),.DI32(DI_L0[32]),.DI33(DI_L0[33]),.DI34(DI_L0[34]),.DI35(DI_L0[35]),.DI36(DI_L0[36]),.DI37(DI_L0[37]),.DI38(DI_L0[38]),.DI39(DI_L0[39]),
    .DI40(DI_L0[40]),.DI41(DI_L0[41]),.DI42(DI_L0[42]),.DI43(DI_L0[43]),.DI44(DI_L0[44]),.DI45(DI_L0[45]),.DI46(DI_L0[46]),.DI47(DI_L0[47]),.DI48(DI_L0[48]),.DI49(DI_L0[49]),
    .DI50(DI_L0[50]),.DI51(DI_L0[51]),.DI52(DI_L0[52]),.DI53(DI_L0[53]),.DI54(DI_L0[54]),.DI55(DI_L0[55]),.DI56(DI_L0[56]),.DI57(DI_L0[57]),.DI58(DI_L0[58]),.DI59(DI_L0[59]),
    .DI60(DI_L0[60]),.DI61(DI_L0[61]),.DI62(DI_L0[62]),.DI63(DI_L0[63]),
    .DO0(DO_L0[0]),.DO1(DO_L0[1]),.DO2(DO_L0[2]),.DO3(DO_L0[3]),.DO4(DO_L0[4]),.DO5(DO_L0[5]),.DO6(DO_L0[6]),.DO7(DO_L0[7]),.DO8(DO_L0[8]),.DO9(DO_L0[9]),
    .DO10(DO_L0[10]),.DO11(DO_L0[11]),.DO12(DO_L0[12]),.DO13(DO_L0[13]),.DO14(DO_L0[14]),.DO15(DO_L0[15]),.DO16(DO_L0[16]),.DO17(DO_L0[17]),.DO18(DO_L0[18]),.DO19(DO_L0[19]),
    .DO20(DO_L0[20]),.DO21(DO_L0[21]),.DO22(DO_L0[22]),.DO23(DO_L0[23]),.DO24(DO_L0[24]),.DO25(DO_L0[25]),.DO26(DO_L0[26]),.DO27(DO_L0[27]),.DO28(DO_L0[28]),.DO29(DO_L0[29]),
    .DO30(DO_L0[30]),.DO31(DO_L0[31]),.DO32(DO_L0[32]),.DO33(DO_L0[33]),.DO34(DO_L0[34]),.DO35(DO_L0[35]),.DO36(DO_L0[36]),.DO37(DO_L0[37]),.DO38(DO_L0[38]),.DO39(DO_L0[39]),
    .DO40(DO_L0[40]),.DO41(DO_L0[41]),.DO42(DO_L0[42]),.DO43(DO_L0[43]),.DO44(DO_L0[44]),.DO45(DO_L0[45]),.DO46(DO_L0[46]),.DO47(DO_L0[47]),.DO48(DO_L0[48]),.DO49(DO_L0[49]),
    .DO50(DO_L0[50]),.DO51(DO_L0[51]),.DO52(DO_L0[52]),.DO53(DO_L0[53]),.DO54(DO_L0[54]),.DO55(DO_L0[55]),.DO56(DO_L0[56]),.DO57(DO_L0[57]),.DO58(DO_L0[58]),.DO59(DO_L0[59]),
    .DO60(DO_L0[60]),.DO61(DO_L0[61]),.DO62(DO_L0[62]),.DO63(DO_L0[63]),
    .CK(clk),.WEB(WEB_L0),.OE(1'b1), .CS(1'b1));

L1 L1_MEM(    
    .A0(addr1[0]),.A1(addr1[1]),.A2(addr1[2]),.A3(addr1[3]),.A4(addr1[4]),.A5(addr1[5]),.A6(addr1[6]),.A7(addr1[7]),.A8(addr1[8]),.A9(addr1[9]),
    .A10(addr1[10]),
    .DI0(DI_L1[0]),.DI1(DI_L1[1]),.DI2(DI_L1[2]),.DI3(DI_L1[3]),.DI4(DI_L1[4]),.DI5(DI_L1[5]),.DI6(DI_L1[6]),.DI7(DI_L1[7]),.DI8(DI_L1[8]),.DI9(DI_L1[9]),
    .DI10(DI_L1[10]),.DI11(DI_L1[11]),.DI12(DI_L1[12]),.DI13(DI_L1[13]),.DI14(DI_L1[14]),.DI15(DI_L1[15]),.DI16(DI_L1[16]),.DI17(DI_L1[17]),.DI18(DI_L1[18]),.DI19(DI_L1[19]),
    .DI20(DI_L1[20]),.DI21(DI_L1[21]),.DI22(DI_L1[22]),.DI23(DI_L1[23]),.DI24(DI_L1[24]),.DI25(DI_L1[25]),.DI26(DI_L1[26]),.DI27(DI_L1[27]),.DI28(DI_L1[28]),.DI29(DI_L1[29]),
    .DI30(DI_L1[30]),.DI31(DI_L1[31]),.DI32(DI_L1[32]),.DI33(DI_L1[33]),.DI34(DI_L1[34]),.DI35(DI_L1[35]),.DI36(DI_L1[36]),.DI37(DI_L1[37]),.DI38(DI_L1[38]),.DI39(DI_L1[39]),
    .DI40(DI_L1[40]),.DI41(DI_L1[41]),.DI42(DI_L1[42]),.DI43(DI_L1[43]),.DI44(DI_L1[44]),.DI45(DI_L1[45]),.DI46(DI_L1[46]),.DI47(DI_L1[47]),.DI48(DI_L1[48]),.DI49(DI_L1[49]),
    .DI50(DI_L1[50]),.DI51(DI_L1[51]),.DI52(DI_L1[52]),.DI53(DI_L1[53]),.DI54(DI_L1[54]),.DI55(DI_L1[55]),.DI56(DI_L1[56]),.DI57(DI_L1[57]),.DI58(DI_L1[58]),.DI59(DI_L1[59]),
    .DI60(DI_L1[60]),.DI61(DI_L1[61]),.DI62(DI_L1[62]),.DI63(DI_L1[63]),
    .DO0(DO_L1[0]),.DO1(DO_L1[1]),.DO2(DO_L1[2]),.DO3(DO_L1[3]),.DO4(DO_L1[4]),.DO5(DO_L1[5]),.DO6(DO_L1[6]),.DO7(DO_L1[7]),.DO8(DO_L1[8]),.DO9(DO_L1[9]),
    .DO10(DO_L1[10]),.DO11(DO_L1[11]),.DO12(DO_L1[12]),.DO13(DO_L1[13]),.DO14(DO_L1[14]),.DO15(DO_L1[15]),.DO16(DO_L1[16]),.DO17(DO_L1[17]),.DO18(DO_L1[18]),.DO19(DO_L1[19]),
    .DO20(DO_L1[20]),.DO21(DO_L1[21]),.DO22(DO_L1[22]),.DO23(DO_L1[23]),.DO24(DO_L1[24]),.DO25(DO_L1[25]),.DO26(DO_L1[26]),.DO27(DO_L1[27]),.DO28(DO_L1[28]),.DO29(DO_L1[29]),
    .DO30(DO_L1[30]),.DO31(DO_L1[31]),.DO32(DO_L1[32]),.DO33(DO_L1[33]),.DO34(DO_L1[34]),.DO35(DO_L1[35]),.DO36(DO_L1[36]),.DO37(DO_L1[37]),.DO38(DO_L1[38]),.DO39(DO_L1[39]),
    .DO40(DO_L1[40]),.DO41(DO_L1[41]),.DO42(DO_L1[42]),.DO43(DO_L1[43]),.DO44(DO_L1[44]),.DO45(DO_L1[45]),.DO46(DO_L1[46]),.DO47(DO_L1[47]),.DO48(DO_L1[48]),.DO49(DO_L1[49]),
    .DO50(DO_L1[50]),.DO51(DO_L1[51]),.DO52(DO_L1[52]),.DO53(DO_L1[53]),.DO54(DO_L1[54]),.DO55(DO_L1[55]),.DO56(DO_L1[56]),.DO57(DO_L1[57]),.DO58(DO_L1[58]),.DO59(DO_L1[59]),
    .DO60(DO_L1[60]),.DO61(DO_L1[61]),.DO62(DO_L1[62]),.DO63(DO_L1[63]),
    .CK(clk),.WEB(WEB_L1),.OE(1'b1), .CS(1'b1));
/*
R1 R1_MEM(
    .A0(addr_R[0]),.A1(addr_R[1]),.A2(addr_R[2]),.A3(addr_R[3]),.A4(addr_R[4]),.A5(addr_R[5]),.A6(addr_R[6]),
    .DO0(DO_R[0]), .DO1(DO_R[1]), .DO2(DO_R[2]), .DO3(DO_R[3]), .DO4(DO_R[4]),
    .DO5(DO_R[5]), .DO6(DO_R[6]), .DO7(DO_R[7]), .DO8(DO_R[8]), .DO9(DO_R[9]),
    .DO10(DO_R[10]), .DO11(DO_R[11]), .DO12(DO_R[12]), .DO13(DO_R[13]), .DO14(DO_R[14]),
    .DO15(DO_R[15]), .DO16(DO_R[16]), .DO17(DO_R[17]), .DO18(DO_R[18]), .DO19(DO_R[19]),
    .DO20(DO_R[20]), .DO21(DO_R[21]), .DO22(DO_R[22]), .DO23(DO_R[23]),
    .DI0(DI_R[0]), .DI1(DI_R[1]), .DI2(DI_R[2]), .DI3(DI_R[3]), .DI4(DI_R[4]),
    .DI5(DI_R[5]), .DI6(DI_R[6]), .DI7(DI_R[7]), .DI8(DI_R[8]), .DI9(DI_R[9]),
    .DI10(DI_R[10]), .DI11(DI_R[11]), .DI12(DI_R[12]), .DI13(DI_R[13]), .DI14(DI_R[14]),
    .DI15(DI_R[15]), .DI16(DI_R[16]), .DI17(DI_R[17]), .DI18(DI_R[18]), .DI19(DI_R[19]),
    .DI20(DI_R[20]), .DI21(DI_R[21]), .DI22(DI_R[22]), .DI23(DI_R[23]),
    .CK(clk),.WEB(WEB_R),.OE(1'b1), .CS(1'b1));

reg [6:0] addr_R, addr_R_ns;
reg [23:0] DI_R;
reg [23:0] DO_R;
reg [6:0] storeR_cnt, storeR_cnt_ns;
reg WEB_R;
always @(*) begin
    if (cur_state == CAL && cal_cnt != 0) begin
        WEB_R = 0;
    end
    else begin
        WEB_R = 1;
    end
end
always @(*) begin
    if (cur_state == CAL && cal_cnt != 0) begin
        addr_R = storeR_cnt;
    end
end
always @(*) begin
    if (cur_state == CAL && cal_cnt != 0) begin
        DI_R = 
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        storeR_cnt <= 0;
    end
    else begin
        storeR_cnt <= storeR_cnt_ns;
    end
end
always @(*) begin
    if (cur_state == CAL && cal_cnt != 0) begin
        storeR_cnt_ns = storeR_cnt + 1;
    end
    else begin
        storeR_cnt_ns = storeR_cnt;
    end
end
*/
//=======================================================
//                   Reg/Wire
//=======================================================
typedef enum reg[3:0]{INPUT = 4'd0, INPUT1 = 4'd1, READ = 4'd2, CAL = 4'd3, WAIT = 4'd4, SAD = 4'd5, SORT = 4'd6, OUT = 4'd7, PRINT = 4'd8 }state;
state cur_state, nxt_state;

reg [2:0]mv_cnt, mv_cnt_ns;
reg [5:0] set_cnt,set_cnt_ns;
reg [7:0] temp_ns [0:7], temp[0:7];
reg [2:0] cnt, cnt_ns;
reg [11:0] mvx0[0:1], mvy0[0:1];
reg [11:0] mvx0_ns[0:1], mvy0_ns[0:1];
reg [11:0] mvx1[0:1], mvy1[0:1];
reg [11:0] mvx1_ns[0:1], mvy1_ns[0:1];
integer i,j;
reg [7:0] cal0 [0:1][0:10],cal0_ns[0:1][0:10];
reg [4:0] scale1_L0[0:1], scale2_L0[0:1], scale1_L0_ns[0:1],scale2_L0_ns[0:1];
reg [11:0] A1_L00, A2_L00;
reg [11:0] A1_L01, A2_L01;
reg [23:0] BI_L00, BI_L01;
reg [23:0] BI_L00_ns, BI_L01_ns;
reg [2:0] cal_cnt, cal_cnt_ns;
reg [3:0] total_cal_cnt, total_cal_cnt_ns;
reg [2:0] site0, site0_ns;
reg [1:0] load0_cnt, load0_cnt_ns;
reg [3:0] row0_cnt, row0_cnt_ns;
reg [3:0] store_cnt, store_cnt_ns;
reg [3:0] require0, require0_ns;
reg [1:0] delay_load0_cnt;
reg input_first, input_first_ns;
reg out_valid_ns;

typedef enum reg[3:0]{INPUT_L1 = 4'd0, INPUT1_L1 = 4'd1, READ_L1 = 4'd2, CAL_L1 = 4'd3, WAIT1= 4'd4, SAD1= 4'd5, SORT1 = 4'd6, OUT1 = 4'd7, PRINT1= 4'd8}state_L1;
state_L1 cur_state_L1, nxt_state_L1;
reg [4:0] scale1_L1[0:1], scale2_L1[0:1], scale1_L1_ns[0:1],scale2_L1_ns[0:1];
reg [7:0] cal1 [0:1][0:10],cal1_ns[0:1][0:10];
reg [11:0] A1_L10, A2_L10;
reg [11:0] A1_L11, A2_L11;
reg [23:0] BI_L10, BI_L11;
reg [23:0] BI_L10_ns, BI_L11_ns;
reg [2:0] site1, site1_ns;
reg [1:0] load1_cnt, load1_cnt_ns;
reg [3:0] row1_cnt, row1_cnt_ns;
reg [3:0] store1_cnt, store1_cnt_ns;
reg [3:0] require1, require1_ns;
reg [1:0] delay_load1_cnt;
reg [2:0] cal_cnt1, cal_cnt1_ns;
reg [3:0] total_cal_cnt1, total_cal_cnt1_ns;
reg [3:0] wait_cnt, wait_cnt_ns;
reg [5:0] print_cnt, print_cnt_ns;

reg [63:0] D0, D1;
reg [2:0] delay_sram0;
reg [2:0] delay_sram1;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        D0 <= 0;
        D1 <= 0;
    end
    else begin
        D0 <= DO_L0;
        D1 <= DO_L1;
    end
end
//--------------------------------------
//            CAL SAD
//--------------------------------------
reg [23:0] sad0, sad1,sad2,sad3,sad4,sad5,sad6,sad7,sad8;
reg [23:0] sad0_ns, sad1_ns,sad2_ns,sad3_ns,sad4_ns,sad5_ns,sad6_ns,sad7_ns,sad8_ns;
reg [4:0] point_cnt,point_cnt_ns;
reg [5:0] add_cnt,add_cnt_ns;
reg [23:0] ans0,ans1,ans2,ans3; 
reg [3:0]sad_row_cnt, sad_col_cnt;
reg [3:0]sad_row_cnt_ns, sad_col_cnt_ns;
reg [23:0] b00_ns, b00;
reg [23:0] b01_ns, b01;
reg [23:0] b02_ns, b02;
reg [23:0] b03_ns, b03;
reg [23:0] b10_ns, b10;
reg [23:0] b11_ns, b11;
reg [23:0] b12_ns, b12;
reg [23:0] b13_ns, b13;

//******************************************
//=======================================================
//                   Design
//=======================================================
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr_R <= 0;
    end
    else begin
        addr_R <= addr_R_ns;
    end
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        delay_sram0 <= 0;
        delay_sram1 <= 0;
    end
    else begin
        delay_sram0 <= delay_load0_cnt;
        delay_sram1 <= delay_load1_cnt;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        set_cnt <= 0;
    end
    else begin
        
        set_cnt <= set_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mv_cnt <= 0;
    end
    else begin
        
        mv_cnt <= mv_cnt_ns;
    end
end
always @(*) begin
    set_cnt_ns = set_cnt;
    if (cur_state == INPUT) begin
        set_cnt_ns = 0;
    end
    else if (cur_state == PRINT && print_cnt == 55) begin
        set_cnt_ns = set_cnt + 1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        delay_load0_cnt <= 3;
    end
    else begin
        
        delay_load0_cnt <= load0_cnt;
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
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        delay_load1_cnt <= 3;
    end
    else begin
        
        delay_load1_cnt <= load1_cnt;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        input_first <= 0;
    end
    else begin
        input_first <= input_first_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        store_cnt <= 0;
    end
    else begin
        store_cnt <= store_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        store1_cnt <= 0;
    end
    else begin
        store1_cnt <= store1_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load1_cnt <= 0;
    end
    else begin
        load1_cnt <= load1_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load0_cnt <= 0;
    end
    else begin
        load0_cnt <= load0_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        row1_cnt <= 0;
    end
    else begin
        row1_cnt <= row1_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        row0_cnt <= 0;
    end
    else begin
        row0_cnt <= row0_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        require0 <= 0;
    end
    else begin
        require0 <= require0_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        require1 <= 0;
    end
    else begin
        require1 <= require1_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i<2;i++) begin
            mvx0[i] <= 0;
            mvy0[i] <= 0;
            mvx1[i] <= 0;
            mvy1[i] <= 0;
        end
    end
    else begin
        for (i = 0; i<2;i++) begin
            mvx0[i] <= mvx0_ns[i];
            mvy0[i] <= mvy0_ns[i];
            mvx1[i] <= mvx1_ns[i];
            mvy1[i] <= mvy1_ns[i];
        end        
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        WEB_L0 <= 1;
        WEB_L1 <= 1;
    end
    else begin
        WEB_L0 <= WEB_L0_ns;
        WEB_L1 <= WEB_L1_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr0 <= 0;
        addr1 <= 0;
    end
    else begin
        addr0 <= addr0_ns;
        addr1 <= addr1_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i<8;i++) begin
            temp[i] <= 0;
        end
        
    end
    else begin
        for (i = 0; i<8;i++) begin
            temp[i] <= temp_ns[i];
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state <= INPUT; 
    end
    else begin
        cur_state <= nxt_state;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state_L1 <= INPUT_L1; 
    end
    else begin
        cur_state_L1 <= nxt_state_L1;
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
always @(*) begin
    nxt_state = cur_state;
    case(cur_state) 
        INPUT: begin
            if (addr1 == 2047 && cnt == 7) begin
                nxt_state = INPUT1;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        INPUT1: begin
            if (mv_cnt == 7) begin
                nxt_state = READ;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        READ: begin
            if (row0_cnt >= 1 && load0_cnt == require0) begin
                nxt_state = CAL;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        CAL: begin
            if (cal_cnt == 6 && total_cal_cnt < 9) begin
                nxt_state = READ;
            end
            else if (cal_cnt == 6 && total_cal_cnt == 9) begin // all BI are completed
                nxt_state = WAIT;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        WAIT: begin
            if (require0 == require1 || wait_cnt == 11) begin
                nxt_state = SAD;
            end
            else if (wait_cnt < 11) begin
                nxt_state = WAIT;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        SAD: begin
            if (point_cnt >= 1 && add_cnt == 16) begin
                nxt_state = SORT;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        SORT: begin
            if (point_cnt < 9) begin
                nxt_state = SAD;
            end
            else begin
                nxt_state = OUT;
            end
        end
        OUT: begin
            if (cnt == 1) begin
                nxt_state = PRINT;
            end
            else if (cnt == 0) begin
                nxt_state = READ;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        PRINT: begin
            if (print_cnt == 55 && set_cnt < 63)begin
                nxt_state = INPUT1;
            end
            else if (print_cnt == 55 && set_cnt == 63) begin
                nxt_state = INPUT;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        
    endcase
end
always @(*) begin
    nxt_state_L1 = cur_state_L1;
    case(cur_state_L1) 
        INPUT_L1: begin
            if (addr1 == 2047 && cnt == 7) begin
                nxt_state_L1 = INPUT1_L1;
            end
            else begin
                nxt_state_L1 = cur_state_L1;
            end
        end
        INPUT1_L1: begin
            if (mv_cnt == 7) begin
                nxt_state_L1 = READ_L1;
            end
            else begin
                nxt_state_L1 = cur_state_L1;
            end
        end
        READ_L1: begin
            if (row1_cnt >= 1 && load1_cnt == require1) begin
                nxt_state_L1 = CAL_L1;
            end
            else begin
                nxt_state_L1 = cur_state_L1;
            end
        end
        CAL_L1: begin
            if (cal_cnt1 == 6 && total_cal_cnt1 < 9) begin
                nxt_state_L1 = READ_L1;
            end
            else if (cal_cnt1 == 6 && total_cal_cnt1 == 9) begin // all BI are completed
                nxt_state_L1 = WAIT1;
            end
            else begin
                nxt_state_L1 = cur_state_L1;
            end
        end
        WAIT1: begin
            if (require0 == require1 || wait_cnt == 11) begin
                nxt_state_L1 = SAD1;
            end
            else if (wait_cnt < 11) begin
                nxt_state_L1 = WAIT1;
            end
            else begin
                nxt_state_L1 = cur_state_L1;
            end
        end
        SAD1: begin
            if (point_cnt >= 1 && add_cnt == 16) begin
                nxt_state_L1 = SORT1;
            end
            else begin
                nxt_state_L1 = cur_state_L1;
            end
        end
        SORT1: begin
            if (point_cnt < 9) begin
                nxt_state_L1 = SAD1;
            end
            else begin
                nxt_state_L1 = OUT1;
            end
        end
        OUT1: begin
            if (cnt == 1) begin
                nxt_state_L1 = PRINT1;
            end
            else if (cnt == 0) begin
                nxt_state_L1 = READ_L1;
            end
            else begin
                nxt_state_L1 = cur_state_L1;
            end
        end
        PRINT1: begin
            if (print_cnt == 55 && set_cnt <63)begin
                nxt_state_L1 = INPUT1_L1;
            end
            else if (print_cnt == 55 && set_cnt == 63) begin
                nxt_state_L1 = INPUT_L1;
            end
            else begin
                nxt_state_L1 = cur_state_L1;
            end
        end
    endcase
end
always @(*) begin
    cnt_ns = cnt;
    if (cur_state == INPUT && in_valid) begin
        if (cnt != 7) begin
            cnt_ns = cnt + 1;
        end
        else begin
            cnt_ns = 0;
        end
    end
    else if (cur_state == INPUT1) begin
        cnt_ns = 0; // for the use of the next state to calculate bilinear
    end
    else if (cur_state == OUT && cnt == 0) begin
        cnt_ns = 1;
    end
    else if (cur_state == PRINT) begin
        cnt_ns = 0;
    end
    else begin
        cnt_ns = cnt;
    end
end
always @(*) begin
    mv_cnt_ns = mv_cnt;
    if (cur_state == INPUT1 && in_valid2) begin
        mv_cnt_ns = mv_cnt + 1;
    end
    else if (cur_state == INPUT1 && in_valid2 && mv_cnt == 7) begin
        mv_cnt_ns = 0; // for the use of the next state to calculate bilinear
    end
end
//-------------------------------
//           read L0L1
//-------------------------------

always @(*) begin
    if (addr0 == 2047 && cnt==0 &&cur_state == INPUT) begin
        input_first_ns = 1;
    end
    else if((cur_state == INPUT&&addr0<2047) || cur_state==READ)begin
        input_first_ns = 0;
    end
    else if (cur_state == PRINT) begin
        input_first_ns = 0;
    end
    else begin
        input_first_ns=input_first;
    end
    
end
always @(*) begin
    if (cur_state == INPUT && cnt == 7 && !input_first) begin
        WEB_L0_ns = 0;
    end
    else begin
        WEB_L0_ns = 1;
    end
end
always @(*) begin
    if (cur_state == INPUT && cnt == 7 && input_first) begin
        WEB_L1_ns = 0;
    end
    else begin
        WEB_L1_ns = 1;
    end
end

always @(*) begin
    for (i = 0; i<8;i++) begin
        temp_ns[i] = temp[i];
    end
    if (cur_state == INPUT && in_valid) begin
        temp_ns[cnt] = in_data[11:4]; 
    end
    else begin
        for (i = 0; i<8;i++) begin
            temp_ns[i] = temp[i];
        end
    end
end
always @(*) begin
    if (!WEB_L0) begin
        DI_L0[7:0] = temp[7]; 
        DI_L0[15:8] = temp[6];
        DI_L0[23:16] = temp[5];
        DI_L0[31:24] = temp[4];
        DI_L0[39:32] = temp[3];
        DI_L0[47:40] = temp[2];
        DI_L0[55:48] = temp[1];
        DI_L0[63:56] = temp[0];
    end
    else begin
        DI_L0 = 0;
    end
end

always @(*) begin
    if (!WEB_L1) begin
        DI_L1[7:0] = temp[7]; 
        DI_L1[15:8] = temp[6];
        DI_L1[23:16] = temp[5];
        DI_L1[31:24] = temp[4];
        DI_L1[39:32] = temp[3];
        DI_L1[47:40] = temp[2];
        DI_L1[55:48] = temp[1];
        DI_L1[63:56] = temp[0];
    end
    else begin
        DI_L1 = 0;
    end
end
/*
always @(*) begin
    if (!WEB_L1) begin
        addr1_ns = addr1 + 1;   
    end
    else begin
        addr1_ns = addr1;
    end
end
*/
//-------------------------------
//           read MV
//-------------------------------
always @(*) begin
    for (i = 0; i < 2 ; i++) begin
        mvx0_ns[i] = mvx0[i];
        mvy0_ns[i] = mvy0[i];
        mvx1_ns[i] = mvx1[i];
        mvy1_ns[i] = mvy1[i];
    end
    if (cur_state == INPUT1) begin
        case(mv_cnt) 
            0: begin mvx0_ns[0] = in_data; end
            1: begin mvy0_ns[0] = in_data; end
            2: begin mvx1_ns[0] = in_data; end
            3: begin mvy1_ns[0] = in_data; end
            4: begin mvx0_ns[1] = in_data; end
            5: begin mvy0_ns[1] = in_data; end
            6: begin mvx1_ns[1] = in_data; end
            7: begin mvy1_ns[1] = in_data; end
        endcase
    end
end
//-------------------------------
//        READ FROM SRAM
//-------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        site0 <= 0;
    end
    else begin
        site0 <= site0_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        site1 <= 0;
    end
    else begin
        site1 <= site1_ns;
    end
end
//WEB_L0 == 1 read
always @(*) begin
    addr1_ns = addr1;

    if (!WEB_L1) begin
        addr1_ns = addr1 + 1;   
    end
    else if(cur_state_L1 == INPUT1_L1)begin
        if(mv_cnt == 7)begin
            addr1_ns = (mvy1[0][11:4] << 4) + mvx1[0][11:4]/ 8;
            
        end
    end
    else if (cur_state_L1 == READ_L1) begin
        //one row is not complete so it has to continue
        if (load1_cnt != require1) begin
            addr1_ns = addr1 + 1;
            
        end

        // to another row
        else if (load1_cnt == require1) begin
            addr1_ns = addr1 +16 - require1;
            
        end
    end
    else if (cur_state_L1 == OUT1 && cnt == 0) begin
            addr1_ns = (mvy1[1][11:4] << 4) + mvx1[1][11:4]/ 8;
            
    end
    else if (cur_state_L1 == PRINT1) begin
        addr1_ns = 0;
        
    end
    
end
always@(*)begin
    site1_ns = site1;
    if (cur_state_L1 == INPUT_L1) begin
        site1_ns = 0;
    end
    else if(cur_state_L1 == INPUT1_L1)begin
        if(mv_cnt == 7)begin
            site1_ns = (mvx1[0][11:4]) % 8;
        end
    end
    else if (cur_state_L1 == OUT1 && cnt == 0) begin
        site1_ns = (mvx1[1][11:4]) % 8; 
    end
    else if (cur_state_L1 == PRINT1) begin
        site1_ns = 0;
    end
end
always @(*) begin
    addr0_ns = addr0;
    //if (cur_state == INPUT) begin
    //    site0_ns = 0;
    //end
    if (!WEB_L0 && cur_state == INPUT && addr0 != 2047) begin
        addr0_ns = addr0 + 1;   
    end
    else if (WEB_L0 && cur_state == INPUT && addr0 == 2047)begin
        addr0_ns = addr0;
    end
    else if(cur_state == INPUT1)begin
        if(mv_cnt == 7)begin
            addr0_ns = (mvy0[0][11:4] << 4) + mvx0[0][11:4] / 8;
        end
    end
    else if (cur_state == READ) begin
        //one row is not complete so it has to continue
        if (load0_cnt != require0) begin
            addr0_ns = addr0 + 1;
        end

        // to another row
        else if (load0_cnt == require0) begin
            addr0_ns = addr0 +16 - require0;
        end
    end
    else if (cur_state == OUT && cnt == 0) begin
            addr0_ns = (mvy0[1][11:4] << 4) + mvx0[1][11:4]/ 8;
    end
    else if (cur_state == PRINT) begin
        addr0_ns = 0;
    end
    
end
always@(*)begin
    site0_ns = site0;
    if(cur_state == INPUT1)begin
        if(mv_cnt == 7)begin
            site0_ns = (mvx0[0][11:4]) % 8;
        end
    end
    else if (cur_state == OUT && cnt == 0) begin
            site0_ns = (mvx0[1][11:4]) % 8; 
    end
    else if (cur_state == PRINT) begin
        site0_ns = 0;
    end
end
//load0 means that for one row how much time it had to read from the memory
always @(*) begin
    load0_cnt_ns = load0_cnt;
    if (cur_state == INPUT1) begin
        load0_cnt_ns = 0;
    end
    else if (cur_state == READ && (require0 != load0_cnt)) begin
        load0_cnt_ns = load0_cnt + 1;
    end
    else if (cur_state == READ &&  require0 == load0_cnt)begin
        load0_cnt_ns = 0;
    end
    else if (cur_state == CAL &&nxt_state==READ) begin
        load0_cnt_ns = 0;
    end
    else if(cur_state==CAL)begin
        load0_cnt_ns=0;
    end
end
//load0 means that for one row how much time it had to read from the memory
always @(*) begin
    load1_cnt_ns = load1_cnt;
    if (cur_state_L1 == INPUT1_L1) begin
        load1_cnt_ns = 0;
    end
    else if (cur_state_L1 == READ_L1 && (require1 != load1_cnt)) begin
        load1_cnt_ns = load1_cnt + 1;
    end
    else if (cur_state_L1 == READ_L1 &&  require1 == load1_cnt)begin
        load1_cnt_ns = 0;
    end
    else if (cur_state_L1 == CAL_L1 &&nxt_state_L1==READ_L1) begin
        load1_cnt_ns = 0;
    end
    else if(cur_state_L1==CAL_L1)begin
        load1_cnt_ns=0;
    end
end
always @(*) begin
    row0_cnt_ns = row0_cnt;
    if (cur_state == INPUT1) begin
        row0_cnt_ns = 0;
    end
    else if (cur_state == READ) begin
        if (load0_cnt == require0) begin
            row0_cnt_ns = row0_cnt + 1; // record the row of reading
        end
    end
    else if (cur_state == OUT) begin
        row0_cnt_ns = 0;
    end    
end
always @(*) begin
    row1_cnt_ns = row1_cnt;
    if (cur_state_L1 == INPUT1_L1) begin
        row1_cnt_ns = 0;
    end
    else if (cur_state_L1 == READ_L1) begin
        if (load1_cnt == require1) begin
            row1_cnt_ns = row1_cnt + 1; // record the row of reading
        end
    end 
    else if (cur_state_L1 == OUT1) begin
        row1_cnt_ns = 0;
    end   
end
always @(*) begin
    require0_ns = require0;
    if (cur_state == INPUT1) begin
        require0_ns = 1;
    end
    else if (cur_state == READ) begin

        case(site0_ns)
            0,1,2,3,4,5: require0_ns = 1;
            6,7: require0_ns = 2;
        endcase
    end
    if (cur_state == OUT) begin
        require0_ns = 1;
    end
end
always @(*) begin
    require1_ns = require1;
    if (cur_state_L1 == INPUT1_L1) begin
        require1_ns = 1;
    end
    else if (cur_state_L1 == READ_L1) begin

        case(site1_ns)
            0,1,2,3,4,5: require1_ns = 1;
            6,7: require1_ns = 2;
        endcase
    end
    if (cur_state_L1 == OUT1) begin
        require1_ns = 1;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i=0;i<2;i=i+1)begin
            for (j=0;j<11;j++) begin
                cal0[i][j]<=0;
            end
        end
    end
    else begin
        for(i=0;i<2;i=i+1)begin
            for (j=0;j<11;j++) begin
                cal0[i][j]<=cal0_ns[i][j];
            end
        end
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i=0;i<2;i=i+1)begin
            for (j=0;j<11;j++) begin
                cal1[i][j]<=0;
            end
        end
    end
    else begin
        for(i=0;i<2;i=i+1)begin
            for (j=0;j<11;j++) begin
                cal1[i][j]<=cal1_ns[i][j];
            end
        end
    end
end

always@(*)begin
    for (i=0;i<2;i++) begin
        for (j=0;j<11;j++) begin
            cal0_ns[i][j] = cal0[i][j];
        end
    end
    if((cur_state==READ&&((load0_cnt!=0&&load0_cnt!=1)||row0_cnt==1))||(cur_state==CAL&&cal_cnt<=1))begin
        case(site0)
            0:begin
                case(delay_sram0)
                    0:begin
                        cal0_ns[0][10]=cal0[1][7];
                        cal0_ns[0][9] =cal0[1][6];
                        cal0_ns[0][8] =cal0[1][5];
                        cal0_ns[0][7] =cal0[1][4];
                        cal0_ns[0][6] =cal0[1][3];
                        cal0_ns[0][5] =cal0[1][2];
                        cal0_ns[0][4] =cal0[1][1];
                        cal0_ns[0][3] =cal0[1][0];
                        cal0_ns[0][2] =cal0[0][10];
                        cal0_ns[0][1] =cal0[0][9];
                        cal0_ns[0][0] =cal0[0][8];
                        cal0_ns[1][3] =D0[63:56];
                        cal0_ns[1][4] =D0[55:48];
                        cal0_ns[1][5] =D0[47:40];
                        cal0_ns[1][6] =D0[39:32];
                        cal0_ns[1][7] =D0[31:24];
                        cal0_ns[1][8] =D0[25:16];
                        cal0_ns[1][9] =D0[15:8];
                        cal0_ns[1][10]=D0[7:0];
                        for(i=0;i<=2;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+8];
                        end
                    end
                    1:begin
                        cal0_ns[1][8]=D0[63:56];
                        cal0_ns[1][9]=D0[55:48];
                        cal0_ns[1][10]=D0[47:40];
                        for(i=0;i<=7;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+3];
                        end
                        cal0_ns[0][10]=cal0[1][2];
                        cal0_ns[0][9]=cal0[1][1];
                        cal0_ns[0][8]=cal0[1][0];
                        cal0_ns[0][7]=cal0[0][10];
                        cal0_ns[0][6]=cal0[0][9];
                        cal0_ns[0][5]=cal0[0][8];
                        cal0_ns[0][4]=cal0[0][7];
                        cal0_ns[0][3]=cal0[0][6];
                        cal0_ns[0][2]=cal0[0][5];
                        cal0_ns[0][1]=cal0[0][4];
                        cal0_ns[0][0]=cal0[0][3];
                    end
                endcase
            end
            1:begin
                case(delay_sram0)
                    0:begin
                        //shift 7
                        cal0_ns[0][10]=cal0[1][6];
                        cal0_ns[0][9]=cal0[1][5];
                        cal0_ns[0][8]=cal0[1][4];
                        cal0_ns[0][7]=cal0[1][3];
                        cal0_ns[0][6]=cal0[1][2];
                        cal0_ns[0][5]=cal0[1][1];
                        cal0_ns[0][4]=cal0[1][0];
                        cal0_ns[0][3]=cal0[1][10];
                        cal0_ns[0][2]=cal0[0][9];
                        cal0_ns[0][1]=cal0[0][8];
                        cal0_ns[0][0]=cal0[0][7];
                        cal0_ns[1][4]=D0[55:48];
                        cal0_ns[1][5]=D0[47:40];
                        cal0_ns[1][6]=D0[39:32];
                        cal0_ns[1][7]=D0[31:24];
                        cal0_ns[1][8]=D0[23:16];
                        cal0_ns[1][9]=D0[15:8];
                        cal0_ns[1][10]=D0[7:0];
                        for(i=0;i<=3;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+7];
                        end
                    end
                    1:begin
                        //shift4
                        cal0_ns[1][7] = D0[63:56];
                        cal0_ns[1][8]=D0[55:48];
                        cal0_ns[1][9]=D0[47:40];
                        cal0_ns[1][10]=D0[39:32];
                        for(i=0;i<=6;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+4];
                        end
                        cal0_ns[0][10]=cal0[1][3];
                        cal0_ns[0][9]=cal0[1][2];
                        cal0_ns[0][8]=cal0[1][1];
                        cal0_ns[0][7]=cal0[1][0];
                        cal0_ns[0][6]=cal0[0][10];
                        cal0_ns[0][5]=cal0[0][9];
                        cal0_ns[0][4]=cal0[0][8];
                        cal0_ns[0][3]=cal0[0][7];
                        cal0_ns[0][2]=cal0[0][6];
                        cal0_ns[0][1]=cal0[0][5];
                        cal0_ns[0][0]=cal0[0][4];
                    end
                endcase
            end
            2:begin
                case(delay_sram0)
                    0:begin
                        //shift 6
                        cal0_ns[0][10]=cal0[1][5];
                        cal0_ns[0][9]=cal0[1][4];
                        cal0_ns[0][8]=cal0[1][3];
                        cal0_ns[0][7]=cal0[1][2];
                        cal0_ns[0][6]=cal0[1][1];
                        cal0_ns[0][5]=cal0[1][0];
                        cal0_ns[0][4]=cal0[0][10];
                        cal0_ns[0][3]=cal0[0][9];
                        cal0_ns[0][2]=cal0[0][8];
                        cal0_ns[0][1]=cal0[0][7];
                        cal0_ns[0][0]=cal0[0][6];
                        for(i=0;i<=4;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+6];
                        end
                        cal0_ns[1][5]=D0[47:40];
                        cal0_ns[1][6]=D0[39:32];
                        cal0_ns[1][7]=D0[31:24];
                        cal0_ns[1][8]=D0[23:16];
                        cal0_ns[1][9]=D0[15:8];
                        cal0_ns[1][10]=D0[7:0];

                    end
                    1:begin
                        //shift5
                        cal0_ns[1][6] = D0[63:56];
                        cal0_ns[1][7] = D0[55:48];
                        cal0_ns[1][8]=D0[47:40];
                        cal0_ns[1][9]=D0[39:32];
                        cal0_ns[1][10]=D0[31:24];
                        for(i=0;i<=5;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+5];
                        end
                        cal0_ns[0][10]=cal0[1][4];
                        cal0_ns[0][9]=cal0[1][3];
                        cal0_ns[0][8]=cal0[1][2];
                        cal0_ns[0][7]=cal0[1][1];
                        cal0_ns[0][6]=cal0[1][0];
                        cal0_ns[0][5]=cal0[0][10];
                        cal0_ns[0][4]=cal0[0][9];
                        cal0_ns[0][3]=cal0[0][8];
                        cal0_ns[0][2]=cal0[0][7];
                        cal0_ns[0][1]=cal0[0][6];
                        cal0_ns[0][0]=cal0[0][5];
                    end
                endcase
            end
            3:begin
                case(delay_sram0)
                    0:begin
                        //shift 5
                        cal0_ns[0][10]=cal0[1][4];
                        cal0_ns[0][9]=cal0[1][3];
                        cal0_ns[0][8]=cal0[1][2];
                        cal0_ns[0][7]=cal0[1][1];
                        cal0_ns[0][6]=cal0[1][0];
                        cal0_ns[0][5]=cal0[0][10];
                        cal0_ns[0][4]=cal0[0][9];
                        cal0_ns[0][3]=cal0[0][8];
                        cal0_ns[0][2]=cal0[0][7];
                        cal0_ns[0][1]=cal0[0][6];
                        cal0_ns[0][0]=cal0[0][5];
                        for(i=0;i<=5;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+5];
                        end
                        cal0_ns[1][6]=D0[39:32];
                        cal0_ns[1][7]=D0[31:24];
                        cal0_ns[1][8]=D0[23:16];
                        cal0_ns[1][9]=D0[15:8];
                        cal0_ns[1][10]=D0[7:0];

                    end
                    1:begin
                        //shift 6
                        cal0_ns[1][5] = D0[63:56];
                        cal0_ns[1][6] = D0[55:48];
                        cal0_ns[1][7] = D0[47:40];
                        cal0_ns[1][8]=D0[39:32];
                        cal0_ns[1][9]=D0[31:24];
                        cal0_ns[1][10]=D0[23:16];
                        for(i=0;i<=4;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+6];
                        end
                        cal0_ns[0][10]=cal0[1][5];
                        cal0_ns[0][9]=cal0[1][4];
                        cal0_ns[0][8]=cal0[1][3];
                        cal0_ns[0][7]=cal0[1][2];
                        cal0_ns[0][6]=cal0[1][1];
                        cal0_ns[0][5]=cal0[1][0];
                        cal0_ns[0][4]=cal0[0][10];
                        cal0_ns[0][3]=cal0[0][9];
                        cal0_ns[0][2]=cal0[0][8];
                        cal0_ns[0][1]=cal0[0][7];
                        cal0_ns[0][0]=cal0[0][6];
                    end
                endcase
            end
            4:begin
                case(delay_sram0)
                    0:begin
                        //shift 4
                        cal0_ns[0][10]=cal0[1][3];
                        cal0_ns[0][9]=cal0[1][2];
                        cal0_ns[0][8]=cal0[1][1];
                        cal0_ns[0][7]=cal0[1][0];
                        cal0_ns[0][6]=cal0[0][10];
                        cal0_ns[0][5]=cal0[0][9];
                        cal0_ns[0][4]=cal0[0][8];
                        cal0_ns[0][3]=cal0[0][7];
                        cal0_ns[0][2]=cal0[0][6];
                        cal0_ns[0][1]=cal0[0][5];
                        cal0_ns[0][0]=cal0[0][4];
                        for(i=0;i<=6;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+4];
                        end
                        cal0_ns[1][7]=D0[31:24];
                        cal0_ns[1][8]=D0[23:16];
                        cal0_ns[1][9]=D0[15:8];
                        cal0_ns[1][10]=D0[7:0];

                    end
                    1:begin
                        //shift 7
                        cal0_ns[1][4] = D0[63:56];
                        cal0_ns[1][5] = D0[55:48];
                        cal0_ns[1][6] = D0[47:40];
                        cal0_ns[1][7] = D0[39:32];
                        cal0_ns[1][8]=D0[31:24];
                        cal0_ns[1][9]=D0[23:16];
                        cal0_ns[1][10]=D0[15:8];
                        for(i=0;i<=3;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+7];
                        end
                        cal0_ns[0][10]=cal0[1][6];
                        cal0_ns[0][9]=cal0[1][5];
                        cal0_ns[0][8]=cal0[1][4];
                        cal0_ns[0][7]=cal0[1][3];
                        cal0_ns[0][6]=cal0[1][2];
                        cal0_ns[0][5]=cal0[1][1];
                        cal0_ns[0][4]=cal0[1][0];
                        cal0_ns[0][3]=cal0[0][10];
                        cal0_ns[0][2]=cal0[0][9];
                        cal0_ns[0][1]=cal0[0][8];
                        cal0_ns[0][0]=cal0[0][7];
                    end
                endcase
            end
            5:begin
                case(delay_sram0)
                    0:begin
                        cal0_ns[1][8]=D0[23:16];
                        cal0_ns[1][9]=D0[15:8];
                        cal0_ns[1][10]=D0[7:0];
                        for(i=0;i<=7;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+3];
                        end
                        cal0_ns[0][10]=cal0[1][2];
                        cal0_ns[0][9]=cal0[1][1];
                        cal0_ns[0][8]=cal0[1][0];
                        cal0_ns[0][7]=cal0[0][10];
                        cal0_ns[0][6]=cal0[0][9];
                        cal0_ns[0][5]=cal0[0][8];
                        cal0_ns[0][4]=cal0[0][7];
                        cal0_ns[0][3]=cal0[0][6];
                        cal0_ns[0][2]=cal0[0][5];
                        cal0_ns[0][1]=cal0[0][4];
                        cal0_ns[0][0]=cal0[0][3];
                    end
                    1:begin
                        cal0_ns[0][10]=cal0[1][7];
                        cal0_ns[0][9]=cal0[1][6];
                        cal0_ns[0][8]=cal0[1][5];
                        cal0_ns[0][7]=cal0[1][4];
                        cal0_ns[0][6]=cal0[1][3];
                        cal0_ns[0][5]=cal0[1][2];
                        cal0_ns[0][4]=cal0[1][1];
                        cal0_ns[0][3]=cal0[1][0];
                        cal0_ns[0][2]=cal0[0][10];
                        cal0_ns[0][1]=cal0[0][9];
                        cal0_ns[0][0]=cal0[0][8];
                        cal0_ns[1][3]=D0[63:56];
                        cal0_ns[1][4]=D0[55:48];
                        cal0_ns[1][5]=D0[47:40];
                        cal0_ns[1][6]=D0[39:32];
                        cal0_ns[1][7]=D0[31:24];
                        cal0_ns[1][8]=D0[23:16];
                        cal0_ns[1][9]=D0[15:8];
                        cal0_ns[1][10]=D0[7:0];
                        for(i=0;i<=2;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+8];
                        end
                    end
                endcase
            end
            6:begin
                case(delay_sram0)
                    0:begin
                        //SHIFT 2 
                        cal0_ns[1][9]=D0[15:8];
                        cal0_ns[1][10]=D0[7:0];
                        for(i=0;i<=8;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+2];
                        end
                        cal0_ns[0][10]=cal0[1][1];
                        cal0_ns[0][9]=cal0[1][0];
                        cal0_ns[0][8]=cal0[0][10];
                        cal0_ns[0][7]=cal0[0][9];
                        cal0_ns[0][6]=cal0[0][8];
                        cal0_ns[0][5]=cal0[0][7];
                        cal0_ns[0][4]=cal0[0][6];
                        cal0_ns[0][3]=cal0[0][5];
                        cal0_ns[0][2]=cal0[0][4];
                        cal0_ns[0][1]=cal0[0][3];
                        cal0_ns[0][0]=cal0[0][2];
                    end
                    1:begin
                        //SHIFT 8 
                        cal0_ns[0][10]=cal0[1][7];
                        cal0_ns[0][9]=cal0[1][6];
                        cal0_ns[0][8]=cal0[1][5];
                        cal0_ns[0][7]=cal0[1][4];
                        cal0_ns[0][6]=cal0[1][3];
                        cal0_ns[0][5]=cal0[1][2];
                        cal0_ns[0][4]=cal0[1][1];
                        cal0_ns[0][3]=cal0[1][0];
                        cal0_ns[0][2]=cal0[0][10];
                        cal0_ns[0][1]=cal0[0][9];
                        cal0_ns[0][0]=cal0[0][8];
                        cal0_ns[1][3]=D0[63:56];
                        cal0_ns[1][4]=D0[55:48];
                        cal0_ns[1][5]=D0[47:40];
                        cal0_ns[1][6]=D0[39:32];
                        cal0_ns[1][7]=D0[31:24];
                        cal0_ns[1][8]=D0[23:16];
                        cal0_ns[1][9]=D0[15:8];
                        cal0_ns[1][10]=D0[7:0];
                        for(i=0;i<=2;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+8];
                        end
                    end
                    2: begin
                        //shift 1
                        for(i=0;i<=9;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+1];
                        end    
                        cal0_ns[1][10] = D0[63:56];
                        cal0_ns[0][10]=cal0[1][0];
                        cal0_ns[0][9]=cal0[0][10];
                        cal0_ns[0][8]=cal0[0][9];
                        cal0_ns[0][7]=cal0[0][8];
                        cal0_ns[0][6]=cal0[0][7];
                        cal0_ns[0][5]=cal0[0][6];
                        cal0_ns[0][4]=cal0[0][5];
                        cal0_ns[0][3]=cal0[0][4];
                        cal0_ns[0][2]=cal0[0][3];
                        cal0_ns[0][1]=cal0[0][2];
                        cal0_ns[0][0]=cal0[0][1];                                            
                    end
                endcase
            
            end
            7:begin
                case(delay_sram0)
                    0:begin
                        //SHIFT 1
                        cal0_ns[1][10]=D0[7:0];
                        for(i=0;i<=9;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+1];
                        end
                        cal0_ns[0][10]=cal0[1][0];
                        cal0_ns[0][9]=cal0[0][10];
                        cal0_ns[0][8]=cal0[0][9];
                        cal0_ns[0][7]=cal0[0][8];
                        cal0_ns[0][6]=cal0[0][7];
                        cal0_ns[0][5]=cal0[0][6];
                        cal0_ns[0][4]=cal0[0][5];
                        cal0_ns[0][3]=cal0[0][4];
                        cal0_ns[0][2]=cal0[0][3];
                        cal0_ns[0][1]=cal0[0][2];
                        cal0_ns[0][0]=cal0[0][1];
                    end
                    1:begin
                        //SHIFT 8 
                        cal0_ns[0][10]=cal0[1][7];
                        cal0_ns[0][9]=cal0[1][6];
                        cal0_ns[0][8]=cal0[1][5];
                        cal0_ns[0][7]=cal0[1][4];
                        cal0_ns[0][6]=cal0[1][3];
                        cal0_ns[0][5]=cal0[1][2];
                        cal0_ns[0][4]=cal0[1][1];
                        cal0_ns[0][3]=cal0[1][0];
                        cal0_ns[0][2]=cal0[0][10];
                        cal0_ns[0][1]=cal0[0][9];
                        cal0_ns[0][0]=cal0[0][8];
                        cal0_ns[1][3]=D0[63:56];
                        cal0_ns[1][4]=D0[55:48];
                        cal0_ns[1][5]=D0[47:40];
                        cal0_ns[1][6]=D0[39:32];
                        cal0_ns[1][7]=D0[31:24];
                        cal0_ns[1][8]=D0[23:16];
                        cal0_ns[1][9]=D0[15:8];
                        cal0_ns[1][10]=D0[7:0];
                        for(i=0;i<=2;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+8];
                        end
                    end
                    2: begin
                        //shift 2
                        for(i=0;i<=8;i=i+1)begin
                            cal0_ns[1][i]=cal0[1][i+2];
                        end    
                        cal0_ns[1][10] = D0[55:48];
                        cal0_ns[1][9] = D0[63:56];
                        cal0_ns[0][10]=cal0[1][1];
                        cal0_ns[0][9]=cal0[1][0];
                        cal0_ns[0][8]=cal0[0][10];
                        cal0_ns[0][7]=cal0[0][9];
                        cal0_ns[0][6]=cal0[0][8];
                        cal0_ns[0][5]=cal0[0][7];
                        cal0_ns[0][4]=cal0[0][6];
                        cal0_ns[0][3]=cal0[0][5];
                        cal0_ns[0][2]=cal0[0][4];
                        cal0_ns[0][1]=cal0[0][3];
                        cal0_ns[0][0]=cal0[0][2];                                            
                    end
                endcase
            end
        endcase
    end
end
integer a,b;
always@(*)begin
    for (i=0;i<2;i++) begin
        for (j=0;j<11;j++) begin
            cal1_ns[i][j] = cal1[i][j];
        end
    end
    if((cur_state_L1==READ_L1&&((load1_cnt!=0&&load1_cnt!=1)||row1_cnt==1))||(cur_state_L1==CAL_L1&&cal_cnt1<=1))begin
        case(site1)
            0:begin
                case(delay_sram1)
                    0:begin
                        cal1_ns[0][10]=cal1[1][7];
                        cal1_ns[0][9] =cal1[1][6];
                        cal1_ns[0][8] =cal1[1][5];
                        cal1_ns[0][7] =cal1[1][4];
                        cal1_ns[0][6] =cal1[1][3];
                        cal1_ns[0][5] =cal1[1][2];
                        cal1_ns[0][4] =cal1[1][1];
                        cal1_ns[0][3] =cal1[1][0];
                        cal1_ns[0][2] =cal1[0][10];
                        cal1_ns[0][1] =cal1[0][9];
                        cal1_ns[0][0] =cal1[0][8];
                        cal1_ns[1][3] =D1[63:56];
                        cal1_ns[1][4] =D1[55:48];
                        cal1_ns[1][5] =D1[47:40];
                        cal1_ns[1][6] =D1[39:32];
                        cal1_ns[1][7] =D1[31:24];
                        cal1_ns[1][8] =D1[25:16];
                        cal1_ns[1][9] =D1[15:8];
                        cal1_ns[1][10]=D1[7:0];
                        for(a=0;a<=2;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+8];
                        end
                    end
                    1:begin
                        cal1_ns[1][8]=D1[63:56];
                        cal1_ns[1][9]=D1[55:48];
                        cal1_ns[1][10]=D1[47:40];
                        for(a=0;a<=7;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+3];
                        end
                        cal1_ns[0][10]=cal1[1][2];
                        cal1_ns[0][9]=cal1[1][1];
                        cal1_ns[0][8]=cal1[1][0];
                        cal1_ns[0][7]=cal1[0][10];
                        cal1_ns[0][6]=cal1[0][9];
                        cal1_ns[0][5]=cal1[0][8];
                        cal1_ns[0][4]=cal1[0][7];
                        cal1_ns[0][3]=cal1[0][6];
                        cal1_ns[0][2]=cal1[0][5];
                        cal1_ns[0][1]=cal1[0][4];
                        cal1_ns[0][0]=cal1[0][3];
                    end
                endcase
            end
            1:begin
                case(delay_sram1)
                    0:begin
                        //shift 7
                        cal1_ns[0][10]=cal1[1][6];
                        cal1_ns[0][9]=cal1[1][5];
                        cal1_ns[0][8]=cal1[1][4];
                        cal1_ns[0][7]=cal1[1][3];
                        cal1_ns[0][6]=cal1[1][2];
                        cal1_ns[0][5]=cal1[1][1];
                        cal1_ns[0][4]=cal1[1][0];
                        cal1_ns[0][3]=cal1[1][10];
                        cal1_ns[0][2]=cal1[0][9];
                        cal1_ns[0][1]=cal1[0][8];
                        cal1_ns[0][0]=cal1[0][7];
                        cal1_ns[1][4]=D1[55:48];
                        cal1_ns[1][5]=D1[47:40];
                        cal1_ns[1][6]=D1[39:32];
                        cal1_ns[1][7]=D1[31:24];
                        cal1_ns[1][8]=D1[23:16];
                        cal1_ns[1][9]=D1[15:8];
                        cal1_ns[1][10]=D1[7:0];
                        for(a=0;a<=3;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+7];
                        end
                    end
                    1:begin
                        //shift4
                        cal1_ns[1][7] = D1[63:56];
                        cal1_ns[1][8]=D1[55:48];
                        cal1_ns[1][9]=D1[47:40];
                        cal1_ns[1][10]=D1[39:32];
                        for(a=0;a<=6;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+4];
                        end
                        cal1_ns[0][10]=cal1[1][3];
                        cal1_ns[0][9]=cal1[1][2];
                        cal1_ns[0][8]=cal1[1][1];
                        cal1_ns[0][7]=cal1[1][0];
                        cal1_ns[0][6]=cal1[0][10];
                        cal1_ns[0][5]=cal1[0][9];
                        cal1_ns[0][4]=cal1[0][8];
                        cal1_ns[0][3]=cal1[0][7];
                        cal1_ns[0][2]=cal1[0][6];
                        cal1_ns[0][1]=cal1[0][5];
                        cal1_ns[0][0]=cal1[0][4];
                    end
                endcase
            end
            2:begin
                case(delay_sram1)
                    0:begin
                        //shift 6
                        cal1_ns[0][10]=cal1[1][5];
                        cal1_ns[0][9]=cal1[1][4];
                        cal1_ns[0][8]=cal1[1][3];
                        cal1_ns[0][7]=cal1[1][2];
                        cal1_ns[0][6]=cal1[1][1];
                        cal1_ns[0][5]=cal1[1][0];
                        cal1_ns[0][4]=cal1[0][10];
                        cal1_ns[0][3]=cal1[0][9];
                        cal1_ns[0][2]=cal1[0][8];
                        cal1_ns[0][1]=cal1[0][7];
                        cal1_ns[0][0]=cal1[0][6];
                        for(a=0;a<=4;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+6];
                        end
                        cal1_ns[1][5]=D1[47:40];
                        cal1_ns[1][6]=D1[39:32];
                        cal1_ns[1][7]=D1[31:24];
                        cal1_ns[1][8]=D1[23:16];
                        cal1_ns[1][9]=D1[15:8];
                        cal1_ns[1][10]=D1[7:0];

                    end
                    1:begin
                        //shift5
                        cal1_ns[1][6] = D1[63:56];
                        cal1_ns[1][7] = D1[55:48];
                        cal1_ns[1][8]=D1[47:40];
                        cal1_ns[1][9]=D1[39:32];
                        cal1_ns[1][10]=D1[31:24];
                        for(a=0;a<=5;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+5];
                        end
                        cal1_ns[0][10]=cal1[1][4];
                        cal1_ns[0][9]=cal1[1][3];
                        cal1_ns[0][8]=cal1[1][2];
                        cal1_ns[0][7]=cal1[1][1];
                        cal1_ns[0][6]=cal1[1][0];
                        cal1_ns[0][5]=cal1[0][10];
                        cal1_ns[0][4]=cal1[0][9];
                        cal1_ns[0][3]=cal1[0][8];
                        cal1_ns[0][2]=cal1[0][7];
                        cal1_ns[0][1]=cal1[0][6];
                        cal1_ns[0][0]=cal1[0][5];
                    end
                endcase
            end
            3:begin
                case(delay_sram1)
                    0:begin
                        //shift 5
                        cal1_ns[0][10]=cal1[1][4];
                        cal1_ns[0][9]=cal1[1][3];
                        cal1_ns[0][8]=cal1[1][2];
                        cal1_ns[0][7]=cal1[1][1];
                        cal1_ns[0][6]=cal1[1][0];
                        cal1_ns[0][5]=cal1[0][10];
                        cal1_ns[0][4]=cal1[0][9];
                        cal1_ns[0][3]=cal1[0][8];
                        cal1_ns[0][2]=cal1[0][7];
                        cal1_ns[0][1]=cal1[0][6];
                        cal1_ns[0][0]=cal1[0][5];
                        for(a=0;a<=5;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+5];
                        end
                        cal1_ns[1][6]=D1[39:32];
                        cal1_ns[1][7]=D1[31:24];
                        cal1_ns[1][8]=D1[23:16];
                        cal1_ns[1][9]=D1[15:8];
                        cal1_ns[1][10]=D1[7:0];

                    end
                    1:begin
                        //shift 6
                        cal1_ns[1][5] = D1[63:56];
                        cal1_ns[1][6] = D1[55:48];
                        cal1_ns[1][7] = D1[47:40];
                        cal1_ns[1][8]=D1[39:32];
                        cal1_ns[1][9]=D1[31:24];
                        cal1_ns[1][10]=D1[23:16];
                        for(a=0;a<=4;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+6];
                        end
                        cal1_ns[0][10]=cal1[1][5];
                        cal1_ns[0][9]=cal1[1][4];
                        cal1_ns[0][8]=cal1[1][3];
                        cal1_ns[0][7]=cal1[1][2];
                        cal1_ns[0][6]=cal1[1][1];
                        cal1_ns[0][5]=cal1[1][0];
                        cal1_ns[0][4]=cal1[0][10];
                        cal1_ns[0][3]=cal1[0][9];
                        cal1_ns[0][2]=cal1[0][8];
                        cal1_ns[0][1]=cal1[0][7];
                        cal1_ns[0][0]=cal1[0][6];
                    end
                endcase
            end
            4:begin
                case(delay_sram1)
                    0:begin
                        //shift 4
                        cal1_ns[0][10]=cal1[1][3];
                        cal1_ns[0][9]=cal1[1][2];
                        cal1_ns[0][8]=cal1[1][1];
                        cal1_ns[0][7]=cal1[1][0];
                        cal1_ns[0][6]=cal1[0][10];
                        cal1_ns[0][5]=cal1[0][9];
                        cal1_ns[0][4]=cal1[0][8];
                        cal1_ns[0][3]=cal1[0][7];
                        cal1_ns[0][2]=cal1[0][6];
                        cal1_ns[0][1]=cal1[0][5];
                        cal1_ns[0][0]=cal1[0][4];
                        for(a=0;a<=6;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+4];
                        end
                        cal1_ns[1][7]=D1[31:24];
                        cal1_ns[1][8]=D1[23:16];
                        cal1_ns[1][9]=D1[15:8];
                        cal1_ns[1][10]=D1[7:0];

                    end
                    1:begin
                        //shift 7
                        cal1_ns[1][4] = D1[63:56];
                        cal1_ns[1][5] = D1[55:48];
                        cal1_ns[1][6] = D1[47:40];
                        cal1_ns[1][7] = D1[39:32];
                        cal1_ns[1][8]=D1[31:24];
                        cal1_ns[1][9]=D1[23:16];
                        cal1_ns[1][10]=D1[15:8];
                        for(a=0;a<=3;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+7];
                        end
                        cal1_ns[0][10]=cal1[1][6];
                        cal1_ns[0][9]=cal1[1][5];
                        cal1_ns[0][8]=cal1[1][4];
                        cal1_ns[0][7]=cal1[1][3];
                        cal1_ns[0][6]=cal1[1][2];
                        cal1_ns[0][5]=cal1[1][1];
                        cal1_ns[0][4]=cal1[1][0];
                        cal1_ns[0][3]=cal1[0][10];
                        cal1_ns[0][2]=cal1[0][9];
                        cal1_ns[0][1]=cal1[0][8];
                        cal1_ns[0][0]=cal1[0][7];
                    end
                endcase
            end
            5:begin
                case(delay_sram1)
                    0:begin
                        cal1_ns[1][8]=D1[23:16];
                        cal1_ns[1][9]=D1[15:8];
                        cal1_ns[1][10]=D1[7:0];
                        for(a=0;a<=7;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+3];
                        end
                        cal1_ns[0][10]=cal1[1][2];
                        cal1_ns[0][9]=cal1[1][1];
                        cal1_ns[0][8]=cal1[1][0];
                        cal1_ns[0][7]=cal1[0][10];
                        cal1_ns[0][6]=cal1[0][9];
                        cal1_ns[0][5]=cal1[0][8];
                        cal1_ns[0][4]=cal1[0][7];
                        cal1_ns[0][3]=cal1[0][6];
                        cal1_ns[0][2]=cal1[0][5];
                        cal1_ns[0][1]=cal1[0][4];
                        cal1_ns[0][0]=cal1[0][3];
                    end
                    1:begin
                        cal1_ns[0][10]=cal1[1][7];
                        cal1_ns[0][9]=cal1[1][6];
                        cal1_ns[0][8]=cal1[1][5];
                        cal1_ns[0][7]=cal1[1][4];
                        cal1_ns[0][6]=cal1[1][3];
                        cal1_ns[0][5]=cal1[1][2];
                        cal1_ns[0][4]=cal1[1][1];
                        cal1_ns[0][3]=cal1[1][0];
                        cal1_ns[0][2]=cal1[0][10];
                        cal1_ns[0][1]=cal1[0][9];
                        cal1_ns[0][0]=cal1[0][8];
                        cal1_ns[1][3]=D1[63:56];
                        cal1_ns[1][4]=D1[55:48];
                        cal1_ns[1][5]=D1[47:40];
                        cal1_ns[1][6]=D1[39:32];
                        cal1_ns[1][7]=D1[31:24];
                        cal1_ns[1][8]=D1[23:16];
                        cal1_ns[1][9]=D1[15:8];
                        cal1_ns[1][10]=D1[7:0];
                        for(a=0;a<=2;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+8];
                        end
                    end
                endcase
            end
            6:begin
                case(delay_sram1)
                    0:begin
                        //SHIFT 2 
                        cal1_ns[1][9]=D1[15:8];
                        cal1_ns[1][10]=D1[7:0];
                        for(a=0;a<=8;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+2];
                        end
                        cal1_ns[0][10]=cal1[1][1];
                        cal1_ns[0][9]=cal1[1][0];
                        cal1_ns[0][8]=cal1[0][10];
                        cal1_ns[0][7]=cal1[0][9];
                        cal1_ns[0][6]=cal1[0][8];
                        cal1_ns[0][5]=cal1[0][7];
                        cal1_ns[0][4]=cal1[0][6];
                        cal1_ns[0][3]=cal1[0][5];
                        cal1_ns[0][2]=cal1[0][4];
                        cal1_ns[0][1]=cal1[0][3];
                        cal1_ns[0][0]=cal1[0][2];
                    end
                    1:begin
                        //SHIFT 8 
                        cal1_ns[0][10]=cal1[1][7];
                        cal1_ns[0][9]=cal1[1][6];
                        cal1_ns[0][8]=cal1[1][5];
                        cal1_ns[0][7]=cal1[1][4];
                        cal1_ns[0][6]=cal1[1][3];
                        cal1_ns[0][5]=cal1[1][2];
                        cal1_ns[0][4]=cal1[1][1];
                        cal1_ns[0][3]=cal1[1][0];
                        cal1_ns[0][2]=cal1[0][10];
                        cal1_ns[0][1]=cal1[0][9];
                        cal1_ns[0][0]=cal1[0][8];
                        cal1_ns[1][3]=D1[63:56];
                        cal1_ns[1][4]=D1[55:48];
                        cal1_ns[1][5]=D1[47:40];
                        cal1_ns[1][6]=D1[39:32];
                        cal1_ns[1][7]=D1[31:24];
                        cal1_ns[1][8]=D1[23:16];
                        cal1_ns[1][9]=D1[15:8];
                        cal1_ns[1][10]=D1[7:0];
                        for(a=0;a<=2;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+8];
                        end
                    end
                    2: begin
                        //shift 1
                        for(a=0;a<=9;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+1];
                        end    
                        cal1_ns[1][10] = D1[63:56];
                        cal1_ns[0][10]=cal1[1][0];
                        cal1_ns[0][9]=cal1[0][10];
                        cal1_ns[0][8]=cal1[0][9];
                        cal1_ns[0][7]=cal1[0][8];
                        cal1_ns[0][6]=cal1[0][7];
                        cal1_ns[0][5]=cal1[0][6];
                        cal1_ns[0][4]=cal1[0][5];
                        cal1_ns[0][3]=cal1[0][4];
                        cal1_ns[0][2]=cal1[0][3];
                        cal1_ns[0][1]=cal1[0][2];
                        cal1_ns[0][0]=cal1[0][1];                                            
                    end
                endcase
            
            end
            7:begin
                case(delay_sram1)
                    0:begin
                        //SHIFT 1
                        cal1_ns[1][10]=D1[7:0];
                        for(a=0;a<=9;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+1];
                        end
                        cal1_ns[0][10]=cal1[1][0];
                        cal1_ns[0][9]=cal1[0][10];
                        cal1_ns[0][8]=cal1[0][9];
                        cal1_ns[0][7]=cal1[0][8];
                        cal1_ns[0][6]=cal1[0][7];
                        cal1_ns[0][5]=cal1[0][6];
                        cal1_ns[0][4]=cal1[0][5];
                        cal1_ns[0][3]=cal1[0][4];
                        cal1_ns[0][2]=cal1[0][3];
                        cal1_ns[0][1]=cal1[0][2];
                        cal1_ns[0][0]=cal1[0][1];
                    end
                    1:begin
                        //SHIFT 8 
                        cal1_ns[0][10]=cal1[1][7];
                        cal1_ns[0][9]=cal1[1][6];
                        cal1_ns[0][8]=cal1[1][5];
                        cal1_ns[0][7]=cal1[1][4];
                        cal1_ns[0][6]=cal1[1][3];
                        cal1_ns[0][5]=cal1[1][2];
                        cal1_ns[0][4]=cal1[1][1];
                        cal1_ns[0][3]=cal1[1][0];
                        cal1_ns[0][2]=cal1[0][10];
                        cal1_ns[0][1]=cal1[0][9];
                        cal1_ns[0][0]=cal1[0][8];
                        cal1_ns[1][3]=D1[63:56];
                        cal1_ns[1][4]=D1[55:48];
                        cal1_ns[1][5]=D1[47:40];
                        cal1_ns[1][6]=D1[39:32];
                        cal1_ns[1][7]=D1[31:24];
                        cal1_ns[1][8]=D1[23:16];
                        cal1_ns[1][9]=D1[15:8];
                        cal1_ns[1][10]=D1[7:0];
                        for(a=0;a<=2;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+8];
                        end
                    end
                    2: begin
                        //shift 2
                        for(a=0;a<=8;a=a+1)begin
                            cal1_ns[1][a]=cal1[1][a+2];
                        end    
                        cal1_ns[1][10] = D1[55:48];
                        cal1_ns[1][9] = D1[63:56];
                        cal1_ns[0][10]=cal1[1][1];
                        cal1_ns[0][9]=cal1[1][0];
                        cal1_ns[0][8]=cal1[0][10];
                        cal1_ns[0][7]=cal1[0][9];
                        cal1_ns[0][6]=cal1[0][8];
                        cal1_ns[0][5]=cal1[0][7];
                        cal1_ns[0][4]=cal1[0][6];
                        cal1_ns[0][3]=cal1[0][5];
                        cal1_ns[0][2]=cal1[0][4];
                        cal1_ns[0][1]=cal1[0][3];
                        cal1_ns[0][0]=cal1[0][2];                                            
                    end
                endcase
            end
        endcase
    end
end
//-----------------------------------------------
//          calculate the interpolation
//-----------------------------------------------

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
        cal_cnt1 <= 0;
    end
    else begin
        cal_cnt1 <= cal_cnt1_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        BI_L00 <= 0;
    end
    else begin
        BI_L00 <= BI_L00_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        BI_L10 <= 0;
    end
    else begin
        BI_L10 <= BI_L10_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        BI_L01 <= 0;
    end
    else begin
        BI_L01 <= BI_L01_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        BI_L11 <= 0;
    end
    else begin
        BI_L11 <= BI_L11_ns;
    end
end
always @(*) begin
    if (cur_state == INPUT1 || cur_state == READ) begin
        cal_cnt_ns = 0;
    end
    //else if (cur_state == CAL && delay_load0_cnt == 1) begin
        //cal_cnt_ns = 0;
    //end
    else if (cur_state == CAL && cal_cnt < 6) begin
        cal_cnt_ns = cal_cnt + 1;
    end
    else begin
        cal_cnt_ns = cal_cnt;
    end
end
always @(*) begin
    if (cur_state_L1 == INPUT1_L1 || cur_state_L1 == READ_L1) begin
        cal_cnt1_ns = 0;
    end
    //else if (cur_state == CAL && delay_load0_cnt == 1) begin
        //cal_cnt_ns = 0;
    //end
    else if (cur_state_L1 == CAL_L1 && cal_cnt1 < 6) begin
        cal_cnt1_ns = cal_cnt1 + 1;
    end
    else begin
        cal_cnt1_ns = cal_cnt1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0 ;i<2;i++) begin
            scale1_L0[i] <= 0;
            scale2_L0[i] <= 0;
        end
    end
    else begin
        for (i = 0 ;i<2;i++) begin
            scale1_L0[i] <= scale1_L0_ns[i];
            scale2_L0[i] <= scale2_L0_ns[i];
        end        
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0 ;i<2;i++) begin
            scale1_L1[i] <= 0;
            scale2_L1[i] <= 0;
        end
    end
    else begin
        for (i = 0 ;i<2;i++) begin
            scale1_L1[i] <= scale1_L1_ns[i];
            scale2_L1[i] <= scale2_L1_ns[i];
        end        
    end
end
always @(*) begin
    for (i = 0 ;i<2;i++) begin
        scale1_L0_ns[i] = scale1_L0[i];
        scale2_L0_ns[i] = scale2_L0[i];
    end
    if (cur_state == READ) begin
        scale1_L0_ns[0] = mvx0[cnt][3:0];
        scale2_L0_ns[0] = mvy0[cnt][3:0];
        scale1_L0_ns[1] = 5'b10000 - mvx0[cnt][3:0];
        scale2_L0_ns[1] = 5'b10000 - mvy0[cnt][3:0];
    end
end
always @(*) begin
    for (i = 0 ;i<2;i++) begin
        scale1_L1_ns[i] = scale1_L1[i];
        scale2_L1_ns[i] = scale2_L1[i];
    end
    if (cur_state_L1 == READ_L1) begin
        scale1_L1_ns[0] = mvx1[cnt][3:0];
        scale2_L1_ns[0] = mvy1[cnt][3:0];
        scale1_L1_ns[1] = 5'b10000 - mvx1[cnt][3:0];
        scale2_L1_ns[1] = 5'b10000 - mvy1[cnt][3:0];
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        total_cal_cnt <= 0;
    end
    else begin
        total_cal_cnt <= total_cal_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        total_cal_cnt1 <= 0;
    end
    else begin
        total_cal_cnt1 <= total_cal_cnt1_ns;
    end
end
always @(*) begin
    if (cur_state == INPUT1) begin
        total_cal_cnt_ns = 0;
    end
    else if (cur_state == CAL && cal_cnt == 6) begin
        total_cal_cnt_ns = total_cal_cnt + 1;
    end
    else if (cur_state == OUT) begin
        total_cal_cnt_ns = 0;
    end
    else begin
        total_cal_cnt_ns = total_cal_cnt;
    end
end
always @(*) begin
    if (cur_state_L1 == INPUT1_L1) begin
        total_cal_cnt1_ns = 0;
    end
    else if (cur_state_L1 == CAL_L1 && cal_cnt1 == 6) begin
        total_cal_cnt1_ns = total_cal_cnt1 + 1;
    end
    else if (cur_state_L1 == OUT1) begin
        total_cal_cnt1_ns = 0;
    end
    else begin
        total_cal_cnt1_ns = total_cal_cnt1;
    end
end
always @(*) begin
    BI_L00_ns = 0;
    BI_L01_ns = 0;
    if (cur_state == CAL) begin
        case(cal_cnt)
            2: begin
                A1_L00 = cal0[0][0] * scale1_L0[1] + cal0[0][1] * scale1_L0[0];
                A2_L00 = cal0[1][0] * scale1_L0[1] + cal0[1][1] * scale1_L0[0];
                BI_L00_ns = A1_L00 * scale2_L0[1] + A2_L00 * scale2_L0[0];
                A1_L01 = cal0[0][1] * scale1_L0[1] + cal0[0][2] * scale1_L0[0];
                A2_L01 = cal0[1][1] * scale1_L0[1] + cal0[1][2] * scale1_L0[0];
                BI_L01_ns = A1_L01 * scale2_L0[1] + A2_L01 * scale2_L0[0];
            end
            3: begin
                A1_L00 = cal0[0][2] * scale1_L0[1] + cal0[0][3] * scale1_L0[0];
                A2_L00 = cal0[1][2] * scale1_L0[1] + cal0[1][3] * scale1_L0[0];
                BI_L00_ns = A1_L00 * scale2_L0[1] + A2_L00 * scale2_L0[0];
                A1_L01 = cal0[0][3] * scale1_L0[1] + cal0[0][4] * scale1_L0[0];
                A2_L01 = cal0[1][3] * scale1_L0[1] + cal0[1][4] * scale1_L0[0];
                BI_L01_ns = A1_L01 * scale2_L0[1] + A2_L01 * scale2_L0[0];
            end
            4: begin
                A1_L00 = cal0[0][4] * scale1_L0[1] + cal0[0][5] * scale1_L0[0];
                A2_L00 = cal0[1][4] * scale1_L0[1] + cal0[1][5] * scale1_L0[0];
                BI_L00_ns = A1_L00 * scale2_L0[1] + A2_L00 * scale2_L0[0];
                A1_L01 = cal0[0][5] * scale1_L0[1] + cal0[0][6] * scale1_L0[0];
                A2_L01 = cal0[1][5] * scale1_L0[1] + cal0[1][6] * scale1_L0[0];
                BI_L01_ns = A1_L01 * scale2_L0[1] + A2_L01 * scale2_L0[0];
            end
            5: begin
                A1_L00 = cal0[0][6] * scale1_L0[1] + cal0[0][7] * scale1_L0[0];
                A2_L00 = cal0[1][6] * scale1_L0[1] + cal0[1][7] * scale1_L0[0];
                BI_L00_ns = A1_L00 * scale2_L0[1] + A2_L00 * scale2_L0[0];
                A1_L01 = cal0[0][7] * scale1_L0[1] + cal0[0][8] * scale1_L0[0];
                A2_L01 = cal0[1][7] * scale1_L0[1] + cal0[1][8] * scale1_L0[0];
                BI_L01_ns = A1_L01 * scale2_L0[1] + A2_L01 * scale2_L0[0];
            end
            6: begin
                A1_L00 = cal0[0][8] * scale1_L0[1] + cal0[0][9] * scale1_L0[0];
                A2_L00 = cal0[1][8] * scale1_L0[1] + cal0[1][9] * scale1_L0[0];
                BI_L00_ns = A1_L00 * scale2_L0[1] + A2_L00 * scale2_L0[0];
                A1_L01 = cal0[0][9] * scale1_L0[1] + cal0[0][10] * scale1_L0[0];
                A2_L01 = cal0[1][9] * scale1_L0[1] + cal0[1][10] * scale1_L0[0];
                BI_L01_ns = A1_L01 * scale2_L0[1] + A2_L01 * scale2_L0[0];
            end
        endcase
    end
end
always @(*) begin
    BI_L10_ns = 0;
    BI_L11_ns = 0;
    if (cur_state_L1 == CAL_L1) begin
        case(cal_cnt1)
            2: begin
                A1_L10 = cal1[0][0] * scale1_L1[1] + cal1[0][1] * scale1_L1[0];
                A2_L10 = cal1[1][0] * scale1_L1[1] + cal1[1][1] * scale1_L1[0];
                BI_L10_ns = A1_L10 * scale2_L1[1] + A2_L10 * scale2_L1[0];
                A1_L11 = cal1[0][1] * scale1_L1[1] + cal1[0][2] * scale1_L1[0];
                A2_L11 = cal1[1][1] * scale1_L1[1] + cal1[1][2] * scale1_L1[0];
                BI_L11_ns = A1_L11 * scale2_L1[1] + A2_L11 * scale2_L1[0];
            end
            3: begin
                A1_L10 = cal1[0][2] * scale1_L1[1] + cal1[0][3] * scale1_L1[0];
                A2_L10 = cal1[1][2] * scale1_L1[1] + cal1[1][3] * scale1_L1[0];
                BI_L10_ns = A1_L10 * scale2_L1[1] + A2_L10 * scale2_L1[0];
                A1_L11 = cal1[0][3] * scale1_L1[1] + cal1[0][4] * scale1_L1[0];
                A2_L11 = cal1[1][3] * scale1_L1[1] + cal1[1][4] * scale1_L1[0];
                BI_L11_ns = A1_L11 * scale2_L1[1] + A2_L11 * scale2_L1[0];
            end
            4: begin
                A1_L10 = cal1[0][4] * scale1_L1[1] + cal1[0][5] * scale1_L1[0];
                A2_L10 = cal1[1][4] * scale1_L1[1] + cal1[1][5] * scale1_L1[0];
                BI_L10_ns = A1_L10 * scale2_L1[1] + A2_L10 * scale2_L1[0];
                A1_L11 = cal1[0][5] * scale1_L1[1] + cal1[0][6] * scale1_L1[0];
                A2_L11 = cal1[1][5] * scale1_L1[1] + cal1[1][6] * scale1_L1[0];
                BI_L11_ns = A1_L11 * scale2_L1[1] + A2_L11 * scale2_L1[0];
            end
            5: begin
                A1_L10 = cal1[0][6] * scale1_L1[1] + cal1[0][7] * scale1_L1[0];
                A2_L10 = cal1[1][6] * scale1_L1[1] + cal1[1][7] * scale1_L1[0];
                BI_L10_ns = A1_L10 * scale2_L1[1] + A2_L10 * scale2_L1[0];
                A1_L11 = cal1[0][7] * scale1_L1[1] + cal1[0][8] * scale1_L1[0];
                A2_L11 = cal1[1][7] * scale1_L1[1] + cal1[1][8] * scale1_L1[0];
                BI_L11_ns = A1_L11 * scale2_L1[1] + A2_L11 * scale2_L1[0];
            end
            6: begin
                A1_L10 = cal1[0][8] * scale1_L1[1] + cal1[0][9] * scale1_L1[0];
                A2_L10 = cal1[1][8] * scale1_L1[1] + cal1[1][9] * scale1_L1[0];
                BI_L10_ns = A1_L10 * scale2_L1[1] + A2_L10 * scale2_L1[0];
                A1_L11 = cal1[0][9] * scale1_L1[1] + cal1[0][10] * scale1_L1[0];
                A2_L11 = cal1[1][9] * scale1_L1[1] + cal1[1][10] * scale1_L1[0];
                BI_L11_ns = A1_L11 * scale2_L1[1] + A2_L11 * scale2_L1[0];
            end
        endcase
    end
end
always @(*) begin
    store_cnt_ns = store_cnt;
    if (cur_state == INPUT1) begin
        store_cnt_ns = 0;
    end
    else if (cur_state == CAL && cal_cnt == 6) begin
        store_cnt_ns = store_cnt + 1;
    end
    else if (cur_state == OUT) begin
        store_cnt_ns = 0;
    end
end
reg [23:0] BI_L0[0:9][0:9], BI_L0_ns[0:9][0:9]; // for check/////////////////////////////
always @(*) begin
    store1_cnt_ns = store1_cnt;
    if (cur_state_L1 == INPUT1_L1) begin
        store1_cnt_ns = 0;
    end
    else if (cur_state_L1 == CAL_L1 && cal_cnt1 == 6) begin
        store1_cnt_ns = store1_cnt + 1;
    end
    else if (cur_state_L1 == OUT1) begin
        store1_cnt_ns = 0;
    end
end
reg [23:0] BI_L1[0:9][0:9], BI_L1_ns[0:9][0:9]; // for check/////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<10;i++) begin
            for (j = 0;j<10;j++) begin
                BI_L0[i][j] <= 0;
            end
        end
    end
    else begin
        for (i = 0;i<10;i++) begin
            for (j = 0;j<10;j++) begin
                BI_L0[i][j] <= BI_L0_ns[i][j];
            end
        end
    end
end



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<10;i++) begin
            for (j = 0;j<10;j++) begin
                BI_L1[i][j] <= 0;
            end
        end
    end
    else begin
        for (i = 0;i<10;i++) begin
            for (j = 0;j<10;j++) begin
                BI_L1[i][j] <= BI_L1_ns[i][j];
            end
        end
    end
end
always @(*) begin
    for (i = 0;i<10;i++) begin
        for (j = 0;j<10;j++) begin
            BI_L0_ns[i][j] = BI_L0[i][j];
        end
    end
    if (cur_state == CAL) begin
        case(cal_cnt)
            2: begin
                BI_L0_ns[store_cnt][0] = BI_L00_ns;
                BI_L0_ns[store_cnt][1] = BI_L01_ns;
            end
            3: begin
                BI_L0_ns[store_cnt][2] = BI_L00_ns;
                BI_L0_ns[store_cnt][3] = BI_L01_ns;
            end
            4: begin
                BI_L0_ns[store_cnt][4] = BI_L00_ns;
                BI_L0_ns[store_cnt][5] = BI_L01_ns;
            end
            5: begin
                BI_L0_ns[store_cnt][6] = BI_L00_ns;
                BI_L0_ns[store_cnt][7] = BI_L01_ns;
            end
            6: begin
                BI_L0_ns[store_cnt][8] = BI_L00_ns;
                BI_L0_ns[store_cnt][9] = BI_L01_ns;
            end
        endcase 
    end
end
always @(*) begin
    for (i = 0;i<10;i++) begin
        for (j = 0;j<10;j++) begin
            BI_L1_ns[i][j] = BI_L1[i][j];
        end
    end
    if (cur_state_L1 == CAL_L1) begin
        case(cal_cnt1)
            2: begin
                BI_L1_ns[store1_cnt][0] = BI_L10_ns;
                BI_L1_ns[store1_cnt][1] = BI_L11_ns;
            end
            3: begin
                BI_L1_ns[store1_cnt][2] = BI_L10_ns;
                BI_L1_ns[store1_cnt][3] = BI_L11_ns;
            end
            4: begin
                BI_L1_ns[store1_cnt][4] = BI_L10_ns;
                BI_L1_ns[store1_cnt][5] = BI_L11_ns;
            end
            5: begin
                BI_L1_ns[store1_cnt][6] = BI_L10_ns;
                BI_L1_ns[store1_cnt][7] = BI_L11_ns;
            end
            6: begin
                BI_L1_ns[store1_cnt][8] = BI_L10_ns;
                BI_L1_ns[store1_cnt][9] = BI_L11_ns;
            end
        endcase 
    end
end
//-----------------------------------------------------
//                  WAIT
//-------------------------------------------


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wait_cnt <= 0;
    end
    else begin
        wait_cnt <= wait_cnt_ns;
    end
end
always @(*) begin
    wait_cnt_ns = wait_cnt;
    if (cur_state == WAIT) begin
        wait_cnt_ns = wait_cnt + 1;
    end
    else if (cur_state != WAIT)begin
        wait_cnt_ns = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
            b00 <= 0;
            b01 <= 0;
            b02 <= 0;
            b03 <= 0;
            b10 <= 0;
            b11 <= 0;
            b12 <= 0;
            b13 <= 0;
    end 
    else begin
            b00 <= b00_ns;
            b01 <= b01_ns;
            b02 <= b02_ns;
            b03 <= b03_ns;
            b10 <= b10_ns;
            b11 <= b11_ns;
            b12 <= b12_ns;
            b13 <= b13_ns;        
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sad_row_cnt <= 0;
        sad_col_cnt <= 0;
    end
    else begin
        sad_row_cnt <= sad_row_cnt_ns;
        sad_col_cnt <= sad_col_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        point_cnt <= 0;
        add_cnt <= 0;
    end
    else begin
        point_cnt <= point_cnt_ns;
        add_cnt <= add_cnt_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sad0 <= 0;
        sad1 <= 0;
        /*
        sad2 <= 0;
        sad3 <= 0;
        sad4 <= 0;
        sad5 <= 0;
        sad6 <= 0;
        sad7 <= 0;
        sad8 <= 0;
        */
    end
    else begin
        sad0 <= sad0_ns;
        sad1 <= sad1_ns;
        /*
        sad2 <= sad2_ns;
        sad3 <= sad3_ns;
        sad4 <= sad4_ns;
        sad5 <= sad5_ns;
        sad6 <= sad6_ns;
        sad7 <= sad7_ns;
        sad8 <= sad8_ns;
        */
    end
end
reg [3:0]index_min, index_min_ns;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        index_min <= 0;
    end
    else begin
        index_min <= index_min_ns;
    end
end
always @(*) begin
    sad0_ns = sad0;
    sad1_ns = sad1;
    index_min_ns = index_min;
    
    /*
    sad2_ns = sad2;
    sad3_ns = sad3;
    sad4_ns = sad4;
    sad5_ns = sad5;
    sad6_ns = sad6;
    sad7_ns = sad7;
    sad8_ns = sad8;
    */
    ans0 = 0;
    ans1 = 0;
    ans2 = 0;
    ans3 = 0;
    if (cur_state == READ) begin
        sad0_ns = 0;
        sad1_ns = 0;
        index_min_ns = 0;
    end
    else if (cur_state == SAD && add_cnt != 0) begin
        if (b00 > b10) begin
            ans0 = b00 - b10;
        end
        else begin
            ans0 = b10 - b00;
        end
        if (b01 > b11) begin
            ans1 = b01 - b11;
        end
        else begin
            ans1 = b11 - b01;
        end
        if (b02 > b12) begin
            ans2 = b02 - b12;
        end
        else begin
            ans2 = b12 - b02;
        end
        if (b03 > b13) begin
            ans3 = b03 - b13;
        end
        else begin
            ans3 = b13 - b03;
        end
        
        case(point_cnt)
            0: sad0_ns = sad0 + ans0 + ans1 + ans2 + ans3;
            1: sad1_ns = sad1 + ans0 + ans1 + ans2 + ans3;
            default: sad1_ns = sad1 + ans0 + ans1 + ans2 + ans3;
            /*
            2: sad2_ns = sad2 + ans0 + ans1 + ans2 + ans3;
            3: sad3_ns = sad3 + ans0 + ans1 + ans2 + ans3;
            4: sad4_ns = sad4 + ans0 + ans1 + ans2 + ans3;
            5: sad5_ns = sad5 + ans0 + ans1 + ans2 + ans3;
            6: sad6_ns = sad6 + ans0 + ans1 + ans2 + ans3;
            7: sad7_ns = sad7 + ans0 + ans1 + ans2 + ans3;
            8: sad8_ns = sad8 + ans0 + ans1 + ans2 + ans3;
            */
        endcase
        
    end
//--------------------------------
//             SORT
//--------------------------------
    else if (cur_state == SORT) begin
        if (sad0 <= sad1) begin
            sad1_ns = 0;
            sad0_ns = sad0;
            index_min_ns = index_min;
        end
        else begin // sad1<sad0
            sad0_ns = sad1; 
            sad1_ns = 0;
            index_min_ns = point_cnt - 1;
        end
    end
end
always @(*) begin
    /*
    if (cur_state == WAIT) begin
        b00_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 0];
        b01_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 1];
        b02_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 2];
        b03_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 3];
        b10_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 2];
        b11_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 3];
        b12_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 4];
        b13_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 5];        
    end
    */
    b00_ns = b00;
    b01_ns = b01;
    b02_ns = b02;
    b03_ns = b03;
    b10_ns = b10;
    b11_ns = b11;
    b12_ns = b12;
    b13_ns = b13;
    if (cur_state == SAD) begin
        case(point_cnt)
            0: begin
                b00_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 0];
                b01_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 1];
                b02_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 2];
                b03_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 3];
                b10_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 2];
                b11_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 3];
                b12_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 4];
                b13_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 5]; 
            end 
            1: begin
                b00_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 0];
                b01_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 1];
                b02_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 2];
                b03_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 3];
                b10_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 2];
                b11_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 3];
                b12_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 4];
                b13_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 5]; 
            end  
            2: begin
                b00_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 0];
                b01_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 1];
                b02_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 2];
                b03_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 3];
                b10_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 2];
                b11_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 3];
                b12_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 4];
                b13_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 5]; 
            end 
            3: begin
                b00_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 1];
                b01_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 2];
                b02_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 3];
                b03_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 4];
                b10_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 1];
                b11_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 2];
                b12_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 3];
                b13_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 4]; 
            end 
            4: begin
                b00_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 1];
                b01_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 2];
                b02_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 3];
                b03_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 4];
                b10_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 1];
                b11_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 2];
                b12_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 3];
                b13_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 4]; 
            end  
            5: begin
                b00_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 1];
                b01_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 2];
                b02_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 3];
                b03_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 4];
                b10_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 1];
                b11_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 2];
                b12_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 3];
                b13_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 4]; 
            end  
            6: begin
                b00_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 2];
                b01_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 3];
                b02_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 4];
                b03_ns = BI_L0[sad_row_cnt + 0][sad_col_cnt + 5];
                b10_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 0];
                b11_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 1];
                b12_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 2];
                b13_ns = BI_L1[sad_row_cnt + 2][sad_col_cnt + 3]; 
            end 
            7: begin
                b00_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 2];
                b01_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 3];
                b02_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 4];
                b03_ns = BI_L0[sad_row_cnt + 1][sad_col_cnt + 5];
                b10_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 0];
                b11_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 1];
                b12_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 2];
                b13_ns = BI_L1[sad_row_cnt + 1][sad_col_cnt + 3]; 
            end 
            8: begin
                b00_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 2];
                b01_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 3];
                b02_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 4];
                b03_ns = BI_L0[sad_row_cnt + 2][sad_col_cnt + 5];
                b10_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 0];
                b11_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 1];
                b12_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 2];
                b13_ns = BI_L1[sad_row_cnt + 0][sad_col_cnt + 3]; 
            end        
        endcase
    end
end
always @(*) begin
    sad_row_cnt_ns = sad_row_cnt;
    sad_col_cnt_ns = sad_col_cnt;
    if (cur_state == SAD) begin
        if (add_cnt == 16) begin
            sad_row_cnt_ns = 0;
            sad_col_cnt_ns = 0;            
        end
        else if (sad_col_cnt == 4 && sad_row_cnt != 7) begin
            sad_row_cnt_ns = sad_row_cnt + 1;
            sad_col_cnt_ns = 0;
        end
        else if (sad_col_cnt == 4 && sad_row_cnt == 7) begin
            sad_row_cnt_ns = 0;
            sad_col_cnt_ns = 0;
        end
        else if (sad_col_cnt == 0) begin
            sad_row_cnt_ns = sad_row_cnt;
            sad_col_cnt_ns = 4;
        end
    end
    else if (cur_state == SORT) begin
        sad_row_cnt_ns = 0;
        sad_col_cnt_ns = 0;        
    end
    else if (cur_state == CAL) begin
        sad_row_cnt_ns = 0;
        sad_col_cnt_ns = 0;
    end
end
always @(*) begin
    if (cur_state == SAD && add_cnt != 16) begin
        add_cnt_ns = add_cnt + 1;
    end
    else if (cur_state == SAD && add_cnt == 16)begin
        add_cnt_ns = 0;
    end
    else if (cur_state == INPUT || cur_state == OUT)begin
        add_cnt_ns = 0;
    end
    else begin
        add_cnt_ns = add_cnt;
    end
end
always @(*) begin
    if (cur_state == SAD && add_cnt == 16) begin
        point_cnt_ns = point_cnt + 1;
    end
    else if (cur_state == SAD) begin
        point_cnt_ns = point_cnt;
    end
    else if (cur_state == INPUT || cur_state == OUT) begin
        point_cnt_ns = 0;
    end
    else begin
        point_cnt_ns = point_cnt;
    end
end
reg [55:0] out_sad_reg, out_sad_reg_ns;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_sad_reg <= 0;
    end
    else begin
        out_sad_reg <= out_sad_reg_ns;
    end
end
always @(*) begin
    out_sad_reg_ns = out_sad_reg;
    if (cur_state == OUT) begin
        if (cnt == 0) begin
            out_sad_reg_ns[27:0] = {index_min, sad0};
        end
        else begin
            out_sad_reg_ns[55:28] = {index_min, sad0};
        end
    end
    else begin
        out_sad_reg_ns = out_sad_reg;
    end
end
always @(*) begin
    if (cur_state == PRINT && print_cnt <56) begin
        out_valid_ns = 1;
    end
    else begin
        out_valid_ns = 0;
    end
end 
always @(*) begin
    /*if (cur_state == PRINT && !out_valid) begin
        print_cnt_ns = print_cnt;
    end
    else 
    */
    if (cur_state == PRINT) begin
        print_cnt_ns = print_cnt + 1;
    end
    else if (cur_state == INPUT) begin
        print_cnt_ns = 0;
    end
    else if (cur_state == READ) begin
        print_cnt_ns = 0;
    end
    else begin
        print_cnt_ns = print_cnt;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        out_valid<=0;
        out_sad<=0;
    end
    else if (cur_state == PRINT)begin
        out_valid <= out_valid_ns;
        out_sad <= out_sad_reg[print_cnt];
    end
    else begin
        out_valid<=0;
        out_sad<=0;
    end
end

endmodule
