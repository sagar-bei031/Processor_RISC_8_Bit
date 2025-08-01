`timescale 1ns / 1ps

module DataMemory (
    input clk,
    input [15:0] data_addr_bus,
    input data_bus_write_enable,
    inout [7:0] data_bus
);

    reg [7:0] data_reg [0:255];

    assign data_bus = data_bus_write_enable ? 8'hzz : data_reg[data_addr_bus];

    initial begin
        $readmemh("data_memory.mem", data_reg);
    end

    always @(posedge clk) begin
        if (data_bus_write_enable) begin
            data_reg[data_addr_bus] <= data_bus;
        end
    end

endmodule
