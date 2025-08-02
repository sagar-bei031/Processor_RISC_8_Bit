`timescale 1ns / 1ps

module ALU_Tb();

    reg  [3:0] alu_control;
    reg  [7:0] A, B;
    wire [7:0] result;
    wire [3:0] flag;
    
    ALU dut (
        .control(alu_control),
        .input_A(A),
        .input_B(B),
        .result(result),
        .flag(flag)
    );
    
    integer i;
    
    initial begin
        // Check ALU operations
        A = 8'hAA;
        B = 8'h0B;
        for (i=0; i<10; i=i+1) begin
            alu_control = i;
            #10;
        end
        
        // Check zero flag
        #10;
        A = 8'h00;
        B = 8'h00;
        alu_control = 4'h1;
        
        // Check carry flag
        #10;
        A = 8'hff;
        B = 8'h01;
        alu_control = 4'h1;
        
        // check divide by zero flag
        #10;
        B = 8'h00;
        alu_control = 4'h4;
        
        // check sign flag
        #10;
        A = 8'h00;
        B = 8'h01;
        alu_control = 4'h2;
        
        // check flag reset
        #10;
        alu_control = 5'hf;
        
        #10 $finish;
    end

endmodule
