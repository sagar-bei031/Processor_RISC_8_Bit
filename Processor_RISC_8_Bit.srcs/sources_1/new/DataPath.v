`timescale 1ns / 1ps

module DataPath(
        input [3:0] alu_control,
        input [7:0] alu_input_A, alu_input_B,
        output [7:0] alu_result,
        output [3:0] alu_flag,
        
        input rf_write_enable,
        input [3:0] rf_read_addr1, rf_read_addr2,
        output [7:0] rf_output_data1, rf_output_data2,
        input [3:0] rf_write_addr,
        input [7:0] rf_input_data
    );
    
    ALU alu_inst (
            .control(alu_control),
            .input_A(alu_input_A),
            .input_B(alu_input_B),
            .result(alu_result),
            .flag(alu_flag)
        );
        
    RegisterFile rf_inst (
            .write_enable(rf_write_enable),
            .read_addr1(rf_read_addr1),
            .read_addr2(rf_read_addr2),
            .output_data1(rf_output_data1),
            .output_data2(rf_output_data2),
            .write_addr(rf_write_addr),
            .input_data(rf_input_data)
        );
    
endmodule
