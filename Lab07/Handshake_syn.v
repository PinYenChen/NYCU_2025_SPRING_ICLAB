module Handshake_syn #(parameter WIDTH=32) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

assign sidle = ( sreq || sack ) ? 0 : 1; // SYNCHRONIZER IS BUSY!!!

reg [WIDTH-1:0] s_data;

typedef enum reg {s_IDLE = 0 ,s_SEND = 1}s_state;
s_state s_cur_state, s_nxt_state;

// Synchronizer
NDFF_syn SRC(.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn DST(.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));

// Source
always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) begin
        s_cur_state <= s_IDLE;
    end
    else begin
        s_cur_state <= s_nxt_state;
    end
end
always @(*) begin
    s_nxt_state = s_cur_state;
    case(s_cur_state) 
        s_IDLE: begin
            if (sready && !sreq) begin
                s_nxt_state = s_SEND;
            end
            else begin
                s_nxt_state = s_cur_state;
            end
        end
        s_SEND: begin
            if (!sreq && !sack) begin
                s_nxt_state = s_IDLE;
            end
            else begin
                s_nxt_state = s_cur_state;
            end
        end
    endcase
end
always @(posedge sclk or negedge rst_n) begin
    if(!rst_n)begin
        s_data <= 0; 
    end
    else begin
        if (s_cur_state == s_IDLE) begin
        s_data <= din; 
        end
        else begin
            s_data <= s_data;
        end
    end
    
end
always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) begin
        sreq <= 0;
    end
    else if(sready && !sreq && s_cur_state == s_IDLE)begin
        sreq <= 1;
    end
    else if(sack && s_cur_state == s_SEND)begin
        sreq <= 0;
    end
    else begin
        sreq <= sreq;
    end
end
//Destination
typedef enum reg{d_IDLE = 0 , d_OUT = 1}d_state;
d_state d_cur_state, d_nxt_state;
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) begin
        d_cur_state <= d_IDLE;
    end
    else begin
        d_cur_state <= d_nxt_state;
    end
end
always @(*) begin
    d_nxt_state = d_cur_state;
    case(d_cur_state)     
        d_IDLE: begin
            if (!dreq && dack) begin //dreq && !dack
                d_nxt_state = d_OUT;
            end
            else begin
                d_nxt_state = d_cur_state;
            end
        end
        d_OUT: begin
            if (!dbusy) begin
                d_nxt_state = d_IDLE;
            end
            else begin
                d_nxt_state = d_cur_state;
            end
        end
    endcase
end
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) begin
        dack <= 0;
    end
    else if (dreq) begin
        dack <= 1;
    end
    else begin
        dack <= 0;
    end
end
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) begin
        dvalid <= 0;
    end
    else if (d_cur_state == d_OUT && !dbusy) begin
        dvalid <= 1;
    end
    else begin
        dvalid <= 0;
    end
end
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) begin
        dout <= 0;
    end
    else if (d_cur_state == d_OUT && !dbusy) begin
        dout <= s_data;
    end
    else begin
        dout <= 0;
    end
end

endmodule