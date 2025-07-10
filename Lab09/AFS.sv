//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2025/4
//		Version		: v1.0
//   	File Name   : AFS.sv
//   	Module Name : AFS
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module AFS(input clk, INF.AFS_inf inf);
import usertype::*;
//==============================================//
//              logic declaration               //
// ============================================ //
typedef enum logic [3:0] {
    IDLE = 0,
    PURCHASE_CHECK = 1,
    RESTOCK = 2,
    READ_HANDSHAKE = 3,
    READ = 4,
    WAIT = 5,
    WARN_CHECK = 6,
    CAL_UPDATE = 7,
    WRITE_HANDSHAKE = 8, 
    WRITE = 9,
    WRITE_FINISH = 10,
    OUT = 11
} state;
state cur_state, nxt_state;
//d_state d_cur_state, d_nxt_state;  

Action cur_action;
Strategy_Type cur_strategy;
Mode cur_mode;
Date cur_date; // month day
logic [11:0] restock_rose, restock_lily, restock_carnation, restock_baby;
Data_No cur_data_no;
Data_Dir cur_dram_info; // stock of rose, lily, carnation, baby

logic complete_reg, complete_reg_ns;
logic out_valid_reg, out_valid_reg_ns;
Warn_Msg warn_msg_reg, warn_msg_reg_ns;

// counter
logic [1:0] restock_cnt, restock_cnt_ns;
// write back to DRAM
logic [11:0] update_rose, update_lily, update_carnation, update_baby;

logic read_finish;
logic restock_read;
// -------------------------------------------------
//                    MAIN FSM
// -------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        cur_state <= IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end
always_comb begin
    nxt_state = cur_state;
    case(cur_state)
    /*
        IDLE: begin
            if (inf.sel_action_valid) begin
                nxt_state = PURCHASE_CHECK;
            end
        end
        */
        IDLE: begin
            if (inf.data_no_valid) begin
                nxt_state = READ_HANDSHAKE;
            end
        end
        READ_HANDSHAKE: begin
            if (inf.AR_READY) begin
                nxt_state = READ; 
            end
        end
        READ: begin
            if (read_finish) begin
                if (cur_action == Restock && !(restock_read)) begin
                    nxt_state = WAIT;
                end
                else begin
                    nxt_state = WARN_CHECK; // WRITE_HANDSHAKE
                end
            end
        end
        WAIT: begin
            if (restock_read) begin
                nxt_state = WARN_CHECK;
            end
        end
        WARN_CHECK: begin
            nxt_state = CAL_UPDATE;
        end
        CAL_UPDATE: begin
            case(cur_action)
                Purchase: nxt_state = (!complete_reg)? OUT: WRITE_HANDSHAKE;
                Restock: nxt_state = WRITE_HANDSHAKE;
                Check_Valid_Date: nxt_state = OUT;
                default: nxt_state = cur_state;
            endcase

        end
        WRITE_HANDSHAKE: begin
            if (inf.AW_READY) begin
                nxt_state = WRITE;
            end            
        end
        WRITE: begin
            if (inf.W_READY) begin
                nxt_state = WRITE_FINISH;
            end
        end
        WRITE_FINISH: begin
            if (inf.B_VALID) begin
                nxt_state = OUT;
            end
        end        
        OUT: begin
            nxt_state = IDLE;
        end
    endcase
end
// -------------------------------------------------
//                    INPUT
// -------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        cur_action <= 0;
    end
    else begin
        if (inf.sel_action_valid) begin
            cur_action <= inf.D.d_act[0];
        end
        else begin
            cur_action <= cur_action;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        cur_strategy <= 0;
    end
    else begin
        if (inf.strategy_valid) begin
            cur_strategy <= inf.D.d_strategy[0];
        end
        else begin
            cur_strategy <= cur_strategy;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        cur_mode <= 0;
    end
    else begin
        if (inf.mode_valid) begin
            cur_mode <= inf.D.d_mode[0];
        end
        else begin
            cur_mode <= cur_mode;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        cur_date <= 0;
    end
    else begin
        if (inf.date_valid) begin
            cur_date <= inf.D.d_date[0];
        end
        else begin
            cur_date <= cur_date;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        cur_data_no <= 0;
    end
    else begin
        if (inf.data_no_valid) begin
            cur_data_no <= inf.D.d_data_no[0];
        end
        else begin
            cur_data_no <= cur_data_no;
        end
    end
end
// **************** FOR RESTOCK ***************
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        restock_rose <= 0;
    end
    else begin
        if (inf.restock_valid && restock_cnt == 0) begin
            restock_rose <= inf.D.d_stock[0];
        end
        else begin
            restock_rose <= restock_rose;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        restock_lily <= 0;
    end
    else begin
        if (inf.restock_valid && restock_cnt == 1) begin
            restock_lily <= inf.D.d_stock[0];
        end
        else begin
            restock_lily <= restock_lily;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        restock_carnation <= 0;
    end
    else begin
        if (inf.restock_valid && restock_cnt == 2) begin
            restock_carnation <= inf.D.d_stock[0];
        end
        else begin
            restock_carnation <= restock_carnation;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        restock_baby <= 0;
    end
    else begin
        if (inf.restock_valid && restock_cnt == 3) begin
            restock_baby <= inf.D.d_stock[0];
        end
        else begin
            restock_baby <= restock_baby;
        end
    end
end
// -------------------------------------------------
//                    COUNTER
// -------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        restock_cnt <= 0;
    end 
    else begin
        if (cur_state == IDLE) begin
            restock_cnt <= 0;
        end
        else if (cur_action == Restock) begin
            if (inf.restock_valid) begin
                restock_cnt <= restock_cnt + 1;
            end
            else begin
                restock_cnt <= restock_cnt;
            end
        end
        else begin
            restock_cnt <= 0;
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        restock_read <= 0;
    end
    else begin
        if (cur_state == OUT) begin //IDLE
            restock_read <= 0;
        end 
        else if (restock_cnt == 3 && inf.restock_valid) begin
            restock_read <= 1;
        end
        else begin
            restock_read <= restock_read;
        end
    end
end
// -------------------------------------------------
//                DRAM read signal 
// -------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.AR_VALID <= 0;
    end
    else begin
        if (nxt_state == READ_HANDSHAKE) begin
            inf.AR_VALID <= 1;
        end
        else begin
            inf.AR_VALID <= 0;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.R_READY <= 0;
    end
    else begin
        if (nxt_state == READ) begin
            inf.R_READY <= 1;
        end
        else begin
            inf.R_READY <= 0;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.AR_ADDR <= 0;
    end
    else begin
        //if (nxt_state == READ_HANDSHAKE) begin
            inf.AR_ADDR <= {4'b1, 5'b0, cur_data_no, 3'b0};
        //end
        /*
        else begin
            inf.AR_ADDR <= 0;
        end
        */
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        cur_dram_info.Rose <= 0;
        cur_dram_info.Lily <= 0;
        cur_dram_info.Carnation <= 0;
        cur_dram_info.Baby_Breath <= 0;
        cur_dram_info.M <= 0;
        cur_dram_info.D <= 0;
    end
    else begin 
        if (inf.R_VALID) begin //&& inf.R_READY
            cur_dram_info.Rose <= inf.R_DATA[63:52];
            cur_dram_info.Lily <= inf.R_DATA[51:40];
            cur_dram_info.Carnation <= inf.R_DATA[31:20];
            cur_dram_info.Baby_Breath <= inf.R_DATA[19:8];
            cur_dram_info.M <= inf.R_DATA[35:32];
            cur_dram_info.D <= inf.R_DATA[4:0];        
        end
        else if (cur_state == IDLE) begin
            cur_dram_info.Rose <= 0;
            cur_dram_info.Lily <= 0;
            cur_dram_info.Carnation <= 0;
            cur_dram_info.Baby_Breath <= 0;
            cur_dram_info.M <= 0;
            cur_dram_info.D <= 0;        
        end
        else begin
            cur_dram_info.Rose <= cur_dram_info.Rose;
            cur_dram_info.Lily <= cur_dram_info.Lily;
            cur_dram_info.Carnation <= cur_dram_info.Carnation;
            cur_dram_info.Baby_Breath <= cur_dram_info.Baby_Breath;
            cur_dram_info.M <= cur_dram_info.M;
            cur_dram_info.D <= cur_dram_info.D;         
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        read_finish <= 0;
    end  
    else if(inf.R_VALID) begin
        read_finish <= 1;
    end
    else if(cur_state == IDLE) begin
        read_finish <= 0;
    end
end
// ---------------------------------------
//                consumed 
// ---------------------------------------
logic [9:0] consume_rose, consume_lily, consume_carnation, consume_baby;
always_ff @(posedge clk) begin
    /*
    if (!inf.rst_n) begin
        consume_rose <= 0;
    end
    */
    //else begin
        case(cur_strategy)
            Strategy_A: begin consume_rose <= (cur_mode == Single) ? 120 : (cur_mode == Group_Order? 480 : 960);end
            Strategy_E: begin consume_rose <= (cur_mode == Single) ? 60  : (cur_mode == Group_Order? 240 : 480); end
            Strategy_G: begin consume_rose <= (cur_mode == Single) ? 60  : (cur_mode == Group_Order? 240 : 480); end
            Strategy_H: begin consume_rose <= (cur_mode == Single) ? 30  : (cur_mode == Group_Order? 120 : 240); end
            default: consume_rose <= 0;
        endcase
        
    //end
end
always_ff @(posedge clk ) begin
    /*
    if (!inf.rst_n) begin
        consume_lily <= 0;
    end
    else begin
    */
        case(cur_strategy)
            Strategy_B: begin consume_lily <= (cur_mode == Single) ? 120 : (cur_mode == Group_Order? 480 : 960);end
            Strategy_E: begin consume_lily <= (cur_mode == Single) ? 60  : (cur_mode == Group_Order? 240 : 480); end
            Strategy_H: begin consume_lily <= (cur_mode == Single) ? 30  : (cur_mode == Group_Order? 120 : 240); end
            default: consume_lily <= 0;
        endcase
        
    //end
end
always_ff @(posedge clk) begin
    /*
    if (!inf.rst_n) begin
        consume_carnation <= 0;
    end
    else begin
    */
        case(cur_strategy)
            Strategy_C: begin consume_carnation <= (cur_mode == Single) ? 120 : (cur_mode == Group_Order? 480 : 960);end
            Strategy_F: begin consume_carnation <= (cur_mode == Single) ? 60  : (cur_mode == Group_Order? 240 : 480); end
            Strategy_G: begin consume_carnation <= (cur_mode == Single) ? 60  : (cur_mode == Group_Order? 240 : 480); end
            Strategy_H: begin consume_carnation <= (cur_mode == Single) ? 30  : (cur_mode == Group_Order? 120 : 240); end
            default: consume_carnation <= 0;
        endcase
        
    //end
end
always_ff @(posedge clk) begin
    /*
    if (!inf.rst_n) begin
        consume_baby <= 0;
    end
    else begin
    */
        case(cur_strategy)
            Strategy_D: begin consume_baby <= (cur_mode == Single) ? 120 : (cur_mode == Group_Order? 480 : 960);end
            Strategy_F: begin consume_baby <= (cur_mode == Single) ? 60  : (cur_mode == Group_Order? 240 : 480); end
            Strategy_H: begin consume_baby <= (cur_mode == Single) ? 30  : (cur_mode == Group_Order? 120 : 240); end
            default: consume_baby <= 0;
        endcase
    //end
end
// ---------------------------------------
//                total 
// ---------------------------------------
logic date_warn_flag;
logic stock_warn_flag;
logic restock_warn_flag;
logic [12:0] total_rose, total_lily, total_carnation, total_baby;

always_ff @(posedge clk) begin
    /*
    if (!inf.rst_n) begin
        total_rose <= 0;
        total_lily <= 0;
        total_carnation <= 0;
        total_baby <= 0;
    end
    else begin
    */
        total_rose <= cur_dram_info.Rose + restock_rose;
        total_lily <= cur_dram_info.Lily + restock_lily;
        total_carnation <= cur_dram_info.Carnation + restock_carnation;
        total_baby <= cur_dram_info.Baby_Breath + restock_baby;         
    //end
end

logic [11:0] minus_rose, minus_lily, minus_carnation, minus_baby;
always_ff @(posedge clk) begin
    /*
    if (!inf.rst_n) begin
        minus_rose <= 0;
        minus_lily <= 0;
        minus_carnation <= 0;
        minus_baby <= 0;
    end
    
    else begin
    */
        minus_rose <= cur_dram_info.Rose - consume_rose;
        minus_lily <= cur_dram_info.Lily - consume_lily;
        minus_carnation <= cur_dram_info.Carnation - consume_carnation;
        minus_baby <= cur_dram_info.Baby_Breath - consume_baby;      
    //end
end
always_ff @(posedge clk) begin
    
    if (!inf.rst_n) begin
        update_rose <= 0;
        update_lily <= 0;
        update_carnation <= 0;
        update_baby <= 0;
    end
    else if (cur_state == CAL_UPDATE) begin
        if (!date_warn_flag && !stock_warn_flag && cur_action == Purchase) begin 
            update_rose <= minus_rose;
            update_lily <= minus_lily;
            update_carnation <= minus_carnation;
            update_baby <= minus_baby;
        end
        else if (cur_action == Restock) begin
            update_rose <= (total_rose[12] == 1) ? 4095: total_rose;
            update_lily <= (total_lily[12] == 1) ? 4095: total_lily;
            update_carnation <= (total_carnation[12] == 1) ? 4095: total_carnation;
            update_baby <= (total_baby[12] == 1) ? 4095: total_baby;            
        end
        else begin
            update_rose <= cur_dram_info.Rose ;
            update_lily <= cur_dram_info.Lily ;
            update_carnation <= cur_dram_info.Carnation ;
            update_baby <= cur_dram_info.Baby_Breath;       
        end        
    end
end

// -------------------------------------------------
//                     WARN 
// -------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.out_valid <= 0;
    end
    else if (cur_state == OUT) begin
        inf.out_valid <= 1;       
    end
    else begin
        inf.out_valid <= 0;        
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.complete <= 0;
        inf.warn_msg <= No_Warn;
    end
    else if (cur_state == OUT) begin
        inf.complete <= complete_reg;
        inf.warn_msg <= warn_msg_reg;        
    end
    else begin
        inf.complete <= 0;
        inf.warn_msg <= No_Warn;        
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        date_warn_flag <= 0;
    end
    else if((cur_state == WARN_CHECK) &&((cur_date.M < cur_dram_info.M) || (cur_date.M == cur_dram_info.M && cur_date.D < cur_dram_info.D)) )begin
        date_warn_flag <= 1;
    end
    else if (cur_state == IDLE) begin
        date_warn_flag <= 0;
    end
    else begin
        date_warn_flag <= date_warn_flag;
    end
end
logic rose_lack, lily_lack, carnation_lack, baby_lack;
assign rose_lack = (cur_dram_info.Rose < consume_rose)? 1:0;
assign lily_lack = (cur_dram_info.Lily < consume_lily)? 1:0;
assign carnation_lack = (cur_dram_info.Carnation < consume_carnation )? 1:0;
assign baby_lack = (cur_dram_info.Baby_Breath < consume_baby)? 1:0;


always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        stock_warn_flag <= 0;
    end
    else if ((cur_state == WARN_CHECK) && (rose_lack || lily_lack ||carnation_lack || baby_lack)) begin
        stock_warn_flag <= 1;
    end
    else if (cur_state == IDLE) begin
        stock_warn_flag <= 0;
    end
    else begin
        stock_warn_flag <= stock_warn_flag;
    end
end
logic limit1, limit2, limit_final;
assign limit1 = (total_rose[12] == 1 || total_lily[12] == 1);
assign limit2 = (total_carnation[12] == 1 || total_baby[12] == 1);
assign limit_final = limit1 || limit2;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        restock_warn_flag <= 0;
    end
    else if ((cur_state == WARN_CHECK) && limit_final) begin
        restock_warn_flag <= 1;
    end
    else if (cur_state == IDLE) begin
        restock_warn_flag <= 0;
    end
    else begin
        restock_warn_flag <= restock_warn_flag;
    end
end
always_comb begin
    warn_msg_reg = No_Warn;
    complete_reg = 0;
    case(cur_action)
        Purchase: begin
            if (date_warn_flag) begin
                warn_msg_reg = Date_Warn;
                complete_reg = 0;                
            end
            else if (stock_warn_flag) begin
                warn_msg_reg = Stock_Warn;
                complete_reg = 0;   
            end
            else begin
                warn_msg_reg = No_Warn;
                complete_reg = 1;                
            end
        end
        Restock: begin
            if (restock_warn_flag) begin
                warn_msg_reg = Restock_Warn;
                complete_reg = 0;                
            end
            else begin
                warn_msg_reg = No_Warn;
                complete_reg = 1;                
            end  
        end
        Check_Valid_Date: begin
            if (date_warn_flag) begin
                warn_msg_reg = Date_Warn;
                complete_reg = 0;                
            end
            else begin
                warn_msg_reg = No_Warn;
                complete_reg = 1;                
            end            
        end
    endcase
end
// -------------------------------------------------
//                DRAM write signal 
// -------------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.AW_VALID <= 0;
    end
    else begin
        if (nxt_state == WRITE_HANDSHAKE) begin
            inf.AW_VALID <= 1;
        end
        else begin
            inf.AW_VALID <= 0;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.AW_ADDR <= 0;
    end
    else begin
        //if (d_nxt_state == WRITE_HANDSHAKE) begin
            inf.AW_ADDR <= {4'b1, 5'b0, cur_data_no, 3'b0};
        //end
        //else begin
        //    inf.AW_ADDR <= 0;
        //end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.W_VALID <= 0;
    end
    else begin
        if (nxt_state == WRITE) begin
            inf.W_VALID <= 1;
        end
        else begin
            inf.W_VALID <= 0;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.B_READY <= 0;
    end
    else begin
        if (nxt_state == WRITE_FINISH) begin
            inf.B_READY <= 1;
        end
        else begin
            inf.B_READY <= 0;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin 
    if (!inf.rst_n) begin
        inf.W_DATA <= 0;
    end
    else begin
        //if (d_nxt_state == WRITE) begin
            if (cur_action == Restock) begin
                inf.W_DATA <= {update_rose, update_lily, 4'b0, cur_date.M, update_carnation, update_baby, 3'b0, cur_date.D};
            end
            else begin
                inf.W_DATA <= {update_rose, update_lily, 4'b0, cur_dram_info.M, update_carnation, update_baby, 3'b0, cur_dram_info.D};
            end
        //end
        //else begin
        //    inf.W_DATA <= 0;
        //end
    end
end
endmodule



