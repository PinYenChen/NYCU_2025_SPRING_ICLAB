/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2025 Spring IC Design Laboratory 
Lab09: SystemVerilog Design and Verification 
File Name   : PATTERN.sv
Module Name : PATTERN
Release version : v1.0 (Release Date: April-2025)
//   (Strategy_C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
// `include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;
//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter CYCLE = 15; // your ct
parameter PAT_NUM = 4500;
parameter SEED = 5487;
integer i_pat, i, j, latency, total_latency, out_num;
//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  // 32 box
reg[10*8:1] txt_blue_prefix   = "\033[1;34m";
reg[10*8:1] txt_green_prefix  = "\033[1;32m";
reg[9*8:1]  reset_color       = "\033[1;0m";
Action input_action;
Strategy_Type input_strategy;
Mode input_mode;
Date input_date;
Data_No input_data_no;
Stock input_rose, input_lily, input_carnation, input_baby;

Stock DRAM_rose, DRAM_lily, DRAM_carnation, DRAM_baby;
Date DRAM_date;
Stock update_rose, update_lily, update_carnation, update_baby;
Date expire_date;
Warn_Msg golden_warn;
logic golden_complete;
//================================================================
// class random
//================================================================

/**
 * Class representing a random action.
 */
class random_act;
    randc Action act_id;
    constraint range{
        act_id inside{Purchase, Restock, Check_Valid_Date};
    }
    function new(int seed);
        this.srandom(seed);
    endfunction
endclass
class random_strategy;
    randc Strategy_Type strategy_rand;
    constraint range{
        strategy_rand inside {Strategy_A,Strategy_B,Strategy_C,Strategy_D,Strategy_E,Strategy_F,Strategy_G,Strategy_H};
    }
    function new(int seed);
        this.srandom(seed);
    endfunction
endclass
class random_mode;
    randc Mode mode_rand;
    constraint range{
        mode_rand inside {Single, Group_Order, Event};
    }
    function new(int seed);
        this.srandom(seed);
    endfunction
endclass
class random_date;
    randc Date date_rand;
    constraint limit{
        date_rand.M inside{[1:12]};
        if (date_rand.M==1||date_rand.M==3||date_rand.M==5||date_rand.M==7||date_rand.M==8||date_rand.M==10||date_rand.M==12)
            date_rand.D inside{[1:31]};
        else if (date_rand.M==4||date_rand.M==6||date_rand.M==9||date_rand.M==11)
            date_rand.D inside{[1:30]};
        else if (date_rand.M==2)
            date_rand.D inside{[1:28]};          
    }
    function new(int seed);
        this.srandom(seed);
    endfunction
endclass
class random_data_no;
    randc Data_No data_no_rand;
    constraint range{
        data_no_rand inside {[0:4095]};
    }
    function new(int seed);
        this.srandom(seed);
    endfunction
endclass
class random_restock_amount;
    randc Stock restock_amount_rand;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint limit{
        restock_amount_rand inside{[0:4095]};
    }
endclass
random_act action_rnd;
random_strategy strategy_rnd;
random_mode mode_rnd;
random_date date_rnd;
random_data_no data_no_rnd;
random_restock_amount restock_amount_rnd;
//================================================================
// initial
//================================================================

initial begin
    $readmemh(DRAM_p_r,golden_DRAM);
    
    action_rnd = new(SEED);
    strategy_rnd = new(SEED);
    mode_rnd = new(SEED);
    date_rnd = new(SEED);
    data_no_rnd = new(SEED);
    restock_amount_rnd = new(SEED);
    
    reset_task;
    @(negedge clk);
    for(i_pat = 0 ; i_pat < PAT_NUM ; i_pat++)begin
        golden_warn = No_Warn;
        golden_complete = 1'b1;
        input_task;
        load_DRAM;
        cal_ans_task;
        wait_out_valid_task;
        check_ans_task;
        $display("%0sPASS PATTERN NO.%4d %0sCycles: %3d%0s",txt_blue_prefix, i_pat, txt_green_prefix, latency, reset_color);

    end
    YOU_PASS_task;
end
task reset_task; 
    //valid signal
    inf.rst_n = 1'b1;
    inf.sel_action_valid = 1'b0;
    inf.strategy_valid = 1'b0;
    inf.mode_valid = 1'b0;
    inf.date_valid = 1'b0;
    inf.data_no_valid = 1'b0;
    inf.restock_valid = 1'b0;

    // data signal
    inf.D = 72'bx;
    #CYCLE; inf.rst_n = 1'b0; 
    #CYCLE; inf.rst_n = 1'b1;   
    total_latency = 0;
    if (inf.out_valid === 1 || inf.warn_msg === 1 || inf.complete === 1 || inf.AR_VALID===1|| |inf.AR_ADDR===1 || inf.R_READY===1 ||inf.AW_VALID===1|| |inf.AW_ADDR===1||inf.W_VALID===1|| |inf.W_DATA===1 ||inf.B_READY===1) begin
        $display ("                             Reset Task Fail                         ");
        repeat (2) #CYCLE;
        $finish;
    end
    #CYCLE;
endtask
task input_task;

// --------------------------------------------
//                 Action input
// --------------------------------------------
    inf.sel_action_valid = 1'b1;
    
    if (i_pat >= 0 && i_pat <= 1799) begin
        input_action = Purchase;
    end 
    else if (i_pat >= 1800 && i_pat <= 2399) begin
        if (i_pat % 2 == 0) begin
            input_action = Check_Valid_Date;
        end
        else begin
            input_action = Purchase;
        end
    end
    else if (i_pat >= 2400 && i_pat <= 2999) begin
        if (i_pat % 2 == 0) begin
            input_action = Restock;
        end
        else begin
            input_action = Purchase;
        end        
    end
    else if (i_pat >= 3000 && i_pat <= 3299) begin
        input_action = Check_Valid_Date;
    end
    else if (i_pat >= 3300 && i_pat <= 3899) begin
        if (i_pat % 2 == 0) begin
            input_action = Restock;
        end
        else begin
            input_action = Check_Valid_Date;
        end  
    end
    else if (i_pat >= 3900 && i_pat <= 4199) begin
        input_action = Restock;
    end
    else begin
        i = action_rnd.randomize();
        input_action = action_rnd.act_id;
    end
    inf.D = input_action;
    @(negedge clk)
    inf.sel_action_valid = 1'b0;
    inf.D ='bx;

consume_table;
// --------------------------------------------
//              Strategy input
// --------------------------------------------
    if(input_action == Purchase)begin
        if (i_pat >= 0 && i_pat <=299) begin
            input_strategy = Strategy_A;
        end
        else if (i_pat >= 300 && i_pat <= 599) begin
            input_strategy = Strategy_B;
        end
        else if (i_pat >= 600 && i_pat <= 899) begin
            input_strategy = Strategy_C;
        end
        else if (i_pat >= 900 && i_pat <= 1199) begin
            input_strategy = Strategy_D;
        end
        else if (i_pat >= 1200 && i_pat <= 1499) begin
            input_strategy = Strategy_E;
        end
        else if (i_pat >= 1500 && i_pat <= 1799) begin
            input_strategy = Strategy_F;
        end
        else if (i_pat >= 1800 && i_pat <= 2399) begin
            input_strategy = Strategy_G;
        end
        else if (i_pat >= 2400 && i_pat <= 2999) begin
            input_strategy = Strategy_H;
        end
        
        else begin
            i = strategy_rnd.randomize();
            input_strategy = strategy_rnd.strategy_rand;            
        end
    end
    repeat($urandom_range(0, 3)) @(negedge clk);
    inf.strategy_valid = 1'b1;
    inf.D = input_strategy;
    @(negedge clk)
    inf.strategy_valid = 1'b0;
    inf.D ='bx;
// --------------------------------------------
//                Mode input
// --------------------------------------------    
    if ((i_pat >= 0 && i_pat <= 99) || (i_pat >= 300 && i_pat <= 399) || (i_pat >= 600 && i_pat <= 699) || (i_pat >= 900 && i_pat <= 999) || (i_pat >= 1200 && i_pat <= 1299) || (i_pat >= 1500 && i_pat <= 1599) || (i_pat >= 1800 && i_pat <= 1999) || (i_pat >= 2400 && i_pat <= 2599)) begin
        input_mode = Single;
    end
    else if ((i_pat >= 100 && i_pat <= 199) || (i_pat >= 400 && i_pat <= 499) || (i_pat >= 700 && i_pat <= 799) || (i_pat >= 1000 && i_pat <= 1099) || (i_pat >= 1300 && i_pat <= 1399) || (i_pat >= 1600 && i_pat <= 1699) || (i_pat >= 2000 && i_pat <= 2199) || (i_pat >= 2600 && i_pat <= 2799)) begin
        input_mode = Group_Order;
    end
    else if ((i_pat >= 200 && i_pat <= 299) || (i_pat >= 500 && i_pat <= 599) || (i_pat >= 800 && i_pat <= 899) || (i_pat >= 1100 && i_pat <= 1199) || (i_pat >= 1400 && i_pat <= 1499) || (i_pat >= 1700 && i_pat <= 1799) || (i_pat >= 2200 && i_pat <= 2399) || (i_pat >= 2800 && i_pat <= 2999)) begin
        input_mode = Event;
    end
    else begin
        i = mode_rnd.randomize();
        input_mode = mode_rnd.mode_rand; 
    end
    repeat($urandom_range(0, 3)) @(negedge clk);
    inf.mode_valid = 1'b1;
    inf.D = input_mode;
    @(negedge clk)
    inf.mode_valid = 1'b0;
    inf.D = 'bx;
// --------------------------------------------
//                Date input
// -------------------------------------------- 
    if(i_pat >= 0 && i_pat <=9)begin
        input_date.M = 4'd8;
        input_date.D = 5'd28;
    end
    else if (i_pat >= 100 && i_pat <= 299) begin
        input_date.M = 4'd12;
        input_date.D = 5'd31;
    end
    else if(i_pat == 2101)begin
        input_date.M = 4'd12;
        input_date.D = 5'd31;
    end
    else if((i_pat >= 300) && (i_pat <= 2999))begin
        input_date.M = 4'd4;
        input_date.D = 5'd10;
    end
    else begin
        i = date_rnd.randomize();
        input_date = date_rnd.date_rand;
    end  
    repeat($urandom_range(0, 3)) @(negedge clk);
    inf.date_valid = 1'b1;
    inf.D = input_date;
    @(negedge clk)
    inf.date_valid = 1'b0;
    inf.D ='bx; 
// --------------------------------------------
//                Data_no input
// --------------------------------------------  
    if (i_pat >= 0 && i_pat <=9) begin
        input_data_no = 8'd100;
    end
    else if (i_pat >= 10 && i_pat <= 2999) begin
        if (input_action == Check_Valid_Date) begin
            input_data_no = 8'd123;
        end
        else begin
            input_data_no = 8'd5;
        end
    end
    else if (i_pat == 2101) begin
        input_data_no = 8'd0;
    end
    else begin
        i = data_no_rnd.randomize();
        input_data_no = data_no_rnd.data_no_rand;        
    end   
    repeat($urandom_range(0, 3)) @(negedge clk);
    inf.data_no_valid = 1'b1;
    inf.D = input_data_no;
    @(negedge clk)
    inf.data_no_valid = 1'b0;
    inf.D = 'bx;
// --------------------------------------------
//                Restock input
// --------------------------------------------     
    if (input_action == Restock) begin
        if (i_pat >= 0 && i_pat <=9) begin
            input_rose = 4095;
        end
        else if (i_pat == 2101) begin
            input_rose = 0;
        end
        else if (i_pat >= 3900 && i_pat <= 3999) begin
            input_lily = 4095;
        end
        else begin
            i = restock_amount_rnd.randomize();
            input_rose = restock_amount_rnd.restock_amount_rand;
        end
        repeat($urandom_range(0, 3)) @(negedge clk);
        inf.restock_valid = 1'b1;
        inf.D = input_rose;
        @(negedge clk)
        inf.restock_valid = 1'b0;
        inf.D = 'bx;
    end
    if (input_action == Restock) begin
        if (i_pat >= 0 && i_pat <=9) begin
            input_lily = 1139;
        end
        else if (i_pat == 2101) begin
            input_lily = 0;
        end
        else if (i_pat >= 3900 && i_pat <= 3999) begin
            input_lily = 4095;
        end
        else begin
            i = restock_amount_rnd.randomize();
            input_lily = restock_amount_rnd.restock_amount_rand;
        end
        repeat($urandom_range(0, 3)) @(negedge clk);
        inf.restock_valid = 1'b1;
        inf.D = input_lily;
        @(negedge clk)
        inf.restock_valid = 1'b0;
        inf.D = 'bx;        
    end     
    if (input_action == Restock) begin
        if (i_pat >= 0 && i_pat <=9) begin
            input_carnation = 1823;
        end
        else if (i_pat == 2101) begin
            input_carnation = 0;
        end
        else if (i_pat >= 3900 && i_pat <= 3999) begin
            input_carnation = 4095;
        end
        else begin
            i = restock_amount_rnd.randomize();
            input_carnation = restock_amount_rnd.restock_amount_rand;
        end
        repeat($urandom_range(0, 3)) @(negedge clk);
        inf.restock_valid = 1'b1;
        inf.D = input_carnation;
        @(negedge clk)
        inf.restock_valid = 1'b0;
        inf.D = 'bx;        
    end 
    if (input_action == Restock) begin
        if (i_pat >= 0 && i_pat <=9) begin
            input_baby = 1724;
        end
        else if (i_pat == 2101) begin
            input_baby = 0;
        end
        else if (i_pat >= 3900 && i_pat <= 3999) begin
            input_baby = 4095;
        end
        else begin
            i = restock_amount_rnd.randomize();
            input_baby = restock_amount_rnd.restock_amount_rand;
        end
        repeat($urandom_range(0, 3)) @(negedge clk);
        inf.restock_valid = 1'b1;
        inf.D = input_baby;
        @(negedge clk)
        inf.restock_valid = 1'b0;
        inf.D = 'bx;        
    end  
endtask
task send_strategy_type_task;
    i = strategy_rnd.randomize();
    input_strategy = strategy_rnd.strategy_rand;
    inf.strategy_valid = 1'b1;
    inf.D = input_strategy;
    @(negedge clk)
    inf.strategy_valid = 1'b0;
    inf.D ='bx;
endtask
task send_mode_task;
    i = mode_rnd.randomize();
    input_mode = mode_rnd.mode_rand;
    inf.mode_valid = 1'b1;
    inf.D = input_mode;
    @(negedge clk)
    inf.mode_valid = 1'b0;
    inf.D = 'bx;
endtask
task send_date_task;
    i = date_rnd.randomize();
    input_date = date_rnd.date_rand;
    inf.date_valid = 1'b1;
    inf.D = input_date;
    @(negedge clk)
    inf.date_valid = 1'b0;
    inf.D ='bx;
endtask
task send_data_no_task;
    i = data_no_rnd.randomize();
    input_data_no = data_no_rnd.data_no_rand;
    inf.data_no_valid = 1'b1;
    inf.D = input_data_no;
    @(negedge clk)
    inf.data_no_valid = 1'b0;
    inf.D = 'bx;
endtask
task send_flower_task;
    i = restock_amount_rnd.randomize();
    input_rose = restock_amount_rnd.restock_amount_rand;
    inf.restock_valid = 1'b1;
    inf.D = input_rose;
    @(negedge clk)
    inf.restock_valid = 1'b0;
    inf.D = 'bx;

    i = restock_amount_rnd.randomize();
    input_lily = restock_amount_rnd.restock_amount_rand;
    inf.restock_valid = 1'b1;
    inf.D = input_lily;
    @(negedge clk)
    inf.restock_valid = 1'b0;
    inf.D = 'bx;

    i = restock_amount_rnd.randomize();
    input_carnation = restock_amount_rnd.restock_amount_rand;
    inf.restock_valid = 1'b1;
    inf.D = input_carnation;
    @(negedge clk)
    inf.restock_valid = 1'b0;
    inf.D = 'bx;

    i = restock_amount_rnd.randomize();
    input_baby = restock_amount_rnd.restock_amount_rand;
    inf.restock_valid = 1'b1;
    inf.D = input_baby;
    @(negedge clk)
    inf.restock_valid = 1'b0;
    inf.D = 'bx;
endtask

task load_DRAM;
    DRAM_rose  =    {golden_DRAM[65536 + 8*input_data_no+7]       , golden_DRAM[65536 + 8*input_data_no + 6][7:4]};
    DRAM_lily  =    {golden_DRAM[65536 + 8*input_data_no + 6][3:0], golden_DRAM[65536 + 8*input_data_no + 5]} ;
    DRAM_carnation= {golden_DRAM[65536 + 8*input_data_no + 3]     , golden_DRAM[65536 + 8*input_data_no + 2][7:4]};
    DRAM_baby  =    {golden_DRAM[65536 + 8*input_data_no + 2][3:0], golden_DRAM[65536 + 8*input_data_no + 1]}; 
    DRAM_date.D   = {golden_DRAM[65536 + 8*input_data_no][4:0]};
    DRAM_date.M   = {golden_DRAM[65536 + 8*input_data_no + 4][3:0]};
endtask

task cal_ans_task;
    golden_complete = 1;
    golden_warn = No_Warn;
    update_rose = DRAM_rose;    
    update_lily = DRAM_lily;
    update_carnation = DRAM_carnation;
    update_baby = DRAM_baby;
    expire_date = DRAM_date;
    case(input_action)
        Purchase: begin
            if (input_date. M < DRAM_date.M || ((input_date.M == DRAM_date.M) && input_date.D < DRAM_date.D)) begin
                golden_complete = 0;
                golden_warn = Date_Warn;
            end
            else begin
                case(input_strategy)
                    Strategy_A: begin
                        case(input_mode)
                            Single: begin
                                if (DRAM_rose < 120) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end
                            Group_Order: begin
                                if (DRAM_rose < 480) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end
                            Event: begin
                                if (DRAM_rose < 960) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end
                        endcase
                    end
                    Strategy_B:begin
                        case(input_mode)
                            Single: begin
                                if (DRAM_lily < 120) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end
                            Group_Order: begin
                                if (DRAM_lily < 480) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end
                            Event: begin
                                if (DRAM_lily < 960) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end            
                        endcase
                    end
                    Strategy_C:begin
                        case(input_mode)
                            Single: begin
                                if (DRAM_carnation < 120) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end
                            Group_Order: begin
                                if (DRAM_carnation < 480) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end
                            Event: begin
                                if (DRAM_carnation < 960) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end               
                        endcase
                    end
                    Strategy_D:begin
                        case(input_mode)
                            Single: begin
                                if (DRAM_baby < 120) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end
                            Group_Order: begin
                                if (DRAM_baby < 480) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end
                            Event: begin
                                if (DRAM_baby < 960) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                        
                                end
                            end           
                        endcase
                    end
                    Strategy_E:begin
                        case(input_mode)
                            Single: begin
                                if (DRAM_rose <60 || DRAM_lily < 60) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end
                            Group_Order:begin
                                if (DRAM_rose <240 || DRAM_lily < 240) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end
                            Event: begin
                                if (DRAM_rose <480 || DRAM_lily < 480) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end           
                        endcase
                    end
                    Strategy_F:begin
                        case(input_mode)
                            Single: begin
                                if (DRAM_carnation <60 || DRAM_baby < 60) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end
                            Group_Order:begin
                                if (DRAM_carnation <240 || DRAM_baby < 240) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end
                            Event: begin
                                if (DRAM_carnation <480 || DRAM_baby < 480) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end           
                        endcase
                    end
                    Strategy_G:begin
                        case(input_mode)
                            Single: begin
                                if (DRAM_rose <60 || DRAM_carnation < 60) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end
                            Group_Order:begin
                                if (DRAM_rose <240 || DRAM_carnation < 240) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end
                            Event: begin
                                if (DRAM_rose <480 || DRAM_carnation < 480) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end           
                        endcase
                    end
                    Strategy_H:begin
                        case(input_mode)
                            Single: begin
                                if (DRAM_rose <30 || DRAM_lily < 30 || DRAM_carnation <30 || DRAM_baby < 30) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end
                            Group_Order:begin
                                if (DRAM_rose <120 || DRAM_lily < 120 || DRAM_carnation <120 || DRAM_baby < 120) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end
                            Event: begin
                                if (DRAM_rose <240 || DRAM_lily < 240 || DRAM_carnation <240 || DRAM_baby < 240) begin
                                    golden_complete = 0;
                                    golden_warn = Stock_Warn;                         
                                end
                            end           
                        endcase
                    end
                endcase 
            end
            if(golden_warn === No_Warn && golden_complete === 1)begin
                case(input_strategy)
                    Strategy_A: begin
                    case(input_mode)
                        Single: begin
                            update_rose = DRAM_rose - 120;
                        end
                        Group_Order: begin
                            update_rose = DRAM_rose - 480;
                        end
                        Event: begin
                            update_rose = DRAM_rose - 960;
                        end
                    endcase
                    end
                    Strategy_B:begin
                    case(input_mode)
                        Single: begin
                            update_lily = DRAM_lily - 120;
                        end
                        Group_Order: begin
                            update_lily = DRAM_lily - 480;
                        end
                        Event: begin
                            update_lily = DRAM_lily - 960;
                        end
                    endcase
                    end
                    Strategy_C:begin
                    case(input_mode)
                        Single: begin
                            update_carnation = DRAM_carnation - 120;
                        end
                        Group_Order: begin
                            update_carnation = DRAM_carnation - 480;
                        end
                        Event: begin
                            update_carnation = DRAM_carnation - 960;
                        end
                    endcase
                    end
                    Strategy_D:begin
                    case(input_mode)
                        Single: begin
                            update_baby = DRAM_baby - 120;
                        end
                        Group_Order: begin
                            update_baby = DRAM_baby - 480;
                        end
                        Event: begin
                            update_baby = DRAM_baby - 960;
                        end
                    endcase
                    end
                    Strategy_E:begin
                    case(input_mode)
                        Single: begin
                            update_rose = DRAM_rose - 60;
                            update_lily = DRAM_lily - 60;
                        end
                        Group_Order: begin
                            update_rose = DRAM_rose - 240;
                            update_lily = DRAM_lily - 240;
                        end
                        Event: begin
                            update_rose = DRAM_rose - 480;
                            update_lily = DRAM_lily - 480;
                        end
                    endcase
                    end
                    Strategy_F:begin
                    case(input_mode)
                        Single: begin
                            update_carnation = DRAM_carnation - 60;
                            update_baby = DRAM_baby- 60;
                        end
                        Group_Order: begin
                            update_carnation = DRAM_carnation - 240;
                            update_baby = DRAM_baby- 240;
                        end
                        Event: begin
                            update_carnation = DRAM_carnation - 480;
                            update_baby = DRAM_baby- 480;
                        end
                    endcase
                    end
                    Strategy_G:begin
                    case(input_mode)
                        Single: begin
                            update_rose = DRAM_rose - 60;
                            update_carnation = DRAM_carnation - 60;
                        end
                        Group_Order: begin
                            update_rose = DRAM_rose - 240;
                            update_carnation = DRAM_carnation - 240;
                        end
                        Event: begin
                            update_rose = DRAM_rose - 480;
                            update_carnation = DRAM_carnation - 480;
                        end
                    endcase
                    end
                    Strategy_H:begin
                    case(input_mode)
                        Single: begin
                            update_rose = DRAM_rose - 30;
                            update_lily = DRAM_lily - 30;
                            update_carnation = DRAM_carnation - 30;
                            update_baby = DRAM_baby - 30;

                        end
                        Group_Order: begin
                            update_rose = DRAM_rose - 120;
                            update_lily = DRAM_lily - 120;
                            update_carnation = DRAM_carnation - 120;
                            update_baby = DRAM_baby - 120;
                        end
                        Event: begin
                            update_rose = DRAM_rose - 240;
                            update_lily = DRAM_lily - 240;
                            update_carnation = DRAM_carnation - 240;
                            update_baby = DRAM_baby - 240;
                        end
                    endcase
                    end
                endcase
            end         
        end
        Restock:begin
            expire_date = input_date;
            if (DRAM_rose + input_rose > 4095) begin
                update_rose = 4095;
                golden_complete = 0;
                golden_warn = Restock_Warn;
            end
            else begin
                update_rose = DRAM_rose + input_rose;           
            end
            if (DRAM_lily + input_lily > 4095) begin
                update_lily = 4095;
                golden_complete = 0;
                golden_warn = Restock_Warn;
            end
            else begin
                update_lily = DRAM_lily + input_lily;           
            end        
            if (DRAM_carnation + input_carnation > 4095) begin
                update_carnation = 4095;
                golden_complete = 0;
                golden_warn = Restock_Warn;
            end
            else begin
                update_carnation = DRAM_carnation + input_carnation;           
            end
            if (DRAM_baby + input_baby > 4095) begin
                update_baby = 4095;
                golden_complete = 0;
                golden_warn = Restock_Warn;
            end
            else begin
                update_baby = DRAM_baby + input_baby;           
            end
        end
        Check_Valid_Date: begin
            if (input_date. M < DRAM_date.M || ((input_date.M == DRAM_date.M) && input_date.D < DRAM_date.D)) begin
                golden_complete = 0;
                golden_warn = Date_Warn;
            end            
        end
    endcase
    // Write back to DRAM
    {golden_DRAM[65536 + 8*input_data_no+7]       , golden_DRAM[65536 + 8*input_data_no + 6][7:4]} = update_rose;
    {golden_DRAM[65536 + 8*input_data_no + 6][3:0], golden_DRAM[65536 + 8*input_data_no + 5]}      = update_lily ;
    {golden_DRAM[65536 + 8*input_data_no + 3]     , golden_DRAM[65536 + 8*input_data_no + 2][7:4]} = update_carnation;
    {golden_DRAM[65536 + 8*input_data_no + 2][3:0], golden_DRAM[65536 + 8*input_data_no + 1]}      = update_baby; 
    {golden_DRAM[65536 + 8*input_data_no][4:0]}     = expire_date.D;
    {golden_DRAM[65536 + 8*input_data_no + 4][3:0]} = expire_date.M;    


endtask
logic [9:0] consume_rose, consume_lily, consume_carnation, consume_baby;
task consume_table;
    consume_rose = 0;
    case(input_strategy)
        Strategy_A: begin consume_rose = (input_mode == Single) ? 120 : (input_mode == Group_Order? 480 : 960);end
        Strategy_E: begin consume_rose = (input_mode == Single) ? 60  : (input_mode == Group_Order? 240 : 480); end
        Strategy_G: begin consume_rose = (input_mode == Single) ? 60  : (input_mode == Group_Order? 240 : 480); end
        Strategy_H: begin consume_rose = (input_mode == Single) ? 30  : (input_mode == Group_Order? 120 : 240); end
    endcase
    consume_lily = 0;
    case(input_strategy)
        Strategy_B: begin consume_lily = (input_mode == Single) ? 120 : (input_mode == Group_Order? 480 : 960);end
        Strategy_E: begin consume_lily = (input_mode == Single) ? 60  : (input_mode == Group_Order? 240 : 480); end
        Strategy_H: begin consume_lily = (input_mode == Single) ? 30  : (input_mode == Group_Order? 120 : 240); end
    endcase
    consume_carnation = 0;
    case(input_strategy)
        Strategy_C: begin consume_carnation = (input_mode == Single) ? 120 : (input_mode == Group_Order? 480 : 960);end
        Strategy_F: begin consume_carnation = (input_mode == Single) ? 60  : (input_mode == Group_Order? 240 : 480); end
        Strategy_G: begin consume_carnation = (input_mode == Single) ? 60  : (input_mode == Group_Order? 240 : 480); end
        Strategy_H: begin consume_carnation = (input_mode == Single) ? 30  : (input_mode == Group_Order? 120 : 240); end
    endcase
    consume_baby = 0;
    case(input_strategy)
        Strategy_D: begin consume_baby = (input_mode == Single) ? 120 : (input_mode == Group_Order? 480 : 960);end
        Strategy_F: begin consume_baby = (input_mode == Single) ? 60  : (input_mode == Group_Order? 240 : 480); end
        Strategy_H: begin consume_baby = (input_mode == Single) ? 30  : (input_mode == Group_Order? 120 : 240); end
    endcase

endtask
task wait_out_valid_task;
    latency = 0;
    while(inf.out_valid !== 1)begin
        latency = latency + 1;
        if(latency == 1000* CYCLE)begin
            $display("                       over 1000 cycles                       ");
            repeat (2) @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
endtask
task check_ans_task;
    out_num = 1;
    while(inf.out_valid === 1) begin
        if(inf.warn_msg !== golden_warn || inf.complete !== golden_complete)begin
            $display("                      Wrong Answer                    ");
            //repeat (2) @(negedge clk);
            //$finish;            
            
            $display ("Cur_action is %s %0s %s      ",txt_blue_prefix, input_action, reset_color);
            if (input_action == Restock) begin
                $display("GOLDEN %s %0s %s", txt_blue_prefix, golden_warn, reset_color);
                $display("GOLDEN ROSE %4d + %4d = %4d " ,DRAM_rose, input_rose, DRAM_rose + input_rose);
                $display("GOLDEN LILY %4d + %4d = %4d" ,DRAM_lily, input_lily, DRAM_lily + input_lily);
                $display("GOLDEN CARN %4d + %4d = %4d" ,DRAM_carnation, input_carnation, DRAM_carnation + input_carnation);
                $display("GOLDEN BABY %4d + %4d = %4d" ,DRAM_baby, input_baby, DRAM_baby + input_baby);
                $display("YOUR   %s %0s %s", txt_green_prefix, inf.warn_msg, reset_color);
            
                repeat (2) @(negedge clk);
                $finish;
            end
            else if (input_action == Purchase) begin
                $display ("Cur_strategy is %s %0s %s", txt_blue_prefix,input_strategy,  reset_color);
                $display ("Cur_mode is %s %0s %s    ", txt_blue_prefix, input_mode, reset_color);
                $display("GOLDEN %s %0s %s", txt_blue_prefix, golden_warn, reset_color);
                $display("Today date is %2d,%2d, and DRAM date is %2d,%2d", input_date.M, input_date.D,DRAM_date.M,DRAM_date.D );
                $display("NEED CONSUME ROSE %4d , but have %4d " ,consume_rose, DRAM_rose);
                $display("NEED CONSUME LILY %4d , but have %4d " ,consume_lily, DRAM_lily);
                $display("NEED CONSUME CARN %4d , but have %4d " ,consume_carnation, DRAM_carnation);
                $display("NEED CONSUME BABY %4d , but have %4d " ,consume_baby, DRAM_baby);
                $display("YOUR   %s %0s %s", txt_green_prefix, inf.warn_msg, reset_color);
                repeat (2) @(negedge clk);
                $finish;                
            end
            else begin
                $display("GOLDEN %s %0s %s", txt_blue_prefix, golden_warn, reset_color);
                $display("YOUR   %s %0s %s", txt_green_prefix, inf.warn_msg, reset_color);
                repeat (2) @(negedge clk);
                $finish;                 
            end
                            
    	end
        @(negedge clk);
        if(out_num > 1) begin
            $display("                 out_valid should be high for 1 cycle                   ");
            $finish;
        end
        else begin
            @(negedge clk);
            out_num = out_num + 1;
        end
    end
endtask
task YOU_PASS_task;begin
    
$display ("----------------------------------------------------------------------------------------------------------------------");
$display ("                                                  Congratulations                                                     ");
$display ("                                           You have passed all patterns!                                              ");
$display ("                                                                                                                      ");
$display ("                                        Your execution cycles   = %5d cycles                                          ", total_latency);
$display ("----------------------------------------------------------------------------------------------------------------------");

//$display("                      Congratulations                    ");
$finish;
end endtask

endprogram