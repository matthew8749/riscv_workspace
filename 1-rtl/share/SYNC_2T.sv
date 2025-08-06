module SYNC_2T (/*AUTOARG*/
   // Outputs
   sync_o, sync_pulse,
   // Inputs
   rstn, clk, sync_i
   );
/*AUTOINPUT*/
/*AUTOOUTPUT*/
/*AUTOINOUT*/
/*AUTOWIRE*/
/*AUTOREG*/

//---------------------------------------------------------
// Input/Output Descriptions
//---------------------------------------------------------
input          rstn       ;
input          clk        ;
input          sync_i     ;

output         sync_o     ;
output         sync_pulse ;

//---------------------------------------------------------
// reg/wire declarations
//---------------------------------------------------------
reg    [2:0]   sync_i_d   ;

//---------------------------------------------------------
// Combination logic
//---------------------------------------------------------
wire           sync_o     = sync_i_d[1] ;
wire           sync_pulse = sync_i_d[1] & ~sync_i_d[2] ;

//---------------------------------------------------------
// Sequential logic
//---------------------------------------------------------
always @(posedge clk or negedge rstn) begin
  if (~rstn) begin
      sync_i_d <= 3'd0 ;
  end
  else begin   
      sync_i_d <= {sync_i_d[1], sync_i_d[0], sync_i} ;
  end
end

endmodule
