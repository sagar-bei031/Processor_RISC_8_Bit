`timescale 1ns / 1ps
`include "parameter.vh"

module CU (
    input clk,
    input rst,
    
    input [31:0] inst_bus,         
    output [15:0] inst_addr_bus,  
    
    inout [7:0] data_bus,
    output data_bus_write_enable,
    output [15:0] data_addr_bus,
    
    output rf_write_enable,
    output [3:0] rf_write_addr, rf_read_addr1, rf_read_addr2,
    input [7:0] rf_output_data1, rf_output_data2,
    output [7:0] rf_input_data,  
    
    output [3:0] alu_control,
    output [7:0] alu_input_A, alu_input_B,
    input [7:0] alu_result,
    input [3:0] alu_flag
);

    reg [15:0] pc, jmp_pc;
    reg jmp_reg;
    reg hlt_reg;

    reg [7:0] opcode, operand0, operand1, operand2;  // decoded instruction parts
    
    assign inst_addr_bus = pc;

    reg [15:0] data_addr_bus_reg;
    reg [7:0] data_bus_input_reg, data_bus_output_reg;
    reg data_bus_write_enable_reg;
    
    assign data_addr_bus = data_addr_bus_reg;
    assign data_bus = data_bus_write_enable_reg ? data_bus_output_reg : 8'hzz;
    assign data_bus_write_enable = data_bus_write_enable_reg;

    reg rf_write_enable_reg;
    reg [3:0] rf_write_addr_reg, rf_read_addr1_reg, rf_read_addr2_reg;
    reg [7:0] rf_input_data_reg;
    
    assign rf_write_enable = rf_write_enable_reg;
    assign rf_write_addr = rf_write_addr_reg;
    assign rf_read_addr1 = rf_read_addr1_reg;
    assign rf_read_addr2 = rf_read_addr2_reg;
    assign rf_input_data = rf_input_data_reg;

    reg [3:0] alu_control_reg;
    reg [7:0] alu_input_A_reg, alu_input_B_reg;
    
    assign alu_control = alu_control_reg;
    assign alu_input_A = alu_input_A_reg;
    assign alu_input_B = alu_input_B_reg;

    // handle read from inout bus
    always @(data_bus_write_enable_reg or data_bus) begin
        if (!data_bus_write_enable_reg)
            data_bus_input_reg = data_bus;
    end    

    // main combinational logic
    always @(*) begin
        if (rst) begin
            data_bus_write_enable_reg = 1'b0;
            rf_write_enable_reg = 1'b0;
            jmp_reg = 1'b0;
            hlt_reg = 1'b0;
            alu_control_reg = 4'hf;
        end else begin
            // decode instruction
            opcode   = inst_bus[31:24];
            operand0 = inst_bus[23:16];
            operand1 = inst_bus[15:8];
            operand2 = inst_bus[7:0];

            casex (opcode)
                // load direct 
                // [opcode=ldd, 
                // op0=dest_reg, 
                // op1=lower_data_addr, 
                // op2=higher_data_addr]
                8'b1000_0000: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b1;
                    jmp_reg = 1'b0;
                    hlt_reg = 1'b0;
                        
                    // read from data memory 
                    data_addr_bus_reg = {operand2, operand1};
                    
                    // write data on dest register
                    rf_write_addr_reg = operand0[3:0];
                    rf_input_data_reg = data_bus_input_reg;
                end
                
                // load immediate 
                // [opcode=ldi, 
                // op0=dest_reg, 
                // op1=immediate_value]
                8'b1000_0001: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b1;
                    jmp_reg = 1'b0;
                
                    // write on register file
                    rf_write_addr_reg = operand0[3:0];
                    rf_input_data_reg = operand1;
                end
                
                // store direct 
                // [opcode=std, 
                // op0=src_reg, 
                // op1=lower_data_addr, 
                // op2=higher_data_addr]
                8'b1000_0010: begin
                    data_bus_write_enable_reg = 1'b1;
                    rf_write_enable_reg = 1'b0;
                    jmp_reg = 1'b0;
                        
                    // read data from src register
                    rf_read_addr1_reg = operand0;
                    // store to data memory
                    data_addr_bus_reg = {operand2, operand1};
                    data_bus_output_reg = rf_output_data1;
                end
               
                // store immediate 
                // [opcode=sti, 
                // op0=immediate_value, 
                // op1=lower_data_addr, 
                // op2=higher_data_addr]
                8'b1000_0011: begin
                    data_bus_write_enable_reg = 1'b1;
                    rf_write_enable_reg = 1'b0;
                    jmp_reg = 1'b0;
                
                    // write immediate to data memory
                    data_addr_bus_reg = {operand2, operand1};
                    data_bus_output_reg = operand0;
                end

                // uncondition jump
                // [opcode=jmp,
                // oprand1=lower_inst_addr,
                // operand2=higher_inst_addr]
                8'b0100_0000: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b0;
                    jmp_reg = 1'b1;
                    
                    // jump address
                    jmp_pc = {operand2, operand1};
                end
                
                // jump on zero
                // [opcode=jmz
                // oprand1=lower_inst_addr,
                // operand2=higher_inst_addr]
                8'b0110_0001: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b0;
                    
                    // read registers
                    if (alu_flag[`Zflag]) begin
                        jmp_pc = {operand2, operand1};
                        jmp_reg = 1'b1;
                    end else begin
                        jmp_reg = 1'b0;
                    end   
                end
                
                // jump on divided by zero
                // [opcode=jmdz
                // oprand1=lower_inst_addr,
                // operand2=higher_inst_addr]
                8'b0110_0010: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 0;
                    
                    // read registers
                    if (alu_flag[`Dflag]) begin
                        jmp_pc = {operand2, operand1};
                        jmp_reg = 1'b1;
                    end else begin
                        jmp_reg = 1'b0;
                    end   
                end
                
                // jump on carry
                // [opcode=jmc
                // oprand1=lower_inst_addr,
                // operand2=higher_inst_addr]
                8'b0110_0011: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b0;
                    
                    // read registers
                    if (alu_flag[`Cflag]) begin
                        jmp_pc = {operand2, operand1};
                        jmp_reg = 1'b1;
                    end else begin
                        jmp_reg = 1'b0;
                    end   
                end
                
                // jump on divided by negative
                // [opcode=jmn
                // oprand1=lower_inst_addr,
                // operand2=higher_inst_addr]
                8'b0110_0100: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b0;
                    
                    // read registers
                    if (alu_flag[`Sflag]) begin
                        jmp_pc = {operand2, operand1};
                        jmp_reg = 1'b1;
                    end else begin
                        jmp_reg = 1'b0;
                    end   
                end
                
                // jump on not zero ...
                // [opcode=jmnz ...
                // oprand1=lower_inst_addr,
                // operand2=higher_inst_addr]
                8'b0111_0010: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b0;
                    
                    // read registers
                    if (!alu_flag[`Zflag]) begin
                        jmp_pc = {operand2, operand1};
                        jmp_reg = 1'b1;
                    end else begin
                        jmp_reg = 1'b0;
                    end   
                end
                
                // jump on not divided by zero ...
                // [opcode=jmnd ...
                // oprand1=lower_inst_addr,
                // operand2=higher_inst_addr]
                8'b0111_0010: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b0;
                    
                    // read registers
                    if (!alu_flag[`Dflag]) begin
                        jmp_pc = {operand2, operand1};
                        jmp_reg = 1'b1;
                    end else begin
                        jmp_reg = 1'b0;
                    end   
                end
                
                // jump on not carry ...
                // [opcode=jmnz ...
                // oprand1=lower_inst_addr,
                // operand2=higher_inst_addr]
                8'b0111_0011: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b0;
                    
                    // read registers
                    if (!alu_flag[`Cflag]) begin
                        jmp_pc = {operand2, operand1};
                        jmp_reg = 1'b1;
                    end else begin
                        jmp_reg = 1'b0;
                    end   
                end
                
                // jump on not negative (positive) ...
                // [opcode=jmnn ...
                // oprand1=lower_inst_addr,
                // operand2=higher_inst_addr]
                8'b0111_0010: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b0;
                    
                    // read registers
                    if (!alu_flag[`Sflag]) begin
                        jmp_pc = {operand2, operand1};
                        jmp_reg = 1'b1;
                    end else begin
                        jmp_reg = 1'b0;
                    end   
                end
                
                // data processing
                // [opcode=add,sub,mul,div, ...
                // operand0=dest_reg,
                // operand1=src_reg1
                // operand2=src_reg2]
                8'b0000_xxxx: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b1;
                    jmp_reg = 1'b0;
                    
                    // set read and write addresses of registers
                    rf_read_addr1_reg = operand1;
                    rf_read_addr2_reg = operand2;
                    rf_write_addr_reg = operand0;
                    
                    // use alu
                    alu_control_reg = opcode[3:0];
                    alu_input_A_reg = rf_output_data1;
                    alu_input_B_reg = rf_output_data2;
                    rf_input_data_reg = alu_result;
                end
                
                // halt
                // opcode = hlt
                // others = XX
                8'b1100_0000: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b0;
                    jmp_reg = 1'b0;
                    hlt_reg = 1'b1;
                end
                
                default: begin
                    data_bus_write_enable_reg = 1'b0;
                    rf_write_enable_reg = 1'b0;
                    jmp_reg = 1'b0;
                 end
            endcase
        end
    end
    
    // PC update
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 16'hffff;
        else if (hlt_reg)
            pc <= pc;        
        else if (jmp_reg)
            pc <= jmp_pc;
        else
            pc <= pc + 1;
    end

endmodule
