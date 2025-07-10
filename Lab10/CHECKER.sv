/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2025 Spring IC Design Laboratory 
Lab10: SystemVerilog Coverage & Assertion
File Name   : CHECKER.sv
Module Name : CHECKER
Release version : v1.0 (Release Date: May-2025)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype.sv"
module Checker(input clk, INF.CHECKER inf);
import usertype::*;

// integer fp_w;

// initial begin
// fp_w = $fopen("out_valid.txt", "w");
// end

/**
 * This section contains the definition of the class and the instantiation of the object.
 *  * 
 * The always_ff blocks update the object based on the values of valid signals.
 * When valid signal is true, the corresponding property is updated with the value of inf.D
 */

class Strategy_and_mode;
    Strategy_Type f_type;
    Mode f_mode;
endclass

Strategy_and_mode fm_info = new();

Action cur_action;

always_ff @(posedge clk) begin
    if(inf.strategy_valid) begin
        fm_info.f_type = inf.D.d_strategy[0];
    end
    if(inf.mode_valid) begin
        fm_info.f_mode = inf.D.d_mode[0];
    end
    if(inf.sel_action_valid) begin
        cur_action = inf.D.d_act[0];
    end
end
// -----------------------------------------------
//                      SPEC1
// Each case of Strategy_Type should be select at least 100 times.
// -----------------------------------------------
covergroup SPEC1 @(posedge clk iff(inf.strategy_valid));
    option.per_instance = 1;
    option.at_least = 100;
    strategy_cover: coverpoint inf.D.d_strategy[0]
    {
        bins bins_strategy [] = {Strategy_A, Strategy_B, Strategy_C, Strategy_D, Strategy_E, Strategy_F, Strategy_G, Strategy_H};
    }
endgroup

// -----------------------------------------------
//                      SPEC2
// Each case of Mode should be select at least 100 times.
// -----------------------------------------------
covergroup SPEC2 @(posedge clk iff(inf.mode_valid));
    option.per_instance = 1;
    option.at_least = 100;
    mode_cover: coverpoint inf.D.d_mode[0]
    {
        bins bins_mode [] = {Single, Group_Order, Event};
    }
endgroup
// -----------------------------------------------
//                      SPEC3
//  Create a cross bin for the SPEC1 and SPEC2. Each combination should be selected at least 100 times. 
//  (Strategy_A,B,C,D,E,F,G,H) x (Single, Group_Order, Event)
// -----------------------------------------------
covergroup SPEC3 @(negedge clk iff(inf.mode_valid));
    option.per_instance = 1;
    option.at_least = 100;
    cross fm_info.f_type,fm_info.f_mode;
endgroup
// -----------------------------------------------
//                      SPEC4
// Output signal inf.err_msg should be“No_Warn”,“Date_Warn”,“Stock_Warn“,”Restock_Warn”,each at least 10 times. (Sample the value when inf.out_valid is high)
// -----------------------------------------------
covergroup SPEC4 @(negedge clk iff(inf.out_valid));
    option.per_instance = 1;
    option.at_least = 10;
    warn_cover: coverpoint inf.warn_msg{
        bins bins_warn [] = {No_Warn, Date_Warn, Stock_Warn, Restock_Warn};
    }
endgroup
// -----------------------------------------------
//                      SPEC5
// Create the transitions bin for the inf.D.act[0] signal from [Purchase:Check_Valid_Date] to
// [Purchase:Check_Valid_Date]. Each transition should be hit at least 300 times. (sample the value
// at posedge clk iff inf.sel_action_valid)
// -----------------------------------------------
covergroup SPEC5 @(posedge clk iff(inf.sel_action_valid));
    option.per_instance = 1;
    option.at_least = 300;
    action_cover: coverpoint inf.D.d_act[0]{
        bins bins_action_change [] = ([Purchase:Check_Valid_Date] => [Purchase:Check_Valid_Date]);
    }
endgroup
// -----------------------------------------------
//                      SPEC6
// Create a covergroup for material of supply action with auto_bin_max = 32, and each bin have to hit at least one time.
// -----------------------------------------------
covergroup SPEC6 @(posedge clk iff(inf.restock_valid));
	option.at_least = 1;
	option.per_instance = 1;
	stock_cover: coverpoint inf.D.d_stock[0]{
		option.auto_bin_max = 32;
	}
endgroup 

SPEC1 strategy_conv = new();
SPEC2 mode_cov = new();
SPEC3 cross_cov=new();
SPEC4 warm_conv = new();
SPEC5 action_change_conv = new();
SPEC6 restock_conv = new();

// -----------------------------------------------
//                      Assertion 1
// All outputs signals (including AFS.sv) should be zero after reset.
// -----------------------------------------------
always @(negedge inf.rst_n) begin
    #(2);
    assert_1: assert((inf.out_valid === 0) && (inf.warn_msg === No_Warn) && (inf.complete === 0) && (inf.AR_VALID === 0) && (inf.AR_ADDR === 0) && (inf.R_READY === 0) && (inf.AW_VALID === 0) &&
                    (inf.AW_ADDR === 0) && (inf.W_VALID === 0) && (inf.W_DATA === 0) && (inf.B_READY === 0))
    else begin
		$fatal(0,"Assertion 1 is violated");
    end 
end

// -----------------------------------------------
//                      Assertion 2
// Latency should be less than 1000 cycles for each operation.
// -----------------------------------------------
assert_2_1: assert property (latency_purchase_check)
else begin
    $fatal(0,"Assertion 2 is violated");
end 

property latency_purchase_check;
    @(posedge clk) ((cur_action === Purchase || cur_action === Check_Valid_Date) && inf.data_no_valid) |-> (##[1:1000] inf.out_valid);
endproperty

assert_2_2: assert property (latency_restock)
else begin
    $fatal(0,"Assertion 2 is violated");
end 
logic [1:0] stock_cnt;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        stock_cnt <= 0; 
    end
    else begin
        if (inf.restock_valid) begin
            stock_cnt <= stock_cnt + 1;
        end
    end
end
property latency_restock;
    @(posedge clk) ((cur_action === Restock) && inf.restock_valid && stock_cnt === 3) |-> (##[1:1000] inf.out_valid);
endproperty
// -----------------------------------------------
//                      Assertion 3
// If action is completed (complete=1), warn_msg should be 2’b0 (No_Warn).
// -----------------------------------------------
assert_3: assert property (complete_warn)
else begin
    $fatal(0,"Assertion 3 is violated");
end 

property complete_warn;
    @(negedge clk) (inf.complete === 1) |-> (inf.warn_msg === No_Warn);
endproperty
// -----------------------------------------------
//                      Assertion 4
// Next input valid will be valid 1-4 cycles after previous input valid fall.
// -----------------------------------------------
assert_4_1: assert property(purchase_case)
else begin
    $fatal(0,"Assertion 4 is violated");
end 
property purchase_case;
    @(posedge clk) (inf.sel_action_valid === 1 && inf.D.d_act[0] === Purchase) |-> (##[1:4] inf.strategy_valid ##[1:4] inf.mode_valid ##[1:4] inf.date_valid ##[1:4] inf.data_no_valid);
endproperty

assert_4_2: assert property(restock_case)
else begin
    $fatal(0,"Assertion 4 is violated");
end 
property restock_case;
    @(posedge clk) (inf.sel_action_valid === 1 && inf.D.d_act[0] === Restock) |-> (##[1:4] inf.date_valid ##[1:4] inf.data_no_valid ##[1:4] inf.restock_valid ##[1:4] inf.restock_valid ##[1:4] inf.restock_valid ##[1:4] inf.restock_valid);
endproperty

assert_4_3: assert property(check_case)
else begin
    $fatal(0,"Assertion 4 is violated");
end 
property check_case;
    @(posedge clk) (inf.sel_action_valid === 1 && inf.D.d_act[0] === Check_Valid_Date) |-> (##[1:4] inf.date_valid ##[1:4] inf.data_no_valid);
endproperty

// -----------------------------------------------
//                      Assertion 5
// All input valid signals won’t overlap with each other.
// -----------------------------------------------
assert_5_1: assert property(sel_action_valid)
else begin
    $fatal(0,"Assertion 5 is violated");
end 
property sel_action_valid;
    @ (posedge clk) (inf.sel_action_valid === 1) |-> ((inf.strategy_valid === 0) && (inf.mode_valid === 0) && (inf.date_valid === 0) && (inf.data_no_valid === 0) && (inf.restock_valid === 0));
endproperty

assert_5_2: assert property(strategy_valid)
else begin
    $fatal(0,"Assertion 5 is violated");
end 
property strategy_valid;
    @ (posedge clk) (inf.strategy_valid === 1) |-> ((inf.sel_action_valid === 0) && (inf.mode_valid === 0) && (inf.date_valid === 0) && (inf.data_no_valid === 0) && (inf.restock_valid === 0));
endproperty

assert_5_3: assert property(mode_valid)
else begin
    $fatal(0,"Assertion 5 is violated");
end 
property mode_valid;
    @ (posedge clk) (inf.mode_valid === 1) |-> ((inf.sel_action_valid === 0) && (inf.strategy_valid === 0) && (inf.date_valid === 0) && (inf.data_no_valid === 0) && (inf.restock_valid === 0));
endproperty

assert_5_4: assert property(date_valid)
else begin
    $fatal(0,"Assertion 5 is violated");
end 
property date_valid;
    @ (posedge clk) (inf.date_valid === 1) |-> ((inf.sel_action_valid === 0) && (inf.mode_valid === 0) && (inf.strategy_valid === 0) && (inf.data_no_valid === 0) && (inf.restock_valid === 0));
endproperty

assert_5_5: assert property(data_no_valid)
else begin
    $fatal(0,"Assertion 5 is violated");
end 
property data_no_valid;
    @ (posedge clk) (inf.data_no_valid === 1) |-> ((inf.sel_action_valid === 0) && (inf.mode_valid === 0) && (inf.strategy_valid === 0) && (inf.date_valid === 0) && (inf.restock_valid === 0));
endproperty

assert_5_6: assert property(restock_valid)
else begin
    $fatal(0,"Assertion 5 is violated");
end 
property restock_valid;
    @ (posedge clk) (inf.restock_valid === 1) |-> ((inf.sel_action_valid === 0) && (inf.mode_valid === 0) && (inf.strategy_valid === 0) && (inf.date_valid === 0) && (inf.data_no_valid === 0));
endproperty
// -----------------------------------------------
//                      Assertion 6
//  Out_valid can only be high for exactly one cycle.
// -----------------------------------------------
assert_6: assert property(out_valid)
else begin
    $fatal(0,"Assertion 6 is violated");
end 
property out_valid;
    @(posedge clk) (inf.out_valid === 1) |=> (inf.out_valid === 0);
endproperty
// -----------------------------------------------
//                      Assertion 7
// Next operation will be valid 1-4 cycles after out_valid fall
// -----------------------------------------------

assert_7: assert property(nxt_pattern)
else begin
    $fatal(0,"Assertion 7 is violated");
end 
property nxt_pattern;
    @(posedge clk) (inf.out_valid === 1) |-> (##[1:4] inf.sel_action_valid);
endproperty

// -----------------------------------------------
//                      Assertion 8
// The input date from pattern should adhere to the real calendar. (ex: 2/29, 3/0, 4/31, 13/1 are illegal cases)
// -----------------------------------------------
/*
assert_8_1: assert property(feb_check)
else begin
    $fatal(0,"Assertion 8 is violated");
end 
property feb_check;
    @(negedge clk) (inf.date_valid === 1 && inf.D.d_date[0].M === 2) |-> (inf.D.d_date[0].D >= 1 && inf.D.d_date[0].D <= 28);
endproperty

assert_8_2: assert property(big_check)
else begin
    $fatal(0,"Assertion 8 is violated");
end 
property big_check;
    @(negedge clk) 
    (inf.date_valid === 1 && (inf.D.d_date[0].M === 1 || inf.D.d_date[0].M === 3 || inf.D.d_date[0].M === 5 || inf.D.d_date[0].M === 7 || inf.D.d_date[0].M === 8 || inf.D.d_date[0].M === 10 || inf.D.d_date[0].M === 12)) 
    |-> (inf.D.d_date[0].D >= 1 && inf.D.d_date[0].D <= 31);
endproperty

assert_8_3: assert property(small_check)
else begin
    $fatal(0,"Assertion 8 is violated");
end 
property small_check;
    @(negedge clk) 
    (inf.date_valid === 1 && (inf.D.d_date[0].M === 4 || inf.D.d_date[0].M === 6 || inf.D.d_date[0].M === 9 || inf.D.d_date[0].M === 11)) 
    |-> (inf.D.d_date[0].D >= 1 && inf.D.d_date[0].D <= 30);
endproperty
*/
assert_8 : assert property(date_check)
else  begin
    $fatal(0,"Assertion 8 is violated");
end
property date_check;
    @(negedge clk) ( inf.date_valid===1 |-> 
    ((inf.D.d_date[0].M === 1 || inf.D.d_date[0].M === 3 || inf.D.d_date[0].M === 5 || inf.D.d_date[0].M === 7 || inf.D.d_date[0].M === 8 || inf.D.d_date[0].M === 10 || inf.D.d_date[0].M === 12)&&(1 <= inf.D.d_date[0].D && inf.D.d_date[0].D <= 31))
    ||
     ((inf.D.d_date[0].M === 4 || inf.D.d_date[0].M === 6 || inf.D.d_date[0].M === 9 || inf.D.d_date[0].M === 11 )&&(1 <= inf.D.d_date[0].D && inf.D.d_date[0].D <= 30))
    ||
     ((inf.D.d_date[0].M === 2)&&(1 <= inf.D.d_date[0].D && inf.D.d_date[0].D <= 28))   
    );
endproperty

// -----------------------------------------------
//                      Assertion 9
// The AR_VALID signal should not overlap with the AW_VALID signal.
// -----------------------------------------------
assert_9: assert property(arvalid_awvalid)
else begin
    $fatal(0,"Assertion 9 is violated");
end 
property arvalid_awvalid;
    @(posedge clk) (inf.AR_VALID === 1) |-> (inf.AW_VALID === 0);
endproperty
endmodule