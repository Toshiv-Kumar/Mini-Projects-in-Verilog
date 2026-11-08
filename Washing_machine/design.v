module washingMachine(clk, rst, start, pause, stage, done);
  parameter idle=0, fill=1, wash=2, rinse=3, spin=4, donew=5;
  input clk, rst, start, pause;
  output reg [2:0]stage=idle;
  output reg done=0;
  reg [2:0]state=idle;
  reg [1:0]clkcount=0;
  reg [2:0]PS=idle;
  
  always @(posedge clk or posedge rst)
    begin
      if (rst==1)
        begin
          clkcount<=0;
          PS<=idle;
          state<=idle;
          done<=0;
          stage<=idle;
          
        end
      else if (start==1 && pause==0)
        begin
            state<=PS;
            if (clkcount<3) 
              clkcount<=clkcount+1;
            else begin
              clkcount<=0;
              
              if (state==idle && PS==idle)begin
                state<=fill;
                PS<=fill;
              end
              else if (PS==fill) begin
                state<=wash;
                PS<=wash;
              end
              else if (PS==wash) begin
                state<=rinse;
                PS<=rinse;
              end
              else if (PS==rinse) begin
                state<=spin;
                PS<=spin;
              end
              else if (PS==spin) begin
                state<=donew;
                PS<=donew;
              end
              else if (PS==donew) begin
                state<=donew;
                PS<=donew;
              end
            end
        end
      else if (pause==1) begin
        state<=idle;
        PS<=PS;
        
      end
    end
  
  always @(state)
    begin
      case(state)
        idle:
          begin
            stage=idle;
            done=0;
          end
        fill:
          begin
            stage=fill;
            done=0;
          end
        wash:
          begin
            stage=wash;
            done=0;
          end
        rinse:
          begin
            stage=rinse;
            done=0;
          end
        spin:
          begin
            stage=spin;
            done=0;
          end
        donew:
          begin
            stage=donew;
            done=1;
          end
      endcase
    end
endmodule
