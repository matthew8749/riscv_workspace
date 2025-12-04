// from :  https://community.cadence.com/cadence_technology_forums/f/logic-design/34786/clock-gating-timing-report-with-synthesized-icg-cell

module ICG_posedge(
  input ck_in,
  input enable,
  input test,
  output ck_out  

);

reg en1;
wire tm_out, ck_inb;

assign tm_out = enable | test ;
assign ck_inb = ~ck_in;

always @(ck_inb, tm_out)
      if(ck_inb)
        en1 = tm_out;
              
assign ck_out = ck_in & en1;
endmodule
