module ALU (Z, A, M, addsub);
input [15:0]A, M;
input addsub;
output reg [15:0]Z;

always @(*) begin
if (addsub==1) 
    Z=A+M;
else if (addsub==0) 
    Z=A-M;
end
endmodule

module counter (count, decr, ldcnt, clk);
input decr, ldcnt, clk;
output reg [4:0]count;
always @(posedge clk) begin
    if (ldcnt) count<=5'b10000;
    else if (decr) count<=count-1;
    end
endmodule

module shiftreg (data_out, data_in, s_in, clk, ld, clr, sft);
input s_in, clk, ld, clr, sft;
input [15:0]data_in;
output reg [15:0]data_out;

always @(posedge clk) begin
    if (clr) data_out<=0;
    else if (ld) data_out<=data_in;
    else if (sft) data_out<={s_in,data_out[15:1]};
end
endmodule

module PIPO (data_out, data_in, clk, load);
    input [15:0] data_in;
    input load, clk;
    output reg [15:0] data_out;

always @(posedge clk) 
  if (load) data_out<=data_in;
endmodule

module dff (d, q, clk, clr);
    input d, clk, clr;
    output reg q;
    always @(posedge clk) begin
        if (clr) q<=0;
        else q<=d;
    end
endmodule

 



module BOOTH (ldA, ldQ, ldM, clrA, clrQ, clrff, sftA, sftQ, addsub, decr, ldcnt, data_in, clk, qm1, eqz, q0);
input ldA, ldQ, ldM, clrA, clrQ, clrff, sftA, sftQ, addsub, clk, decr, ldcnt;
  input [15:0]data_in; // what about the count variables? ask gpt
output qm1, eqz;
output q0;
  wire [15:0]A;
  wire [15:0]M;
  wire [15:0]Q;
  wire [15:0]Z;
wire [4:0] count; // doubt about how to initialize it

assign eqz= ~|count;
  assign q0= Q[0];

  shiftreg AR (A,Z, A[15], clk, ldA, clrA, sftA);//A[15] is input as it depends on the previous A[15] value beforeshif
shiftreg QR (Q, data_in, A[0],clk, ldQ, clrQ, sftQ );// Q is o/p wire as Q[0] goes to ctrl path
dff QM1(Q[0], qm1, clk, clrff);
  PIPO MR (M, data_in, clk, ldM);
ALU AS (Z, A, M, addsub);
counter CN (count, decr, ldcnt, clk);
endmodule

module controller (ldA, clrA, sftA, ldQ, clrQ, sftQ, ldM, clrff, addsub, start, decr, ldcnt, done, clk, q0, qm1, eqz);
input clk, q0, qm1, start, eqz;
output reg ldA, clrA, sftA, ldQ, clrQ, sftQ, ldM, clrff, addsub, decr, ldcnt, done;

parameter s0=3'b000, s1=3'b001, s2=3'b010, s3=3'b011, s4=3'b100, s5=3'b101, s6=3'b110;
reg [2:0]state;

always @(posedge clk) begin
    case(state)
        s0: if (start) state<=s1;
        s1: state<=s2;
        s2: begin #2 if(q0==0 && qm1==1) state<=s3;
else if (q0==1 && qm1==0) state<=s4;
else if ({q0,qm1}==2'b00 || {q0, qm1}==2'b11) state<=s5; end
        s3: state<=s5;
        s4: state<=s5;
        s5: begin if(eqz==0) begin #2 if(q0==0 && qm1==1) state<=s3;
else if (q0==1 && qm1==0) state<=s4; end
else if (eqz) state<=s6; end
        s6: state<=s6;
        default: state<=s0;
    endcase
end

always @(state) begin
    case(state)
        s0: begin #1 ldA=0; clrA=0; sftA=0; ldQ=0; clrQ=0; sftQ=0; ldM=0; clrff=0; decr=0; ldcnt=0; done=0; end
        s1: begin #1  clrA=1; clrff=1; ldcnt=1; ldM=1; end
        s2: begin #1 clrA=0; clrff=0; ldcnt=0; ldM=0; ldQ=1; end
        s3: begin #1 sftA=0; sftQ=0; decr=0; ldQ=0; ldA=1; addsub=1; end
        

s4: begin #1 sftA=0; sftQ=0; decr=0; ldQ=0; ldA=1; addsub=0; end
        s5: begin #1 sftA=1; sftQ=1; ldA=0; decr=1; ldQ=0; end
        s6: begin #1 sftA=0; sftQ=0; decr=0; done=1; end
        default: begin #1 clrA=0; sftA=0; ldQ=0; sftQ=0; end
endcase
end
endmodule
            

