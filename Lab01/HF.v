module HF(
    // Input signals
    input [24:0] symbol_freq,
    // Output signals
    output reg [19:0] out_encoded
);

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment

//signal input
reg [10:0] weight [0:4];
//five sorted
reg [9:0] sorted1 [0:4];
reg [10:0] sorted2 [0:3];
reg [11:0] sorted3 [0:2];
reg [12:0] sorted4 [0:1];

reg [10:0] new_value1; // 3 bits are the alphabet and 6 bits are the possible result of the merged process
reg [11:0] new_value2;  //max: 6 bits plus 5 bits ==> 7 bits plus 5 bits onehot code
reg [12:0] new_value3; //max: two 6 bit addition ==> 7 bits or 7 bits + 6 bit ==> 8 bits plus 5 bits onehot code
//reg [4:0] last_site;
reg [12:0] final0,final1;

//first sorting(5)
reg [9:0] f00,f01,f02,f03,f04;
reg [9:0] f10,f11,f12,f13,f14;
reg [9:0] f20,f22,f23,f24;
wire [9:0] f21;
reg [9:0] f30,f31,f32,f33,f34;
reg [9:0] f40,f41,f42,f43,f44;
//reg [4:0] f50,f51,f52,f53,f54,f55;
//second sorting(4)
reg [10:0] s00,s01,s02,s03;
//reg [10:0] s10,s11,s12,s13;
//reg [10:0] s21,s22;
//reg [10:0] s30,s31,s32,s33;

reg [11:0] t00,t01,t02;
//reg [11:0] t10,t11,t12;
//reg [11:0] t20,t21,t22;

//code determination
reg [3:0]code1[0:4];
reg [3:0]code2[0:4];
reg [3:0]code3[0:4];
reg [3:0]code4[0:4];
//reg [3:0]ini_code;

reg [1:0] delete1 [0:4];
reg [1:0] delete2 [0:4];
reg [1:0] delete3 [0:4];
//reg [1:0] delete4 [0:4];

//reg [1:0]ini_delete;

reg [1:0] change1 [0:4];
reg [1:0] change2 [0:4];
reg [1:0] change3 [0:4];

reg [3:0] flag [0:9];
//reg [1:0] change4 [0:4];

/*
always @(*) begin
    ini_code = 4'b1111;
    ini_delete = 2'b11;
end

reg [4:0]merge_onehot1;
reg [4:0]merge_onehot2;
reg [4:0]merge_onehot3;


always @ (*) begin
    for(int i = 0; i < 3; i++) begin
        merge_onehot1[i] = 5'b00000;
        merge_onehot2[i] = 5'b00000;
        merge_onehot3[i] = 5'b00000;
    end
end
*/



//================================================================
//    DESIGN
//================================================================

//===================================
//
//========sorting 5 things
//
//===================================
always @ (*)  
begin
    weight[0] = {symbol_freq[24:20],5'b00001};
    weight[1] = {symbol_freq[19:15],5'b00010};
    weight[2] = {symbol_freq[14:10],5'b00100};
    weight[3] = {symbol_freq[9:5]  ,5'b01000};
    weight[4] = {symbol_freq[4:0]  ,5'b10000};
    //site1[0] = 0; //site[0] = value : which alphabet is the min.
    //site1[1] = 1; //site[1]
    //site1[2] = 2; //site[2]
    //site1[3] = 3; //site[3]
    //site1[4] = 4; //site[4] 
end
//stage 0
always @ (*) 
begin
    if (weight[0][9:5]<weight[4][9:5]) begin
        f00 = weight[0];
        f04 = weight[4];
    end
    else if (weight[0][9:5] == weight[4][9:5]) begin
        if (weight[0][4:0] < weight[4][4:0]) begin
            f00 = weight[0];
            f04 = weight[4];
        end
        else begin
            f00 = weight[4];
            f04 = weight[0];
        end
    end
    else begin // weight[4] < weight[0] 
        f00 = weight[4];
        f04 = weight[0];
    end
end
always @ (*) 
begin
    f01 = weight[1];
    f02 = weight[2];
    f03 = weight[3];
end

//stage 1
always @ (*) 
begin
    if (f02[9:5]<f04[9:5]) begin
        f12 = f02;
        f14 = f04;
    end
    else if (f02[9:5] == f04[9:5]) begin
        if (f02[4:0] < f04[4:0]) begin
            f12 = f02;
            f14 = f04;
        end
        else begin
            f12 = f04;
            f14 = f02;
        end
    end
    else begin //f04<f02
        f12 = f04;
        f14 = f02;
    end
end
always @ (*) 
begin
    if (f01[9:5]<f03[9:5]) begin
        f11 = f01;
        f13 = f03;
    end
    else if (f01[9:5] == f03[9:5]) begin
        if (f01[4:0] < f03[4:0]) begin
            f11 = f01;
            f13 = f03;
        end
        else begin
            f11 = f03;
            f13 = f01;
        end
    end
    else begin
        f11 = f03;
        f13 = f01;
    end
end
always @ (*)  
begin
    f10 = f00;
end
//stage 2
always @ (*) 
begin
    if (f10[9:5]<f12[9:5]) begin
        f20 = f10;
        f22 = f12;
    end
    else if (f10[9:5] == f12[9:5]) begin
        if (f10[4:0] < f12[4:0]) begin
            f20 = f10;
            f22 = f12;
        end
        else begin
            f20 = f12;
            f22 = f10;
        end
    end
    else begin
        f20 = f12;
        f22 = f10;
    end
end
always @ (*)  
begin
    if (f13[9:5]<f14[9:5]) begin
        f23 = f13;
        f24 = f14;
    end
    else if (f13[9:5] == f14[9:5]) begin
        if (f13[4:0] < f14[4:0]) begin
            f23 = f13;
            f24 = f14;
        end
        else begin
            f23 = f14;
            f24 = f13;
        end
    end
    else begin
        f23 = f14;
        f24 = f13;
    end
end

assign f21=f11;
///////////stage3
always @ (*) 
begin
    if (f20[9:5]<f23[9:5]) begin
        f30 = f20;
        f33 = f23;
    end
    else if (f20[9:5] == f23[9:5]) begin
        if (f20[4:0] < f23[4:0]) begin
            f30 = f20;
            f33 = f23;
        end
        else begin
            f30 = f23;
            f33 = f20;
        end
    end
    else begin
        f30 = f23;
        f33 = f20;
    end
end
always @ (*)  
begin
    if (f21[9:5]<f22[9:5]) begin
        f31 = f21;
        f32 = f22;
    end
    else if (f21[9:5] == f22[9:5]) begin
        if (f21[4:0] < f22[4:0]) begin
            f31 = f21;
            f32 = f22;
        end
        else begin
            f31 = f22;
            f32 = f21;
        end
    end
    else begin
        f31 = f22;
        f32 = f21;
    end
end

always @ (*)  
begin
    f34 = f24;
end


///////stage 4
always @ (*) 
begin
    if (f30[9:5]<f31[9:5]) begin
        f40 = f30;
        f41 = f31;
    end
    else if (f30[9:5] == f31[9:5]) begin
        if (f30[4:0] < f31[4:0]) begin
            f40 = f30;
            f41 = f31;
        end
        else begin
            f40 = f31;
            f41 = f30;
        end
    end
    else begin
        f40 = f31;
        f41 = f30;
    end
end

always @ (*) 
begin
    if (f32[9:5]<f33[9:5]) begin
        f42 = f32;
        f43 = f33;
    end
    else if (f32[9:5] == f33[9:5]) begin
        if (f32[4:0] < f33[4:0]) begin
            f42 = f32;
            f43 = f33;
        end
        else begin
            f42 = f33;
            f43 = f32;
        end
    end
    else begin
        f42 = f33;
        f43 = f32;
    end
end

always @ (*) 
begin
    f44 = f34;
end

always @ (*) 
begin
    sorted1[0] = f40;
    sorted1[1] = f41;
    sorted1[2] = f42;
    sorted1[3] = f43;
    sorted1[4] = f44;
end

//dealing with the result
always @(*) 
begin
    new_value1[10:5] = sorted1[0][9:5] + sorted1[1][9:5];

    //record who are merged to new_value1
    new_value1[4:0] = sorted1[0][4:0] | sorted1[1][4:0];
end

always @(*) begin
    for (int i = 0; i<=4; i++) begin
        code1[i] = 'b1111;
    end
    //determine code
    if (sorted1[0][0] == 1) begin //sorted1[0][0] = value 1 represent a 
        code1[0][0] = 0;
    end
    else if(sorted1[1][0] == 1) begin // a is second min
        code1[0][0] = 1;
    end
    else begin // if not the msb should be change to 0
        code1[0][3] = 0;
    end

    if (sorted1[0][1] == 1) begin //b
        code1[1][0] = 0;
    end 
    else if(sorted1[1][1] == 1) begin // b is second min
        code1[1][0] = 1;
    end
    else begin
        code1[1][3] = 0;
    end

    if (sorted1[0][2] == 1) begin//c
        code1[2][0] = 0;
    end
    else if(sorted1[1][2] == 1) begin // b is second min
        code1[2][0] = 1;
    end
    else begin
        code1[2][3] = 0;
    end

    if (sorted1[0][3] == 1) begin//d
        code1[3][0] = 0;
    end     
    else if(sorted1[1][3] == 1) begin // b is second min
        code1[3][0] = 1;
    end
    else begin
        code1[3][3] = 0;
    end

    if (sorted1[0][4] == 1) begin//d
        code1[4][0] = 0;
    end
    else if(sorted1[1][4] == 1) begin // b is second min
        code1[4][0] = 1;
    end
    else begin
        code1[4][3] = 0;
    end

    //for second small no need to change for the first stage
end

always @(*) begin

    for (int i = 0; i<=4; i++) begin
        delete1[i] = 'b11;
        change1[i] = 'b00;
    end
    for(int i=0;i<=4;i++)begin
        if (sorted1[0][i] == 1 || sorted1[1][i] ==1 ) begin //sorted1[0][0] = value 1 represent a 
            change1[i] = 'b00 +1;
        end
        else begin // if not the msb should be change to 0
            delete1[i] = 'b11 -1;
        end

    end
    /*
    //determine change and delete signal
    if (sorted1[0][0] == 1 || sorted1[1][0] ==1 ) begin //sorted1[0][0] = value 1 represent a 
        change1[0] = b'00 +1;
    end
    else begin // if not the msb should be change to 0
        delete1[0] = b'11 -1;
    end

    if (sorted1[0][1] == 1 || sorted1[1][1] ==1 ) begin //b
        change1[1] = b'00+1;
    end else begin
        delete1[1] = b'11 -1;
    end

    if (sorted1[0][2] == 1 || sorted1[1][2] ==1 ) begin//c
        change1[2] = b'00+1;
    end else begin
        delete1[2] = b'11 -1;
    end

    if (sorted1[0][3] == 1 || sorted1[1][3] ==1 ) begin//d
        change1[3] = b'00+1;
    end else begin
        delete1[3] = b'11 -1;
    end

    if (sorted1[0][4] == 1 || sorted1[1][4] ==1 ) begin//d
        change1[4] = b'00+1;
    end else begin
        delete1[4] = b'11 -1;
    end
    */

end



//===================================
//
//========sorting 4 things
//
//===================================

always @ (*)  
begin
    s00 = new_value1;
    s01 = sorted1[2]; 
    s02 = sorted1[3];
    s03 = sorted1[4]; 
end

always @ (*) begin
    if (s00[10:5]<=s01[10:5]) begin
        sorted2[0] = s00;
        sorted2[1] = s01;
        sorted2[2] = s02;
        sorted2[3] = s03;
        
    end 
    else if(s00[10:5]<=s02[10:5])begin
        sorted2[0] = s01;
        sorted2[1] = s00;
        sorted2[2] = s02;
        sorted2[3] = s03;
    end
    else if(s00[10:5]<=s03[10:5])begin
        sorted2[0] = s01;
        sorted2[1] = s02;
        sorted2[2] = s00;
        sorted2[3] = s03;
    end
    else begin
        sorted2[0] = s01;
        sorted2[1] = s02;
        sorted2[2] = s03;
        sorted2[3] = s00;
    end
end
/*
//stage 1
always @ (*) 
begin
    if (s00[10:5]<s01[10:5]) begin
        s10 = s00;
        s11 = s01;
    end
    else begin
        s10 = s01;
        s11 = s00;
    end
end
always @ (*)  
begin
    if (s02[10:5]<=s03[10:5]) begin
        s12 = s02;
        s13 = s03;
    end
    else begin
        s12 = s03;
        s13 = s02;
    end
end
//stage 2
always @ (*) 
begin
    if (s11[10:5]<=s12[10:5]) begin
        s21 = s11;
        s22 = s12;
    end
    else begin
        s21 = s12;
        s22 = s11;
    end
end

always @ (*)  
begin
    s20 = s10;
    s23 = s13;
end


//stage 3
always @ (*) 
begin
    if (s10[10:5]<=s21[10:5]) begin
        s30 = s10;
        s31 = s21;
    end
    else begin
        s30 = s21;
        s31 = s10;
    end
end
always @ (*) 
begin
    if (s22[10:5]<=s13[10:5]) begin
        s32 = s22;
        s33 = s13;
    end
    else begin
        s32 = s13;
        s33 = s22;
    end
end
//stage 4
always @ (*) 
begin
    if (s31[10:5]<=s32[10:5]) begin
        sorted2[1] = s31;
        sorted2[2] = s32;
    end
    else begin
        sorted2[1] = s32;
        sorted2[2] = s32;
    end
end
always @ (*)  
begin
    sorted2[0] = s30;
    sorted2[3] = s33;
end
*/
//dealing with the output of the second sorting
always @ (*) 
begin
    new_value2[11:5] = sorted2[0][10:5] + sorted2[1][10:5];

    //record who are merged to new_value1
    new_value2[4:0] = sorted2[0][4:0] | sorted2[1][4:0];
end

always @(*) // the most min
begin
    for (int i = 0 ; i<=4;i++) begin
        code2[i] = code1[i];
    end

    if (sorted2[0][0] == 1 ) begin // a
        code2[0][change1[0]] = 0;
    end
    else if (sorted2[1][0] == 1) begin
        code2[0][change1[0]] = 1;
    end
    else begin
        code2[0][delete1[0]] = 0;
    end

    if (sorted2[0][1] == 1 ) begin // b
        code2[1][change1[1]] = 0;
    end
    else if (sorted2[1][1] == 1) begin
        code2[1][change1[1]] = 1;
    end
    else begin
        code2[1][delete1[1]] = 0;
    end

    if (sorted2[0][2] == 1 ) begin // c
        code2[2][change1[2]] = 0;
    end
    else if (sorted2[1][2] == 1) begin
        code2[2][change1[2]] = 1;
    end
    else begin
        code2[2][delete1[2]] = 0;
    end

    if (sorted2[0][3] == 1 ) begin // d
        code2[3][change1[3]] = 0;
    end
    else if (sorted2[1][3] == 1) begin
        code2[3][change1[3]] = 1;
    end
    else begin
        code2[3][delete1[3]] = 0;
    end

    if (sorted2[0][4] == 1 ) begin // e
        code2[4][change1[4]] = 0;
    end
    else if (sorted2[1][4] == 1) begin
        code2[4][change1[4]] = 1;
    end
    else begin
        code2[4][delete1[4]] = 0;
    end
end
always @(*) begin

    for(int i=0;i<=4;i++)begin
        if (sorted2[0][i] == 1 || sorted2[1][i] ==1 ) begin //sorted1[0][0] = value 1 represent a 
            change2[i] = change1[i] +1;
            delete2[i] = delete1[i];
        end
        else begin // if not the msb should be change to 0
            delete2[i] = delete1[i]-1;
            change2[i] = change1[i];
        end

    end
end

//sorting 3
always @(*) begin
    t00 = new_value2;
    t01 = sorted2[2];
    t02 = sorted2[3];
end
always @ (*) begin
    if (t00[11:5]<=t01[11:5]) begin
        sorted3[0] = t00;
        sorted3[1] = t01;
        sorted3[2] = t02;

    end 
    else if(t00[11:5]<=t02[11:5])begin
        sorted3[0] = t01;
        sorted3[1] = t00;
        sorted3[2] = t02;

    end
    else begin
        sorted3[0] = t01;
        sorted3[1] = t02;
        sorted3[2] = t00;
    end
end

/*
//stage 1
always @(*) begin
    if (t00<= t01) begin
        t10 = t00;
        t11 = t01;
    end
    else begin
        t10 = t01;
        t11 = t00;
    end
    t12 = t02;
end
//stage 2
always @(*) begin
    if (t11<= t12) begin
        t21 = t11;
        t22 = t12;
    end
    else begin
        t21 = t12;
        t22 = t11;
    end
    t20 = t10;
end
//stage 3 
always @(*) begin
    if (t20<=t21) begin
        sorted3[0] = t20;
        sorted3[1] = t21;
    end
    else begin
        sorted3[0] = t21;
        sorted3[1] = t20;
    end
end
*/
//end of sorting 3 things
//dealing with the result of sorting 3
always @(*) begin
        new_value3[12:5] = sorted3[0][11:5] + sorted3[1][11:5];

        //record who are merged to new_value1
        new_value3[4:0] = sorted3[0][4:0] | sorted3[1][4:0];
end

always @(*) // the most min
begin
    for (int i = 0 ; i<=4;i++) begin
        code3[i] = code2[i];
    end

    if (sorted3[0][0] == 1 ) begin // a
        code3[0][change2[0]] = 0;
    end
    else if (sorted3[1][0] == 1) begin
        code3[0][change2[0]] = 1;
    end
    else begin
        code3[0][delete2[0]] = 0;
    end

    if (sorted3[0][1] == 1 ) begin // b
        code3[1][change2[1]] = 0;
    end
    else if (sorted3[1][1] == 1) begin
        code3[1][change2[1]] = 1;
    end
    else begin
        code3[1][delete2[1]] = 0;
    end

    if (sorted3[0][2] == 1 ) begin // c
        code3[2][change2[2]] = 0;
    end
    else if (sorted3[1][2] == 1) begin
        code3[2][change2[2]] = 1;
    end
    else begin
        code3[2][delete2[2]] = 0;
    end

    if (sorted3[0][3] == 1 ) begin // d
        code3[3][change2[3]] = 0;
    end
    else if (sorted3[1][3] == 1) begin
        code3[3][change2[3]] = 1;
    end
    else begin
        code3[3][delete2[3]] = 0;
    end
    if (sorted3[0][4] == 1 ) begin // e
        code3[4][change2[4]] = 0;
    end
    else if (sorted3[1][4] == 1) begin
        code3[4][change2[4]] = 1;
    end
    else begin
        code3[4][delete2[4]] = 0;
    end
end
always @(*) begin

    for(int i=0;i<=4;i++)begin
        if (sorted3[0][i] == 1 || sorted3[1][i] ==1 ) begin //sorted3[0][0] = value 1 represent a 
            change3[i] = change2[i] +1;
            delete3[i] = delete2[i];
        end
        else begin // if not the msb should be change to 0
            delete3[i] = delete2[i]-1;
            change3[i] = change2[i];
        end

    end
end
//final two values merge
/*
always @(*) begin
    last_site = sorted3[0][4:0] | sorted3[1][4:0];
    //don't care about the value
end
*/
//2 sorting
always @(*) begin
    final1 = sorted3[2];
    final0 = new_value3;

    if (final0[12:5] <= final1[12:5]) begin
        sorted4[0] = final0;
        sorted4[1] = final1;
    end
    else begin
        sorted4[0] = final1;
        sorted4[1] = final0;
    end

end

always @(*) // the most min and the second min
begin
    for (int i = 0 ; i<=4;i++) begin
        code4[i] = code3[i];
    end

    if (sorted4[0][0] == 1 ) begin // a
        code4[0][change3[0]] = 0;
    end
    else if (sorted4[1][0] == 1) begin
        code4[0][change3[0]] = 1;
    end
    else begin
        code4[0][delete3[0]] = 0;
    end

    if (sorted4[0][1] ==1 ) begin // b
        code4[1][change3[1]] = 0;
    end
    else if (sorted4[1][1] ==1 ) begin
        code4[1][change3[1]] = 1;
    end
    else begin
        code4[1][delete3[1]] = 0;
    end

    if (sorted4[0][2] ==1 ) begin // c
        code4[2][change3[2]] = 0;
    end
    else if (sorted4[1][2] ==1 ) begin
        code4[2][change3[2]] = 1;
    end
    else begin
        code4[2][delete3[2]] = 0;
    end

    if (sorted4[0][3] ==1 ) begin // d
        code4[3][change3[3]] = 0;
    end
    else if (sorted4[1][3] ==1) begin
        code4[3][change3[3]] = 1;
    end
    else begin
        code4[3][delete3[3]] = 0;
    end

    if (sorted4[0][4] == 1 ) begin // e
        code4[4][change3[4]] = 0;
    end
    else if (sorted4[1][4] == 1) begin
        code4[4][change3[4]] = 1;
    end
    else begin
        code4[4][delete3[4]] = 0;
    end
end
always@ (*) begin
    out_encoded = {code4[0],code4[1],code4[2],code4[3],code4[4]};
end


endmodule
