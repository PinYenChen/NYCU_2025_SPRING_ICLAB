module MAZE(
    // input
    input clk,
    input rst_n,
	input in_valid,
	input [1:0] in,

    // output
    output reg out_valid,
    output reg [1:0] out
);
// --------------------------------------------------------------
// Reg & Wire
// --------------------------------------------------------------
typedef enum reg[2:0]{IDLE = 3'd0,EXPAND = 3'd1,BACK = 3'd2,DONE = 3'd3,FIND_SWORD = 3'd4, BACK_SWORD = 3'd5, IDLE_SWORD = 3'd7}state;
state state_cur,state_ns;


reg [1:0] map [0:16][0:16];
reg [1:0] map_ns [0:16][0:16];
reg [2:0] cumulate1,cumulate2,cumulate3,cumulate4;

reg [5:0] column, column_ns;
reg [5:0] row, row_ns; //0-16
//reg [5:0] back_x, back_x_ns;
//reg [5:0] back_y, back_y_ns; //0-16
reg [4:0] queue0_x [0:16];
reg [4:0] queue0_y [0:16];
reg [4:0] queue0_x_ns [0:16];
reg [4:0] queue0_y_ns [0:16];
reg [4:0] queue1_x [0:16];
reg [4:0] queue1_y [0:16];
reg [4:0] queue1_x_ns [0:16];
reg [4:0] queue1_y_ns [0:16];
reg [7:0] depth [0:16][0:16];
reg [7:0] depth_ns [0:16][0:16];
reg [7:0] deep, deep_ns;

reg visited [0:16][0:16];
reg visited_ns [0:16][0:16];
reg [4:0] cnt_queue0, cnt_queue1; 
reg [4:0] cnt_queue0_ns, cnt_queue1_ns; 
reg [4:0] ori_queue0;
reg [4:0] ori_queue1;
reg [4:0] ori_queue0_ns;
reg [4:0] ori_queue1_ns;

reg flag, flag_ns;

reg has_sword_monster, has_sword_monster_ns;
reg [1:0] out_reg [0:430],out_reg_ns[0:430]; //right:0, down:1, left:2, up:3
reg [4:0]back_x,back_y;
reg [4:0]back_x_ns,back_y_ns;
reg [8:0] out_reg_cnt,out_reg_cnt_ns;
reg sequence_queue, sequence_queue_ns;
//reg find;
reg [4:0] cur_x, cur_y;
reg [4:0] find_cur_x,find_cur_y;
reg [2:0] find_cumulate1,find_cumulate2,find_cumulate3,find_cumulate4;

//reg [8:0] keep_deep, keep_deep_ns;
reg [8:0] keep_total, keep_total_ns;
//reg [8:0] cnt_back, cnt_back_ns;

reg [8:0] back_length, back_length_ns;
reg [8:0] back_cnt, back_cnt_ns;
//reg [8:0] print_count, print_count_ns;
integer i,j;
// --------------------------------------------------------------
// Design
// --------------------------------------------------------------
reg[4:0] sword_site_x,sword_site_y;
reg[4:0] sword_site_x_ns, sword_site_y_ns;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sword_site_x <= 0;
        sword_site_y <= 0;
    end
    else begin
        sword_site_x <= sword_site_x_ns;
        sword_site_y <= sword_site_y_ns;
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        print_count <= 0;
    end
    else begin
        print_count <= print_count_ns;
        
    end
end
*/
reg flag_start, flag_start_ns;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        
        flag_start <= 1;
    end
    else begin
        
        flag_start <= flag_start_ns;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        back_length <= 0;
    end
    else begin
        back_length <= back_length_ns;
        
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        keep_total <= 0;
    end
    else begin
        keep_total <= keep_total_ns;
        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        back_cnt <= 0;
    end
    else begin
        back_cnt <= back_cnt_ns;
        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0 ; i < 17 ; i++) begin
            for (j = 0 ; j < 17 ; j++) begin
                map[i][j] <= 0;    
            end
        end

    end
    else begin
        for (i = 0 ; i < 17 ; i++) begin
            for (j = 0 ; j < 17 ; j++) begin
                map[i][j] <= map_ns[i][j];   
            end
        end        
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0 ; i < 17 ; i++) begin
            for (j = 0 ; j < 17 ; j++) begin
                visited[i][j] <= 0;    
            end
        end
    end
    else begin
        for (i = 0 ; i < 17 ; i++) begin
            for (j = 0 ; j < 17 ; j++) begin
                visited[i][j] <= visited_ns[i][j];   
            end
        end        
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0 ; i < 17 ; i++) begin
            for (j = 0 ; j < 17 ; j++) begin
                depth[i][j] <= 0;    
            end
        end

    end
    else begin
        for (i = 0 ; i < 17 ; i++) begin
            for (j = 0 ; j < 17 ; j++) begin
                depth[i][j] <= depth_ns[i][j];   
            end
        end        
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        deep <= 0;

    end
    else  begin
        deep <= deep_ns;

    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_back <= 0;

    end
    else  begin
        cnt_back <= cnt_back_ns;

    end
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sequence_queue <= 0;

    end
    else  begin
        sequence_queue <= sequence_queue_ns;

    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        has_sword_monster <= 0;
    end
    else  begin
        has_sword_monster <= has_sword_monster_ns;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        row <= 0;
        column <= 0;
    end
    else  begin
        row <= row_ns;
        column <= column_ns ;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i<17; i++) begin
            queue0_x[i] <= 0;
            queue0_y[i] <= 0;
        end
    end
    else begin
        for (i = 0; i<17;i++) begin
            queue0_x[i] <= queue0_x_ns[i];
            queue0_y[i] <= queue0_y_ns[i]; 
        end     
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i<17; i++) begin
            queue1_x[i] <= 0;
            queue1_y[i] <= 0;
        end
    end
    else begin
        for (i = 0; i<17;i++) begin
            queue1_x[i] <= queue1_x_ns[i];
            queue1_y[i] <= queue1_y_ns[i]; 
        end    
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_queue0 <= 0;
        cnt_queue1 <= 0;
    end
    else begin
        cnt_queue0 <= cnt_queue0_ns;
        cnt_queue1 <= cnt_queue1_ns;     
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ori_queue0 <= 1; //originally there is a zero in the queue0
        ori_queue1 <= 0; //originally there is no element in the queue1
    end
    else begin
        ori_queue0 <= ori_queue0_ns;
        ori_queue1 <= ori_queue1_ns;
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0 ;i<430;i++) begin
            out_reg[i] <= 0;
        end
    end
    else begin
        for (i = 0;i<430;i++) begin
            out_reg[i] <=out_reg_ns[i];
        end
    end
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_reg_cnt<=0;
    end
    else begin
        out_reg_cnt <= out_reg_cnt_ns;
    end
end

always @(negedge rst_n or posedge clk) begin
    if (!rst_n) begin
        state_cur = IDLE;
    end
    else begin
        state_cur = state_ns;
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        keep_deep <= 0;
    end
    else begin
        keep_deep <= keep_deep_ns;
    end
end
*/

// ------------------------
// NS_Transition
// ------------------------
always @(*) begin
    case(state_cur) 
        IDLE:begin
            if (row == 16 && column == 16) begin // the input is over
                state_ns = EXPAND;
            end
            else begin
                state_ns = state_cur;
            end
        end

        EXPAND : begin
            if (cur_x == 16 && cur_y == 16) begin
                
                state_ns = BACK;
            end
            else begin
                state_ns = state_cur;
            end
        end
        BACK: begin
            if (deep == 0 && has_sword_monster == 0) begin
                state_ns = DONE;
            end
            else if (deep == 0 && has_sword_monster == 1) begin //has to find the sword
                state_ns = IDLE_SWORD;
            end
            else begin
                state_ns = state_cur;
            end
        end
        DONE: begin
            if (out_reg_cnt == 0) begin
                state_ns = IDLE;
            end
            else begin
                state_ns = state_cur;
            end
        end
        IDLE_SWORD: begin
            state_ns = FIND_SWORD;
        end
        FIND_SWORD : begin
            if (map[find_cur_x][find_cur_y] == 2) begin
                state_ns = BACK_SWORD;
            end
            else begin
                state_ns = state_cur;
            end
        end
        BACK_SWORD: begin
            if (deep == 0) begin
                state_ns = DONE;
            end
            else begin
                state_ns = state_cur;
            end
        end
        default: state_ns = state_cur;
    endcase 
end

// ------------------------
// Output Control
// ------------------------

always @(*) begin
    for (i = 0; i < 17 ; i++) begin
        for (j = 0; j < 17 ; j++) begin
            map_ns[i][j] = map[i][j];
        end
    end
    case (state_cur) 
        IDLE: begin
                
            if (in_valid) begin
                map_ns [row][column] = in;
            end
            else begin
                for (i = 0; i < 17 ; i++) begin
                    for (j = 0; j < 17 ; j++) begin
                        map_ns[i][j] = map[i][j];
                    end
                end
            end
                         
        end
    endcase
end
always@(*)begin
    case (state_cur) 
        IDLE: begin 
            if (in_valid) begin
                if (column == 16) begin
                    row_ns = row + 1;
                    column_ns = 0;
                end
                else begin 
                    row_ns = row;
                    column_ns = column + 1;
                end
            end
            else begin
                row_ns = 0;
                column_ns = 0;
            end
                         
        end
        default: begin 
            row_ns = 0;
            column_ns = 0;
        end
    endcase
end

always @(*) begin
    //combinational
    cumulate1 = 0;
    cumulate2 = 0;
    cumulate3 = 0;
    cumulate4 = 0;
    cur_x=0;
    cur_y=0;
    find_cumulate1 = 0;
    find_cumulate2 = 0;
    find_cumulate3 = 0;
    find_cumulate4 = 0;
    find_cur_x = 0;
    find_cur_y = 0;
    //sequential
    sequence_queue_ns = sequence_queue;
    cnt_queue0_ns = cnt_queue0;
    cnt_queue1_ns = cnt_queue1;
    ori_queue0_ns = ori_queue0;
    ori_queue1_ns = ori_queue1;
    for (i = 0 ; i < 17 ; i++) begin
        for (j = 0 ; j < 17 ; j++) begin
            visited_ns[i][j] = visited[i][j];   
        end
    end    
    for (i = 0 ; i < 17 ; i++) begin
        for (j = 0 ; j < 17 ; j++) begin
            depth_ns[i][j] = depth[i][j];   
        end
    end 
    for (i = 0 ; i < 17 ; i++) begin
        queue1_x_ns[i] = queue1_x[i];   
    end
        for (i = 0 ; i < 17 ; i++) begin
        queue1_y_ns[i] = queue1_y[i];   
    end
        for (i = 0 ; i < 17 ; i++) begin
        queue0_x_ns[i] = queue0_x[i];   
    end
        for (i = 0 ; i < 17 ; i++) begin
        queue0_y_ns[i] = queue0_y[i];   
    end
      

    case (state_cur)
            IDLE:begin
                cnt_queue0_ns = 0;
                cnt_queue1_ns = 0;
                for (i = 0 ; i < 17 ; i++) begin
                    for (j = 0 ; j < 17 ; j++) begin
                        visited_ns[i][j] = 0;   
                    end
                end 
                visited_ns[0][0]=1;
                for (i = 0 ; i < 17 ; i++) begin
                    for (j = 0 ; j < 17 ; j++) begin
                        depth_ns[i][j] = 0;   
                    end
                end
                ori_queue0_ns = 1;
                ori_queue1_ns = 0;
                for (i = 0 ; i < 17 ; i++) begin
                    queue0_x_ns[i] = 0;   
                end
                for (i = 0 ; i < 17 ; i++) begin
                    queue0_y_ns[i] = 0;   
                end
                for (i = 0 ; i < 17 ; i++) begin
                    queue1_x_ns[i] = 0;   
                end
                for (i = 0 ; i < 17 ; i++) begin
                    queue1_y_ns[i] = 0;   
                end
                sequence_queue_ns = 0; 

            end 
            EXPAND: begin
                cumulate1 = 0;
                cumulate2 = 0;
                cumulate3 = 0;
                cumulate4 = 0;
                if (sequence_queue == 0) begin
                    cur_x = queue0_x [cnt_queue0];
                    cur_y = queue0_y [cnt_queue0];
                    cnt_queue0_ns = cnt_queue0 +1; //start pop out the element in the queue0
                    
                    
                    if (cur_x == 16 || map [cur_x + 1][cur_y] == 1 || visited[cur_x + 1][cur_y] == 1 ) begin //down direction
                        queue1_x_ns [ori_queue1] = 0;
                        queue1_y_ns [ori_queue1] = 0;
                        cumulate1 = 0; 
                    end
                    else begin
                        queue1_x_ns [ori_queue1] = cur_x +1;
                        queue1_y_ns [ori_queue1] = cur_y;
                        cumulate1 = 1;
                        visited_ns [cur_x +1][cur_y] = 1;
                        depth_ns [cur_x +1][cur_y] = deep;
                    end
                    if (cur_y == 16 || map [cur_x][cur_y + 1] == 1 || visited[cur_x][cur_y + 1] == 1) begin  //right direction
                        queue1_x_ns [ori_queue1 + cumulate1] = 0;
                        queue1_y_ns [ori_queue1 + cumulate1] = 0;
                        cumulate2 = cumulate1; 

                    end
                    else begin
                        queue1_x_ns [ori_queue1 + cumulate1] = cur_x;
                        queue1_y_ns [ori_queue1 + cumulate1] = cur_y+1;
                        cumulate2 = cumulate1 + 1;
                        visited_ns [cur_x][cur_y + 1] = 1;
                        depth_ns [cur_x][cur_y + 1] = deep;         
                    end
                    if (cur_y == 0 || map [cur_x][cur_y - 1] == 1 || visited[cur_x][cur_y - 1] == 1) begin  //left direction
                        queue1_x_ns [ori_queue1 + cumulate2] = 0;
                        queue1_y_ns [ori_queue1 + cumulate2] = 0;
                        cumulate3 = cumulate2; 
                    end
                    else begin
                        queue1_x_ns [ori_queue1 + cumulate2] = cur_x;
                        queue1_y_ns [ori_queue1 + cumulate2] = cur_y - 1;
                        cumulate3 = cumulate2 + 1;  
                        visited_ns [cur_x][cur_y - 1] = 1;
                        depth_ns [cur_x][cur_y - 1] = deep;      
                    end
                    if (cur_x == 0 || map [cur_x-1][cur_y] == 1 || visited[cur_x -1][cur_y] == 1) begin  //up direction
                        queue1_x_ns [ori_queue1 + cumulate3] = 0;
                        queue1_y_ns [ori_queue1 + cumulate3] = 0;
                        cumulate4 = cumulate3 + 0; 
                    end
                    else begin
                        queue1_x_ns [ori_queue1 + cumulate3] = cur_x - 1;
                        queue1_y_ns [ori_queue1 + cumulate3] = cur_y;
                        cumulate4 = cumulate3 + 1;  
                        visited_ns [cur_x - 1][cur_y] = 1;
                        depth_ns [cur_x - 1][cur_y] = deep;    
                    end
                    ori_queue1_ns = ori_queue1 + cumulate4; // to decide the number of pop out in the next stage
                    
                    if (cnt_queue0 == ori_queue0) begin // have popped all the element in the queue, so reset tge ori_queue0 & counter
                        cnt_queue0_ns = 0;
                        ori_queue0_ns = 0;
                        sequence_queue_ns = 1; //change to another queue
                    end
                    else begin
                        cnt_queue0_ns = cnt_queue0 + 1;
                        ori_queue0_ns = ori_queue0;
                        sequence_queue_ns = sequence_queue;

                    end
                    
                    /*
                    if (find) begin
                        back_x_ns = 16;
                    end
                    else begin
                        back_x_ns = back_x;
                    end
                    */
                end
                else begin
                    cur_x = queue1_x [cnt_queue1];
                    cur_y = queue1_y [cnt_queue1];
                    cnt_queue1_ns = cnt_queue1 +1;
                    //cnt_queue1_ns = cnt_queue1 +1; //start pop out the element in the queue0
                    if (cur_x == 16 || map [cur_x + 1][cur_y] == 1 ||visited[cur_x + 1][cur_y] == 1) begin //down direction
                        queue0_x_ns [ori_queue0] = 0;
                        queue0_y_ns [ori_queue0] = 0;
                        cumulate1 = 0; 
                    end
                    else begin
                        queue0_x_ns [ori_queue0] = cur_x +1;
                        queue0_y_ns [ori_queue0] = cur_y;
                        cumulate1 = 1;
                        visited_ns [cur_x +1][cur_y] = 1;
                        depth_ns [cur_x +1][cur_y] = deep;
                    end
                    if (cur_y == 16 || map [cur_x][cur_y + 1] == 1 ||visited[cur_x][cur_y + 1] == 1) begin  //right direction
                        queue0_x_ns [ori_queue0 + cumulate1] = 0;
                        queue0_y_ns [ori_queue0 + cumulate1] = 0;
                        cumulate2 = cumulate1; 

                    end
                    else begin
                        queue0_x_ns [ori_queue0 + cumulate1] = cur_x;
                        queue0_y_ns [ori_queue0 + cumulate1] = cur_y+1;
                        cumulate2 = cumulate1 + 1;
                        visited_ns [cur_x][cur_y + 1] = 1;
                        depth_ns [cur_x][cur_y + 1] = deep;      
                    end
                    if (cur_y == 0 || map [cur_x][cur_y - 1] == 1 || visited[cur_x][cur_y -1] == 1) begin  //left direction
                        queue0_x_ns [ori_queue0 + cumulate2] = 0;
                        queue0_y_ns [ori_queue0 + cumulate2] = 0;
                        cumulate3 = cumulate2; 
                    end
                    else begin
                        queue0_x_ns [ori_queue0 + cumulate2] = cur_x;
                        queue0_y_ns [ori_queue0 + cumulate2] = cur_y - 1;
                        cumulate3 = cumulate2 + 1;  
                        visited_ns [cur_x][cur_y - 1] = 1;
                        depth_ns [cur_x][cur_y - 1] = deep;   
                    end
                    if (cur_x == 0 || map [cur_x-1][cur_y] == 1 || visited[cur_x -1] [cur_y ] == 1) begin  //up direction
                        queue0_x_ns [ori_queue0 + cumulate3] = 0;
                        queue0_y_ns [ori_queue0 + cumulate3] = 0;
                        cumulate4 = cumulate3 + 0; 
                    end
                    else begin
                        queue0_x_ns [ori_queue0 + cumulate3] = cur_x - 1;
                        queue0_y_ns [ori_queue0 + cumulate3] = cur_y;
                        cumulate4 = cumulate3 + 1;  
                        visited_ns [cur_x - 1][cur_y] = 1;
                        depth_ns [cur_x - 1][cur_y] = deep;       
                    end
                    ori_queue0_ns = ori_queue0 + cumulate4; // to decide the number of pop out in the next stage

                    if (cnt_queue1 == ori_queue1) begin // have popped all the element in the queue, so reset tge ori_queue0 & counter
                        cnt_queue1_ns = 0;
                        ori_queue1_ns = 0;
                        sequence_queue_ns = 0; //change to another queue
                    end
                    else begin
                        cnt_queue1_ns = cnt_queue1 + 1;
                        ori_queue1_ns = ori_queue1 ;
                        sequence_queue_ns = sequence_queue;
                    end
                    /*
                    if (cur_x == 16 && cur_y == 16) begin
                        back_x_ns = 16;
                    end
                    else begin
                        back_x_ns = back_x;
                    end
                    */
                end 
            end
            IDLE_SWORD: begin
                cnt_queue0_ns = 0;
                cnt_queue1_ns = 0;
                for (i = 0 ; i < 17 ; i++) begin
                    for (j = 0 ; j < 17 ; j++) begin
                        visited_ns[i][j] = 0;   
                    end
                end 
                visited_ns[0][0]=1;
                for (i = 0 ; i < 17 ; i++) begin
                    for (j = 0 ; j < 17 ; j++) begin
                        depth_ns[i][j] = 0;   
                    end
                end
                ori_queue0_ns = 1;
                ori_queue1_ns = 0;
                for (i = 0 ; i < 17 ; i++) begin
                    queue0_x_ns[i] = 0;   
                end
                for (i = 0 ; i < 17 ; i++) begin
                    queue0_y_ns[i] = 0;   
                end
                for (i = 0 ; i < 17 ; i++) begin
                    queue1_x_ns[i] = 0;   
                end
                for (i = 0 ; i < 17 ; i++) begin
                    queue1_y_ns[i] = 0;   
                end
                sequence_queue_ns = 0; 
            end
            FIND_SWORD: begin
                find_cumulate1 = 0;
                find_cumulate2 = 0;
                find_cumulate3 = 0;
                find_cumulate4 = 0;
                if (sequence_queue == 0) begin
                    find_cur_x = queue0_x [cnt_queue0];
                    find_cur_y = queue0_y [cnt_queue0];
                    cnt_queue0_ns = cnt_queue0 +1; //start pop out the element in the queue0
                    
                    //don't add to the queue: if there is wall or over the border 
                    if (find_cur_x == 16 || map [find_cur_x + 1][find_cur_y] == 1 || visited[find_cur_x + 1][find_cur_y] == 1 || map[find_cur_x+1][find_cur_y] == 3)  begin //down direction
                        queue1_x_ns [ori_queue1] = 0;
                        queue1_y_ns [ori_queue1] = 0;
                        find_cumulate1 = 0; 
                    end
                    else begin // add to the queue: if there is a road or it has found the sword(since it would be popped next) the decision is map[find_cur_x][find_cur_y]
                        queue1_x_ns [ori_queue1] = find_cur_x +1;
                        queue1_y_ns [ori_queue1] = find_cur_y;
                        find_cumulate1 = 1;
                        visited_ns [find_cur_x +1][find_cur_y] = 1;
                        depth_ns [find_cur_x +1][find_cur_y] = deep;
                    end
                    if (find_cur_y == 16 || map [find_cur_x][find_cur_y + 1] == 1 || visited[find_cur_x][find_cur_y + 1] == 1 || map[find_cur_x][find_cur_y+1] == 3) begin  //right direction
                        queue1_x_ns [ori_queue1 + find_cumulate1] = 0;
                        queue1_y_ns [ori_queue1 + find_cumulate1] = 0;
                        find_cumulate2 = find_cumulate1; 

                    end
                    else begin
                        queue1_x_ns [ori_queue1 + find_cumulate1] = find_cur_x;
                        queue1_y_ns [ori_queue1 + find_cumulate1] = find_cur_y+1;
                        find_cumulate2 = find_cumulate1 + 1;
                        visited_ns [find_cur_x][find_cur_y + 1] = 1;
                        depth_ns [find_cur_x][find_cur_y + 1] = deep;         
                    end
                    if (find_cur_y == 0 || map [find_cur_x][find_cur_y - 1] == 1 || visited[find_cur_x][find_cur_y - 1] == 1 || map[find_cur_x][find_cur_y -1] == 3) begin  //left direction
                        queue1_x_ns [ori_queue1 + find_cumulate2] = 0;
                        queue1_y_ns [ori_queue1 + find_cumulate2] = 0;
                        find_cumulate3 = find_cumulate2; 
                    end
                    else begin
                        queue1_x_ns [ori_queue1 + find_cumulate2] = find_cur_x;
                        queue1_y_ns [ori_queue1 + find_cumulate2] = find_cur_y - 1;
                        find_cumulate3 = find_cumulate2 + 1;  
                        visited_ns [find_cur_x][find_cur_y - 1] = 1;
                        depth_ns [find_cur_x][find_cur_y - 1] = deep;      
                    end
                    if (find_cur_x == 0 || map [find_cur_x-1][find_cur_y] == 1 || visited[find_cur_x -1][find_cur_y] == 1|| map[find_cur_x-1][find_cur_y] == 3) begin  //up direction
                        queue1_x_ns [ori_queue1 + find_cumulate3] = 0;
                        queue1_y_ns [ori_queue1 + find_cumulate3] = 0;
                        find_cumulate4 = find_cumulate3 + 0; 
                    end
                    else begin
                        queue1_x_ns [ori_queue1 + find_cumulate3] = find_cur_x - 1;
                        queue1_y_ns [ori_queue1 + find_cumulate3] = find_cur_y;
                        find_cumulate4 = find_cumulate3 + 1;  
                        visited_ns [find_cur_x - 1][find_cur_y] = 1;
                        depth_ns [find_cur_x - 1][find_cur_y] = deep;    
                    end
                    ori_queue1_ns = ori_queue1 + find_cumulate4; // to decide the number of pop out in the next stage
                    
                    if (cnt_queue0 == ori_queue0) begin // have popped all the element in the queue, so reset tge ori_queue0 & counter
                        cnt_queue0_ns = 0;
                        ori_queue0_ns = 0;
                        sequence_queue_ns = 1; //change to another queue
                    end
                    else begin
                        cnt_queue0_ns = cnt_queue0 + 1;
                        ori_queue0_ns = ori_queue0;
                        sequence_queue_ns = sequence_queue;

                    end
                    
                    /*
                    if (find) begin
                        back_x_ns = 16;
                    end
                    else begin
                        back_x_ns = back_x;
                    end
                    */
                end
                else begin
                    find_cur_x = queue1_x [cnt_queue1];
                    find_cur_y = queue1_y [cnt_queue1];
                    cnt_queue1_ns = cnt_queue1 +1;
                    //cnt_queue1_ns = cnt_queue1 +1; //start pop out the element in the queue0
                    if (find_cur_x == 16 || map [find_cur_x + 1][find_cur_y] == 1 ||visited[find_cur_x + 1][find_cur_y] == 1|| map[find_cur_x+1][find_cur_y] == 3) begin //down direction
                        queue0_x_ns [ori_queue0] = 0;
                        queue0_y_ns [ori_queue0] = 0;
                        find_cumulate1 = 0; 
                    end
                    else begin
                        queue0_x_ns [ori_queue0] = find_cur_x +1;
                        queue0_y_ns [ori_queue0] = find_cur_y;
                        find_cumulate1 = 1;
                        visited_ns [find_cur_x +1][find_cur_y] = 1;
                        depth_ns [find_cur_x +1][find_cur_y] = deep;
                    end
                    if (find_cur_y == 16 || map [find_cur_x][find_cur_y + 1] == 1 ||visited[find_cur_x][find_cur_y + 1] == 1|| map[find_cur_x][find_cur_y+1] == 3) begin  //right direction
                        queue0_x_ns [ori_queue0 + find_cumulate1] = 0;
                        queue0_y_ns [ori_queue0 + find_cumulate1] = 0;
                        find_cumulate2 = find_cumulate1; 

                    end
                    else begin
                        queue0_x_ns [ori_queue0 + find_cumulate1] = find_cur_x;
                        queue0_y_ns [ori_queue0 + find_cumulate1] = find_cur_y+1;
                        find_cumulate2 = find_cumulate1 + 1;
                        visited_ns [find_cur_x][find_cur_y + 1] = 1;
                        depth_ns [find_cur_x][find_cur_y + 1] = deep;      
                    end
                    if (find_cur_y == 0 || map [find_cur_x][find_cur_y - 1] == 1 || visited[find_cur_x][find_cur_y -1] == 1|| map[find_cur_x][find_cur_y-1] == 3) begin  //left direction
                        queue0_x_ns [ori_queue0 + find_cumulate2] = 0;
                        queue0_y_ns [ori_queue0 + find_cumulate2] = 0;
                        find_cumulate3 = find_cumulate2; 
                    end
                    else begin
                        queue0_x_ns [ori_queue0 + find_cumulate2] = find_cur_x;
                        queue0_y_ns [ori_queue0 + find_cumulate2] = find_cur_y - 1;
                        find_cumulate3 = find_cumulate2 + 1;  
                        visited_ns [find_cur_x][find_cur_y - 1] = 1;
                        depth_ns [find_cur_x][find_cur_y - 1] = deep;   
                    end
                    if (find_cur_x == 0 || map [find_cur_x-1][find_cur_y] == 1 || visited[find_cur_x -1] [find_cur_y ] == 1|| map[find_cur_x -1][find_cur_y] == 3) begin  //up direction
                        queue0_x_ns [ori_queue0 + find_cumulate3] = 0;
                        queue0_y_ns [ori_queue0 + find_cumulate3] = 0;
                        find_cumulate4 = find_cumulate3 + 0; 
                    end
                    else begin
                        queue0_x_ns [ori_queue0 + find_cumulate3] = find_cur_x - 1;
                        queue0_y_ns [ori_queue0 + find_cumulate3] = find_cur_y;
                        find_cumulate4 = find_cumulate3 + 1;  
                        visited_ns [find_cur_x - 1][find_cur_y] = 1;
                        depth_ns [find_cur_x - 1][find_cur_y] = deep;       
                    end
                    ori_queue0_ns = ori_queue0 + find_cumulate4; // to decide the number of pop out in the next stage

                    if (cnt_queue1 == ori_queue1) begin // have popped all the element in the queue, so reset tge ori_queue0 & counter
                        cnt_queue1_ns = 0;
                        ori_queue1_ns = 0;
                        sequence_queue_ns = 0; //change to another queue
                    end
                    else begin
                        cnt_queue1_ns = cnt_queue1 + 1;
                        ori_queue1_ns = ori_queue1 ;
                        sequence_queue_ns = sequence_queue;
                    end
                    /*
                    if (find_cur_x == 16 && find_cur_y == 16) begin
                        back_x_ns = 16;
                    end
                    else begin
                        back_x_ns = back_x;
                    end
                    */
                end 
            
            end

    endcase          
end

//reg got_sword,got_sword_ns;
always @(*) begin
    if (state_cur == IDLE) begin
        back_length_ns = out_reg_cnt;
    end
    if (state_cur == BACK) begin
        back_length_ns = out_reg_cnt - 1;
    end
    else begin
        back_length_ns = back_length;
    end
end
always @(*) begin
    if (state_cur == IDLE_SWORD) begin
        back_cnt_ns = 0;
    end
    else if ( state_cur == BACK_SWORD && back_x == 0 && back_y == 0) begin
        back_cnt_ns = back_cnt + 1;
    end
    else begin
        back_cnt_ns = back_cnt;
    end
end

always @(*) begin
    sword_site_x_ns = sword_site_x;
    sword_site_y_ns = sword_site_y;
    if (state_cur == FIND_SWORD) begin
        if (map [find_cur_x][find_cur_y] == 2) begin
            sword_site_x_ns = find_cur_x;
            sword_site_y_ns = find_cur_y;
        end
        else begin
            sword_site_x_ns = sword_site_x;
            sword_site_y_ns = sword_site_y;
        end
    end
end
/*
always @(*) begin
    cnt_back_ns = cnt_back;
    if (state_cur == IDLE) begin
        cnt_back_ns = 0;
    end
    if (state_cur == BACK_SWORD)begin
        cnt_back_ns = cnt_back + 1;
    end
    else begin
        cnt_back_ns = cnt_back;
    end
end
*/
/*
always @(*) begin
    keep_deep_ns = keep_deep;
    if (state_cur == IDLE) begin
        keep_deep_ns = 0;
    end
    else
    if (state_cur == FIND_SWORD ) begin
        keep_deep_ns = deep - 1;
    end
    else if (state_cur == DONE) begin
        if (out_reg_cnt == 0 )begin
            keep_deep_ns = keep_deep -1;
        end
        else begin
            keep_deep_ns = keep_deep;
        end
    end
    
end
*/
always@(*)begin
    deep_ns = deep;
    if (state_cur == IDLE) begin
        deep_ns = 1;
    end
    else if(state_cur==EXPAND)begin
        if(sequence_queue==0)begin
            if(cnt_queue0 == ori_queue0)begin
                deep_ns = deep+1;// change the depth of the queue
            end
            else if (cur_x == 16 && cur_y ==16) begin
                deep_ns = deep - 1;
            end
            else begin
                deep_ns = deep;
            end
        end
        else begin
            if(cnt_queue1 == ori_queue1)begin
                deep_ns = deep + 1;// change the depth of the queue
            end
            else if (cur_x == 16 && cur_y == 16) begin
                deep_ns = deep - 1;
            end
            else begin
                deep_ns = deep;
            end
        end
    end
    else if (state_cur == BACK) begin
        deep_ns = deep - 1;
    end
    else if (state_cur == IDLE_SWORD) begin
        deep_ns = 1;
    end
    else if(state_cur==FIND_SWORD)begin
        if(sequence_queue==0)begin
            if(cnt_queue0 == ori_queue0 && map[find_cur_x][find_cur_y] != 2)begin
                deep_ns = deep+1;// change the depth of the queue
            end
            else if (map[find_cur_x][find_cur_y] == 2) begin
                deep_ns = deep;
            end
            else begin
                deep_ns = deep;
            end
        end
        else begin
            if(cnt_queue1 == ori_queue1 && map[find_cur_x][find_cur_y] != 2 )begin
                deep_ns = deep+1;// change the depth of the queue
            end
            else if (map[find_cur_x][find_cur_y] == 2) begin
                deep_ns = deep;
            end
            else begin
                deep_ns = deep;
            end
        end
    end
    else if (state_cur == BACK_SWORD) begin
        if (flag_start) begin
            deep_ns = deep - 1;
        end
        else begin
            deep_ns = deep +1 ;
        end
    end
    
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        back_deep <= 0;
    end else begin
        back_deep <= back_deep_ns;
    end
end

always @(*) begin
    back_deep_ns = back_deep;
     if (state_cur == EXPAND) begin
        back_deep_ns = deep -1;
     end 
    else if (state_cur == BACK) begin
        back_deep_ns = back_deep -1;
     end
        else begin
        back_deep_ns = back_deep;
     end

end
*/
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        back_x <= 0;
        back_y <= 0;
    end
    else begin
        back_x <= back_x_ns;
        back_y <= back_y_ns;
    end
end
always @(*) begin
    back_x_ns = back_x;
    back_y_ns = back_y;
    case (state_cur)
        EXPAND: begin
            back_x_ns=16;
            back_y_ns=16;
        end
        BACK: begin
            //from ending going back to the start
            //now we have to find level deep-1
            if (back_x != 0 && visited[back_x - 1][back_y] == 1 && depth[back_x -1][back_y] == deep - 1 ) begin //go up
                back_x_ns=back_x-1;
                back_y_ns=back_y;
            end
            else if (back_x != 16 && visited[back_x + 1][back_y] == 1 && depth[back_x + 1][back_y] == deep - 1 )begin //go down
                back_x_ns=back_x+1;
                back_y_ns=back_y;
                
            end 
            else if (back_y !=0 && visited[back_x][back_y-1] == 1 && depth[back_x][back_y-1] == deep - 1) begin //go left
                back_x_ns=back_x;
                back_y_ns=back_y-1;
            end
            else if (back_y != 16 && visited[back_x][back_y+1] == 1 && depth[back_x][back_y+1] == deep - 1) begin //go right
                back_x_ns=back_x;
                back_y_ns=back_y+1;
            end
        end
        FIND_SWORD: begin

        if (map [find_cur_x][find_cur_y] == 2) begin
            back_x_ns = find_cur_x;
            back_y_ns = find_cur_y;
        end
        else begin
            back_x_ns = back_x;
            back_y_ns = back_y;
        end


        end
        BACK_SWORD: begin
            if (flag_start) begin
                if (back_x != 0 && visited[back_x - 1][back_y] == 1 && depth[back_x -1][back_y] == deep - 1 ) begin //go up
                    back_x_ns=back_x-1;
                    back_y_ns=back_y;
                end
                else if (back_x != 16 && visited[back_x + 1][back_y] == 1 && depth[back_x + 1][back_y] == deep - 1 )begin //go down
                    back_x_ns=back_x+1;
                    back_y_ns=back_y;
                    end 
                else if (back_y !=0 && visited[back_x][back_y-1] == 1 && depth[back_x][back_y-1] == deep - 1) begin //go left
                    back_x_ns=back_x;
                    back_y_ns=back_y-1;
                end
                else if (back_y != 16 && visited[back_x][back_y+1] == 1 && depth[back_x][back_y+1] == deep - 1) begin //go right
                    back_x_ns=back_x;
                    back_y_ns=back_y+1;
                end          
            end
            /*else begin
                if (back_x != 0 && visited[back_x - 1][back_y] == 1 && depth[back_x -1][back_y] == deep + 1 ) begin //go up
                    back_x_ns=back_x-1;
                    back_y_ns=back_y;
                end
                else if (back_x != 16 && visited[back_x + 1][back_y] == 1 && depth[back_x + 1][back_y] == deep + 1 )begin //go down
                    back_x_ns=back_x+1;
                    back_y_ns=back_y;
                    end 
                else if (back_y !=0 && visited[back_x][back_y-1] == 1 && depth[back_x][back_y-1] == deep + 1) begin //go left
                    back_x_ns=back_x;
                    back_y_ns=back_y-1;
                end
                else if (back_y != 16 && visited[back_x][back_y+1] == 1 && depth[back_x][back_y+1] == deep + 1) begin //go right
                    back_x_ns=back_x;
                    back_y_ns=back_y+1;
                end                 
                
            end*/
        end
        
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag <= 0;
    end
    else begin
        flag <= flag_ns;
    end
end


always @(*) begin
    if (state_cur == IDLE_SWORD) begin
        flag_start_ns = 1;
    end
    else if (state_cur == BACK_SWORD) begin
        if (back_x == 0 && back_y == 0 && flag_start) begin
            flag_start_ns = 0;
        end
        else begin
            flag_start_ns = flag_start;
        end
    end
    else begin
        flag_start_ns = flag_start;
    end
end

reg flag_find, flag_find_ns ;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_find <= 0;
    end
    else begin
        flag_find <= flag_find_ns;
    end
    
end
always @(*) begin
    flag_find_ns = flag_find;
    if (state_cur == IDLE) begin
        flag_find_ns = 0;
    end
    else if (state_cur == IDLE_SWORD )begin
        flag_find_ns = 1;
    end
    
end
always @(*) begin

    flag_ns = flag;
    if (state_cur == FIND_SWORD) begin
        if (map[back_x][back_y] == 2) begin
            flag_ns = 1;
        end
        else begin
            flag_ns = 0;
        end
    end
    else if (state_cur == IDLE_SWORD) begin
        flag_ns = 0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i=0;i < 431;i++)begin
            out_reg[i] <= 0;
        end
    end
    else begin
        for(i=0;i < 431;i++)begin
            out_reg[i] <= out_reg_ns[i];
        end
    end
end

always @(*) begin
    has_sword_monster_ns = has_sword_monster;
    for(i=0;i<431;i++)begin
        out_reg_ns[i]= out_reg[i];
    end
    case (state_cur)
        IDLE : begin
            for (i = 0;i<431;i++) begin
                out_reg_ns[i] = 0;
            end
            has_sword_monster_ns = 0;
        end
        EXPAND : begin
            if (map[16][16] == 3) begin
                has_sword_monster_ns = 1;
            end
            else begin
                has_sword_monster_ns = has_sword_monster;
            end
        end
        BACK: begin
            //from ending going back to the start
            //now we have to find level deep-1
            if (back_x != 0 && visited[back_x - 1][back_y] == 1 && depth[back_x -1][back_y] == deep - 1 ) begin //go up
                out_reg_ns[out_reg_cnt] = 1;
                

                if (map[back_x - 1][back_y] == 2)begin
                    has_sword_monster_ns = 0;
                end
                else if(map[back_x - 1][back_y] == 3)begin
                    has_sword_monster_ns = 1;
                end
                else begin
                    has_sword_monster_ns = has_sword_monster;
                end
            end
            else if (back_x != 16 && visited[back_x + 1][back_y] == 1 && depth[back_x + 1][back_y] == deep - 1 )begin
                out_reg_ns[out_reg_cnt] = 3;
                

                if (map[back_x + 1][back_y] == 2)begin
                    has_sword_monster_ns = 0;
                end
                else if(map[back_x + 1][back_y] == 3)begin
                    has_sword_monster_ns = 1;
                end
                else begin
                    has_sword_monster_ns = has_sword_monster;
                end
                
            end 
            else if (back_y !=0 && visited[back_x][back_y-1] == 1 && depth[back_x][back_y-1] == deep - 1) begin                
                out_reg_ns[out_reg_cnt] = 0;
            
                if (map[back_x][back_y-1] == 2)begin
                    has_sword_monster_ns = 0;
                end
                else if(map[back_x ][back_y-1] == 3)begin
                    has_sword_monster_ns = 1;
                end
                else begin
                    has_sword_monster_ns = has_sword_monster;
                end
            end
            else if (back_y !=16 && visited[back_x][back_y+1] == 1 && depth[back_x][back_y + 1] == deep - 1) begin
                out_reg_ns[out_reg_cnt] = 2;
                
                if (map[back_x ][back_y+1] == 2)begin
                    has_sword_monster_ns = 0;
                end
                else if(map[back_x ][back_y+1] == 3)begin
                    has_sword_monster_ns = 1;
                end
                else begin
                    has_sword_monster_ns = has_sword_monster;
                end
            end
        end
        BACK_SWORD: begin
            //from ending going back to the start
            //now we have to find level deep-1
            
            //if (back_x != 0 || back_y != 0) begin
            if (back_x != 0 && visited[back_x - 1][back_y] == 1 && depth[back_x -1][back_y] == deep - 1 ) begin //go up
                out_reg_ns[out_reg_cnt] = 3;                
            end
            else if (back_x != 16 && visited[back_x + 1][back_y] == 1 && depth[back_x + 1][back_y] == deep - 1 )begin // go down
                out_reg_ns[out_reg_cnt] = 1;                
            end 
            else if (back_y !=0 && visited[back_x][back_y-1] == 1 && depth[back_x][back_y-1] == deep - 1) begin                
                out_reg_ns[out_reg_cnt] = 2;           
            end
            else if (back_y !=16 && visited[back_x][back_y+1] == 1 && depth[back_x][back_y + 1] == deep - 1) begin
                out_reg_ns[out_reg_cnt] = 0;
            end
            //end
            /*
            else begin //go to the sword
                if (out_reg [back_length + keep_deep - back_cnt] == 2) begin
                    out_reg_ns[out_reg_cnt] = 0;
                end
                else if (out_reg[back_length + keep_deep - back_cnt] == 3) begin
                    out_reg_ns[out_reg_cnt] = 1;
                end          
                else if (out_reg[back_length + keep_deep - back_cnt] == 0) begin
                    out_reg_ns[out_reg_cnt] = 2;
                end
                else begin
                    out_reg_ns[out_reg_cnt] = 3;
                end
            end
            */

        end

    endcase
end
reg phase1, phase1_ns;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        phase1 <= 0;
    end
    else begin
        phase1 <= phase1_ns;
    end
end
always @(*) begin
    phase1_ns = phase1;
    if (state_cur == IDLE) begin
        phase1_ns = 0;
    end
    else if (state_cur == BACK_SWORD) begin
        phase1_ns = 1;
    end
    else if (state_cur == DONE && out_reg_cnt == back_length +1) begin
        phase1_ns = 0;
    end  
    else begin
        phase1_ns = phase1;
    end
end
integer t;

always @(*) begin
    out_reg_cnt_ns = out_reg_cnt;
    if (state_cur == IDLE) begin
        out_reg_cnt_ns = 0;
    end
    if (state_cur == BACK) begin
        if (back_x == 0 && back_y == 0) begin
            out_reg_cnt_ns = out_reg_cnt ;
            t =0 ;
        end
        else begin
            out_reg_cnt_ns = out_reg_cnt + 1 ;
            t=6;
        end
    end
    else if (state_cur == DONE) begin
        if (flag_find) begin
            if (out_reg_cnt > back_length + 1  && phase1) begin
                out_reg_cnt_ns = out_reg_cnt - 1;
                t =1;
            end
            else if (out_reg_cnt == back_length + 1 && phase1) begin
                out_reg_cnt_ns = out_reg_cnt;
                t=2;
            end
            else if (!phase1 && out_reg_cnt >= back_length + 1 && out_reg_cnt < keep_total) begin
                out_reg_cnt_ns = out_reg_cnt + 1;
                t=3;
            end
            else if (out_reg_cnt == keep_total) begin
                out_reg_cnt_ns = back_length;
                t=4;
            end
            else if (out_reg_cnt < back_length + 1) begin
                out_reg_cnt_ns = out_reg_cnt - 1;
                t=5;
            end
        end
        else if (out_reg_cnt !=0) begin
            out_reg_cnt_ns = out_reg_cnt - 1 ;
        end
    end
    else if (state_cur == IDLE_SWORD) begin
        out_reg_cnt_ns = out_reg_cnt - 1 ;
    end // for extra one cycle
    else if (state_cur == BACK_SWORD) begin
        /*
        if (back_cnt == keep_deep) begin
            out_reg_cnt_ns = out_reg_cnt;
        end
        else begin
            out_reg_cnt_ns = out_reg_cnt + 1;
        end
        */
        if (deep == 0)begin
            out_reg_cnt_ns = out_reg_cnt ;
        end
        else begin
            out_reg_cnt_ns = out_reg_cnt +1;
        end
    end
    
    
end

reg out_valid_temp_ns,out_valid_temp;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else begin
        out_valid <=out_valid_temp;
    end
end 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid_temp <= 0;
    end
    else begin
        out_valid_temp <=out_valid_temp_ns;
    end
end
always @(*) begin
    if (state_cur == DONE &&  out_reg_cnt !=0) begin
        out_valid_temp_ns = 1;
    end
    else begin
        out_valid_temp_ns = 0;
    end
end
reg [1:0]out_ns;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out <= 0;
    end
    else begin
        out<=out_ns;
        
    end
end
/*
always @(*) begin
    if (state_cur == DONE && print_count != sword_cnt )begin
        print_count_ns = print_count + 1;
    end
    else begin
        print_count_ns = print_count;
    end
end
*/
/*
reg [8:0] print1_cnt, print1_cnt_ns;
reg [8:0] print2_cnt, print2_cnt_ns;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        print1_cnt <= 0;
        print2_cnt <= 0;
    end
    else begin
        print1_cnt <= print1_cnt_ns;
        print2_cnt <= print2_cnt_ns;        
    end
end
always @(*) begin
    print1_cnt_ns = print1_cnt;
    print2_cnt_ns = print2_cnt;
    if (state_cur == BACK_SWORD) begin
        print1_cnt_ns =  keep_total - keep_deep + 1;
        print2_cnt_ns = back_length + 1;
    end
    else if (state_cur == DONE) begin
        if (print1_cnt != keep_total) begin
            print1_cnt_ns = print1_cnt + 1;
        end
        else if (print1_cnt == keep_total && print2_cnt != back_length + keep_deep) begin
            print2_cnt_ns = print2_cnt + 1;
        end
    end
end
*/

always @(*) begin
    if (state_cur == BACK) begin
        keep_total_ns = out_reg_cnt - 1;
    end
    else if (state_cur == BACK_SWORD) begin
        keep_total_ns = out_reg_cnt - 1;
    end
    else begin
        keep_total_ns = keep_total;
    end
end
/*
integer t;

always @(*) begin
    if (state_cur == DONE && out_reg_cnt > back_length+1 && flag_find) begin
        //output the first route
        if (print1_cnt < keep_total) begin //find sword
            out_ns = out_reg[print1_cnt +1 ];
            
        end else if (print1_cnt == keep_total && print2_cnt <= back_length + keep_deep) begin
            out_ns = out_reg[print2_cnt];
            
        end
        else begin
            out_ns=0;
            
        end
    end
    else if ((state_cur == DONE)&& (out_reg_cnt!=0)) begin
        out_ns = out_reg[out_reg_cnt-1];
    end
    else begin
        out_ns = 0;
    end
end
*/
//integer n;

reg phase1_d1;
always@(posedge clk)begin
    phase1_d1<=phase1;
end
always@(*)begin
    if(out_valid_temp==1)begin
        if(phase1)begin
            if (out_reg[out_reg_cnt] == 2 ) begin
                out_ns = 0; 
                //n=1;
            end
            else if (out_reg[out_reg_cnt] == 0 )begin
                out_ns = 2;
                //n=2;
            end
            else if (out_reg[out_reg_cnt] == 1) begin
                out_ns = 3;
                //n=3;
            end
            else begin
                out_ns = 1;
                //n=4;
            end
        end

        else 
            out_ns = out_reg[out_reg_cnt];
    end
    else begin
        out_ns=0;
    end
end
/*
always@(*)begin
    if ((state_cur == DONE)&& (out_reg_cnt!=0) && !flag_find) begin
        out_ns = out_reg[out_reg_cnt-1];
        n=0;
    end
    else if(state_cur == DONE && phase1&&out_reg_cnt==back_length+1)begin
        out_ns = out_reg[out_reg_cnt];
    end
    else if (state_cur == DONE && phase1) begin
        if (out_reg[out_reg_cnt-1] == 2 ) begin
            out_ns = 0; 
            n=1;
        end
        else if (out_reg[out_reg_cnt-1] == 0 )begin
            out_ns = 2;
            n=2;
        end
        else if (out_reg[out_reg_cnt-1] == 1) begin
            out_ns = 3;
            n=3;
        end
        else begin
            out_ns = 1;
            n=4;
        end
    end
    else if (state_cur == DONE && out_reg_cnt != 0 && flag_find ) begin
            out_ns = out_reg[out_reg_cnt-1];
            n=5;
    end
    else begin
        out_ns = 0;
        n=6;
    end
end

*/


endmodule