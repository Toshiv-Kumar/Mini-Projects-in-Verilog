module testbench;
  wire [2:0]stage; wire done; reg clk, rst, start, pause;
  washingMachine dutobject(clk, rst, start, pause, stage, done);
  initial begin
    $monitor($time,"clk=%b, rst=%b, start=%b, pause=%b, stage=%b, done=%b",clk, rst, start, pause, stage, done);
    $dumpfile("washing.vcd"); $dumpvars(0, testbench);
    clk=1'b0; rst=1'b0; start= 1'b0; pause=1'b0;
  end
  always #1 clk=~clk;
  
  initial
    begin
      #4 start=1'b1;
      #35 pause=1'b1;
      #10 pause=1'b0;
      #10 rst=1'b1;
      #3 rst=1'b0;
      #1 $finish;
    end
endmodule
