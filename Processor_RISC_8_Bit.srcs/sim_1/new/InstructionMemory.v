`timescale 1ns / 1ps

module InstructionMemory(
        input [15:0] inst_addr_bus,
        output [31:0] inst_bus
    );
    
    reg [31:0] instruction_reg [0:255];
    
    assign  inst_bus =  instruction_reg[inst_addr_bus]; 
    
    initial begin
        $readmemh("instruction_memory.mem", instruction_reg);
    end
    
endmodule
