// +FHDR--------------------------------------------------------------------------------------------------------- //
// Project ____________                                                                                           //
// File name __________ async_fifo_pkg.sv                                                                         //
// Creator ____________ [Your Name]                                                                               //
// Built Date _________ YYYY-MM-DD                                                                                //
// Function ___________ Shared constants, parameters, and utility functions for Async FIFO                        //
// Hierarchy __________ Top-level package                                                                         //
// -FHDR--------------------------------------------------------------------------------------------------------- //
`timescale 1ns/10ps

package async_fifo_pkg;

  // --------------------------------------------
  // Parameterized Functions
  // --------------------------------------------

  // Binary to Gray code converter
  function automatic [WIDTH-1:0] bin2gray #(parameter int WIDTH = 5)
    (input [WIDTH-1:0] bin);
    bin2gray = (bin >> 1) ^ bin;
  endfunction

  // Gray code to Binary converter
  function automatic [WIDTH-1:0] gray2bin #(parameter int WIDTH = 5)
    (input [WIDTH-1:0] gray);
    integer i;
    begin
      gray2bin[WIDTH-1] = gray[WIDTH-1];
      for (i = WIDTH-2; i >= 0; i = i - 1)
        gray2bin[i] = gray2bin[i+1] ^ gray[i];
    end
  endfunction

  // --------------------------------------------
  // Optional: Common parameter macro
  // --------------------------------------------
  // Use `include if needed in other files
  localparam int DEFAULT_ADR_BIT = 4;
  localparam int DEFAULT_DAT_BIT = 32;

  // --------------------------------------------
  // Optional: FIFO status encoding
  // --------------------------------------------
  typedef enum logic [1:0] {
    FIFO_EMPTY   = 2'b00,
    FIFO_FULL    = 2'b01,
    FIFO_NORMAL  = 2'b10,
    FIFO_UNKNOWN = 2'b11
  } fifo_status_e;

endpackage