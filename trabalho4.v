// uma fsm que conta de 0 até 59
// e liga a saida loop por um clock quando a contagem
// chega a 59
module count59(input clk, input rst, input ud, output [5:0] Count, output loop);
reg [5:0] Count;
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

// uma fsm que conta de 0 até 23
module count23(input clk, input rst, input ud, output [4:0] Count);
reg [4:0] Count;
  always @ (posedge clk or negedge rst)
begin
  if (~rst)
    Count <= 0;   // reset register
  else if ( Count == 23 && ud )
    Count <= 0;
  else if ( Count == 0 && ~ud )
    Count <= 23;
  else if(ud)
    Count <= Count + 1;  // increment register
  else if(~ud)
    Count <= Count - 1;  // deincrement register
end
endmodule


// FSM do pulsar ao apertar botao MODO
/*

Modo Relogio
Estado | Endereco
  1        0000
  2        0001

Ajuste hora alarme
Estado | Endereco
  1        0010
  2        0011

Ajuste minuto alarme
Estado | Endereco
  1        0100
  2        0101

Cronometro
Estado | Endereco
  1        0110
  2        0111

Ajuste hora
Estado | Endereco
  1        1000
  2        1001

Ajuste minuto
Estado | Endereco
  1        1010
  2        1011
*/

module modo_pulsar(input clk, reset, modo,
  output[2:0] modoatual);
  reg[3:0] state;

  always @(posedge clk or negedge reset)
    begin
      if(reset==0)
        state=4'd0; // modo relogio
      else
        case(state)
          4'd0:
            if(modo==1'b1) state = 4'd1;
          4'd1:
            if(modo==1'b0) state = 4'd2;
          4'd2:
            if(modo==1'b1) state = 4'd3;
          4'd3:
            if(modo==1'b0) state = 4'd4;
          4'd4:
            if(modo==1'b1) state = 4'd5;
          4'd5:
            if(modo==1'b0) state = 4'd6;
          4'd6:
            if(modo==1'b1) state = 4'd7;
          4'd7:
            if(modo==1'b0) state = 4'd8;
          4'd8:
            if(modo==1'b1) state = 4'd9;
          4'd9:
            if(modo==1'b0) state = 4'd10;
          4'd10:
            if(modo==1'b1) state = 4'd11;
          4'd11:
            if(modo==1'b0) state = 4'd0;
        endcase
    end

    assign modoatual = (state==4'd0 || state==4'd1) ? 3'd0 // relogio
                      :(state==4'd2 || state==4'd3) ? 3'd1 // ajuste hora alarme
                      :(state==4'd4 || state==4'd5) ? 3'd2 // ajuste minuto alarme
                      :(state==4'd6 || state==4'd7) ? 3'd3 // cronometro
                      :(state==4'd8 || state==4'd9) ? 3'd4 // ajuste hora
                      :(state==4'd10 || state==4'd11) ? 3'd5 : 3'd0; // ajuste minuto
endmodule



module relogio(input clk,rst,modo,mais,menos,
  output[5:0] h,m,s,
  output alarmeon, som);

  wire outs,outs1,
       routs,routs1,
       aouts,aouts1;
  wire enable,nr;
  wire [5:0] hc,mc,sc,
             hr,mr,sr,
             ha,ma,sa;

  reg alarmeligado = 1'b0;


  assign enable = (menos) & clk;
  assign nr = res & zera;

  assign alarmeon = 1'b0;
  assign som = 1'b0;
  assign alarmeligado = 1'b0;
  assign alarmeon = alarmeligado;

  wire[2:0] modoatual; //
  modo_pulsar stm(clk,rst,modo,modoatual);

  //cronometro
  count59 seg(enable,nr,1'b1,sc,outs);
  count59 min(~outs,nr,1'b1,mc,outs1);
  count23 hor(~outsl,nr,1'b1,hc);

  //alarme
  count59 aseg(enable,rst,1'b1,sa,aouts);
  count59 amin(~aouts,rst,1'b1,ma,aouts1);
  count23 ahor(~aoutsl,rst,1'b1,ha);

  //relogio

  wire rclkhora,rclkminuto,rclkseg;
  assign rclkhora = (modoatual==3'd4) ? mais | menos : ~routsl;
  assign rclkminuto = (modoatual==3'd5) ? mais | menos : ~routs;
  assign rclkseg = (modoatual==3'd4 || modoatual==3'd5) ? 1'b0 : clk; // nao clocka os segundos no mode ajuste,
                                                                   // assim nao clokca minuto e hora pra n ter
                                                                  // inconscistencia

  assign rud = ((modoatual==3'd4 || modoatual==3'd5) & menos) ? 1'b0 : 1'b1;

  count59 rseg(rclkseg,rst,rud,sr,routs);
  count59 rmin(rclkminuto,rst,rud,mr,routsl);
  count23 rhora(rclkhora,rst,rud,hr);


  // botao mais
  always @(posedge mais)
    begin
      case(modoatual)
        3'd0: // modo relogio
          alarmeligado = ~alarmeligado;

      endcase
    end


  // saidas
  assign h = (modoatual==3'd0 || modoatual==3'd4 || modoatual==3'd5) ? hr
                : (modoatual==3'd1 || modoatual==3'd2) ? ha
                : hr;

  assign m = (modoatual==3'd0 || modoatual==3'd4 || modoatual==3'd5) ? mr
                : (modoatual==3'd1 || modoatual==3'd2) ? ma
                : mr;

  assign s = (modoatual==3'd0 || modoatual==3'd4 || modoatual==3'd5) ? sr
                : (modoatual==3'd1 || modoatual==3'd2) ? sa
                : sr;

endmodule

// top do trabalho
module top(input clk,rst,modo,mais,menos,
  output[5:0]h,m,s,
  output alarmeon,som);

  relogio C(clk,rst,modo,mais,menos,h,m,s,alarmeon, som);
endmodule
