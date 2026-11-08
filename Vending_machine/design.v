module Vending(clk, rst, coin, product_dispense, return_change);
  input clk, rst;
  input [1:0] coin;
  output reg [2:0] return_change = 0;
  output reg product_dispense = 0;

  reg [2:0] amount = 0;
  reg count = 0;

  parameter s0 = 0, s1 = 1, s2 = 2;
  reg [1:0] state = s0;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= s0;
      amount <= 0;
      count <= 0;
      product_dispense <= 0;
      return_change <= 0;
    end else begin
      if (count == 1) begin
        count <= 0;
        product_dispense <= 0;
        return_change <= 0;
        amount <= 0;
      end

      if (coin == 2'b01 || coin == 2'b10) begin
        amount <= amount + coin;
        if (amount + coin >= 5)
          state <= s2;
        else
          state <= s1;
      end
    end
  end

  always @(state) begin
    case (state)
      s0: begin
       
        product_dispense = 0;
        return_change = 0;
      end
      s1: begin
        product_dispense = 0;
        return_change = 0;
      end
      s2: begin
        product_dispense = 1;
        return_change = amount - 5;
        count = 1;
      end
    endcase
  end
endmodule
