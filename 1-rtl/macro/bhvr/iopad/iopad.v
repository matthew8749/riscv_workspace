module  iopad (PAD, I, OE, C);
inout   PAD;
input   I, OE;
output  C;

wire    PAD = OE ? I : 1'bz;
wire    C = PAD;
endmodule
