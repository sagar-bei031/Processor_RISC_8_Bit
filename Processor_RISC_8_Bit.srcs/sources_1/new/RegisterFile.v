`timescale 1ns / 1ps

module RegisterFile (
    input write_enable,
    input [3:0] read_addr1, read_addr2,
    output [7:0] output_data1, output_data2,
    input [3:0] write_addr,
    input [7:0] input_data
);

    reg [7:0] output_data1_reg;
    reg [7:0] output_data2_reg;
    reg [7:0] r[0:7]; // 8 registers: r0 to r7
    wire [7:0] zero_wire;
    
    
    assign output_data1 = output_data1_reg;
    assign output_data2 = output_data2_reg;
    assign zero_wire = 8'h00;
    
    always @(*) begin
        r[0] = zero_wire;
    end

    always @(read_addr1, read_addr2) begin
            output_data1_reg = r[read_addr1];
            output_data2_reg = r[read_addr2];
    end
    
    always @(write_enable, write_addr, input_data) begin
        if (write_enable && (write_addr != 4'h0))
            r[write_addr] = input_data;
    end
    
endmodule
