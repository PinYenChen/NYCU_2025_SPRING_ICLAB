module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
    seed_in,
    out_idle,
    out_valid,
    seed_out,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4
);

input clk;
input rst_n;
input in_valid;
input [31:0] seed_in;
input out_idle;
output reg out_valid;
output reg [31:0] seed_out;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

typedef enum reg[1:0]{IDLE = 0 ,INPUT = 1 ,HANDSHAKE = 2, SEND = 3}state;
state cur_state,nxt_state;
reg [31:0] seed_clk1, seed_clk1_ns;



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
        seed_clk1 <= 0;
    end
    else begin
        seed_clk1 <= seed_clk1_ns;
    end
end

always @(*) begin
    nxt_state = cur_state;
    case(cur_state) 
    IDLE: begin
        if (in_valid) begin
            nxt_state = INPUT;
        end
        else begin
            nxt_state = cur_state;
        end
    end
    INPUT: nxt_state = HANDSHAKE;
    HANDSHAKE: begin
        if (out_idle) begin
            nxt_state = SEND;
        end
        else begin
            nxt_state = cur_state;
        end
    end
    SEND: nxt_state = IDLE;
    endcase
end
// ----------------------------------------------
//                    IN
// ----------------------------------------------
always @(*) begin
    seed_clk1_ns = seed_clk1;
    if (in_valid) begin
        seed_clk1_ns = seed_in;
    end
end
// ----------------------------------------------
//                    OUT
// ----------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0; 
    end
    else if (cur_state == SEND) begin
        out_valid <= 1;
    end
    else begin
        out_valid <= 0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seed_out <= 0;
    end
    else if (cur_state == SEND && out_idle) begin
        seed_out <= seed_clk1;
    end
end

endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    seed,
    out_valid,
    rand_num,
    busy,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [31:0] seed;
output reg out_valid;
output reg [31:0] rand_num;
output reg busy;

// You can change the input / output of the custom flag ports
input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

input clk2_fifo_flag1;
input clk2_fifo_flag2;
output clk2_fifo_flag3;
output clk2_fifo_flag4;

typedef enum reg {IDLE = 0 ,CAL = 1}state;
state cur_state, nxt_state;
reg [8:0] cnt_256, cnt_256_ns;
reg [31:0] seed_reg, seed_reg_ns;

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
        cnt_256 <= 0;
    end
    else begin
        cnt_256 <= cnt_256_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seed_reg <= 0;
    end
    else begin
        seed_reg <= seed_reg_ns;
    end
end
always @(*) begin
    nxt_state = cur_state;
    case(cur_state)
        IDLE: begin
            if (in_valid) begin
                nxt_state = CAL;
            end
            else begin
                nxt_state = cur_state;
            end
        end
        CAL: begin
            if (cnt_256[8] == 1 && !fifo_full) begin
                nxt_state = IDLE;
            end
            else begin
                nxt_state = cur_state;
            end

        end
    endcase
end
reg [31:0] seed_step1, seed_step2, seed_step3, seed_step4, seed_step4_ns;
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seed_step4 <= 0;
    end
    else begin
        seed_step4 <= seed_step4_ns;
    end
end
*/
wire [3:0] a;
wire [4:0] b;
wire [2:0] c;
assign a = 13;
assign b = 17;
assign c = 5;


// ----------------------
//          INPUT
// ----------------------
always @(*) begin
    if (in_valid) begin
        seed_reg_ns = seed;
    end
    else if (cur_state == CAL && !fifo_full) begin
        seed_reg_ns = seed_step4;
    end
    else begin
        seed_reg_ns = seed_reg;
    end
end
// ---------------------------
//          CAL & OUT
// ---------------------------
always @(*) begin
    if (cur_state == IDLE) begin
        cnt_256_ns = 0;
    end
    else if (cur_state == CAL && !fifo_full && cnt_256 < 256) begin
        cnt_256_ns = cnt_256 + 1;
    end
    else begin
        cnt_256_ns = cnt_256;
    end
end
always @(*) begin
    seed_step1 = 0;
    seed_step2 = 0;
    seed_step3 = 0;
    seed_step4 = 0;
    if (cur_state == CAL && !fifo_full) begin // calculate the pseudo number with fifo is not full
        seed_step1 = seed_reg;
        seed_step2 = seed_step1 ^ (seed_step1 << a);
        seed_step3 = seed_step2 ^ (seed_step2 >> b);
        seed_step4 = seed_step3 ^ (seed_step3 << c);
    end
end 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rand_num <= 0;
    end
    else if (cur_state == CAL && !fifo_full) begin
        rand_num <= seed_step4;
    end
    else begin
        rand_num <= rand_num;
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (cur_state == CAL && flag) begin
        out_valid <= 1;
    end
    else begin
        out_valid <= 0;
    end
end

*/
//always @(*) out_valid = (!fifo_full)? 1 : 0;
reg flag;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        flag <= 0;
    end
    else if (cur_state == CAL)begin
        flag <= 1;
    end
    else begin
        flag <= 0;
    end
end

always @(*) begin
    if (cur_state == CAL && !fifo_full && flag) begin
        out_valid = 1;
    end
    else begin
        out_valid = 0;
    end
end

always@(*)begin
    if(cur_state == CAL)begin
        busy = 1;
    end
    else begin
        busy = 0;
    end
end
endmodule

module CLK_3_MODULE (
    clk,
    rst_n,
    fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    rand_num,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input clk;
input rst_n;
input fifo_empty;
input [31:0] fifo_rdata;
output reg fifo_rinc;
output reg out_valid;
output reg [31:0] rand_num;

// You can change the input / output of the custom flag ports
input fifo_clk3_flag1;
input fifo_clk3_flag2;
output fifo_clk3_flag3;
output fifo_clk3_flag4;

reg fifo_rinc_d1, fifo_rinc_d2;
assign fifo_rinc = !fifo_empty;
reg [7:0] out_cnt;
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fifo_rinc <= 0;
    end
    else begin
        fifo_rinc <= !fifo_empty;
    end
end
*/
// 3 clk edge principle
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fifo_rinc_d1 <= 0;
        fifo_rinc_d2 <= 0;
    end
    else begin
        fifo_rinc_d1 <= fifo_rinc;
        fifo_rinc_d2 <= fifo_rinc_d1;        
    end
end 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (fifo_rinc_d2) begin
        out_valid <= 1;
    end
    else begin
        out_valid <= 0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_cnt <= 0;
    end
    else if (fifo_rinc_d2) begin
        out_cnt <= out_cnt + 1;
    end
    else begin
        out_cnt <= out_cnt;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rand_num <= 0;
    end
    else if (fifo_rinc_d2) begin
        rand_num <= fifo_rdata;
    end
    else begin
        rand_num <= 0;
    end
end
endmodule
