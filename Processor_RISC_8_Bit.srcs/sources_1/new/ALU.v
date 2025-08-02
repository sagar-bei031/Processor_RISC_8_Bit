`timescale 1ns / 1ps

`include "parameter.vh"

module ALU (
    input [3:0] control,
    input [7:0] input_A, input_B,
    output [7:0] result,
    output [3:0] flag // [S, C, D, Z]
);

reg [7:0] result_reg;
reg [3:0] flag_reg;

assign result = result_reg;
assign flag = flag_reg;

always @(*) begin
    case (control)
        // reset result and flag 
        4'h0: begin
            result_reg = 0;
        end
    
        // add
        4'h1: {flag_reg[`Cflag], result_reg} = input_A + input_B; 
    
        // sub
        4'h2: begin
            result_reg = input_A - input_B;
            flag_reg[`Cflag] = (input_A < input_B);
        end
    
        // mul
        4'h3: result_reg = input_A * input_B;
    
        // div
        4'h4: begin
            if (input_B != 0) begin
                result_reg = input_A / input_B;
                flag_reg[`Dflag] = 0;
            end else begin
                result_reg = 0;
                flag_reg[`Dflag] = 1;
            end
        end
    
        4'h5: result_reg = input_A & input_B; 
        4'h6: result_reg = input_A | input_B; 
        4'h7: result_reg = input_A ^ input_B; 
        4'h8: result_reg = input_A << input_B;
        4'h9: result_reg = input_A >> input_B;
    
        default: begin
            result_reg = 0;
        end
    endcase
    
    flag_reg[`Zflag] = result_reg == 0;
    flag_reg[`Sflag] = result_reg[7];
end

endmodule
