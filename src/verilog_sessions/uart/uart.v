/*

 UART transmitter for DE0 Nano
 
 */

module uart(
  //////////// CLOCK //////////
  input 		          		CLOCK_50,
  //////////// LED //////////
  output		     [7:0]		LED,
  //////////// KEY //////////
  input 		     [1:0]		KEY,
  //////////// SW //////////
  input 		     [3:0]		SW,

  output reg                                    UART_TX,
  output                                        UART_VCC
);

   // Some register and wire declarations
   reg [3:0] transmit_state;
   reg [7:0] transmit_data;
   reg 	     key1_reg;
   wire      key1_edge_detect;
   
   // Reset
   wire 					reset;
   assign reset = ~KEY[0];

   // Tie UART_VCC high - it's used to drive the buffer on the UART board
   assign UART_VCC = 1;
   
   //UART transmit at 115200 baud from 50MHz clock
   reg [7:0] 					clock_divider_counter;
   reg 						uart_clock;


   // Clock counter
   /*
    What must this counter to do allow us to generate
    a 115.2kHz clock down below?
    */   
   always @(posedge CLOCK_50) 
     begin
	if (reset == 1'b1)
	  clock_divider_counter <= 0;
	else if (/* when might we want this counter to go back to zero?*/)
	  clock_divider_counter <= 0;
	else
	  // Otherwise increment the counter
	  clock_divider_counter <= clock_divider_counter + 1;
     end

   // Generate a clock (toggle this register)
   always @(posedge CLOCK_50) 
     begin
	if (reset == 1'b1)
	  uart_clock <= 0;
	else if (/*What condition here to make the clock toggle? 
		  Think about the value of teh clock_divider_counter */)
	  uart_clock <= ~uart_clock;
     end
   
   always @(posedge uart_clock or posedge reset)
     begin
	if (reset)
	  begin
	     // Reset to the "IDLE" state
	     transmit_state <= 0;

	     // The UART line is set to '1' when idle, or reset
	     UART_TX <= 1;

	     // Data we'll transmit - start at ASCII '0'
	     transmit_data <= 8'h30;
	     
	  end
	else
	  begin
	     // What follows is the skeleton of the state machine to control
	     // the bits going onto the UART transmit line.
	     // You will want to, from the idle state:
	     // 1. detect the pushbutton press and go to the the start bit state
	     // 2. then the 8 data bits (LSB first)
	     // 3. finally the stop bit
	     // 4. return to this state ready for the next transmit
	     case (transmit_state)
	       0:
		 begin
		    // Idle state - We want to transition to the start bit state
		    //              when the pushbutton is pressed. (A signal
		    //              detecting this is provided.)
		    //              Hint: You can assign the start bit to the 
		    //              UART TX line in this state as we transition.
		 end
	       1:
		 begin
		    // Start bit state
		 end
	       2,3,4,5,6,7,8:
		 begin
		    // Data bits
		 end
	       9:
		 begin
		    // Stop bit, and transition back to idle (0)
		 end
	       default:
		 // Shouldn't reach here, but just incase, go back to idle!
		 transmit_state <= 0;
	     endcase
	  end
     end

   // Sample the pushbutton
   always @(posedge uart_clock)
     key1_reg <= KEY[1];

   // Detect the change in level
   assign key1_edge_detect = ~KEY[1] & key1_reg;

   // Output the transmit data on the LEDs
   assign LED = transmit_data;

endmodule
