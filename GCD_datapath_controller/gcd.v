module PIPO (data_out, data_in, load, clk);
	input [15:0]data_in;
	input load, clk;
	output [15:0]data_out;

always @(posedge clk) begin
	if (load) data_out<=data_in;
	end
endmodule

module COMPARE (lt, gt, eq, data1, data2);
  input [15:0]data1, data2;
  output lt, gt, eq;
  assign lt= (data1<data2);
  assign gt= (data1>data2);
  assign eq= data1==data2;
endmodule

module MUX (out, in1, in2, sel); // 16 2:1 muxes here
  input [15:0] in0, in1;
  input sel;
  output [15:0]out;

  assign out = sel? in1 : in2;
endmodule

module SUB (out, in1, in2);
  input [15:0] in1, in2;
  output [15:0] out;
always @(*)
	out=in1-in2;
endmodule


module  GCD_datapath (gt, lt, eq, ldA, ldB, sel1, sel2, sel_in, data_in, clk);
input ldA, ldB, sel1, sel2, sel_in, clk;
input [15:0]data_in;
output gt, lt, eq;
wire [15:0]SubOut, bus, Aout, Bout, X, Y;

PIPO A (Aout, Bus, ldA, clk);
PIPO B (Bout, Bus, ldB, clk);
MUX MUX_in1 (X, Aout, Bout, sel1);
MUX MUX_in2 (Y, Aout, Bout, sel2);
MUX MUX_load(Bus, Subout, data_in, sel_in);
SUB SB (SubOut, X, Y);
COMPARE COMP (lt, gt, eq, Aout, Bout);
endmodule

module controller (ldA, ldB, sel1, sel2, sel_in, done, clk, lt, gt, eq, start);
input clk, lt, gt, eq, start;
output reg ldA, ldB, sel1, sel2, sel_in, done;
parameter s0=3'b000, s1=3'b001, s2=3'b010, s3=3'b011, s4=3'b100, s5=3'b101;

reg [2:0]state, next_state;

always @(posedge clk)
	state<=next_state;


always @(state)
begin
	case (state)
		s0: begin sel_in=1; ldA=1; ldB=0;done=0; next_state=s1; end
		s1: begin sel_in=1; ldA=0; ldB=1;next_state=s2; end
		s2: if (eq)begin done=1; next_state=s5;end
			else if (lt) begin
						sel1=1; sel2=0; sel_in=0;
						#1 ldA=0; ldB=1;next_state=s3; end
			else if (gt) begin
						sel1=0; sel2=1; sel_in=0;
						#1 ldA=1; ldB=0;next_state=s4; end
		s3: if (eq) begin done=1; next_state=s5; end
			else if (lt) begin
						sel1=1; sel2=0; sel_in=0;
						#1 ldA=0; ldB=1;next_state=s3; end
			else if (gt) begin
						sel1=0; sel2=1; sel_in=0;
						#1 ldA=1; ldB=0;next_state=s4; end
		s4: if (eq) done=1; //similarlyhere too changes
			else if (lt) begin
						sel1=1; sel2=0; sel_in=0;
						#1 ldA=0; ldB=1; end
			else if (gt) begin
						sel1=0; sel2=1; sel_in=0;
						#1 ldA=1; ldB=0; end
		s5:begin done=1; ldA=0; ldB=0;next_state=s5; end
		default: begin ldA=0; ldB=0;next_state=s0; end
	endcase
	end
endmodule



