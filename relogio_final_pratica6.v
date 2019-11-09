module count59(input clk, input rst, input ud, output [5:0] Count, output loop);  reg [5:0] Count;
  always @ (posedge clk or negedge rst)
begin
  if (~rst)
    Count <= 0;   // reset register
  else if ( Count == 59 & ud )
    Count <= 0;
  else if ( Count == 00 & ~ud )
    Count <= 59;
  else if(ud)
    Count <= Count + 1;  // increment register
  else
    Count <= Count - 1;
end
assign loop = (Count == 59)&ud | (Count==0)&~ud;
endmodule


module count23(input clk, input rst, output [4:0] Count);  reg [4:0] Count;
  always @ (posedge clk or negedge rst)
begin
  if (~rst)
    Count <= 0;   // reset register
  else if ( Count == 23 )
    Count <= 0;
  else
    Count <= Count + 1;  // increment register
end
endmodule

module statem(clk, reset, rc, nrc);
input clk, reset; input  rc; output nrc;
reg[1:0] state;
parameter r0=2'd0, r1=2'd1,c0=2'd2, c1=2'd3;
assign nrc = (state==r0 || state==r1);

always @(posedge clk or negedge reset)
  begin
    if(reset==0)
      state=r0;
    else
      case(state)
        r0:
          if(rc==1'b1) state = r1;
        r1:
          if(rc==1'b0) state = c0;
        c0:
          if(rc==1'b1) state = c1;
        c1:
          if(rc==1'b0) state = r0;
      endcase
  end
endmodule



module relogio(input clk, res, startstop, zera, ud,
  input rc,
  output[5:0] segundos,minutos,
  output[4:0] hora);

  wire outs,outs1, routs, routs1;
  wire enable,nr;
  wire [5:0] sc,sr,mc,mr;
  wire [4:0] hc,hr;
  assign enable = startstop & clk;
  assign nr = res & zera;

  count59 seg(enable,nr,ud,sc,outs);
  count59 min(~outs,nr,ud,mc,outs1);
  count23 hor(~outsl,nr,hc);
  count59 rseg(clk,res,1'b1,sr,routs);
  count59 rmin(-routs,res,1'b1,mr,routsl);
  count23 rhor(~routsl,res,hr);
  assign hora = (nrc)?hr:hc;
  assign minutos = (nrc) ?mr:mc;
  assign segundos = (nrc) ?sr:sc;
  wire nrc;
  statem maq(clk,res,rc,nrc);
endmodule

module top(input clk,res,startstop,zera,ud,
          input rc,
           output[5:0] s,m,
           output[4:0] h);

    relogio C(clk,res,startstop,zera,ud,rc,s,m,h);

endmodule
