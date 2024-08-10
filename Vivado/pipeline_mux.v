module pipeline_mux (in, sel, CE, clk, rst, out);
//Parameters
parameter WIDTH = 18;       //The width of the inputs and outputs
parameter RSTTYPE = "SYNC"; //SYNC or ASYNC for the resets 

//Input ports
input sel;              //Selection of the mux
input [WIDTH-1 : 0] in; //The input
input CE;               //Enable comtrol signal for reg
input clk, rst;         //Clock and reset

//Output ports
output [WIDTH-1 : 0] out;   //The output after MUX selection

reg [WIDTH-1 : 0] in_r;     //Register output

//Generate for the register if the reset is sync or async
generate
    //For sync resets
    if (RSTTYPE == "SYNC") begin
            always @(posedge clk) begin
                if (rst)
                    in_r <= 0;
                else if (CE)
                    in_r <= in;
            end
    end
    //For async resets
    else if (RSTTYPE == "ASYNC") begin
            always @(posedge clk or posedge rst) begin
                if (rst)
                    in_r <= 0;
                else if (CE)
                    in_r <= in;
            end
    end
endgenerate

//Choose between SQ output or comb
assign out = (sel)? in_r : in;
endmodule