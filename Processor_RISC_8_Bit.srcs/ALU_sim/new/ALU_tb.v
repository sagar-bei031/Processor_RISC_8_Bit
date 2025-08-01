`timescale 1ns / 1ps

module ALU_Tb();

    reg  [3:0] AluCtrl;
    reg  [7:0] A, B;
    wire [7:0] Result;
    wire [3:0] Flag;
    
    ALU dut (
        .control(AluCtrl),
        .input_A(A),
        .input_B(B),
        .result(Result),
        .flag(Flag)
    );
    
    integer i;
    
    initial begin
        A = 8'hAA;
        B = 8'hB;
        for (i=0; i<5; i=i+1) begin
            AluCtrl = i;
            #10;
        end
        
        A = 8'hAA;
        B = 8'hBB;
        for (i=0; i<5; i=i+1) begin
            AluCtrl = i;
            #10;
        end

        
        A = 8'hAA;
        B = 8'h0;
        for (i=0; i<5; i=i+1) begin
            AluCtrl = i;
            #10;
        end
        
        $finish;
    end

endmodule
