
module Booth_Multiplier_tb;
  reg [13:0]data_in;
    reg start,clk;
    wire done;
    
  BOOTH DP(ldA, ldQ, ldM, clrA, clrQ, clrff, sftA, sftQ, addsub, decr, ldcnt, data_in, clk, qm1, eqz, q0);
    controller CON(ldA, clrA, sftA, ldQ, clrQ, sftQ, ldM, clrff, addsub, start, decr, ldcnt, done, clk, q0, qm1, eqz);
  wire [15:0]ans;
  assign ans={DP.A, DP.Q, qm1};
    initial begin
    
    clk=1'b0;
    start=1'b0;
    #3 start=1'b1;
    #500 $finish;
    end
    always #5 clk=~clk;

    initial begin
    #16 data_in=5;
    #10 data_in=8;
    end
    initial begin
      $monitor ($time, "clk=%b ans=%b done=%b ",clk, ans, done);
    $dumpfile("Booth_Multiplier_tb.vcd"); $dumpvars(0, Booth_Multiplier_tb);
    end
    
endmodule
