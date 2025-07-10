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

//=======================================================
//                   Reg/Wire
//=======================================================

//counter
reg [2:0] mv_in_cnt, mv_in_cnt_ns;
reg [2:0] image_in_cnt, image_in_cnt_ns;
reg [1:0] read_cnt_img1;
reg [1:0] delay_sram_img1;
reg [2:0] cal_cnt_img1;
reg [5:0] set_cnt;
reg [5:0] print_cnt;

reg input_first;
reg first;

reg [11:0] mvx0[0:1], mvy0[0:1];
reg [11:0] mvx1[0:1], mvy1[0:1];
//BI
reg [3:0] already_row_img1;

reg [2:0] site_img1, site_img2;
reg [7:0] cal_img1 [0:2][0:10], cal_img1_ns[0:2][0:10];
reg [7:0] cal_img2 [0:2][0:10], cal_img2_ns[0:2][0:10];
reg [4:0] scale1_img1[0:1], scale2_img1[0:1];
reg [4:0] scale1_img2[0:1], scale2_img2[0:1];
reg [15:0] BI_L0[0:4], BI_L0_ns[0:4];
reg [11:0] A1_L0[0:4], A2_L0[0:4];
reg [15:0] BI_L1[0:4], BI_L1_ns[0:4];
reg [11:0] A1_L1[0:4], A2_L1[0:4];
reg [15:0] BI_img1 [0:2][0:9], BI_img2[0:2][0:9];

//SAD
reg [23:0] sad_final [0:8]; 
wire [18:0] sad_partial [0:8];
wire [23:0] result_stage1[0:3];
reg  [23:0] result_stage2[0:1];
reg  [23:0] result_stage3;
reg  [23:0] final_result;
wire [2:0] minsite_stage1[0:3];
reg  [2:0] minsite_stage2[0:1];
wire [2:0] minsite_stage3;
reg  [3:0] final_minsite;
reg cmp1,cmp2,cmp3,cmp4,cmp5,cmp6,cmp7,cmp8;
reg [7:0]temp[0:7];

reg [63:0] D0, D1;
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

integer i, j;

typedef enum reg[2:0]{INPUT = 0, INPUT1 = 1, READ = 2, OUT = 3, PRINT = 4}state;
state cur_state, nxt_state;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state <= INPUT;
    end
    else begin
        cur_state <= nxt_state;
    end
end
always @(*) begin
    nxt_state = cur_state;
    case(cur_state) 
        INPUT: begin
            if (addr1 == 2047 && image_in_cnt == 7) begin
                nxt_state = INPUT1;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        INPUT1: begin
            if (mv_in_cnt == 4) begin
                nxt_state = READ;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        READ: begin
            if (already_row_img1 == 14) begin
                nxt_state = OUT;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        OUT: begin
            if (!first) begin
                nxt_state = READ;
            end
            else if (first) begin
                nxt_state = PRINT;
            end
        end
        PRINT: begin
            if (print_cnt == 56) begin
                if (set_cnt == 63) begin
                    nxt_state = INPUT;
                end
                else begin
                    nxt_state = INPUT1;
                end
            end
            else begin
                nxt_state = cur_state;
            end
        end
        
    endcase
end

//-------------------------------
//           counter
//-------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        image_in_cnt <= 0;
    end
    else begin
        image_in_cnt <= image_in_cnt_ns;
    end
end
always @(*) begin
    image_in_cnt_ns = image_in_cnt;
    if (in_valid) begin
        image_in_cnt_ns = image_in_cnt + 1;
    end
    else if (cur_state == INPUT1) begin
        image_in_cnt_ns = 0; 
    end

end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mv_in_cnt <= 0;
    end
    else begin
        mv_in_cnt <= mv_in_cnt_ns;
    end
end
always @(*) begin
    mv_in_cnt_ns = mv_in_cnt;
    if (in_valid2) begin
        mv_in_cnt_ns = mv_in_cnt + 1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        set_cnt <= 0;
    end
    else begin
        if (cur_state == INPUT) begin
            set_cnt <= 0;
        end
        else if (cur_state == PRINT && print_cnt == 56) begin
            set_cnt <= set_cnt + 1;
        end
    end
end
//-------------------------------
//           read image
//-------------------------------

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        input_first <= 0;
    end
    else begin
        if (addr0 == 2047 && image_in_cnt == 7 && cur_state == INPUT) begin
            input_first <= 1;
        end
        else if(cur_state == INPUT && addr0 < 2047) begin
            input_first <= 0;
        end
        else if (cur_state == PRINT) begin
            input_first <= 0;
        end
        else begin
            input_first <= input_first;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        WEB_L0 <= 0;
    end
    else begin
        if (cur_state == INPUT && image_in_cnt == 7 && !input_first) begin
            WEB_L0 <= 0;
        end
        else begin
            WEB_L0 <= 1;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        WEB_L1 <= 0;
    end
    else begin
        if (cur_state == INPUT && image_in_cnt == 7 && input_first) begin
            WEB_L1 <= 0;
        end
        else begin
            WEB_L1 <= 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i<8;i++) begin
            temp[i] <= 0;
        end        
    end
    else begin
        if (cur_state == INPUT && in_valid) begin
            temp[image_in_cnt] <= in_data[11:4]; 
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

//-------------------------------
//           read MV
//-------------------------------

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 2 ; i++) begin
            mvx0[i] <= mvx0[i];
            mvy0[i] <= mvy0[i];
            mvx1[i] <= mvx1[i];
            mvy1[i] <= mvy1[i];
        end
    end
    else begin
        if (in_valid2) begin
            case(mv_in_cnt) 
                0: begin mvx0[0] <= in_data; end
                1: begin mvy0[0] <= in_data; end
                2: begin mvx1[0] <= in_data; end
                3: begin mvy1[0] <= in_data; end
                4: begin mvx0[1] <= in_data; end
                5: begin mvy0[1] <= in_data; end
                6: begin mvx1[1] <= in_data; end
                7: begin mvy1[1] <= in_data; end
            endcase
        end
    end
end
//-------------------------------
//          SRAM address
//-------------------------------
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
always @(*) begin
    addr0_ns = addr0;
    if (!WEB_L0 && in_valid && addr0 != 2047) begin 
        addr0_ns = addr0 + 1;   
    end
    else if (WEB_L0 && in_valid && addr0 == 2047)begin
        addr0_ns = addr0;
    end
    else if(cur_state == INPUT1)begin
        if(mv_in_cnt == 4)begin 
            addr0_ns = (mvy0[0][11:4] << 4) + (mvx0[0][11:4] >> 3); //(mvy0[0][11:4] << 4) + mvx0[0][11:4] / 8;
        end
    end
    else if (cur_state == READ) begin 
        if (already_row_img1 < 2 || (already_row_img1 >= 2 && cal_cnt_img1 <= 2)) begin
            // start to read
            if (read_cnt_img1 < 2) begin
                addr0_ns = addr0 + 1;
            end
            else if (read_cnt_img1 == 2) begin
                addr0_ns = addr0 + (14);
            end  
        end
    end
    else if (cur_state == OUT && !first) begin
        addr0_ns = (mvy0[1][11:4] << 4) + (mvx0[1][11:4] >> 3);
    end
    else if (cur_state == PRINT) begin
        addr0_ns = 0;
    end
end
//WEB_L0 == 1 read
always @(*) begin
    addr1_ns = addr1;
    if (!WEB_L1 && in_valid) begin
        addr1_ns = addr1 + 1;   
    end
    else if(cur_state == INPUT1)begin
        if(mv_in_cnt == 4)begin 
            addr1_ns = (mvy1[0][11:4] << 4) + (mvx1[0][11:4] >> 3); //(mvy0[0][11:4] << 4) + mvx0[0][11:4] / 8;
        end
    end
    else if (cur_state == READ) begin 
        if (already_row_img1 < 2 || (already_row_img1 >= 2 && cal_cnt_img1 <= 2)) begin
            // start to read
            if (read_cnt_img1 < 2) begin
                addr1_ns = addr1 + 1;
            end
            else if (read_cnt_img1 == 2) begin
                addr1_ns = addr1 + (14);
            end  
        end
    end
    else if (cur_state == OUT && !first) begin
        addr1_ns = (mvy1[1][11:4] << 4) + (mvx1[1][11:4] >> 3);
    end
    else if (cur_state == PRINT) begin
        addr1_ns = 0;
    end
end
//------------------------------------
//             READ and CAL
//------------------------------------
always @(posedge clk)begin
    if(cur_state == INPUT1)begin
        if(mv_in_cnt == 4)begin
            site_img1 <= (mvx0[0][6:4]); //(mvx0[0][11:4]) % 8
        end
    end
    else if (cur_state == OUT && !first) begin
        site_img1 <= (mvx0[1][6:4]);
    end
end
always @(posedge clk)begin
    if(cur_state == INPUT1)begin
        if(mv_in_cnt == 4)begin
            site_img2 <= (mvx1[0][6:4]); //(mvx0[0][11:4]) % 8
        end
    end
    else if (cur_state == OUT && !first) begin
        site_img2 <= (mvx1[1][6:4]);
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        delay_sram_img1 <= 0;
    end
    else begin
        delay_sram_img1 <= read_cnt_img1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_cnt_img1 <= 0;
    end
    else begin
        if (cur_state == READ) begin
            if ((read_cnt_img1 < 3)) begin
                read_cnt_img1 <= read_cnt_img1 + 1;
            end
            else if (read_cnt_img1 == 3) begin
                read_cnt_img1 <= ((cal_cnt_img1 < 5 && already_row_img1 >= 2)) ? read_cnt_img1 : 0;
            end
        end
        else if (cur_state == OUT) begin
            read_cnt_img1 <= 0;
        end
        
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        already_row_img1 <= 0;
    end
    else begin
        if (cur_state == READ) begin
            if (read_cnt_img1 < 2 && already_row_img1 < 12) begin
                already_row_img1 <= already_row_img1;
            end
            else if (read_cnt_img1 == 3 && already_row_img1 < 12) begin
                already_row_img1 <= (cal_cnt_img1 < 5 && already_row_img1 >= 2) ? already_row_img1 : already_row_img1 + 1 ;
            end
            else if (already_row_img1 == 12 && read_cnt_img1 == 2) begin
                already_row_img1 <= already_row_img1 + 1;
            end
            else if (already_row_img1 > 12) begin
                already_row_img1 <= already_row_img1 + 1;
            end
        end
        else if (cur_state == OUT) begin
            already_row_img1 <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 3; i++) begin
            for (j = 0 ; j <11; j++) begin
                cal_img1[i][j] <= 0;
            end
        end
    end
    else begin
        for (i = 0; i < 3; i++) begin
            for (j = 0 ; j <11; j++) begin
                cal_img1[i][j] <= cal_img1_ns[i][j];
            end
        end
    end
end
always @(*) begin
    for (i = 0; i < 3; i++) begin
        for (j = 0 ; j <11; j++) begin
            cal_img1_ns[i][j] = cal_img1[i][j];
        end
    end
    if (cur_state == READ) begin
        if (delay_sram_img1 == 0) begin
                for( i = 0 ; i < 2 ; i = i+1)begin
                    for (j = 0; j< 11 ;j++) begin
                        cal_img1_ns[i][j] = cal_img1[i+1][j];
                    end
                end                
            end
        else if ((cal_cnt_img1 < 5 && already_row_img1 <= 2) || (cal_cnt_img1 > 0  && cal_cnt_img1 <5 && already_row_img1 > 2))begin
            // start to read
            case(site_img1)
                0:begin
                    case(delay_sram_img1)
                        1:begin
                            cal_img1_ns[2][0] = D0[63:56];
                            cal_img1_ns[2][1] = D0[55:48];
                            cal_img1_ns[2][2] = D0[47:40];
                            cal_img1_ns[2][3] = D0[39:32];
                            cal_img1_ns[2][4] = D0[31:24];
                            cal_img1_ns[2][5] = D0[25:16];
                            cal_img1_ns[2][6] = D0[15:8];
                            cal_img1_ns[2][7] = D0[7:0];

                        end
                        2:begin
                            cal_img1_ns[2][8] = D0[63:56];
                            cal_img1_ns[2][9] = D0[55:48];
                            cal_img1_ns[2][10]= D0[47:40];
                        end
                    endcase
                end
                1:begin
                    case(delay_sram_img1)
                        1:begin
                            //shift 7
                            cal_img1_ns[2][0] = D0[55:48];
                            cal_img1_ns[2][1] = D0[47:40];
                            cal_img1_ns[2][2] = D0[39:32];
                            cal_img1_ns[2][3] = D0[31:24];
                            cal_img1_ns[2][4] = D0[23:16];
                            cal_img1_ns[2][5] = D0[15:8];
                            cal_img1_ns[2][6] = D0[7:0];
                        end
                        2:begin
                            //shift4
                            cal_img1_ns[2][7] = D0[63:56];
                            cal_img1_ns[2][8] = D0[55:48];
                            cal_img1_ns[2][9] = D0[47:40];
                            cal_img1_ns[2][10] = D0[39:32];
                        end
                    endcase
                end
                2:begin
                    case(delay_sram_img1)
                        1:begin
                            //shift 6
                            cal_img1_ns[2][0]=D0[47:40];
                            cal_img1_ns[2][1]=D0[39:32];
                            cal_img1_ns[2][2]=D0[31:24];
                            cal_img1_ns[2][3]=D0[23:16];
                            cal_img1_ns[2][4]=D0[15:8];
                            cal_img1_ns[2][5]=D0[7:0];

                        end
                        2:begin
                            //shift5
                            cal_img1_ns[2][6] = D0[63:56];
                            cal_img1_ns[2][7] = D0[55:48];
                            cal_img1_ns[2][8] = D0[47:40];
                            cal_img1_ns[2][9] = D0[39:32];
                            cal_img1_ns[2][10]= D0[31:24];
                        end
                    endcase
                    end
                3:begin
                    case(delay_sram_img1)
                        1:begin
                            //shift 5
                            cal_img1_ns[2][0] = D0[39:32];
                            cal_img1_ns[2][1] = D0[31:24];
                            cal_img1_ns[2][2] = D0[23:16];
                            cal_img1_ns[2][3] = D0[15:8];
                            cal_img1_ns[2][4] = D0[7:0];

                        end
                        2:begin
                            //shift 6
                            cal_img1_ns[2][5] = D0[63:56];
                            cal_img1_ns[2][6] = D0[55:48];
                            cal_img1_ns[2][7] = D0[47:40];
                            cal_img1_ns[2][8] = D0[39:32];
                            cal_img1_ns[2][9] = D0[31:24];
                            cal_img1_ns[2][10]= D0[23:16];
                        end
                    endcase
                end
                4:begin
                    case(delay_sram_img1)
                        1:begin
                            //shift 4
                            cal_img1_ns[2][0] = D0[31:24];
                            cal_img1_ns[2][1] = D0[23:16];
                            cal_img1_ns[2][2] = D0[15:8];
                            cal_img1_ns[2][3] = D0[7:0];

                        end
                        2:begin
                            //shift 7
                            cal_img1_ns[2][4] = D0[63:56];
                            cal_img1_ns[2][5] = D0[55:48];
                            cal_img1_ns[2][6] = D0[47:40];
                            cal_img1_ns[2][7] = D0[39:32];
                            cal_img1_ns[2][8] = D0[31:24];
                            cal_img1_ns[2][9] = D0[23:16];
                            cal_img1_ns[2][10]= D0[15:8];
                        end
                    endcase
                end
                5:begin
                    case(delay_sram_img1)
                        1:begin
                            cal_img1_ns[2][0] = D0[23:16];
                            cal_img1_ns[2][1] = D0[15:8];
                            cal_img1_ns[2][2] = D0[7:0];
                        end
                        2:begin
                            cal_img1_ns[2][3] = D0[63:56];
                            cal_img1_ns[2][4] = D0[55:48];
                            cal_img1_ns[2][5] = D0[47:40];
                            cal_img1_ns[2][6] = D0[39:32];
                            cal_img1_ns[2][7] = D0[31:24];
                            cal_img1_ns[2][8] = D0[23:16];
                            cal_img1_ns[2][9] = D0[15:8];
                            cal_img1_ns[2][10]= D0[7:0];
                        end
                    endcase
                end
                6:begin
                    case(delay_sram_img1)
                        1:begin
                        //SHIFT 2 
                        cal_img1_ns[2][0] = D0[15:8];
                        cal_img1_ns[2][1] = D0[7:0];
                        end
                        2:begin
                            //SHIFT 8 
                            cal_img1_ns[2][2] = D0[63:56];
                            cal_img1_ns[2][3] = D0[55:48];
                            cal_img1_ns[2][4] = D0[47:40];
                            cal_img1_ns[2][5] = D0[39:32];
                            cal_img1_ns[2][6] = D0[31:24];
                            cal_img1_ns[2][7] = D0[23:16];
                            cal_img1_ns[2][8] = D0[15:8];
                            cal_img1_ns[2][9] = D0[7:0];
                        end
                        3: begin
                            //shift 1 
                            cal_img1_ns[2][10] = D0[63:56];                                          
                        end
                    endcase
            
                end
                7:begin
                    case(delay_sram_img1)
                        1:begin
                            //SHIFT 1
                            cal_img1_ns[2][0]=D0[7:0];
                        end
                        2:begin
                            //SHIFT 8 
                            cal_img1_ns[2][1] = D0[63:56];
                            cal_img1_ns[2][2] = D0[55:48];
                            cal_img1_ns[2][3] = D0[47:40];
                            cal_img1_ns[2][4] = D0[39:32];
                            cal_img1_ns[2][5] = D0[31:24];
                            cal_img1_ns[2][6] = D0[23:16];
                            cal_img1_ns[2][7] = D0[15:8];
                            cal_img1_ns[2][8] = D0[7:0];
                        end
                        3: begin
                            //shift 2   
                            cal_img1_ns[2][9] = D0[63:56];
                            cal_img1_ns[2][10] = D0[55:48];                     
                        end
                    endcase
                end
            endcase            
        end
    end    
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 3; i++) begin
            for (j = 0 ; j <11; j++) begin
                cal_img2[i][j] <= 0;
            end
        end
    end
    else begin
        for (i = 0; i < 3; i++) begin
            for (j = 0 ; j <11; j++) begin
                cal_img2[i][j] <= cal_img2_ns[i][j];
            end
        end
    end
end
always @(*) begin
    for (i = 0; i < 3; i++) begin
        for (j = 0 ; j <11; j++) begin
            cal_img2_ns[i][j] = cal_img2[i][j];
        end
    end
    if (cur_state == READ) begin
        if (delay_sram_img1 == 0) begin
                for( i = 0 ; i < 2 ; i = i+1)begin
                    for (j = 0; j< 11 ;j++) begin
                        cal_img2_ns[i][j] = cal_img2[i+1][j];
                    end
                end                
            end
        else if ((cal_cnt_img1 < 5 && already_row_img1 <= 2) || (cal_cnt_img1 > 0  && cal_cnt_img1 <5 && already_row_img1 > 2))begin
            // start to read
            case(site_img2)
                0:begin
                    case(delay_sram_img1)
                        1:begin
                            cal_img2_ns[2][0] = D1[63:56];
                            cal_img2_ns[2][1] = D1[55:48];
                            cal_img2_ns[2][2] = D1[47:40];
                            cal_img2_ns[2][3] = D1[39:32];
                            cal_img2_ns[2][4] = D1[31:24];
                            cal_img2_ns[2][5] = D1[25:16];
                            cal_img2_ns[2][6] = D1[15:8];
                            cal_img2_ns[2][7] = D1[7:0];

                        end
                        2:begin
                            cal_img2_ns[2][8] = D1[63:56];
                            cal_img2_ns[2][9] = D1[55:48];
                            cal_img2_ns[2][10]= D1[47:40];
                        end
                    endcase
                end
                1:begin
                    case(delay_sram_img1)
                        1:begin
                            //shift 7
                            cal_img2_ns[2][0] = D1[55:48];
                            cal_img2_ns[2][1] = D1[47:40];
                            cal_img2_ns[2][2] = D1[39:32];
                            cal_img2_ns[2][3] = D1[31:24];
                            cal_img2_ns[2][4] = D1[23:16];
                            cal_img2_ns[2][5] = D1[15:8];
                            cal_img2_ns[2][6] = D1[7:0];
                        end
                        2:begin
                            //shift4
                            cal_img2_ns[2][7] = D1[63:56];
                            cal_img2_ns[2][8] = D1[55:48];
                            cal_img2_ns[2][9] = D1[47:40];
                            cal_img2_ns[2][10] = D1[39:32];
                        end
                    endcase
                end
                2:begin
                    case(delay_sram_img1)
                        1:begin
                            //shift 6
                            cal_img2_ns[2][0]=D1[47:40];
                            cal_img2_ns[2][1]=D1[39:32];
                            cal_img2_ns[2][2]=D1[31:24];
                            cal_img2_ns[2][3]=D1[23:16];
                            cal_img2_ns[2][4]=D1[15:8];
                            cal_img2_ns[2][5]=D1[7:0];

                        end
                        2:begin
                            //shift5
                            cal_img2_ns[2][6] = D1[63:56];
                            cal_img2_ns[2][7] = D1[55:48];
                            cal_img2_ns[2][8] = D1[47:40];
                            cal_img2_ns[2][9] = D1[39:32];
                            cal_img2_ns[2][10]= D1[31:24];
                        end
                    endcase
                    end
                3:begin
                    case(delay_sram_img1)
                        1:begin
                            //shift 5
                            cal_img2_ns[2][0] = D1[39:32];
                            cal_img2_ns[2][1] = D1[31:24];
                            cal_img2_ns[2][2] = D1[23:16];
                            cal_img2_ns[2][3] = D1[15:8];
                            cal_img2_ns[2][4] = D1[7:0];

                        end
                        2:begin
                            //shift 6
                            cal_img2_ns[2][5] = D1[63:56];
                            cal_img2_ns[2][6] = D1[55:48];
                            cal_img2_ns[2][7] = D1[47:40];
                            cal_img2_ns[2][8] = D1[39:32];
                            cal_img2_ns[2][9] = D1[31:24];
                            cal_img2_ns[2][10]= D1[23:16];
                        end
                    endcase
                end
                4:begin
                    case(delay_sram_img1)
                        1:begin
                            //shift 4
                            cal_img2_ns[2][0] = D1[31:24];
                            cal_img2_ns[2][1] = D1[23:16];
                            cal_img2_ns[2][2] = D1[15:8];
                            cal_img2_ns[2][3] = D1[7:0];

                        end
                        2:begin
                            //shift 7
                            cal_img2_ns[2][4] = D1[63:56];
                            cal_img2_ns[2][5] = D1[55:48];
                            cal_img2_ns[2][6] = D1[47:40];
                            cal_img2_ns[2][7] = D1[39:32];
                            cal_img2_ns[2][8] = D1[31:24];
                            cal_img2_ns[2][9] = D1[23:16];
                            cal_img2_ns[2][10]= D1[15:8];
                        end
                    endcase
                end
                5:begin
                    case(delay_sram_img1)
                        1:begin
                            cal_img2_ns[2][0] = D1[23:16];
                            cal_img2_ns[2][1] = D1[15:8];
                            cal_img2_ns[2][2] = D1[7:0];
                        end
                        2:begin
                            cal_img2_ns[2][3] = D1[63:56];
                            cal_img2_ns[2][4] = D1[55:48];
                            cal_img2_ns[2][5] = D1[47:40];
                            cal_img2_ns[2][6] = D1[39:32];
                            cal_img2_ns[2][7] = D1[31:24];
                            cal_img2_ns[2][8] = D1[23:16];
                            cal_img2_ns[2][9] = D1[15:8];
                            cal_img2_ns[2][10]= D1[7:0];
                        end
                    endcase
                end
                6:begin
                    case(delay_sram_img1)
                        1:begin
                            //SHIFT 2 
                            cal_img2_ns[2][0] = D1[15:8];
                            cal_img2_ns[2][1] = D1[7:0];
                        end
                        2:begin
                            //SHIFT 8 
                            cal_img2_ns[2][2] = D1[63:56];
                            cal_img2_ns[2][3] = D1[55:48];
                            cal_img2_ns[2][4] = D1[47:40];
                            cal_img2_ns[2][5] = D1[39:32];
                            cal_img2_ns[2][6] = D1[31:24];
                            cal_img2_ns[2][7] = D1[23:16];
                            cal_img2_ns[2][8] = D1[15:8];
                            cal_img2_ns[2][9] = D1[7:0];
                        end
                        3: begin
                            //shift 1 
                            cal_img2_ns[2][10] = D1[63:56];                                          
                        end
                    endcase
            
                end
                7:begin
                    case(delay_sram_img1)
                        1:begin
                            //SHIFT 1
                            cal_img2_ns[2][0]=D1[7:0];
                        end
                        2:begin
                            //SHIFT 8 
                            cal_img2_ns[2][1] = D1[63:56];
                            cal_img2_ns[2][2] = D1[55:48];
                            cal_img2_ns[2][3] = D1[47:40];
                            cal_img2_ns[2][4] = D1[39:32];
                            cal_img2_ns[2][5] = D1[31:24];
                            cal_img2_ns[2][6] = D1[23:16];
                            cal_img2_ns[2][7] = D1[15:8];
                            cal_img2_ns[2][8] = D1[7:0];
                        end
                        3: begin
                            //shift 2   
                            cal_img2_ns[2][9] = D1[63:56];
                            cal_img2_ns[2][10] = D1[55:48];                     
                        end
                    endcase
                end
            endcase            
        end
    end    
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        first <= 0;
    end
    else begin
        if (cur_state == INPUT1) begin
            first <= 0;
        end
        else if (cur_state == OUT && !first) begin
            first <= 1;
        end
        else begin
            first <= first;
        end
    end
end
always @(posedge clk) begin
    if (cur_state == READ) begin
        scale1_img1 [0] = mvx0[first][3:0];
        scale2_img1 [0] = mvy0[first][3:0];
        scale1_img1 [1] = 5'b10000 - mvx0[first][3:0];
        scale2_img1 [1] = 5'b10000 - mvy0[first][3:0];
    end
end

always @(posedge clk) begin

    if (cur_state == READ && (already_row_img1 >= 2 && already_row_img1 <= 11)) begin
        case(cal_cnt_img1)
            2: begin
                A1_L0[0]  <= cal_img1[0][0] * scale1_img1[1] + cal_img1[0][1] * scale1_img1[0];
                A2_L0[0]  <= cal_img1[1][0] * scale1_img1[1] + cal_img1[1][1] * scale1_img1[0];
                A1_L0[1]  <= cal_img1[0][1] * scale1_img1[1] + cal_img1[0][2] * scale1_img1[0];
                A2_L0[1]  <= cal_img1[1][1] * scale1_img1[1] + cal_img1[1][2] * scale1_img1[0];
                A1_L0[2]  <= cal_img1[0][2] * scale1_img1[1] + cal_img1[0][3] * scale1_img1[0];
                A2_L0[2]  <= cal_img1[1][2] * scale1_img1[1] + cal_img1[1][3] * scale1_img1[0];
                A1_L0[3]  <= cal_img1[0][3] * scale1_img1[1] + cal_img1[0][4] * scale1_img1[0];
                A2_L0[3]  <= cal_img1[1][3] * scale1_img1[1] + cal_img1[1][4] * scale1_img1[0];
                A1_L0[4]  <= cal_img1[0][4] * scale1_img1[1] + cal_img1[0][5] * scale1_img1[0];
                A2_L0[4]  <= cal_img1[1][4] * scale1_img1[1] + cal_img1[1][5] * scale1_img1[0];
                
            end
            3: begin
                A1_L0[0]  <= cal_img1[0][5] * scale1_img1[1] + cal_img1[0][6] * scale1_img1[0];
                A2_L0[0]  <= cal_img1[1][5] * scale1_img1[1] + cal_img1[1][6] * scale1_img1[0];
                A1_L0[1]  <= cal_img1[0][6] * scale1_img1[1] + cal_img1[0][7] * scale1_img1[0];
                A2_L0[1]  <= cal_img1[1][6] * scale1_img1[1] + cal_img1[1][7] * scale1_img1[0];                
                A1_L0[2]  <= cal_img1[0][7] * scale1_img1[1] + cal_img1[0][8] * scale1_img1[0];
                A2_L0[2]  <= cal_img1[1][7] * scale1_img1[1] + cal_img1[1][8] * scale1_img1[0];                
                A1_L0[3]  <= cal_img1[0][8] * scale1_img1[1] + cal_img1[0][9] * scale1_img1[0];
                A2_L0[3]  <= cal_img1[1][8] * scale1_img1[1] + cal_img1[1][9] * scale1_img1[0];                
                A1_L0[4]  <= cal_img1[0][9] * scale1_img1[1] + cal_img1[0][10] * scale1_img1[0];
                A2_L0[4]  <= cal_img1[1][9] * scale1_img1[1] + cal_img1[1][10] * scale1_img1[0];
                
            end
        endcase
    end
end

always @(posedge clk) begin

    //if (cur_state == READ && already_row_img1 >= 2) begin
        case(cal_cnt_img1)
            3: begin
                BI_L0[0] <= A1_L0[0] * scale2_img1[1] + A2_L0[0] * scale2_img1[0];
                BI_L0[1] <= A1_L0[1] * scale2_img1[1] + A2_L0[1] * scale2_img1[0];
                BI_L0[2] <= A1_L0[2] * scale2_img1[1] + A2_L0[2] * scale2_img1[0];
                BI_L0[3] <= A1_L0[3] * scale2_img1[1] + A2_L0[3] * scale2_img1[0];
                BI_L0[4] <= A1_L0[4] * scale2_img1[1] + A2_L0[4] * scale2_img1[0];
            end
            4: begin
                BI_L0[0] <= A1_L0[0] * scale2_img1[1] + A2_L0[0] * scale2_img1[0];
                BI_L0[1] <= A1_L0[1] * scale2_img1[1] + A2_L0[1] * scale2_img1[0];
                BI_L0[2] <= A1_L0[2] * scale2_img1[1] + A2_L0[2] * scale2_img1[0];
                BI_L0[3] <= A1_L0[3] * scale2_img1[1] + A2_L0[3] * scale2_img1[0];
                BI_L0[4] <= A1_L0[4] * scale2_img1[1] + A2_L0[4] * scale2_img1[0];
            end
            default : begin
                for (i = 0;i<5;i++) begin
                    BI_L0[i] <= 0;
                end                
            end
        endcase
    //end
end
always @(posedge clk) begin
    case(cal_cnt_img1)
        4,5: begin
            for (i = 0; i < 5;i++) begin
                BI_img1[0][i] <= BI_img1[0][i+5]; 
                BI_img1[1][i] <= BI_img1[1][i+5];
                BI_img1[2][i] <= BI_img1[2][i+5];
            end
            BI_img1[0][5] <= BI_img1[1][0];
            BI_img1[0][6] <= BI_img1[1][1];
            BI_img1[0][7] <= BI_img1[1][2];
            BI_img1[0][8] <= BI_img1[1][3];
            BI_img1[0][9] <= BI_img1[1][4];

            BI_img1[1][5] <= BI_img1[2][0];
            BI_img1[1][6] <= BI_img1[2][1];
            BI_img1[1][7] <= BI_img1[2][2];
            BI_img1[1][8] <= BI_img1[2][3];
            BI_img1[1][9] <= BI_img1[2][4];
            for (i = 0 ;i < 5; i++) begin
                BI_img1[2][i+5] <= BI_L0[i];
            end
        end
    endcase
end
always @(posedge clk) begin
    if (cur_state == READ) begin
        scale1_img2 [0] = mvx1[first][3:0];
        scale2_img2 [0] = mvy1[first][3:0];
        scale1_img2 [1] = 5'b10000 - mvx1[first][3:0];
        scale2_img2 [1] = 5'b10000 - mvy1[first][3:0];
    end
end

always @(posedge clk) begin

    if (cur_state == READ && (already_row_img1 >= 2 && already_row_img1 <= 11)) begin
        case(cal_cnt_img1)
            2: begin
                A1_L1[0]  <= cal_img2[0][0] * scale1_img2[1] + cal_img2[0][1] * scale1_img2[0];
                A2_L1[0]  <= cal_img2[1][0] * scale1_img2[1] + cal_img2[1][1] * scale1_img2[0];
                A1_L1[1]  <= cal_img2[0][1] * scale1_img2[1] + cal_img2[0][2] * scale1_img2[0];
                A2_L1[1]  <= cal_img2[1][1] * scale1_img2[1] + cal_img2[1][2] * scale1_img2[0];
                A1_L1[2]  <= cal_img2[0][2] * scale1_img2[1] + cal_img2[0][3] * scale1_img2[0];
                A2_L1[2]  <= cal_img2[1][2] * scale1_img2[1] + cal_img2[1][3] * scale1_img2[0];
                A1_L1[3]  <= cal_img2[0][3] * scale1_img2[1] + cal_img2[0][4] * scale1_img2[0];
                A2_L1[3]  <= cal_img2[1][3] * scale1_img2[1] + cal_img2[1][4] * scale1_img2[0];
                A1_L1[4]  <= cal_img2[0][4] * scale1_img2[1] + cal_img2[0][5] * scale1_img2[0];
                A2_L1[4]  <= cal_img2[1][4] * scale1_img2[1] + cal_img2[1][5] * scale1_img2[0];
                
            end
            3: begin
                A1_L1[0]  <= cal_img2[0][5] * scale1_img2[1] + cal_img2[0][6] * scale1_img2[0];
                A2_L1[0]  <= cal_img2[1][5] * scale1_img2[1] + cal_img2[1][6] * scale1_img2[0];
                A1_L1[1]  <= cal_img2[0][6] * scale1_img2[1] + cal_img2[0][7] * scale1_img2[0];
                A2_L1[1]  <= cal_img2[1][6] * scale1_img2[1] + cal_img2[1][7] * scale1_img2[0];                
                A1_L1[2]  <= cal_img2[0][7] * scale1_img2[1] + cal_img2[0][8] * scale1_img2[0];
                A2_L1[2]  <= cal_img2[1][7] * scale1_img2[1] + cal_img2[1][8] * scale1_img2[0];                
                A1_L1[3]  <= cal_img2[0][8] * scale1_img2[1] + cal_img2[0][9] * scale1_img2[0];
                A2_L1[3]  <= cal_img2[1][8] * scale1_img2[1] + cal_img2[1][9] * scale1_img2[0];                
                A1_L1[4]  <= cal_img2[0][9] * scale1_img2[1] + cal_img2[0][10] * scale1_img2[0];
                A2_L1[4]  <= cal_img2[1][9] * scale1_img2[1] + cal_img2[1][10] * scale1_img2[0];
                
            end
        endcase
    end
end

always @(posedge clk) begin
    for (i = 0;i<5;i++) begin
        BI_L1[i] <= 0;
    end
    //if (cur_state == READ && already_row_img2 >= 2) begin
        case(cal_cnt_img1)
            3: begin
                BI_L1[0] <= A1_L1[0] * scale2_img2[1] + A2_L1[0] * scale2_img2[0];
                BI_L1[1] <= A1_L1[1] * scale2_img2[1] + A2_L1[1] * scale2_img2[0];
                BI_L1[2] <= A1_L1[2] * scale2_img2[1] + A2_L1[2] * scale2_img2[0];
                BI_L1[3] <= A1_L1[3] * scale2_img2[1] + A2_L1[3] * scale2_img2[0];
                BI_L1[4] <= A1_L1[4] * scale2_img2[1] + A2_L1[4] * scale2_img2[0];
            end
            4: begin
                BI_L1[0] <= A1_L1[0] * scale2_img2[1] + A2_L1[0] * scale2_img2[0];
                BI_L1[1] <= A1_L1[1] * scale2_img2[1] + A2_L1[1] * scale2_img2[0];
                BI_L1[2] <= A1_L1[2] * scale2_img2[1] + A2_L1[2] * scale2_img2[0];
                BI_L1[3] <= A1_L1[3] * scale2_img2[1] + A2_L1[3] * scale2_img2[0];
                BI_L1[4] <= A1_L1[4] * scale2_img2[1] + A2_L1[4] * scale2_img2[0];
            end
        endcase
    //end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cal_cnt_img1 <= 0;
    end
    else begin
        if (already_row_img1 >= 2 && already_row_img1 <= 13) begin
            if (cal_cnt_img1 != 5) begin
                cal_cnt_img1 <= cal_cnt_img1 + 1;
            end
            else begin
                cal_cnt_img1 <= 0;
            end
        end
        else begin
            cal_cnt_img1 <= 0;
        end
    end
end


always @(posedge clk) begin
    case(cal_cnt_img1)
        4,5: begin
            for (i = 0; i < 5;i++) begin
                BI_img2[0][i] <= BI_img2[0][i+5]; 
                BI_img2[1][i] <= BI_img2[1][i+5];
                BI_img2[2][i] <= BI_img2[2][i+5];
            end
            BI_img2[0][5] <= BI_img2[1][0];
            BI_img2[0][6] <= BI_img2[1][1];
            BI_img2[0][7] <= BI_img2[1][2];
            BI_img2[0][8] <= BI_img2[1][3];
            BI_img2[0][9] <= BI_img2[1][4];

            BI_img2[1][5] <= BI_img2[2][0];
            BI_img2[1][6] <= BI_img2[2][1];
            BI_img2[1][7] <= BI_img2[2][2];
            BI_img2[1][8] <= BI_img2[2][3];
            BI_img2[1][9] <= BI_img2[2][4];
            for (i = 0 ;i < 5; i++) begin
                BI_img2[2][i+5] <= BI_L1[i];
            end
        end
    endcase
end
//------------------------------------
//                SAD
//------------------------------------
 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0;i<9;i++) begin
            sad_final[i] <= 0;
        end
    end
    else begin
        if (cal_cnt_img1 == 2) begin
            case(already_row_img1)
                5: begin
                    for (i = 0;i<9;i++) begin
                        sad_final[i] <= sad_partial[i];
                    end
                end
                6,7,8,9,10,11,12: begin
                    for (i = 0;i<9;i++) begin
                        sad_final[i] <= sad_final[i] + sad_partial[i];
                    end                   
                end
            endcase
        end
    end
end
always @(*)begin
    cmp1 = 0;
    case(already_row_img1)
        13: cmp1 = (sad_final[0] <= sad_final[1]);
    endcase
end
always @(*) begin
    cmp2 = 0;
    case(already_row_img1)
        13:cmp2 = (sad_final[2] <= sad_final[3]);
    endcase
end
always@(*) begin
    cmp3 = 0;
    case(already_row_img1)
        13:cmp3 = (sad_final[4] <= sad_final[5]);
    endcase
end
always@(*) begin
    cmp4 = 0;
    case(already_row_img1)
        13:cmp4 = (sad_final[6] <= sad_final[7]);
    endcase
end
assign minsite_stage1[0] = cmp1 ? 0:1;
assign minsite_stage1[1] = cmp2 ? 2:3;
assign minsite_stage1[2] = cmp3 ? 4:5;
assign minsite_stage1[3] = cmp4 ? 6:7;
assign result_stage1[0] = cmp1 ? sad_final[0] : sad_final[1];
assign result_stage1[1] = cmp2 ? sad_final[2] : sad_final[3];
assign result_stage1[2] = cmp3 ? sad_final[4] : sad_final[5];
assign result_stage1[3] = cmp4 ? sad_final[6] : sad_final[7];

always@(*) begin
    cmp5 = 0;
    case(already_row_img1)
        13:cmp5 = (result_stage1[0] <= result_stage1[1]);
    endcase
end
always@(*) begin
    cmp6 = 0;
    case(already_row_img1)
        13:cmp6 = (result_stage1[2] <= result_stage1[3]);
    endcase
end
always @(posedge clk) begin
    case(already_row_img1)
        13: begin
            if (cmp5) begin
                minsite_stage2[0] <= minsite_stage1[0];
                result_stage2[0] <= result_stage1[0];
            end
            else begin
                minsite_stage2[0] <= minsite_stage1[1];
                result_stage2[0] <= result_stage1[1];
            end
        end
    endcase    
end
always @(posedge clk) begin
    case(already_row_img1)
        13: begin
            if (cmp6) begin
                minsite_stage2[1] <= minsite_stage1[2];
                result_stage2[1] <= result_stage1[2];
            end
            else begin
                minsite_stage2[1] <= minsite_stage1[3];
                result_stage2[1] <= result_stage1[3];
            end
        end
    endcase    
end
always @(*)begin
    cmp7 = 0;
    case(already_row_img1)
        14: cmp7 = (result_stage2[0] <= result_stage2[1]);
    endcase
end
assign minsite_stage3 = cmp7 ? minsite_stage2[0]:minsite_stage2[1];
assign result_stage3    = cmp7 ? result_stage2[0] : result_stage2[1];

always @(*)begin
    cmp8 = 0;
    case(already_row_img1)
        14: cmp8 = (result_stage3 <= sad_final[8]);
    endcase
end
always @(posedge clk)begin
    case(already_row_img1)
        14: begin
            if (cmp8) begin
                final_minsite <= minsite_stage3;
                final_result <= result_stage3;
            end
            else begin
                final_minsite <= 8;
                final_result <= sad_final[8];
            end
        end
    endcase
end
reg [27:0] out_reg;
reg out_start;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_start <= 0;
    end
    else begin
        if (cur_state == READ && first && already_row_img1 == 8 && cal_cnt_img1 == 1) begin
            out_start <= 1;
        end
        else if (print_cnt == 56) begin
            out_start <= 0;
        end
    end
end
always @(posedge clk) begin
    if (cur_state == OUT) begin
        out_reg [27:0] <= {final_minsite, final_result};
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        print_cnt <= 0;
    end
    else begin
        if (cur_state == OUT && first) begin
            print_cnt <= print_cnt + 1;
        end
        else if (out_start) begin
            if (print_cnt <56) begin
                print_cnt <= print_cnt + 1;
            end
            else if (print_cnt == 56) begin
                print_cnt <= 0;
            end
        end
        else if (cur_state == READ)begin
            print_cnt <= 0 ;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else begin
        if (out_start && print_cnt <56) begin
            out_valid <= 1;
        end
        else begin
            out_valid <= 0;
        end
        
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_sad <= 0;
    end
    else begin
        if (out_start && print_cnt <56) begin
            out_sad <= (print_cnt >= 28) ? out_reg[print_cnt -28] : out_reg[print_cnt];
        end
        else begin
            out_sad <= 0;
        end
    end
end

cal_sad_row  cal_sad_row_0 (
                .clk(clk),
                .cmp_img10(BI_img1[0][0]), .cmp_img11(BI_img1[0][1]), .cmp_img12(BI_img1[0][2]), .cmp_img13(BI_img1[0][3]),
                .cmp_img14(BI_img1[0][4]), .cmp_img15(BI_img1[0][5]), .cmp_img16(BI_img1[0][6]), .cmp_img17(BI_img1[0][7]),
                .cmp_img20(BI_img2[2][2]), .cmp_img21(BI_img2[2][3]), .cmp_img22(BI_img2[2][4]), .cmp_img23(BI_img2[2][5]),
                .cmp_img24(BI_img2[2][6]), .cmp_img25(BI_img2[2][7]), .cmp_img26(BI_img2[2][8]), .cmp_img27(BI_img2[2][9]),
                .sad_partial(sad_partial[0]));
cal_sad_row  cal_sad_row_1 (
                .clk(clk),
                .cmp_img10(BI_img1[1][0]), .cmp_img11(BI_img1[1][1]), .cmp_img12(BI_img1[1][2]), .cmp_img13(BI_img1[1][3]),
                .cmp_img14(BI_img1[1][4]), .cmp_img15(BI_img1[1][5]), .cmp_img16(BI_img1[1][6]), .cmp_img17(BI_img1[1][7]),
                .cmp_img20(BI_img2[1][2]), .cmp_img21(BI_img2[1][3]), .cmp_img22(BI_img2[1][4]), .cmp_img23(BI_img2[1][5]),
                .cmp_img24(BI_img2[1][6]), .cmp_img25(BI_img2[1][7]), .cmp_img26(BI_img2[1][8]), .cmp_img27(BI_img2[1][9]),
                .sad_partial(sad_partial[1]));
cal_sad_row  cal_sad_row_2 (
                .clk(clk), 
                .cmp_img10(BI_img1[2][0]), .cmp_img11(BI_img1[2][1]), .cmp_img12(BI_img1[2][2]), .cmp_img13(BI_img1[2][3]),
                .cmp_img14(BI_img1[2][4]), .cmp_img15(BI_img1[2][5]), .cmp_img16(BI_img1[2][6]), .cmp_img17(BI_img1[2][7]),
                .cmp_img20(BI_img2[0][2]), .cmp_img21(BI_img2[0][3]), .cmp_img22(BI_img2[0][4]), .cmp_img23(BI_img2[0][5]),
                .cmp_img24(BI_img2[0][6]), .cmp_img25(BI_img2[0][7]), .cmp_img26(BI_img2[0][8]), .cmp_img27(BI_img2[0][9]),
                .sad_partial(sad_partial[2]));
cal_sad_row  cal_sad_row_3 (
                .clk(clk),
                .cmp_img10(BI_img1[0][1]), .cmp_img11(BI_img1[0][2]), .cmp_img12(BI_img1[0][3]), .cmp_img13(BI_img1[0][4]),
                .cmp_img14(BI_img1[0][5]), .cmp_img15(BI_img1[0][6]), .cmp_img16(BI_img1[0][7]), .cmp_img17(BI_img1[0][8]),
                .cmp_img20(BI_img2[2][1]), .cmp_img21(BI_img2[2][2]), .cmp_img22(BI_img2[2][3]), .cmp_img23(BI_img2[2][4]),
                .cmp_img24(BI_img2[2][5]), .cmp_img25(BI_img2[2][6]), .cmp_img26(BI_img2[2][7]), .cmp_img27(BI_img2[2][8]),
                .sad_partial(sad_partial[3]));
cal_sad_row  cal_sad_row_4 (
                .clk(clk), 
                .cmp_img10(BI_img1[1][1]), .cmp_img11(BI_img1[1][2]), .cmp_img12(BI_img1[1][3]), .cmp_img13(BI_img1[1][4]),
                .cmp_img14(BI_img1[1][5]), .cmp_img15(BI_img1[1][6]), .cmp_img16(BI_img1[1][7]), .cmp_img17(BI_img1[1][8]),
                .cmp_img20(BI_img2[1][1]), .cmp_img21(BI_img2[1][2]), .cmp_img22(BI_img2[1][3]), .cmp_img23(BI_img2[1][4]),
                .cmp_img24(BI_img2[1][5]), .cmp_img25(BI_img2[1][6]), .cmp_img26(BI_img2[1][7]), .cmp_img27(BI_img2[1][8]),
                .sad_partial(sad_partial[4]));
cal_sad_row  cal_sad_row_5 (
                .clk(clk), 
                .cmp_img10(BI_img1[2][1]), .cmp_img11(BI_img1[2][2]), .cmp_img12(BI_img1[2][3]), .cmp_img13(BI_img1[2][4]),
                .cmp_img14(BI_img1[2][5]), .cmp_img15(BI_img1[2][6]), .cmp_img16(BI_img1[2][7]), .cmp_img17(BI_img1[2][8]),
                .cmp_img20(BI_img2[0][1]), .cmp_img21(BI_img2[0][2]), .cmp_img22(BI_img2[0][3]), .cmp_img23(BI_img2[0][4]),
                .cmp_img24(BI_img2[0][5]), .cmp_img25(BI_img2[0][6]), .cmp_img26(BI_img2[0][7]), .cmp_img27(BI_img2[0][8]),
                .sad_partial(sad_partial[5]));
cal_sad_row  cal_sad_row_6 (
                .clk(clk), 
                .cmp_img10(BI_img1[0][2]), .cmp_img11(BI_img1[0][3]), .cmp_img12(BI_img1[0][4]), .cmp_img13(BI_img1[0][5]),
                .cmp_img14(BI_img1[0][6]), .cmp_img15(BI_img1[0][7]), .cmp_img16(BI_img1[0][8]), .cmp_img17(BI_img1[0][9]),
                .cmp_img20(BI_img2[2][0]), .cmp_img21(BI_img2[2][1]), .cmp_img22(BI_img2[2][2]), .cmp_img23(BI_img2[2][3]),
                .cmp_img24(BI_img2[2][4]), .cmp_img25(BI_img2[2][5]), .cmp_img26(BI_img2[2][6]), .cmp_img27(BI_img2[2][7]),
                .sad_partial(sad_partial[6]));
cal_sad_row  cal_sad_row_7 (
                .clk(clk), 
                .cmp_img10(BI_img1[1][2]), .cmp_img11(BI_img1[1][3]), .cmp_img12(BI_img1[1][4]), .cmp_img13(BI_img1[1][5]),
                .cmp_img14(BI_img1[1][6]), .cmp_img15(BI_img1[1][7]), .cmp_img16(BI_img1[1][8]), .cmp_img17(BI_img1[1][9]),
                .cmp_img20(BI_img2[1][0]), .cmp_img21(BI_img2[1][1]), .cmp_img22(BI_img2[1][2]), .cmp_img23(BI_img2[1][3]),
                .cmp_img24(BI_img2[1][4]), .cmp_img25(BI_img2[1][5]), .cmp_img26(BI_img2[1][6]), .cmp_img27(BI_img2[1][7]),
                .sad_partial(sad_partial[7]));

cal_sad_row  cal_sad_row_8 (
                .clk(clk),
                .cmp_img10(BI_img1[2][2]), .cmp_img11(BI_img1[2][3]), .cmp_img12(BI_img1[2][4]), .cmp_img13(BI_img1[2][5]),
                .cmp_img14(BI_img1[2][6]), .cmp_img15(BI_img1[2][7]), .cmp_img16(BI_img1[2][8]), .cmp_img17(BI_img1[2][9]),
                .cmp_img20(BI_img2[0][0]), .cmp_img21(BI_img2[0][1]), .cmp_img22(BI_img2[0][2]), .cmp_img23(BI_img2[0][3]),
                .cmp_img24(BI_img2[0][4]), .cmp_img25(BI_img2[0][5]), .cmp_img26(BI_img2[0][6]), .cmp_img27(BI_img2[0][7]),
                .sad_partial(sad_partial[8]));
endmodule



module cal_sad_row(
    input clk,
    input[15:0] cmp_img10,cmp_img11,cmp_img12,cmp_img13,cmp_img14,cmp_img15,cmp_img16,cmp_img17,
    input[15:0] cmp_img20,cmp_img21,cmp_img22,cmp_img23,cmp_img24,cmp_img25,cmp_img26,cmp_img27,
    output reg [18:0] sad_partial
);

wire [15:0] minus_result_ns[0:7];
reg [15:0] minus_result[0:7];
wire [15:0] minus_img1_big[0:7];
wire [15:0] minus_img2_big[0:7];
int i;
assign minus_img1_big[0] = cmp_img10 - cmp_img20;
assign minus_img1_big[1] = cmp_img11 - cmp_img21;
assign minus_img1_big[2] = cmp_img12 - cmp_img22;
assign minus_img1_big[3] = cmp_img13 - cmp_img23;
assign minus_img1_big[4] = cmp_img14 - cmp_img24;
assign minus_img1_big[5] = cmp_img15 - cmp_img25;
assign minus_img1_big[6] = cmp_img16 - cmp_img26;
assign minus_img1_big[7] = cmp_img17 - cmp_img27;

assign minus_img2_big[0] = cmp_img20 - cmp_img10;
assign minus_img2_big[1] = cmp_img21 - cmp_img11;
assign minus_img2_big[2] = cmp_img22 - cmp_img12;
assign minus_img2_big[3] = cmp_img23 - cmp_img13;
assign minus_img2_big[4] = cmp_img24 - cmp_img14;
assign minus_img2_big[5] = cmp_img25 - cmp_img15;
assign minus_img2_big[6] = cmp_img26 - cmp_img16;
assign minus_img2_big[7] = cmp_img27 - cmp_img17;

assign minus_result_ns[0] = (cmp_img10 >= cmp_img20)? (minus_img1_big[0]) : (minus_img2_big[0]);
assign minus_result_ns[1] = (cmp_img11 >= cmp_img21)? (minus_img1_big[1]) : (minus_img2_big[1]);
assign minus_result_ns[2] = (cmp_img12 >= cmp_img22)? (minus_img1_big[2]) : (minus_img2_big[2]);
assign minus_result_ns[3] = (cmp_img13 >= cmp_img23)? (minus_img1_big[3]) : (minus_img2_big[3]);
assign minus_result_ns[4] = (cmp_img14 >= cmp_img24)? (minus_img1_big[4]) : (minus_img2_big[4]);
assign minus_result_ns[5] = (cmp_img15 >= cmp_img25)? (minus_img1_big[5]) : (minus_img2_big[5]);
assign minus_result_ns[6] = (cmp_img16 >= cmp_img26)? (minus_img1_big[6]) : (minus_img2_big[6]);
assign minus_result_ns[7] = (cmp_img17 >= cmp_img27)? (minus_img1_big[7]) : (minus_img2_big[7]);

always @(posedge clk) begin
    for (i = 0; i<8;i++) begin
        minus_result[i] <= minus_result_ns[i];
    end
end
wire [18:0] add_result[0:5];
wire [18:0] add_result_ns;
assign add_result[0] = minus_result[0] + minus_result[1];
assign add_result[1] = minus_result[2] + minus_result[3];
assign add_result[2] = minus_result[4] + minus_result[5];
assign add_result[3] = minus_result[6] + minus_result[7];

assign add_result[4] = add_result[0] + add_result[1];
assign add_result[5] = add_result[2] + add_result[3];

assign add_result_ns = add_result[4] + add_result[5];
always @(posedge clk) begin
    sad_partial <= add_result_ns;
end

endmodule