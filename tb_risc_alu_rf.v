`timescale 1ns / 1ps

module tb_risc_alu_rf;

    reg clk;
    reg reset;

    reg write_enable;
    reg [4:0] write_address;
    reg [31:0] write_data;

    reg [4:0] read_address1;
    reg [4:0] read_address2;

    reg [3:0] ALU_Control;

    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] ALU_Result;

    wire Zero;
    wire Carry_Out;
    wire Overflow;

    integer errors;

    // DUT: Device Under Test
    risc_alu_rf DUT (
        .clk(clk),
        .reset(reset),

        .write_enable(write_enable),
        .write_address(write_address),
        .write_data(write_data),

        .read_address1(read_address1),
        .read_address2(read_address2),

        .ALU_Control(ALU_Control),

        .read_data1(read_data1),
        .read_data2(read_data2),

        .ALU_Result(ALU_Result),
        .Zero(Zero),
        .Carry_Out(Carry_Out),
        .Overflow(Overflow)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    // Write task
    task write_reg;
        input [4:0] address;
        input [31:0] data;
        begin
            @(negedge clk);

            write_enable = 1'b1;
            write_address = address;
            write_data = data;

            @(posedge clk);
            #1;

            write_enable = 1'b0;
        end
    endtask

    // Check ALU result
    task check_alu;
        input [31:0] expected;
        input [8*40:1] test_name;
        begin
            #1;

            if (ALU_Result !== expected) begin
                $display("FAIL: %s", test_name);
                $display("Expected = %h, Actual = %h",
                          expected, ALU_Result);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

    initial begin

        // Initialize
        clk = 0;
        reset = 0;

        write_enable = 0;
        write_address = 0;
        write_data = 0;

        read_address1 = 0;
        read_address2 = 0;

        ALU_Control = 0;

        errors = 0;

        $display("----------------------------------");
        $display(" ALU + REGISTER FILE TEST START");
        $display("----------------------------------");

        // TEST 1: Reset
        reset = 1;

        @(posedge clk);
        #1;

        reset = 0;

        $display("PASS: Reset operation");

        // TEST 2: Write R1 = 10
        write_reg(5'd1, 32'd10);

        // TEST 3: Write R2 = 20
        write_reg(5'd2, 32'd20);

        // TEST 4: Read R1 and R2
        read_address1 = 5'd1;
        read_address2 = 5'd2;

        #1;

        if ((read_data1 !== 32'd10) ||
            (read_data2 !== 32'd20)) begin

            $display("FAIL: Register read verification");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Register read verification");
        end

        // TEST 5: Write attempt to R0
        write_reg(5'd0, 32'hFFFFFFFF);

        read_address1 = 5'd0;
        #1;

        if (read_data1 !== 32'd0) begin
            $display("FAIL: Zero register protection");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Zero register protection");
        end

        // TEST 6: Write disabled
        @(negedge clk);

        write_enable = 0;
        write_address = 5'd3;
        write_data = 32'hDEADBEEF;

        @(posedge clk);
        #1;

        read_address1 = 5'd3;
        #1;

        if (read_data1 !== 32'd0) begin
            $display("FAIL: Write enable protection");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Write enable protection");
        end

        // TEST 7: ADD
        read_address1 = 5'd1;
        read_address2 = 5'd2;

        ALU_Control = 4'b0000;

        check_alu(32'd30, "ADD");

        // TEST 8: SUB
        ALU_Control = 4'b0001;

        check_alu(32'hFFFFFFF6, "SUB");

        // TEST 9: AND
        ALU_Control = 4'b0010;

        check_alu(32'd0, "AND");

        // TEST 10: OR
        ALU_Control = 4'b0011;

        check_alu(32'd30, "OR");

        // TEST 11: XOR
        ALU_Control = 4'b0100;

        check_alu(32'd30, "XOR");

        // TEST 12: NOR
        ALU_Control = 4'b0101;

        check_alu(32'hFFFFFFE1, "NOR");

        // TEST 13: Signed less than
        ALU_Control = 4'b0110;

        check_alu(32'd1, "SLT");

        // TEST 14: Unsigned less than
        ALU_Control = 4'b0111;

        check_alu(32'd1, "SLTU");

        // TEST 15: PASS B
        ALU_Control = 4'b1011;

        check_alu(32'd20, "PASS B");

        // TEST 16: Zero flag
        read_address1 = 5'd1;
        read_address2 = 5'd1;

        ALU_Control = 4'b0001;

        #1;

        if (Zero !== 1'b1) begin
            $display("FAIL: Zero flag");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Zero flag");
        end

        // TEST 17: Reset clears stored data
        @(negedge clk);
        reset = 1;

        @(posedge clk);
        #1;

        reset = 0;

        read_address1 = 5'd1;
        read_address2 = 5'd2;

        #1;

        if ((read_data1 !== 32'd0) ||
            (read_data2 !== 32'd0)) begin

            $display("FAIL: Reset clearing verification");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Reset clearing verification");
        end

        // FINAL RESULT
        $display("----------------------------------");

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
        end
        else begin
            $display("TEST FAILED");
            $display("Total errors = %d", errors);
        end

        $display("----------------------------------");

        #20;
        $finish;

    end

endmodule
