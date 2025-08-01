`timescale 1ns / 1ps

module Processor (
        input clk,
        input rst,
        input [31:0] inst_bus,
        output [15:0] inst_addr_bus,
        inout [7:0] data_bus,
        output data_bus_write_enable,
        output [15:0] data_addr_bus
    );
    
    wire rf_write_enable;
    wire [3:0] rf_write_addr, rf_read_addr1, rf_read_addr2;
    wire [7:0] rf_output_data1, rf_output_data2;
    wire [7:0] rf_input_data;
    
    wire [3:0] alu_control;
    wire [7:0] alu_input_A, alu_input_B;
    wire [7:0] alu_result;
    wire [3:0] alu_flag;
    
    CU cu_inst (
            .clk(clk),
            .rst(rst),
            .inst_bus(inst_bus),
            .inst_addr_bus(inst_addr_bus),
            .data_bus(data_bus),
            .data_bus_write_enable(data_bus_write_enable),
            .data_addr_bus(data_addr_bus),
            
            .rf_write_enable(rf_write_enable),
            .rf_write_addr(rf_write_addr),
            .rf_read_addr1(rf_read_addr1),
            .rf_read_addr2(rf_read_addr2),
            .rf_output_data1(rf_output_data1),
            .rf_output_data2(rf_output_data2),
            .rf_input_data(rf_input_data),
            
            .alu_control(alu_control),
            .alu_input_A(alu_input_A),
            .alu_input_B(alu_input_B),
            .alu_result(alu_result),
            .alu_flag(alu_flag)
        );
        
        
    DataPath data_path_inst (
            .alu_control(alu_control),
            .alu_input_A(alu_input_A),
            .alu_input_B(alu_input_B),
            .alu_result(alu_result),
            .alu_flag(alu_flag),
            
            .rf_write_enable(rf_write_enable),
            .rf_read_addr1(rf_read_addr1),
            .rf_read_addr2(rf_read_addr2),
            .rf_output_data1(rf_output_data1),
            .rf_output_data2(rf_output_data2),
            .rf_write_addr(rf_write_addr),
            .rf_input_data(rf_input_data)
        );
    
endmodule
