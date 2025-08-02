`timescale 1ns / 1ps

`include "parameter.vh"

module Processor_tb ();

reg clk;
reg rst;
wire [31:0] inst_bus;
wire [15:0] inst_addr_bus;
wire [7:0] data_bus;
wire data_bus_write_enable;
wire [15:0] data_addr_bus;

integer file_id;
integer i;
    
    Processor processor_ins (
            .clk(clk),
            .rst(rst),
            .inst_bus(inst_bus),
            .inst_addr_bus(inst_addr_bus),
            .data_bus(data_bus),
            .data_bus_write_enable(data_bus_write_enable),
            .data_addr_bus(data_addr_bus)
        ); 
    
    DataMemory data_mem_ins (
            .clk(clk),
            .data_addr_bus(data_addr_bus),
            .data_bus_write_enable(data_bus_write_enable),
            .data_bus(data_bus)
        );
        
    InstructionMemory inst_mem_ins (
            .inst_addr_bus(inst_addr_bus),
            .inst_bus(inst_bus)
        );
    
    initial begin
        clk = 0;
        forever #(5) clk = ~clk;
    end
    
    initial begin
        rst = 1;
        #10 rst = 0;
        
        // enough to complete all instructions
        #100;
        file_id = $fopen(`DATA_MEMORY_DUMPED_FILE, "w");
        for (i = 0; i < 16; i = i + 1) begin
            $fwrite(file_id, "mem[%0h] = %h\n", i, data_mem_ins.data_reg[i]);
//            $display("mem[%0h] = %h", i, data_mem_ins.data_reg[i]);
        end
        $fclose(file_id);
        
        #10 $finish;
    end
    
endmodule
