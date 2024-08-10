module DSP48A1 (A, B, BCIN, C, D, opmode, 
CARRYIN, CEA, CEB, CEC, CECARRYIN, CED, CEM, 
CEOPMODE, CEP, clk, RSTA, RSTB, RSTC, RSTCARRYIN, 
RSTD, RSTM, RSTOPMODE, RSTP, M, P, CARRYOUT, CARRYOUTF, 
BCOUT, PCIN, PCOUT);

//DSP parameters
parameter A0REG = 0;                //0 for SQ 1 for comb
parameter A1REG = 1;                //0 for SQ 1 for comb
parameter B0REG = 0;                //0 for SQ 1 for comb
parameter B1REG = 1;                //0 for SQ 1 for comb
parameter CREG = 1;                 //0 for SQ 1 for comb
parameter DREG = 1;                 //0 for SQ 1 for comb
parameter MREG = 1;                 //0 for SQ 1 for comb
parameter PREG  = 1;                //0 for SQ 1 for comb
parameter CARRYINREG = 1;           //0 for SQ 1 for comb
parameter CARRYOUTREG = 1;          //0 for SQ 1 for comb
parameter OPMODEREG = 1;            //0 for SQ 1 for comb
parameter CARRYINSEL  = "OPMODE5";  //CARRYIN or OPMODES if you want the carry to be forced from opmode or not
parameter B_INPUT = "DIRECT";       //DIRECT or CASCADE if you want the B to be cascaded from other DSP or an input 
parameter RSTTYPE = "SYNC";         //SYNC or ASYNC if you want all the resets to be sync or not

//input ports
input [17:0] A, B, D;
input [47:0] C;
input [17:0] BCIN;      //Cascaded input from other DSPs 
input [47:0] PCIN;      //Cascaded input from other DSPs 
input [7:0] opmode;     //Operation mode selection
input CARRYIN;
input CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;            //Control signals
input clk;                                                          //Clock signal
input RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;    //Reset signals

//output ports
output [47:0] P, PCOUT;
output [17:0] BCOUT;        //The output from B to cascade it to other DSPs
output [35:0] M;            //the multiplyer output to cascade it to other DSPs
output CARRYOUT, CARRYOUTF; //CARRYOUTF fromn the FPGA, CARRYOUT to other DSPs

wire [7:0] opmodeMUX;
pipeline_mux #(.WIDTH(8), .RSTTYPE(RSTTYPE)) OPMODEREG_pipeline (.in(opmode), .sel(OPMODEREG), .CE(CEOPMODE), .clk(clk), .rst(RSTOPMODE), .out(opmodeMUX));

wire [17:0] DMUX;
pipeline_mux #(.WIDTH(18), .RSTTYPE(RSTTYPE)) DREG_pipeline (.in(D), .sel(DREG), .CE(CED), .clk(clk), .rst(RSTD), .out(DMUX));

wire [17:0] B0IN;
assign B0IN = (B_INPUT == "DIRECT")? B : (B_INPUT == "CASCADE")? BCIN : 0;
wire [17:0] B0MUX;
pipeline_mux #(.WIDTH(18), .RSTTYPE(RSTTYPE)) B0REG_pipeline (.in(B0IN), .sel(B0REG), .CE(CEB), .clk(clk), .rst(RSTB), .out(B0MUX));

//Pre - adder / subtracter
wire [17:0] adder1;
assign adder1 = (opmodeMUX[6])? DMUX - B0MUX : DMUX + B0MUX;

//MUX for choosing to skip pre - adder / subtracter or use it
wire [17:0] B1IN;
assign B1IN = (opmodeMUX[4])? adder1 : B0MUX;
wire [17:0] B1MUX;
pipeline_mux #(.WIDTH(18), .RSTTYPE(RSTTYPE)) B1REG_pipeline (.in(B1IN), .sel(B1REG), .CE(CEB), .clk(clk), .rst(RSTB), .out(B1MUX));
assign BCOUT = B1MUX;   //The output of BCOUT to be cascaded in other DSPs

wire [17:0] A0MUX;
pipeline_mux #(.WIDTH(18), .RSTTYPE(RSTTYPE)) A0REG_pipeline (.in(A), .sel(A0REG), .CE(CEA), .clk(clk), .rst(RSTA), .out(A0MUX));
wire [17:0] A1MUX;
pipeline_mux #(.WIDTH(18), .RSTTYPE(RSTTYPE)) A1REG_pipeline (.in(A0MUX), .sel(A1REG), .CE(CEA), .clk(clk), .rst(RSTA), .out(A1MUX));

//Multiplier stage
wire [35:0] multiplier;
assign multiplier = A1MUX * B1MUX;
pipeline_mux #(.WIDTH(36), .RSTTYPE(RSTTYPE)) MREG_pipeline (.in(multiplier), .sel(MREG), .CE(CEM), .clk(clk), .rst(RSTM), .out(M));

//The concatenation of D A B ports
wire [47:0] D_A_B_concatebated;
assign D_A_B_concatebated = {DMUX[11:0], A1MUX[17:0], B1MUX[17:0]};

//The X-MUX
wire [47:0] XMUX;
assign XMUX = (opmodeMUX[1:0] == 3)? D_A_B_concatebated : (opmodeMUX[1:0] == 2)? PCOUT : (opmodeMUX[1:0] == 1)? {12'b0, M} : 0;

wire [47:0] CMUX;
pipeline_mux #(.WIDTH(48), .RSTTYPE(RSTTYPE)) CREG_pipeline (.in(C), .sel(CREG), .CE(CEC), .clk(clk), .rst(RSTC), .out(CMUX));

//The Z-MUX
wire [47:0] ZMUX;
assign ZMUX = (opmodeMUX[3:2] == 3)? CMUX : (opmodeMUX[3:2] == 2)? PCOUT : (opmodeMUX[3:2] == 1)? PCIN : 0;

//The selection of the CARRYIN signal
wire CARRYIN_SEL;
assign CARRYIN_SEL = (CARRYINSEL  == "OPMODE5")? opmodeMUX[5] : (CARRYINSEL  == "CARRYIN")? CARRYIN : 0;
wire CARRYINMUX;
pipeline_mux #(.WIDTH(1), .RSTTYPE(RSTTYPE)) CYI_pipeline (.in(CARRYIN_SEL), .sel(CARRYINREG), .CE(CECARRYIN), .clk(clk), .rst(RSTCARRYIN), .out(CARRYINMUX));

//Post - adder / subtracter
wire [47:0] adder2;
wire CYO;           //CARRYOUT of the post - added / subtracter
assign {CYO, adder2} = (opmodeMUX[7])? ZMUX - (XMUX + CARRYINMUX) : ZMUX + XMUX + CARRYINMUX;

pipeline_mux #(.WIDTH(1), .RSTTYPE(RSTTYPE)) CYO_pipeline (.in(CYO), .sel(CARRYOUTREG), .CE(CECARRYIN), .clk(clk), .rst(RSTCARRYIN), .out(CARRYOUT));
assign CARRYOUTF = CARRYOUT;

pipeline_mux #(.WIDTH(48), .RSTTYPE(RSTTYPE)) PREG_pipeline (.in(adder2), .sel(PREG), .CE(CEP), .clk(clk), .rst(RSTP), .out(P));
assign PCOUT = P;
endmodule