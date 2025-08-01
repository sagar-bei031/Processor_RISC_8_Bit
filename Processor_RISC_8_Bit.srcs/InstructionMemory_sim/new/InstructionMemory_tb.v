`timescale 1ns / 1ps

module InstructionMemory_tb;

    reg [15:0] inst_addr_bus;
    wire [31:0] inst_bus;

    InstructionMemory dut (
        .inst_addr_bus(inst_addr_bus),
        .inst_bus(inst_bus)
    );

    initial begin
        #20 inst_addr_bus = 16'd0;
        #20 inst_addr_bus = 16'd1;
        #20 inst_addr_bus = 16'd2;
        #20 inst_addr_bus = 16'd3;
        #20 $finish;
    end

endmodule
