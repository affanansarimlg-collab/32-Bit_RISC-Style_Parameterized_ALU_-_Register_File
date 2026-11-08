`timescale 1ns / 1ps

module risc_alu_rf #(
    parameter WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input wire clk,
    input wire reset,

    // Register file write interface
    input wire write_enable,
    input wire [ADDR_WIDTH-1:0] write_address,
    input wire [WIDTH-1:0] write_data,

    // Register file read addresses
    input wire [ADDR_WIDTH-1:0] read_address1,
    input wire [ADDR_WIDTH-1:0] read_address2,

    // ALU control
    input wire [3:0] ALU_Control,

    // Outputs
    output wire [WIDTH-1:0] read_data1,
    output wire [WIDTH-1:0] read_data2,
    output wire [WIDTH-1:0] ALU_Result,
    output wire Zero,
    output wire Carry_Out,
    output wire Overflow
);

    // Register File instance
    register_file #(
        .DATA_WIDTH(WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) RF (
        .clk(clk),
        .reset(reset),

        .write_enable(write_enable),
        .write_address(write_address),
        .write_data(write_data),

        .read_address1(read_address1),
        .read_data1(read_data1),

        .read_address2(read_address2),
        .read_data2(read_data2)
    );

    // ALU instance
    alu #(
        .WIDTH(WIDTH),
        .SHAMT_WIDTH(5)
    ) ALU (
        .A(read_data1),
        .B(read_data2),

        .ALU_Control(ALU_Control),

        .ALU_Result(ALU_Result),
        .Zero(Zero),
        .Carry_Out(Carry_Out),
        .Overflow(Overflow)
    );

endmodule
