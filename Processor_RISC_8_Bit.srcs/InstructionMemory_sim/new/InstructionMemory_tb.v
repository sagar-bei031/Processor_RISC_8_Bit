`timescale 1ns / 1ps

module InstructionMemory_tb;

    reg [15:0] inst_addr_bus;
    wire [31:0] inst_bus;

    InstructionMemory dut (
        .inst_addr_bus(inst_addr_bus),
        .inst_bus(inst_bus)
    );

    initial begin
        #10 inst_addr_bus = 16'd0;
        #10 inst_addr_bus = 16'd1;
        #10 inst_addr_bus = 16'd2;
        #10 inst_addr_bus = 16'd3;
        #10 inst_addr_bus = 16'd4;
        #10 inst_addr_bus = 16'd5;
        #10 inst_addr_bus = 16'd6;
        #10 inst_addr_bus = 16'd7;
        #10 inst_addr_bus = 16'd8;
        #10 inst_addr_bus = 16'd9;
        #10 $finish;
    end

endmodule
