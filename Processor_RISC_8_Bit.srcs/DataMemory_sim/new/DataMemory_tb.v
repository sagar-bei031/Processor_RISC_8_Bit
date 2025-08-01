`timescale 1ns / 1ps


module data_memory_tb;

    reg clk;
    reg [15:0] data_addr_bus;
    reg data_bus_write_enable;
    wire [7:0] data_bus;
    reg [7:0] data_bus_output_reg;
    
    integer i;
    integer file_id;
    
    assign data_bus = data_bus_write_enable ? data_bus_output_reg : 8'hzz;

    
    DataMemory dut (
        .clk(clk),
        .data_addr_bus(data_addr_bus),
        .data_bus_write_enable(data_bus_write_enable),
        .data_bus(data_bus)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        data_addr_bus = 0;
        data_bus_write_enable = 0;
        
        #10;
        data_bus_output_reg = 8'haa;
        data_bus_write_enable = 1;
        
        #10;
        data_addr_bus = 1;
        data_bus_output_reg = 8'hbb;
        data_bus_write_enable = 1;
        
        #10;
        data_addr_bus = 2;
        data_bus_output_reg = 8'hcc;
        data_bus_write_enable = 1;
        
        #10;
        data_addr_bus = 1;
        data_bus_write_enable = 0;
        
        #10;
        file_id = $fopen("C:\\Users\\chaud\\Desktop\\data_memory_dumped.txt", "w");
        for (i = 0; i < 16; i = i + 1) begin
            $fwrite(file_id, "mem[%0d] = %h\n", i, dut.data_reg[i]);
            $display("mem[%0d] = %h", i, dut.data_reg[i]);
        end
        $fclose(file_id);
        
        #10 $finish;
    end

endmodule
