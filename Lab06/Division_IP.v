//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : Division_IP.v
//   	Module Name : Division_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module Division_IP #(parameter IP_WIDTH = 7) (
    // Input signals
    IN_Dividend, IN_Divisor,
    // Output signals
    OUT_Quotient
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_WIDTH*4-1:0]  IN_Dividend;
input [IP_WIDTH*4-1:0]  IN_Divisor;

output logic [IP_WIDTH*4-1:0] OUT_Quotient;

// ===============================================================
// Design
// ===============================================================
    wire [3:0] a_arr [0:IP_WIDTH-1];
    wire [3:0] b_arr [0:IP_WIDTH-1]; // to be sent to the arr
    wire [3:0] q_bit_value [0:IP_WIDTH-1];
    wire [3:0] q_bit_index [0:IP_WIDTH-1];
    genvar i;
    generate
        for (i = 0; i < IP_WIDTH; i = i + 1) begin : UNPACK_INPUT
            assign a_arr[IP_WIDTH-1-i] = IN_Dividend[4*(i+1)-1:4*i];
            assign b_arr[IP_WIDTH-1-i] = IN_Divisor[4*(i+1)-1:4*i];
        end
    endgenerate

    wire [3:0] step_a[0:IP_WIDTH][0:IP_WIDTH-1];
    reg [3:0] q_bit[0:IP_WIDTH-1];
    wire [3:0] high_a[0:IP_WIDTH];
    wire [3:0] high_b;
    //reg [3:0] b_ans_out[0:IP_WIDTH-1];

    integer k;
    reg [3:0] tmp_high_b;
    always @(*) begin
        tmp_high_b = 0;
        for (k = IP_WIDTH-1; k >= 0; k = k - 1) begin
            if (b_arr[k] != 4'd15)
                tmp_high_b = k; // to find the highest bit of b
        end
    end
    /*
    always@(*) begin
        for (k = 0; k< IP_WIDTH; k = k + 1) begin
             q_bit[k] = 15;
        end
    end
    */
    assign high_b = tmp_high_b;
    assign step_a[0] = a_arr;
    assign high_a[0] = 0;


    generate
        for (i = 0; i < IP_WIDTH; i = i + 1) begin : DIV_LOOP
            gf4_div_step #(.IP_WIDTH(IP_WIDTH)) step_inst (
                .a_in(step_a[i]),
                .b_in(b_arr),
                .high_a(high_a[i]),
                .high_b(high_b),
                .a_out(step_a[i+1]),
                .q_bit_value(q_bit_value[i]),
                .q_bit_index(q_bit_index[i]),
                .new_high_a(high_a[i+1]),
                .start_b(tmp_high_b)
            );
        end
    endgenerate
    always @(*) begin
        for(k=0;k<IP_WIDTH;k=k+1)begin
            if(k<=tmp_high_b && high_a[0] <= tmp_high_b)
                q_bit[k]=q_bit_value[tmp_high_b-k];
            else
                q_bit[k]=15;
        end
    end
    generate
        for (i = 0; i < IP_WIDTH; i = i + 1) begin : OUT_Q
            assign OUT_Quotient[4*(i+1)-1:4*i] = q_bit[i];
        end
    endgenerate

endmodule

module gf4_div_step #(parameter IP_WIDTH = 7)(
    input  wire [3:0] a_in [0:IP_WIDTH-1],
    input  wire [3:0] b_in [0:IP_WIDTH-1],
    input  wire [3:0] high_a,
    input  wire [3:0] high_b,
    input wire [3:0] start_b,
    output wire [3:0] a_out[0:IP_WIDTH-1],
    output reg [3:0] q_bit_value,
    output reg [3:0] q_bit_index,
    output reg [3:0] new_high_a
);
    reg [3:0] b_shifted [0:IP_WIDTH-1];
    reg [3:0] b_ans [0:IP_WIDTH - 1];
    wire [3:0] temp_a    [0:IP_WIDTH-1];
    //wire [3:0] sub_out;
    always @(*) begin
        if (a_in[high_a] == 15) begin
            q_bit_value = 15;
            q_bit_index = IP_WIDTH - start_b - high_a - 1;
        end
        else begin
            q_bit_value = (b_in[high_b] > a_in[high_a]) 
                ? 15 - (b_in[high_b] - a_in[high_a])
                : (a_in[high_a] - b_in[high_b]);

            q_bit_index = high_b - high_a;
        end
    end
    genvar i;
    integer j;
    //b shift
    /*
    generate
        for (i = 0; i < IP_WIDTH; i = i + 1) begin : SHIFT_LOOP
            if (i < IP_WIDTH - (high_b - high_a))
                assign b_shifted[i] = b_in[i + high_b - high_a];
            else
                assign b_shifted[i] = 4'd15;  //complement 15
        end
    endgenerate
    */
    always @(*) begin
        if (high_a != high_b) begin
            for (j = 0; j < IP_WIDTH; j = j + 1) begin 
                if (j < IP_WIDTH - (high_b - high_a))
                    b_shifted[j] = b_in[j + high_b - high_a];
                else
                    b_shifted[j] = 4'd15;  //complement 15
            end
        end
        else begin
            for (j = 0; j < IP_WIDTH; j = j + 1) begin
                b_shifted[j] = b_in[j];
            end
        end
    end
    
    //b_ans & mod bitwise
    always @(*) begin
        
        for (j = 0; j<IP_WIDTH; j = j+1) begin
            b_ans[j] = 4'd15;
        end
        
        for (j = 0; j < IP_WIDTH; j = j + 1) begin
            
            if (b_shifted[j] + q_bit_value >= 15 && (b_shifted[j] != 15 && q_bit_value != 15)) begin // need to be modulo when start is not 15
                //$display("here1");
                b_ans[j] = b_shifted[j] -15 + q_bit_value; 
            end
            else if (b_shifted[j] + q_bit_value < 15 && (b_shifted[j] != 15 && q_bit_value != 15)) begin
                //$display("here2");
                b_ans[j] = b_shifted[j] + q_bit_value;
            end
            
            else if (b_shifted[j] == 15 || q_bit_value == 15) begin
                b_ans[j] = 15;
                //$display("j=%0d b_shifted=%0d q_bit_value=%0d → b_ans=%0d", 
          //j, b_shifted[j], q_bit_value, b_ans[j]);
            end

        end
    end

    generate
        for (i = 0; i < IP_WIDTH; i = i + 1) begin : FINAL_SUB
            subtractor #(IP_WIDTH) sub (.A(a_in[i]), .B(b_ans[i]), .out(a_out[i])) ; 
        end
    endgenerate


    //reg [3:0] tmp_high;
    always @(*) begin
        //tmp_high = 0;
        /*
        for (j = IP_WIDTH-1; j >= 0; j = j - 1) begin
            if (a_out[j] != 15)
                new_high_a = j;
        end
        */
        new_high_a = high_a + 1;

    end
    

endmodule



module subtractor( //calculate A-B
    A,B,out
);
input [3:0]A,B;
output reg [3:0]out;
// ===============================================================
// Reg & Wire Declaration
// ===============================================================
reg [3:0]a,b;
always @(*) begin
    case (A)
        0: a = 4'd1;
        1: a = 4'd2;
        2: a = 4'd4;
        3: a = 4'd8;
        4: a = 4'd3;
        5: a = 4'd6;
        6: a = 4'd12;
        7: a = 4'd11;
        8: a = 4'd5;
        9: a = 4'd10;
        10:a = 4'd7;
        11:a = 4'd14;
        12:a = 4'd15;
        13:a = 4'd13; 
        14:a = 4'd9;
        15:a = 4'd0;
    endcase
    case (B)
        0:  b = 4'd1;
        1:  b = 4'd2;
        2:  b = 4'd4;
        3:  b = 4'd8;
        4:  b = 4'd3;
        5:  b = 4'd6;
        6:  b = 4'd12;
        7:  b = 4'd11;
        8:  b = 4'd5;
        9:  b = 4'd10;
        10: b = 4'd7;
        11: b = 4'd14;
        12: b = 4'd15;
        13: b = 4'd13; 
        14: b = 4'd9;
        15: b = 4'd0;
    endcase
    case (a^b)
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
end

endmodule