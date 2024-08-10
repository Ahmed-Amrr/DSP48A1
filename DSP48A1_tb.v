module DSP48A1_tb ();
parameter A0REG = 0;
parameter A1REG = 1;
parameter B0REG = 0;
parameter B1REG = 1;
parameter CREG = 1;
parameter DREG = 1;
parameter MREG = 1;
parameter PREG  = 1;
parameter CARRYINREG = 1;
parameter CARRYOUTREG = 1; 
parameter OPMODEREG = 1;
parameter CARRYINSEL  = "OPMODE5";
parameter B_INPUT = "DIRECT";
parameter RSTTYPE = "SYNC";

reg [17:0] A, B, BCIN, D;
reg [47:0] C, PCIN;
reg [7:0] opmode;
reg CARRYIN, CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, clk, RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;

wire [47:0] P, PCOUT;
wire [17:0] BCOUT;
wire [35:0] M;
wire CARRYOUT, CARRYOUTF;

DSP48A1 #( A0REG, A1REG, B0REG, 
B1REG, CREG, DREG, MREG, PREG , 
CARRYINREG, CARRYOUTREG,  OPMODEREG, CARRYINSEL, 
B_INPUT, RSTTYPE) dut 
(A, B, BCIN, C, D, opmode, 
CARRYIN, CEA, CEB, CEC, CECARRYIN, CED, CEM, 
CEOPMODE, CEP, clk, RSTA, RSTB, RSTC, RSTCARRYIN, 
RSTD, RSTM, RSTOPMODE, RSTP, M, P, CARRYOUT, CARRYOUTF, 
BCOUT, PCIN, PCOUT);

initial begin
    clk = 0;
    forever
        #10 clk = ~clk;
end

initial begin

    //Test the resets
    RSTA = 1;
    RSTB = 1; 
    RSTC = 1;
    RSTCARRYIN = 1; 
    RSTD = 1;
    RSTM = 1;
    RSTOPMODE = 1;
    RSTP = 1;
    @(negedge clk);
    if (P != 0) begin
        $display("there was an error");
        $stop;
    end

    //enable all the control signals
    RSTA = 0;           CEA = 1;
    RSTB = 0;           CEB = 1;
    RSTC = 0;           CEC = 1;
    RSTCARRYIN = 0;     CECARRYIN = 1;
    RSTD = 0;           CED = 1;
    RSTM = 0;           CEM  = 1;
    RSTOPMODE = 0;      CEOPMODE = 1;
    RSTP = 0;           CEP = 1;

    //Testing the pre and post addders and the multiplier 
    opmode = 8'b0001_1101;
    repeat (10)begin
        A = $urandom_range(100,3000);
        B = $urandom_range(100,3000);
        BCIN = $urandom_range(100,3000);
        C = $urandom_range(100,3000);
        D = $urandom_range(100,3000);
        CARRYIN = $random;
        PCIN = $urandom_range(100,3000);
        repeat(4) @(negedge clk);
        if (P != (C + (A * (D + B)))) begin
            $display("there was an error");
            $stop;
        end
    end

    //Testing the port C
    opmode = 8'b0001_1100;
    repeat (10)begin
        A = $urandom_range(100,3000);
        B = $urandom_range(100,3000);
        BCIN = $urandom_range(100,3000);
        C = $urandom_range(100,3000);
        D = $urandom_range(100,3000);
        CARRYIN = $random;
        PCIN = $urandom_range(100,3000);
        repeat(4) @(negedge clk);
        if (P != C) begin
            $display("there was an error");
            $stop;
        end
    end

    //Testing to skip the post adder
    opmode = 8'b0001_0001;
    repeat (10)begin
        A = $urandom_range(100,3000);
        B = $urandom_range(100,3000);
        BCIN = $urandom_range(100,3000);
        C = $urandom_range(100,3000);
        D = $urandom_range(100,3000);
        CARRYIN = $random;
        PCIN = $urandom_range(100,3000);
        repeat(4) @(negedge clk);
        if (P != (A * (D + B))) begin
            $display("there was an error");
            $stop;
        end
    end

    //Testing to skip the pre adder
    opmode = 8'b0000_0001;
    repeat (10)begin
        A = $urandom_range(100,3000);
        B = $urandom_range(100,3000);
        BCIN = $urandom_range(100,3000);
        C = $urandom_range(100,3000);
        D = $urandom_range(100,3000);
        CARRYIN = $random;
        PCIN = $urandom_range(100,3000);
        repeat(4) @(negedge clk);
        if (P != (A * B)) begin
            $display("there was an error");
            $stop;
        end
    end

    //Testing the concatenated port
    opmode = 8'b0000_0011;
    repeat (10)begin
        A = $urandom_range(100,3000);
        B = $urandom_range(100,3000);
        BCIN = $urandom_range(100,3000);
        C = $urandom_range(100,3000);
        D = $urandom_range(100,3000);
        CARRYIN = $random;
        PCIN = $urandom_range(100,3000);
        repeat(4) @(negedge clk);
        if (P != {D[11:0], A[17:0], B[17:0]}) begin
            $display("there was an error");
            $stop;
        end
    end

    //Testing the cascaded PCIN
    opmode = 8'b0000_0100;
    repeat (10)begin
        A = $urandom_range(100,3000);
        B = $urandom_range(100,3000);
        BCIN = $urandom_range(100,3000);
        C = $urandom_range(100,3000);
        D = $urandom_range(100,3000);
        CARRYIN = $random;
        PCIN = $urandom_range(100,3000);
        repeat(4) @(negedge clk);
        if (P != PCIN) begin
            $display("there was an error");
            $stop;
        end
    end
    $stop;
end
endmodule