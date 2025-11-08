
module gcd_datapath(lt, gt, eq, ldA, ldB, sel1, sel2, sel_in, data_in, clk);
     input ldA, ldB, sel1, sel2, sel_in, clk;
     input [15:0] data_in;
     output gt, lt, eq;
     wire [15:0] Aout, Bout, X, Y,Bus, SubOut;
     
     PIPO A (Aout, Bus, ldA, clk );
     PIPO B (Bout, Bus, ldB, clk);
     MUX Mux_in1 (X, Aout, Bout, sel1);
     MUX Mux_in2 (Y, Aout, Bout, sel2);
     MUX Mux_load (Bus, SubOut, data_in, sel_in);
     SUB SB (SubOut, X, Y);
     COMP C (lt, gt, eq, Aout, Bout);
     
endmodule 

module COMP(lt, gt, eq, data1, data2);
    input [15:0] data1, data2;
    output lt, gt, eq;
    
    assign lt = data1 < data2;
    assign gt = data1 > data2;
    assign eq = data1 == data2;
endmodule

module MUX(out, in0, in1, sel);
    input [15:0] in0, in1;
    input sel;
    output [15:0] out;
    
    assign out = sel ? in0 : in1;
    
endmodule

module PIPO(data_out, data_in, load, clk);
    input[15:0] data_in;
    input load, clk;
    output reg [15:0] data_out;
    
    always @ (posedge clk)
        if (load) data_out <= data_in;
endmodule


module SUB(out, in1, in2);
    input [15:0] in1, in2;
    output reg [15:0] out;
    
    always @ (*)
        out = in1 - in2;
endmodule

module gcd_controlpath(ldA, ldB, sel1, sel2, sel_in, done, clk, lt, gt, eq, start);
    input clk, lt, gt, eq, start;
    output reg ldA, ldB, sel1, sel2, sel_in, done;
    
    reg [2:0] state;
    parameter s0= 3'b000, s1= 3'b001, s2= 3'b010, s3= 3'b011, s4= 3'b100, s5= 3'b101;
    
    always @ (posedge clk)
        begin
            case (state)
                s0:     if (start) state <= s1;
                s1:     state <= s2;
                s2:     #2 if (eq) state <= s5; // This delay here is specified because B_register is loaded with value on posedge of clk at the same time this block is triggered, so for surity we delay it so that new b value is observable.
                            else if (lt) state <= s3;
                            else if (gt) state <= s4;
                s3:     #2 if (eq) state <= s5;
                            else if (lt) state <= s3;
                            else if (gt) state <= s4;
                 s4:    #2 if (eq) state <= s5;
                            else if (lt) state <= s3;
                            else if (gt) state <= s4;
                s5:         state <= s5;
                default:    state <= s0;
            endcase
        end
        
        always @ (state) // for s3, s4 and s5 happens at a delay of 2ns that is not at the posedge of clk
            begin
                case (state)
                    s0:     begin if (start) begin sel_in =0; ldA = 1; ldB = 0; done = 0; end end
                    s1:     begin sel_in =0; ldA = 0; ldB = 1; end
                    s2:    #1 if (eq) done = 1;
                            // Don't get confused by the sel input it is oppossite to what is expected, see MUX assign statement declaration.
                            else if (lt) begin sel1 = 0; sel2 = 1; sel_in = 1;  ldA = 0; ldB =1; end
                            else if (gt) begin sel1 = 1; sel2 = 0; sel_in = 1;  ldA = 1; ldB =0; end
             // There is #2 delay here for s3, s4 and s5 basically 
                    s3:     if (eq) done = 1;
                            else if (lt) begin sel1 = 0; sel2 = 1; sel_in = 1;  ldA = 0; ldB =1; end
                            else if (gt) begin sel1 = 1; sel2 = 0; sel_in = 1;  ldA = 1; ldB =0; end
                    s4:     if (eq) done = 1;
                            else if (lt) begin sel1 = 0; sel2 = 1; sel_in = 1;  ldA = 0; ldB =1; end
                            else if (gt) begin sel1 = 1; sel2 = 0; sel_in = 1;  ldA = 1; ldB =0; end
                    s5:     begin done = 1; sel1 = 0; sel2 = 0; ldA = 0; ldB =0; end
                    default: begin ldA = 0; ldB =0; end
                endcase
            end 
endmodule




