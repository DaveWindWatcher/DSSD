module i2c_bit_timer #(
	parameter SIZE = 8
)(
	input wire Clk,
	input wire Rst_n,
	input wire Ticks,                  // El valor inicial del ha de ser configurable, mitjançant una entrada de N-bits que anomenarem Ticks.
	input wire Start,                  // El temporitzador ha de poder tornar al valor inicial en qualsevol moment i mantenir-se en aquest mentre la senyal de Start estigui activa.  
	input wire Stop,                   // El temporitzador ha de poder parar-se sempre que no s’estigui reiniciant. Per fer-ho, heu d’incloure una entrada que anomenarem Stop, activa per nivell alt.
    output reg Out,
    output reg OutCount                // Podem visualitzar en quin nombre del comptador estem
	);
reg [SIZE-1:0] counter;                   // Counter timer

//backwards timer
always @(posedge Clk or negedge Rst_n)
	if(~Rst_n)
		counter <= 0;
	else if (Start || ~|counter)
		counter <= Ticks;
	else if (Stop)
		counter <= counter;
	else 
		counter <= counter -1;

always @(posedge Clk)
	if(counter == 0)
		Out <= 1;
	else 
		Out <= 0;
	
assign Out = Out;
assign OutCount = counter;


endmodule