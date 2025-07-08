/**************************************************************************/
// Copyright (c) 2025, OASIS Lab
// MODULE: STA
// FILE NAME: STA.v
// VERSRION: 1.0
// DATE: 2025/02/26
// AUTHOR: Yu-Hao Cheng, NYCU IEE
// DESCRIPTION: ICLAB 2025 Spring / LAB3 / STA
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
module STA(
	//INPUT
	rst_n,
	clk,
	in_valid,
	delay,
	source,
	destination,
	//OUTPUT
	out_valid,
	worst_delay,
	path
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
input				rst_n, clk, in_valid;
input		[3:0]	delay;
input		[3:0]	source;
input		[3:0]	destination;

output reg			out_valid;
output reg	[7:0]	worst_delay;
output reg	[3:0]	path;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
typedef enum reg[1:0]{IDLE = 2'd0, QUEUE = 2'd1, PATH = 2'd2, DONE = 2'd3}state;
state cur_state, nxt_state;

integer i,j;

reg [3:0] delay_reg [0:15],delay_reg_ns[0:15];
//reg [3:0] source_reg[0:31], source_reg_ns[0:31];
//reg [3:0] destination_reg[0:31], destination_reg_ns[0:31];

reg [3:0] in_degree[0:15], in_degree_ns[0:15];
reg [3:0] parent[0:15], parent_ns[0:15];
reg [7:0] distance[0:15], distance_ns[0:15];
//reg [3:0] queue[0:13], queue_ns[0:13];
//reg queue_cnt[0:15];
//reg [3:0] queue_total, queue_total_ns;
reg dependency[0:15][0:15], dependency_ns[0:15][0:15];

//reg [3:0]order [0:15], order_ns[0:15];
reg [5:0] in_cnt, in_cnt_ns;
//reg [4:0] pop_cnt,pop_cnt_ns;

reg visited[0:15], visited_ns[0:15];
//reg [3:0] order_cnt, order_cnt_ns;
//reg [2:0] in_queue_cnt,in_queue_cnt_ns;
//reg [3:0] back_cnt, back_cnt_ns;
reg [3:0] path_reg[0:15], path_reg_ns[0:15];
reg [4:0] path_cnt, path_cnt_ns;

reg [3:0] start, start_ns;
reg out_valid_ns;
reg [7:0] worst_delay_ns;
reg [3:0] path_ns;
//reg [3:0] cnt0;
//reg [3:0] cnt1,cnt2;
//reg [3:0] cnt3,cnt3_ns;

reg out_valid_f,out_valid_f_ns;

reg flag;
reg [3:0] node;
reg first,first_ns;

//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
/*
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		queue_total <= 0;
	end
	else begin
		queue_total <= queue_total_ns;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cnt3 <= 0;
	end
	else begin
		cnt3 <= cnt3_ns;
	end
end
*/
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		start <= 0;
	end
	else begin
		start <= start_ns;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		path_cnt <= 0;
	end
	else begin
		path_cnt <= path_cnt_ns;
	end
end
/*
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		back_cnt <= 0;
	end
	else begin
		back_cnt <= back_cnt_ns;
	end
end
*/
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_cnt <= 0;
	end
	else if (cur_state == IDLE) begin
			if (in_valid) begin
				in_cnt <= in_cnt_ns + 1;
			end
			else begin
				in_cnt <= in_cnt_ns;
			end
	end
	else begin
		in_cnt <= in_cnt_ns;
	end
end
/*
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		pop_cnt <= 0;
	end
	else begin
		pop_cnt <= pop_cnt_ns;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_queue_cnt <= 0;
	end
	else begin
		in_queue_cnt <= in_queue_cnt_ns;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		order_cnt <= 0;
	end
	else begin
		order_cnt <= order_cnt_ns;
	end
end
*/
/*
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i<32;i++) begin
			source_reg [i] <= 0;
			destination_reg [i] <= 0;
		end
	end
	else begin
		for (i = 0; i<32;i++) begin
			source_reg [i] <= source_reg_ns[i];
			destination_reg [i] <= destination_reg_ns[i];		
		end		
	end
end
*/
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0;i<16;i++) begin
			delay_reg[i] <= 0;
			path_reg[i] <= 0;
		end
	end
	else begin
		for (i = 0;i<16;i++) begin
			delay_reg[i] <= delay_reg_ns[i];
			path_reg[i] <= path_reg_ns[i];
		end		
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i<16;i++) begin
			in_degree [i] <= 0;
		end
	end
	else if(cur_state == IDLE && in_valid) begin
			in_degree [destination] <= in_degree_ns[destination]+1;
		end		
	
	else begin
		for (i = 0; i<16;i++) begin
			in_degree [i] <= in_degree_ns[i];
		end		
	end 
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i<16;i++) begin
			parent [i] <= 0;
		end
	end
	else begin
		for (i = 0; i<16;i++) begin
			parent [i] <= parent_ns[i];
		end		
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i<16;i++) begin
			distance [i] <= 0;
		end
	end
	else begin
		for (i = 0; i<16;i++) begin
			distance [i] <= distance_ns[i];
		end		
	end
end
/*
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i<14;i++) begin
			queue [i] <= 0;
		end
	end
	else begin
		for (i = 0; i<14;i++) begin
			queue [i] <= queue_ns[i];
		end		
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i<16;i++) begin
			order [i] <= 0;
		end
	end
	else begin
		for (i = 0; i<16;i++) begin
			order [i] <= order_ns[i];
		end		
	end
end
*/
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0;i<16;i++) begin
			for (j = 0 ;j<16;j++) begin
				dependency[i][j] <= 0;
			end
		end
	end
	else begin
		for (i = 0 ; i < 16 ; i++) begin
			for (j = 0 ; j < 16 ; j++) begin
				dependency[i][j] <= dependency_ns[i][j];
			end
		end		
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0;i<16;i++) begin
			visited[i] <= 0;
		end
	end
	else begin
		for (i = 0 ; i < 16 ; i++) begin
			visited[i] <= visited_ns[i];
		end		
	end
end
always @(negedge rst_n or posedge clk) begin
    if (!rst_n) begin
        cur_state = IDLE;
    end
    else begin
        cur_state = nxt_state;
    end
end

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
always @(*) begin
	flag = 0;
	node = 0;
	for(i = 0;i<16;i++) begin
		in_degree_ns[i] = in_degree[i];
		parent_ns[i] = parent[i];
		distance_ns[i] = distance[i];
		visited_ns[i] = visited[i];
	end
	for (i = 0;i<16;i++) begin
		for (j=0;j<16;j++) begin
			dependency_ns[i][j] = dependency[i][j];
		end
	end

	if (cur_state == QUEUE) begin
	    flag = 0;

	    for (i = 0; i < 16; i = i + 1) begin
	        if (flag == 0 && (in_degree[i] == 0) && (visited[i] == 0)) begin
	            visited_ns[i] = 1;
	            node = i;
	            flag = 1;
	        end
	    end

	    // Second loop: process dependencies for the selected node (if one was found)
	    if (flag == 1) begin
	        for (j = 1; j < 16; j = j + 1) begin
	            if (dependency[node][j] == 1) begin
	                in_degree_ns[j] = in_degree[j] - 1;
	                if (distance[j] <= distance[node] + delay_reg[node]) begin
	                    distance_ns[j] = distance[node] + delay_reg[node];
	                    parent_ns[j] = node;
	                end
	                in_degree_ns[j] = in_degree[j] - 1;
	            end
	            else begin
	                in_degree_ns[j] = in_degree[j];
	            end
	        end
	    end
	end


	else if (cur_state == DONE) begin
		for (i = 0;i<16;i++) begin
			for (j = 0;j<16;j++) begin
				dependency_ns[i][j] = 0;
			end
		end			
		for(i = 0;i<16;i++) begin
			in_degree_ns[i] = 0;
			parent_ns[i] = 0;
			distance_ns[i] =  0;
			visited_ns[i] = 0;
		end
	end
	else if (cur_state == IDLE) begin
		if (in_valid) begin
			dependency_ns[source][destination] = 1;
		end
		else begin
			for (i = 0;i<16;i++) begin
				for (j = 0;j<16;j++) begin
					dependency_ns[i][j] = dependency[i][j];
				end
			end
		end
		
	end
end

always @(*) begin
	case (cur_state) 
		IDLE:begin
			if (in_cnt == 32) begin
				nxt_state = QUEUE;
			end
			else begin
				nxt_state = cur_state;
			end
		end
		QUEUE: begin
			if (node != 1) begin //HAVEN'T FIND 1 
				nxt_state = QUEUE;
			end
			else begin
				nxt_state = PATH;
			end
		end
		/*
		POP: begin
			/////make it sicher
			if (pop_cnt == queue_total - 1 && order_cnt != 15 ) begin
				nxt_state = QUEUE;
			end
			else if (pop_cnt < queue_total - 1 && order_cnt != 15) begin
				nxt_state = POP;
			end
			else if (order_cnt == 15) begin
				nxt_state = BACK;
			end
			else begin
				nxt_state = cur_state;
			end
		end
		
		BACK: begin
			if (back_cnt == 15) begin
                nxt_state = PATH;
            end
            else begin //back_cnt <15
                nxt_state = cur_state;
            end
		end
		*/
        PATH: begin
            if (parent[start] == 0) begin
                nxt_state = DONE;
            end
            else begin
                nxt_state = cur_state;
            end
        end

        DONE: begin
            if (path_cnt == 0) begin
                nxt_state = IDLE;
            end
            else begin
                nxt_state = cur_state;
            end
        end
		default: nxt_state = cur_state;
	endcase
end

always @(*)begin
	for (i = 0;i<16;i++) begin
		delay_reg_ns[i] = delay_reg[i];
	end
	case (cur_state) 
		IDLE: begin // read the input
			if (in_valid) begin
				if (in_cnt < 16) begin
					//source_reg_ns [in_cnt] = source;
					//destination_reg_ns [in_cnt] = destination;
					delay_reg_ns [in_cnt] = delay;
				end
				else begin
					//source_reg_ns [in_cnt] = source;
					//destination_reg_ns [in_cnt] = destination;
					for (i = 0;i<16;i++) begin
						delay_reg_ns[i] = delay_reg[i];
					end
				end
			end
			else begin
				for(i = 0;i<16;i++) begin
					delay_reg_ns [i] = delay_reg[i];
				end
				//for (i = 0;i<32;i++) begin
					//source_reg_ns [i] = source_reg[i];
					//destination_reg_ns [i] = destination_reg[i];					
				//end	
			end
			/////////does it need else?
		end
		default: begin
			for (i = 0 ; i<16; i++) begin
				//source_reg_ns [i] = source_reg[i];
				//destination_reg_ns [i] = destination_reg[i];
				delay_reg_ns [i] = delay_reg [i];
			end	
			//for (i = 16 ; i<32 ; i++) begin
				//source_reg_ns [i] = source_reg[i];
				//destination_reg_ns [i] = destination_reg[i];
				//delay_reg_ns[i] = delay_reg[i];				
			//end		
		end
	endcase
end

always @(*) begin
	in_cnt_ns = in_cnt; 

	if (cur_state == QUEUE) begin
		in_cnt_ns = 0; // reset to 0
	end 
end
/*
always @(*) begin
	cnt0 = 0;
	cnt1 = 0;
	cnt2 = 0;
	cnt3_ns = cnt3;
	for (i = 0; i<16;i++) begin
		queue_ns [i] = queue[i];
	end
	case(cur_state)
		IDLE: begin
			for (i = 0 ; i< 16;i++) begin
				queue_ns[i] = 0;
			end
			cnt3_ns = 0;
		end
		QUEUE: begin
		case (in_queue_cnt) 
			0: begin
				if (in_degree[0] == 0 && visited[0] == 0) begin
					queue_ns [0] = 0;
					cnt0 = 1;
				end
				else begin
					queue_ns [0] = 0;
					cnt0 = 0;
				end
				if (in_degree[1] == 0 && visited[1] == 0) begin
					queue_ns [cnt0] = 1;
					cnt1 = cnt0 + 1;
				end
				else begin
					queue_ns[cnt0] = 0;
					cnt1 = cnt0;
				end
				if (in_degree[2] == 0 && visited[2] == 0) begin
					queue_ns [cnt1] = 2;
					cnt2 = cnt1 + 1;
				end
				else begin
					queue_ns[cnt1] = 0;
					cnt2 = cnt1;
				end
				if (in_degree[3] == 0 && visited[3] == 0) begin
					queue_ns [cnt2] = 3;
					cnt3_ns = cnt2 + 1;
				end
				else begin
					queue_ns[cnt2] = 0;
					cnt3_ns = cnt2;
				end
			end
			1: begin
				if (in_degree[4] == 0 && visited[4] == 0) begin
					queue_ns [cnt3] = 4;
					cnt0 = cnt3 + 1;
				end
				else begin
					queue_ns [cnt3] = 0;
					cnt0 = cnt3;
				end
				if (in_degree[5] == 0 && visited[5] == 0) begin
					queue_ns [cnt0] = 5;
					cnt1 = cnt0 + 1;
				end
				else begin
					queue_ns[cnt0] = 0;
					cnt1 = cnt0;
				end
				if (in_degree[6] == 0 && visited[6] == 0) begin
					queue_ns [cnt1] = 6;
					cnt2 = cnt1 + 1;
				end
				else begin
					queue_ns[cnt1] = 0;
					cnt2 = cnt1;
				end
				if (in_degree[7] == 0 && visited[7] == 0) begin
					queue_ns [cnt2] = 7;
					cnt3_ns = cnt2 + 1;
				end
				else begin
					queue_ns[cnt2] = 0;
					cnt3_ns = cnt2;
				end
			end
			2: begin
				if (in_degree[8] == 0 && visited[8] == 0) begin
					queue_ns [cnt3] = 8;
					cnt0 = cnt3 + 1;
				end
				else begin
					queue_ns [cnt3] = 0;
					cnt0 = cnt3;
				end
				if (in_degree[9] == 0 && visited[9] == 0) begin
					queue_ns [cnt0] = 9;
					cnt1 = cnt0 + 1;
				end
				else begin
					queue_ns[cnt0] = 0;
					cnt1 = cnt0;
				end
				if (in_degree[10] == 0 && visited[10] == 0) begin
					queue_ns [cnt1] = 10;
					cnt2 = cnt1 + 1;
				end
				else begin
					queue_ns[cnt1] = 0;
					cnt2 = cnt1;
				end
				if (in_degree[11] == 0 && visited[11] == 0) begin
					queue_ns [cnt2] = 11;
					cnt3_ns = cnt2 + 1;
				end
				else begin
					queue_ns[cnt2] = 0;
					cnt3_ns = cnt2;
				end
			end
			3: begin
				if (in_degree[12] == 0 && visited[12] == 0) begin
					queue_ns [cnt3] = 12;
					cnt0 = cnt3 + 1;
				end
				else begin
					queue_ns [cnt3] = 0;
					cnt0 = cnt3;
				end
				if (in_degree[13] == 0 && visited[13] == 0) begin
					queue_ns [cnt0] = 13;
					cnt1 = cnt0 + 1;
				end
				else begin
					queue_ns[cnt0] = 0;
					cnt1 = cnt0;
				end
				if (in_degree[14] == 0 && visited[14] == 0) begin
					queue_ns [cnt1] = 14;
					cnt2 = cnt1 + 1;
				end
				else begin
					queue_ns[cnt1] = 0;
					cnt2 = cnt1;
				end
				if (in_degree[15] == 0 && visited[15] == 0) begin
					queue_ns [cnt2] = 15;
					cnt3_ns = cnt2 + 1;
				end
				else begin
					queue_ns[cnt2] = 0;
					cnt3_ns = cnt2;
				end
			end
		POP: begin
			cnt3_ns = 0;
		end
		endcase
		end
	endcase
end
always @(*) begin
	if (cur_state == IDLE) begin
		in_queue_cnt_ns = 0;
	end
	else if (cur_state == QUEUE) begin
		in_queue_cnt_ns = in_queue_cnt + 1;
	end
	else if (cur_state == POP) begin
		in_queue_cnt_ns = 0;
	end
	else begin
		in_queue_cnt_ns = in_queue_cnt;
	end
end
always @(*) begin
	case(cur_state)
		//queue_total_ns = queue_total;
		IDLE: begin
			queue_total_ns = 0;
		end
		QUEUE: begin
			if (in_queue_cnt == 3) begin
				queue_total_ns = queue_total + cnt3_ns;
			end 
			else begin
				queue_total_ns = queue_total;
			end
		end
		POP: begin
			if (pop_cnt == queue_total - 1) begin
				queue_total_ns = 0; //nxt_state = QUEUE
			end
			else begin
				queue_total_ns = queue_total;
			end
		end
		default: begin
			queue_total_ns = queue_total;
		end
	endcase
end
always @(*) begin
	if (cur_state == POP) begin
		pop_cnt_ns = pop_cnt + 1;
	end
	else begin
		pop_cnt_ns = 0;
	end
end
*/
/*
always @(*) begin
	for(i = 0;i<16;i++) begin
		for(j = 0;j<16;j++) begin
			dependency_ns[i][j] = dependency[i][j];
		end
	end
	case (cur_state) 
		IDLE: begin
			if (in_valid) begin
				dependency_ns[source][destination] = 1;
			end
			else begin
				for (i = 0;i<16;i++) begin
					for (j = 0;j<16;j++) begin
						dependency_ns[i][j] = dependency[i][j];
					end
				end
			end
		end
		DONE:begin
			for (i = 0;i<16;i++) begin
				for (j = 0;j<16;j++) begin
					dependency_ns[i][j] = 0;
				end
			end			
		end
		default: begin
			for (i = 0; i<16;i++) begin
				for (j = 0; j <16; j++) begin
					dependency_ns[i][j] = dependency[i][j];
				end
			end
		end
	endcase
end
always @(*) begin
	case (cur_state)
	    IDLE: begin
	    	for (i = 0 ; i < 16 ; i++) begin
	    		distance_ns[i] = 0;
	    	end
	    end
        BACK: begin
            //node = order[back_cnt];
            for (i = 0;i<16;i++) begin
                if (dependency[order[back_cnt]][i] == 1) begin
                    if (distance[i] <= distance[order[back_cnt]] + delay_reg[order[back_cnt]]) begin
                        distance_ns[i] = distance[order[back_cnt]] + delay_reg[order[back_cnt]];
                    end
                    else begin
                        distance_ns[i] = distance[i];
                    end
                end
				else begin
					distance_ns[i] = distance[i];
				end
            end
        end

		default: begin
			for (i = 0 ; i < 16 ; i++) begin
				distance_ns[i] = distance[i];
			end
		end
	endcase
end
always @(*) begin
	for (i = 0 ; i < 16 ; i++) begin
	    parent_ns[i] = parent[i];
	end	
	case (cur_state)
	    IDLE: begin
		    for (i = 0 ; i < 16 ; i++) begin
			    parent_ns[i] = 0;
		    end
		end
        BACK: begin
            //node = order[back_cnt];
            for (i = 0;i<16;i++) begin
                if (dependency[order[back_cnt]][i] == 1) begin
                    if (distance[i] <= distance[order[back_cnt]] + delay_reg[order[back_cnt]]) begin
                        parent_ns[i] = order[back_cnt];
                    end
                    else begin
                        parent_ns[i] = parent[i];
                    end
                end
				else begin
					parent_ns[i] = parent[i];
				end
            end
        end
	default:begin
		for (i = 0 ; i < 16 ; i++) begin
			parent_ns[i] = parent[i];
		end
	end
	endcase	
end
*/
always @(*) begin
    if (cur_state == IDLE) begin
        worst_delay_ns = 0;
    end
    else if (cur_state == DONE && !out_valid_f) begin
        worst_delay_ns = distance[1] + delay_reg[1] ;
    end
    else begin
        worst_delay_ns = 0;
    end
end
/*
always @(*) begin
    back_cnt_ns = back_cnt;
    if (cur_state == IDLE) begin
        back_cnt_ns = 0;
    end
    else if (cur_state == BACK) begin
        back_cnt_ns = back_cnt + 1;
    end

end
*/
/*
always @(*) begin
	for (i = 0 ; i < 16 ; i++) begin
		order_ns[i] = order[i];
	end
	case (cur_state)
		IDLE: begin
			for (i = 0 ; i < 16 ; i++) begin
				order_ns[i] = 0;
			end
		end
		POP: begin
			order_ns[order_cnt] = queue[pop_cnt];
		end
		default: begin
			for (i = 0 ; i < 16 ; i++) begin
				order_ns[i] = order[i];
			end
	end
	endcase	
end

always @(*) begin
	order_cnt_ns = order_cnt;
	case (cur_state)
		IDLE: begin
			order_cnt_ns = 0;
		end
		POP: begin
			order_cnt_ns = order_cnt_ns +1;
		end
	endcase
end
*/
/*
always @(*) begin
	for (i = 0 ; i<16;i++) begin
		for (j = 0;j<16;j++) begin
			in_degree_ns [i] = in_degree[i];
		end
	end	
	case (cur_state) 
		IDLE:begin
			for (i = 0;i<16;i++) begin
				in_degree_ns[i] = in_degree[i];
			end
		end
		POP: begin
			for (i = 0;i<16;i++) begin
				if (dependency[queue[pop_cnt]][i] == 1) begin
					in_degree_ns[i] = in_degree[i] -1;
				end
				else begin
					in_degree_ns[i] = in_degree[i];
				end
			end
		end
		//reset in_degree formula to be ready to IDLE
		DONE: begin
			for (i = 0 ; i<16;i++) begin
				for (j = 0;j<16;j++) begin
					in_degree_ns [i] = 0;
				end
			end
		end
	endcase
end
*/
/*
always @(*) begin
	for (i = 0 ; i<16;i++) begin
		for (j = 0;j<16;j++) begin
			visited_ns [i] = visited[i];
		end
	end
	case (cur_state)
		IDLE: begin
			for (i = 0;i<16;i++) begin
				for (j = 0 ;j<16;j++) begin
					visited_ns[i] = 0;
				end
			end		
		end
		QUEUE:begin
			case (in_queue_cnt) 
			0: begin
				if (in_degree[0] == 0 && visited[0] == 0) begin
					visited_ns[0] = 1;
				end
				else begin
					visited_ns[0] = visited[0];
				end
				if (in_degree[1] == 0 && visited[1] == 0) begin
					visited_ns[1] = 1;
				end
				else begin
					visited_ns[1] = visited[1];
				end
				if (in_degree[2] == 0 && visited[2] == 0) begin
					visited_ns[2] = 1;
				end
				else begin
					visited_ns[2] = visited[2];
				end
				if (in_degree[3] == 0 && visited[3] == 0) begin
					visited_ns[3] = 1;
				end
				else begin
					visited_ns[3] = visited[3];
				end
			end
			1: begin
				if (in_degree[4] == 0 && visited[4] == 0) begin
					visited_ns[4] = 1;
				end
				else begin
					visited_ns[4] = visited[4];
				end
				if (in_degree[5] == 0 && visited[5] == 0) begin
					visited_ns[5] = 1;
				end
				else begin
					visited_ns[5] = visited[5];
				end
				if (in_degree[6] == 0 && visited[6] == 0) begin
					visited_ns[6] = 1;
				end
				else begin
					visited_ns[6] = visited[6];;
				end
				if (in_degree[7] == 0 && visited[7] == 0) begin
					visited_ns[7] = 1;
				end
				else begin
					visited_ns[7] = visited[7];;
				end
			end
			2: begin
				if (in_degree[8] == 0 && visited[8] == 0) begin
					visited_ns[8] = 1;
				end
				else begin
					visited_ns[8] = visited[8];
				end
				if (in_degree[9] == 0 && visited[9] == 0) begin
					visited_ns[9] = 1;
				end
				else begin
					visited_ns[9] = visited[9];
				end
				if (in_degree[10] == 0 && visited[10] == 0) begin
					visited_ns[10] = 1;
				end
				else begin
					visited_ns[10] = visited[10];
				end
				if (in_degree[11] == 0 && visited[11] == 0) begin
					visited_ns[11] = 1;
				end
				else begin
					visited_ns[11] = visited[11];
				end
			end
			3: begin
				if (in_degree[12] == 0 && visited[12] == 0) begin
					visited_ns[12] = 1;
				end
				else begin
					visited_ns[12] = visited[12];
				end
				if (in_degree[13] == 0 && visited[13] == 0) begin
					visited_ns[13] = 1;
				end
				else begin
					visited_ns[13] = visited[13];
				end
				if (in_degree[14] == 0 && visited[14] == 0) begin
					visited_ns[14] = 1;
				end
				else begin
					visited_ns[14] = visited[14];
				end
				if (in_degree[15] == 0 && visited[15] == 0) begin
					visited_ns[15] = 1;
				end
				else begin
					visited_ns[15] = visited[15];
				end
			end
			endcase
		end
	endcase
end
*/
always @(*) begin
    if (cur_state == QUEUE) begin //originally back
        start_ns = 1;
    end
    else if (cur_state == PATH) begin
        start_ns = parent[start];
    end
    else begin
        start_ns = start;
    end
end
always @(*) begin
    for (i=0;i<16;i++) begin
        path_reg_ns[i] = path_reg[i];
    end
    case (cur_state)
        IDLE: begin
            for (i=0;i<16;i++) begin
                path_reg_ns[i] = 0;
            end
        end
        PATH:begin
            path_reg_ns[path_cnt] = start;
        end
    endcase
end
always @(*) begin
    if (cur_state == IDLE) begin
        path_cnt_ns = 0;
    end
    else if (cur_state == PATH) begin
        path_cnt_ns = path_cnt + 1;
    end
	else if (cur_state == DONE && first) begin
		path_cnt_ns = path_cnt - 1;
	end
    else begin
        path_cnt_ns = path_cnt;
    end
end
//output

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid_f <= 0;
    end
    else begin
        out_valid_f <= out_valid_ns;
    end
end
always @(*) begin
	if (cur_state == DONE) begin
		out_valid_f_ns = 1; 
	end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else begin
        out_valid <= out_valid_ns;
    end
end
always @(*) begin
    if (cur_state == DONE && path_cnt != 0 ) begin
        out_valid_ns = 1;
    end
	/*
	else if (cur_state == DONE && path_cnt == 0) begin
		out_valid_ns = 0;
	end
	*/
    else begin
        out_valid_ns = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        worst_delay <= 0;
    end
    else begin
        worst_delay <= worst_delay_ns;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        path <=0;
    end
    else if (cur_state == DONE) begin
        path <= path_ns;
    end
    else begin
        path <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		first <= 0;
	end
	else begin
		first <= first_ns;
	end
end
always @(*) begin
	first_ns = first;
	if (cur_state == IDLE) begin
		first_ns = 0;
	end
	else if (parent[start] == 0 && cur_state == DONE) begin
		first_ns = 1;
	end
end

always @(*) begin
	if (parent[start] == 0 && cur_state == DONE && !first) begin
		path_ns = 0; // the first point
	end
	else if ((cur_state == DONE)&& (path_cnt!=0)) begin
        path_ns = path_reg[path_cnt-1];
    end
	else begin
		path_ns = 0;
	end
end

endmodule