// TestBench bit_timer
`include "timescale.v"
// delay between clock posedge and check
`define DELAY 2
// verification level: RTL_LVL GATE_LVL
`define RTL_LVL

module tb_i2c_bit_timer(); // module name (same as the file)
  //___________________________________________________________________________
  // input output signals for the DUT
  parameter SIZE = 8;      // data size of the shift register
  reg             clk;     // rellotge del sistema
  reg             rst_n;   // reset del sistema asíncorn i actiu nivell baix
  reg             ticks;   // Valor inicial configurable
  reg             start;   // El temporitzador ha de poder tornar al valor inicial en qualsevol moment i mantenir-se en aquest mentre la senyal de Start estigui activa.  
  reg             stop;    // El temporitzador ha de poder parar-se sempre que no s’estigui reiniciant. Per fer-ho, heu d’incloure una entrada que anomenarem Stop, activa per nivell alt.
  reg             out;     //
  reg             outcount;
  
  // test signals
  integer         errors;    // Accumulated errors during the simulation
  integer         bitCntr;   // used to count bits
  integer         t1,t2; // Used to count time ------------------------
  reg  [SIZE-1:0] vExpected;  // expected value
  reg  [SIZE-1:0] vObtained; // obtained value

  //___________________________________________________________________________
  // Instantiation of the module to be verified
  `ifdef RTL_LVL
  i2c_bit_timer #(.SIZE(SIZE)) DUT(
  `else
  i2c_bit_timer DUT( // used by post-síntesis verification
  `endif
    .Clk           (clk),
    .Rst_n         (rst_n),
    .Ticks         (ticks),
    .Start         (start),
    .Stop          (stop),
    .Out           (out),
    .OutCount      (outcount)
  );

  //___________________________________________________________________________
  // 100 MHz clock generation
  initial clk = 1'b0;
  always #5 clk = ~ clk;


  //___________________________________________________________________________
  // signals and vars initialization
  initial begin
    rst_n  = 1'b1;
    ticks  = {SIZE{1'b0}};
    stop_cntr = {SIZE{1'b0}};
    start  = 1'b0;
    stop   = 1'b0;
  end

  //___________________________________________________________________________
  // Test Vectors

  initial begin
    $timeformat(-9, 2, " ns", 10); // format for the time print
    errors = 0;                    // initialize the errors counter
    reset;                         // puts the DUT in a known stage
    wait_cycles(5);                // waits 5 clock cicles

    $display("[Info- %t] Test Timer", $time);
    ticks = 1'h01;
    stop_cicles = 2;

    test_polsos(ticks, stop_cicles);
    v_Expected = ticks + stop_cicles;
    async_check;
    check_errors;
  end

  //___________________________________________________________________________
  // Test tasks
      
    task test_polsos;
    //Verifiqui el nombre de cicles de rellotge entre dos polsos de sortida consecutius. 
    //Indiqui el temps transcorregut entre dos polsos consecutius. Ajuda: $realtime $time $monitor $display $while. 
 	//Tingui una entrada per escollir el límit de temporitzador. Ajut: quan límit és 0 cas especial! Mostreu un missatge que ho digui.
 	input ticks_test{SIZE{0'b0}};
 	input stop_cicles;
 	begin
 		if(ticks_test == 0)
 			$display("[Info- %t] ticks is 0!");

 		else if(OutCount == ticks_test /2)
 			repeat(stop_cicles) begin
 				stop = 1;
 			end
 			stop = 0;


 		else 			
 			@(posedge out)
 				t1 = $time  // Registrem el temps de la primera posada del out a 1 com a t1
 		    @(posedge out)
 				t2 = $time  // Registrem el temps de la segona posada del out a 1 com a t2
 			v_Obtained = t2-t1;
 		end
 	end
 	endtask

 	//Tingui una entrada per escollir quants cicles es para el temporitzador duran el comptatge.  
	//Ajut 1: 0 cicles vol dir que no es para. 
	//Ajut 2: feu que es pari quan el comptador va per la meitat. 

  endtask



   
  //___________________________________________________________________________
  // Basic tasks

  task reset;
    // generation of reset pulse
    begin
      $display("[Info- %t] Reset", $time);
      rst_n = 1'b0;
      wait_cycles(3);
      rst_n = 1'b1;
    end
  endtask

  task wait_cycles;
    // wait for N clock cycles
    input [32-1:0] Ncycles;
    begin
      repeat(Ncycles) begin
        @(posedge clk);
          #`DELAY;
      end
    end
  endtask

  task sync_check;
    // synchronous output check
    begin
      wait_cycles(1);
      if (vExpected != vObtained) begin
        $display("[Error! %t] The value is %h and should be %h", $time, vObtained, vExpected);
        errors = errors + 1;
      end else begin
        $display("[Info- %t] Successful check at time", $time);
      end
    end
  endtask

  task async_check;
    // asynchronous output check
    begin
      #`DELAY;
      if (vExpected != vObtained) begin
        $display("[Error! %t] The value is %h and should be %h", $time, vObtained, vExpected);
        errors = errors + 1;
      end else begin
        $display("[Info- %t] Successful check at time", $time);
      end
    end
  endtask

  task check_errors;
    // check for errors during the simulation
    begin
      if (errors==0) begin
        $display("********** TEST PASSED **********");
      end else begin
        $display("********** TEST FAILED **********");
      end
    end
  endtask

endmodule
