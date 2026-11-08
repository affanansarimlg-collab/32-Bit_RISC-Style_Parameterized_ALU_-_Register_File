`timescale 1ns / 1ps

module alu #(
    parameter WIDTH = 32,
    parameter SHAMT_WIDTH = 5
)(
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire [3:0] ALU_Control,

    output reg  [WIDTH-1:0] ALU_Result,
    output wire Zero,
    output reg  Carry_Out,
    output reg  Overflow
);

    reg [WIDTH:0] temp;

    // ALU operation codes
    localparam ADD    = 4'b0000;
    localparam SUB    = 4'b0001;
    localparam AND_OP = 4'b0010;
    localparam OR_OP  = 4'b0011;
    localparam XOR_OP = 4'b0100;
    localparam NOR_OP = 4'b0101;
    localparam SLT    = 4'b0110;
    localparam SLTU   = 4'b0111;
    localparam SLL    = 4'b1000;
    localparam SRL    = 4'b1001;
    localparam SRA    = 4'b1010;
    localparam PASS_B = 4'b1011;

    always @(*) begin

        ALU_Result = {WIDTH{1'b0}};
        Carry_Out  = 1'b0;
        Overflow   = 1'b0;
        temp       = {(WIDTH+1){1'b0}};

        case (ALU_Control)

            ADD: begin
                temp = {1'b0, A} + {1'b0, B};
                ALU_Result = temp[WIDTH-1:0];
                Carry_Out = temp[WIDTH];

                Overflow = (~(A[WIDTH-1] ^ B[WIDTH-1])) &
                            (ALU_Result[WIDTH-1] ^ A[WIDTH-1]);
            end

            SUB: begin
                temp = {1'b0, A} - {1'b0, B};
                ALU_Result = temp[WIDTH-1:0];

                // Carry_Out = 1 means no unsigned borrow
                Carry_Out = (A >= B);

                Overflow = (A[WIDTH-1] ^ B[WIDTH-1]) &
                           (ALU_Result[WIDTH-1] ^ A[WIDTH-1]);
            end

            AND_OP: begin
                ALU_Result = A & B;
            end

            OR_OP: begin
                ALU_Result = A | B;
            end

            XOR_OP: begin
                ALU_Result = A ^ B;
            end

            NOR_OP: begin
                ALU_Result = ~(A | B);
            end

            SLT: begin
                ALU_Result = ($signed(A) < $signed(B))
                             ? {{(WIDTH-1){1'b0}}, 1'b1}
                             : {WIDTH{1'b0}};
            end

            SLTU: begin
                ALU_Result = (A < B)
                             ? {{(WIDTH-1){1'b0}}, 1'b1}
                             : {WIDTH{1'b0}};
            end

            SLL: begin
                ALU_Result = A << B[SHAMT_WIDTH-1:0];
            end

            SRL: begin
                ALU_Result = A >> B[SHAMT_WIDTH-1:0];
            end

            SRA: begin
                ALU_Result = $signed(A) >>> B[SHAMT_WIDTH-1:0];
            end

            PASS_B: begin
                ALU_Result = B;
            end

            default: begin
                ALU_Result = {WIDTH{1'b0}};
            end

        endcase
    end

    assign Zero = (ALU_Result == {WIDTH{1'b0}});

endmodule
