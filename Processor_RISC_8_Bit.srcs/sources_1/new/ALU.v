`timescale 1ns / 1ps

`include "parameter.vh"

module ALU (
    input [3:0] control,
    input [7:0] input_A, input_B,
    output [7:0] result,
    output [3:0] flag // [S, D, C Z]
);

reg [7:0] result_reg;
reg [3:0] flag_reg;

assign result = result_reg;
assign flag = flag_reg;

always @(*) begin
    case (control)
        // NOP
        4'h0: begin
            // Do nothing
        end
    
        // add
        4'h1: begin
            {flag_reg[`Cflag], result_reg} = input_A + input_B; 
            flag_reg[`Dflag] = 0;
        end
    
        // sub
        4'h2: begin
            result_reg = input_A - input_B;
            flag_reg[`Cflag] = (input_A < input_B);
            flag_reg[`Dflag] = 1'b0;
        end
    
        // mul
        4'h3: begin
            {flag_reg[`Cflag], result_reg} = input_A * input_B;
            flag_reg[`Dflag] = 1'b0;
        end
    
        // div
        4'h4: begin
            if (input_B != 0) begin
                result_reg = input_A / input_B;
                flag_reg[`Dflag] = 1'b0;
            end else begin
                result_reg = 0;
                flag_reg[`Dflag] = 1'b0;
            end
            flag_reg[`Cflag] = 1'b0;
        end
    
        // Logical operations
        4'h5: begin
            result_reg = input_A & input_B;
            flag_reg[2:1] = 2'b00;
        end
        
        4'h6: begin
            result_reg = input_A | input_B;
            flag_reg[2:1] = 2'b00;
        end
        
        4'h7: begin
            result_reg = input_A ^ input_B;
            flag_reg[2:1] = 2'b00;
        end
        
        4'h8: begin
            result_reg = input_A << input_B;
            flag_reg[2:1] = 2'b00;
        end
        
        4'h9: begin
            result_reg = input_A >> input_B;
            flag_reg[2:1] = 2'b00;
        end
        
        // Reset flag
        4'hf: begin
            result_reg = 8'h00;
            flag_reg[2:1] = 2'b00;
        end
    
        default: begin
            result_reg = 8'h00;
        end
    endcase
    
    flag_reg[`Zflag] = (result_reg == 8'h00) ? 1'b1: 1'b0;
    flag_reg[`Sflag] = result_reg[7];
end

endmodule
