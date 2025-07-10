//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Two Head Attention
//   Author     		: Yu-Chi Lin (a6121461214.st12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : ATTN.v
//   Module Name : ATTN
//   Release version : V1.0 (Release Date: 2025-3)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`define CYCLE_TIME      50.0
`define SEED_NUMBER     28825252
`define PATTERN_NUMBER 100
`define SEED 12345
module PATTERN(
    //Output Port
    clk,
    rst_n,

    in_valid,
    in_str,
    q_weight,
    k_weight,
    v_weight,
    out_weight,

    //Input Port
    out_valid,
    out
    );

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
output  logic        clk, rst_n, in_valid;
output  logic[31:0]  in_str;
output  logic[31:0]  q_weight;
output  logic[31:0]  k_weight;
output  logic[31:0]  v_weight;
output  logic[31:0]  out_weight;

input           out_valid;
input   [31:0]  out;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
real CYCLE = `CYCLE_TIME;
integer SEED;
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;

integer f_in,i_pat,patnum, total_latency, latency,a, golden,lat;
integer str_in,q_in,k_in,v_in,output_in,output_weight_in;
integer total_lat;
//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
  integer fd, r, i;
  string line;
  
  real gold[0:4][0:3];
  real val1, val2, val3, val4;
  integer out_num;
  reg [31:0] dut_data;
  reg [31:0] exp_data;
  reg [31:0] gold_out[0:4][0:3];
//================================================================
// clock
//================================================================

always #(CYCLE/2.0) clk = ~clk;
initial	clk = 0;

//---------------------------------------------------------------------
//   Pattern_Design
//---------------------------------------------------------------------
initial begin
	SEED=567;
    // Open input and output files
    str_in  = $fopen("../00_TESTBED/in_str_hex.txt", "r");
    q_in  = $fopen("../00_TESTBED/q_weight_hex.txt", "r");
    k_in  = $fopen("../00_TESTBED/k_weight_hex.txt", "r");
    v_in  = $fopen("../00_TESTBED/v_weight_hex.txt", "r");
    output_weight_in=$fopen("../00_TESTBED/out_weight_hex.txt", "r");
    output_in = $fopen("../00_TESTBED/output_hex.txt", "r");
    if (str_in == 0||q_in==0||k_in ==0||v_in==0) begin
        $display("Failed to open input file");
        $finish;
    end
    // Initialize signals
    reset_task;

	a = $fscanf(str_in, "%d", patnum);
    a = $fscanf(q_in, "%d", patnum);
    a = $fscanf(k_in, "%d", patnum);
    a = $fscanf(v_in, "%d", patnum);
    a = $fscanf(output_weight_in, "%d", patnum);
    a = $fscanf(output_in, "%d", patnum);
    // Iterate through each pattern
    for (i_pat = 0; i_pat < patnum; i_pat = i_pat + 1) begin
      //a = $fscanf(f_in, "%d", i_pat);
      input_task;
      wait_out_valid_task;
      check_ans_task;
      //$display("%c[5;34m",27);
      //$display("pass pat: %d!   Latency=%d",i_pat,latency);
      //$display("%c[0m",27);
      $display("\033[32m pass pat: %d   Latency=%d \033[0m",i_pat,latency);

      repeat(($urandom(SEED) % 3 + 2)) @(negedge clk);
    end
	  display_pass_task;
	$finish;
end

task reset_task;begin
    rst_n = 1'b1;
    in_valid = 1'b0;
    total_latency = 0;
    q_weight = 32'bx;
    v_weight = 32'bx;
    k_weight = 32'bx;
    out_weight = 32'bx;
    in_str = 32'bx;
    force clk = 0;
    // Apply reset
    #CYCLE; rst_n = 1'b0; 
    #(10*CYCLE); 
    rst_n = 1'b1;
	  

    // Check initial conditions
    if (out_valid !== 1'b0 || out !== 32'b0) begin
        $display("                    You need to reset output                   ");
        repeat (1) #CYCLE;
        $finish;
    end
    #CYCLE;
    release clk;
    #(2*CYCLE); 
	
	
end
endtask
always @(negedge clk) begin
    if ((in_valid===1 && out_valid===1)) begin
        $display("                    SPEC-5 FAIL                   ");
        $finish;            
    end
	else if ( (out_valid===0 && out !==0)) begin
        $display("                    SPEC-6 FAIL                   ");
        $finish;            
    end     
end
task wait_out_valid_task; begin
    latency =0;
    while (out_valid === 0) begin
        latency = latency + 1;
        if (latency == (200*CYCLE)) begin
            display_fail_task;
            $display("                  exceed 200 cycles                   ");
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end endtask

task input_task; begin
    
	@(negedge clk);
	in_valid = 1'b1;
  for(i = 0 ; i < 16 ; i = i + 1)begin
      a = $fscanf(str_in, "%h", in_str);
      a = $fscanf(k_in, "%h", k_weight);
      a = $fscanf(q_in, "%h", q_weight);
      a = $fscanf(v_in, "%h",v_weight);
      a = $fscanf(output_weight_in, "%h",out_weight);
      @(negedge clk);
  end
  q_weight = 32'bxxxx;
	v_weight = 32'bxxxx;
	out_weight = 32'bxxxx;
	k_weight = 32'bxxxx;
	latency = 1;
	for (i = 16 ; i < 20 ; i = i + 1) begin
		a = $fscanf(str_in, "%h", in_str);
		@(negedge clk);
	end
	
  in_valid=1'b0;
	in_str = 32'bxxxx;
	
end endtask
reg [31:0]golden_out[0:19];
real golden_value[0:19];
real error_value[0:19];
real out_value;
task check_ans_task;
    begin
        lat = 0;
        for (i=0;i<20;i=i+1)
        begin
            a = $fscanf(output_in, "%h", golden_out[i]);
            golden_value[i]  = $bitstoshortreal(golden_out[i]);
        end

        while(out_valid === 1)
        begin
            lat = lat + 1;
            out_value = $bitstoshortreal(out);
            error_value[lat-1] = $abs(out_value - golden_value[lat-1]);
            if(lat > 20)
            begin
                display_fail_task;
                $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
                $display ("                                                                        FAIL!                                                               ");
                $display ("                                                         out_valid should be high for 20 cycles                                              ");
                $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
                @(negedge clk);
                $finish;
            end
            if(error_value[lat-1] > 0.0000001)
            begin
                display_fail_task;
                $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
                $display ("                                                                       FAIL!                                                                ");
                $display ("                                                                      Code %d                                                               ", lat-1);
                $display ("                                           Your out is   : %f                                                                          ",out_value);
                $display ("                                           ans should be : %f                                                                          ",golden_value[lat-1]);
                $display ("                                           error         : %f                                                                               ",error_value[lat-1]);
                $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
                @(negedge clk);
                $finish;
            end
            @(negedge clk);
        end
        if(lat !== 20)
        begin
            display_fail_task;
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                                        FAIL!                                                               ");
            $display ("                                                         out_valid should be high for 20 cycles                                              ");
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            @(negedge clk);
            $finish;
        end
        
    end
endtask
// display pass task
task display_pass_task;
    begin
        $display("\033[1;33m                         `oo+oy+`                                                                                                     ");
        $display("\033[1;33m                        /h/----+y        `+++++:                                                                                      ");
        $display("\033[1;33m                      .y------:m/+ydoo+:y:---:+o                                                                                      ");
        $display("\033[1;33m                       o+------/y--::::::+oso+:/y                                                                                     ");
        $display("\033[1;33m                       s/-----:/:----------:+ooy+-                                                                                    ");
        $display("\033[1;33m                      /o----------------/yhyo/::/o+/:-.`                                                                              ");
        $display("\033[1;33m                     `ys----------------:::--------:::+yyo+                                                                           ");
        $display("\033[1;33m                     .d/:-------------------:--------/--/hos/                                                                         ");
        $display("\033[1;33m                     y/-------------------::ds------:s:/-:sy-                                                                         ");
        $display("\033[1;33m                    +y--------------------::os:-----:ssm/o+`                                                                          ");
        $display("\033[1;33m                   `d:-----------------------:-----/+o++yNNmms                                                                        ");
        $display("\033[1;33m                    /y-----------------------------------hMMMMN.                                                                      ");
        $display("\033[1;33m                    o+---------------------://:----------:odmdy/+.                                                                    ");
        $display("\033[1;33m                    o+---------------------::y:------------::+o-/h                                                                    ");
        $display("\033[1;33m                    :y-----------------------+s:------------/h:-:d                                                                    ");
        $display("\033[1;33m                    `m/-----------------------+y/---------:oy:--/y                                                                    ");
        $display("\033[1;33m                     /h------------------------:os++/:::/+o/:--:h-                                                                    ");
        $display("\033[1;33m                  `:+ym--------------------------://++++o/:---:h/                                                                     ");
        $display("\033[1;31m                 `hhhhhoooo++oo+/:\033[1;33m--------------------:oo----\033[1;31m+dd+                                                 ");
        $display("\033[1;31m                  shyyyhhhhhhhhhhhso/:\033[1;33m---------------:+/---\033[1;31m/ydyyhs:`                                              ");
        $display("\033[1;31m                  .mhyyyyyyhhhdddhhhhhs+:\033[1;33m----------------\033[1;31m:sdmhyyyyyyo:                                            ");
        $display("\033[1;31m                 `hhdhhyyyyhhhhhddddhyyyyyo++/:\033[1;33m--------\033[1;31m:odmyhmhhyyyyhy                                            ");
        $display("\033[1;31m                 -dyyhhyyyyyyhdhyhhddhhyyyyyhhhs+/::\033[1;33m-\033[1;31m:ohdmhdhhhdmdhdmy:                                           ");
        $display("\033[1;31m                  hhdhyyyyyyyyyddyyyyhdddhhyyyyyhhhyyhdhdyyhyys+ossyhssy:-`                                                           ");
        $display("\033[1;31m                  `Ndyyyyyyyyyyymdyyyyyyyhddddhhhyhhhhhhhhy+/:\033[1;33m-------::/+o++++-`                                            ");
        $display("\033[1;31m                   dyyyyyyyyyyyyhNyydyyyyyyyyyyhhhhyyhhy+/\033[1;33m------------------:/ooo:`                                         ");
        $display("\033[1;31m                  :myyyyyyyyyyyyyNyhmhhhyyyyyhdhyyyhho/\033[1;33m-------------------------:+o/`                                       ");
        $display("\033[1;31m                 /dyyyyyyyyyyyyyyddmmhyyyyyyhhyyyhh+:\033[1;33m-----------------------------:+s-                                      ");
        $display("\033[1;31m               +dyyyyyyyyyyyyyyydmyyyyyyyyyyyyyds:\033[1;33m---------------------------------:s+                                      ");
        $display("\033[1;31m               -ddhhyyyyyyyyyyyyyddyyyyyyyyyyyhd+\033[1;33m------------------------------------:oo              `-++o+:.`             ");
        $display("\033[1;31m                `/dhshdhyyyyyyyyyhdyyyyyyyyyydh:\033[1;33m---------------------------------------s/            -o/://:/+s             ");
        $display("\033[1;31m                  os-:/oyhhhhyyyydhyyyyyyyyyds:\033[1;33m----------------------------------------:h:--.`      `y:------+os            ");
        $display("\033[1;33m                  h+-----\033[1;31m:/+oosshdyyyyyyyyhds\033[1;33m-------------------------------------------+h//o+s+-.` :o-------s/y  ");
        $display("\033[1;33m                  m:------------\033[1;31mdyyyyyyyyymo\033[1;33m--------------------------------------------oh----:://++oo------:s/d  ");
        $display("\033[1;33m                 `N/-----------+\033[1;31mmyyyyyyyydo\033[1;33m---------------------------------------------sy---------:/s------+o/d  ");
        $display("\033[1;33m                 .m-----------:d\033[1;31mhhyyyyyyd+\033[1;33m----------------------------------------------y+-----------+:-----oo/h  ");
        $display("\033[1;33m                 +s-----------+N\033[1;31mhmyyyyhd/\033[1;33m----------------------------------------------:h:-----------::-----+o/m  ");
        $display("\033[1;33m                 h/----------:d/\033[1;31mmmhyyhh:\033[1;33m-----------------------------------------------oo-------------------+o/h  ");
        $display("\033[1;33m                `y-----------so /\033[1;31mNhydh:\033[1;33m-----------------------------------------------/h:-------------------:soo  ");
        $display("\033[1;33m             `.:+o:---------+h   \033[1;31mmddhhh/:\033[1;33m---------------:/osssssoo+/::---------------+d+//++///::+++//::::::/y+`  ");
        $display("\033[1;33m            -s+/::/--------+d.   \033[1;31mohso+/+y/:\033[1;33m-----------:yo+/:-----:/oooo/:----------:+s//::-.....--:://////+/:`    ");
        $display("\033[1;33m            s/------------/y`           `/oo:--------:y/-------------:/oo+:------:/s:                                                 ");
        $display("\033[1;33m            o+:--------::++`              `:so/:-----s+-----------------:oy+:--:+s/``````                                             ");
        $display("\033[1;33m             :+o++///+oo/.                   .+o+::--os-------------------:oy+oo:`/o+++++o-                                           ");
        $display("\033[1;33m                .---.`                          -+oo/:yo:-------------------:oy-:h/:---:+oyo                                          ");
        $display("\033[1;33m                                                   `:+omy/---------------------+h:----:y+//so                                         ");
        $display("\033[1;33m                                                       `-ys:-------------------+s-----+s///om                                         ");
        $display("\033[1;33m                                                          -os+::---------------/y-----ho///om                                         ");
        $display("\033[1;33m                                                             -+oo//:-----------:h-----h+///+d                                         ");
        $display("\033[1;33m                                                                `-oyy+:---------s:----s/////y                                         ");
        $display("\033[1;33m                                                                    `-/o+::-----:+----oo///+s                                         ");
        $display("\033[1;33m                                                                        ./+o+::-------:y///s:                                         ");
        $display("\033[1;33m                                                                            ./+oo/-----oo/+h                                          ");
        $display("\033[1;33m                                                                                `://++++syo`                                          ");
        $display("\033[1;0m");
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        $display ("                                                               Congratulations!                						                       ");
        $display("*                                                        Your execution cycles = %5d cycles                                                  ", total_latency);
        $display("*                                                        Your clock period = %.1f ns                                                         ", CYCLE);
        $display("*                                                        Total Latency = %.1f ns                                                             ", total_latency*CYCLE);
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        $finish;
    end
endtask

// display fail task
task display_fail_task;
    begin
        $display("                                                                                              ");
        $display("                                                                 ./+oo+/.                     ");
        $display("                                                                /s:-----+s`                   ");
        $display("                                                                y/-------:y                   ");
        $display("                                                           `.-:/od+/------y`                  ");
        $display("                                             `:///+++ooooooo+//::::-----:/y+:`                ");
        $display("                                            -m+:::::::---------------------::o+.              ");
        $display("                                           `hod-------------------------------:o+             ");
        $display("                                     ./++/:s/-o/--------------------------------/s///::.      ");
        $display("                                    /s::-://--:--------------------------------:oo/::::o+     ");
        $display("                                  -+ho++++//hh:-------------------------------:s:-------+/    ");
        $display("                                -s+shdh+::+hm+--------------------------------+/--------:s    ");
        $display("                               -s:hMMMMNy---+y/-------------------------------:---------//    ");
        $display("                               y:/NMMMMMN:---:s-/o:-------------------------------------+`    ");
        $display("                               h--sdmmdy/-------:hyssoo++:----------------------------:/`     ");
        $display("                               h---::::----------+oo+/::/+o:---------------------:+++s-`      ");
        $display("                               s:----------------/s+///------------------------------o`       ");
        $display("                         ``..../s------------------::--------------------------------o        ");
        $display("                     -/oyhyyyyyym:----------------://////:--------------------------:/        ");
        $display("                    /dyssyyyssssyh:-------------/o+/::::/+o/------------------------+`        ");
        $display("                  -+o/---:/oyyssshd/-----------+o:--------:oo---------------------:/.         ");
        $display("                `++--------:/sysssddy+:-------/+------------s/------------------://`          ");
        $display("               .s:---------:+ooyysyyddoo++os-:s-------------/y----------------:++.            ");
        $display("               s:------------/yyhssyshy:---/:o:-------------:dsoo++//:::::-::+syh`            ");
        $display("              `h--------------shyssssyyms+oyo:--------------/hyyyyyyyyyyyysyhyyyy`            ");
        $display("              `h--------------:yyssssyyhhyy+----------------+dyyyysssssssyyyhs+/.             ");
        $display("               s:--------------/yysssssyhy:-----------------shyyyyyhyyssssyyh.                ");
        $display("               .s---------------+sooosyyo------------------/yssssssyyyyssssyo                 ");
        $display("                /+-------------------:++------------------:ysssssssssssssssy-                 ");
        $display("                `s+--------------------------------------:syssssssssssssssyo                  ");
        $display("              `+yhdo--------------------:/--------------:syssssssssssssssyy.                  ");
        $display("              +yysyhh:-------------------+o------------/ysyssssssssssssssy/                   ");
        $display("               /hhysyds:------------------y-----------/+yyssssssssssssssyh`                   ");
        $display("               .h-+yysyds:---------------:s----------:--/yssssssssssssssym:                   ");
        $display("               y/---oyyyyhyo:-----------:o:-------------:ysssssssssyyyssyyd-                  ");
        $display("              `h------+syyyyhhsoo+///+osh---------------:ysssyysyyyyysssssyd:                 ");
        $display("              /s--------:+syyyyyyyyyyyyyyhso/:-------::+oyyyyhyyyysssssssyy+-                 ");
        $display("              +s-----------:/osyyysssssssyyyyhyyyyyyyydhyyyyyyssssssssyys/`                   ");
        $display("              +s---------------:/osyyyysssssssssssssssyyhyyssssssyyyyso/y`                    ");
        $display("              /s--------------------:/+ossyyyyyyssssssssyyyyyyysso+:----:+                    ");
        $display("              .h--------------------------:::/++oooooooo+++/:::----------o`                   ");
    end
endtask

endmodule


