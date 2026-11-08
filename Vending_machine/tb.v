// Code your testbench here
// or browse Examples
module testbench;
  reg clk, rst; reg [1:0]coin; wire [2:0]return_change; wire product_dispense;
  Vending uutobject(clk, rst, coin, product_dispense, return_change);
  initial
    begin
      $monitor($time,"clk=%b, rst=%b, coin=%b, return_change=%b, product_dispense=%b",clk, rst, coin, return_change, product_dispense);
      $dumpfile("machine.vcd"); $dumpvars(0, testbench);
      clk=1'b0; rst=1'b0; coin=0;
    end
  always #5 clk=~clk;
  initial begin
    #3 coin=1; #10 coin=2; #10 coin=1; #10 coin=2;
    #5 $finish;
  end
endmodule
