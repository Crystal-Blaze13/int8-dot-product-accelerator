`timescale 1ns/1ps

module tb_dot_product_4lane;

    reg clk = 0;
    always #5 clk = ~clk;

    reg rst = 1;
    reg valid_in = 0;

    reg signed [7:0] a0, a1, a2, a3;
    reg signed [7:0] b0, b1, b2, b3;

    wire signed [17:0] y;
    wire valid_out;

    dot_product_4lane dut (
        .clk(clk), .rst(rst), .valid_in(valid_in),
        .a0(a0), .a1(a1), .a2(a2), .a3(a3),
        .b0(b0), .b1(b1), .b2(b2), .b3(b3),
        .y(y), .valid_out(valid_out)
    );

    integer expected [0:2];
    reg expected_valid [0:2];

    integer tests_passed = 0;
    integer tests_failed = 0;
    integer cycles = 0;
    integer i;

    integer reference_result;

    // Reference model uses 32-bit integer arithmetic.
    always @(*) begin
        reference_result =
            ($signed(a0) * $signed(b0)) +
            ($signed(a1) * $signed(b1)) +
            ($signed(a2) * $signed(b2)) +
            ($signed(a3) * $signed(b3));
    end

    // Scoreboard: update expected pipeline at rising edge.
    // Compare after nonblocking assignments have settled.
    always @(posedge clk) begin
        if (rst) begin
            for (integer j = 0; j < 3; j = j + 1) begin
                expected[j] = 0;
                expected_valid[j] = 0;
            end
        end else begin
            expected[2] = expected[1];
            expected[1] = expected[0];
            expected[0] = reference_result;

            expected_valid[2] = expected_valid[1];
            expected_valid[1] = expected_valid[0];
            expected_valid[0] = valid_in;
        end

        #1;

        cycles = cycles + 1;

        if (valid_out !== expected_valid[2]) begin
            $display("FAIL cycle=%0d valid_out=%b expected=%b",
                     cycles, valid_out, expected_valid[2]);
            tests_failed = tests_failed + 1;
        end else if (expected_valid[2]) begin
            if ($signed(y) !== expected[2]) begin
                $display("FAIL cycle=%0d y=%0d expected=%0d",
                         cycles, $signed(y), expected[2]);
                tests_failed = tests_failed + 1;
            end else begin
                tests_passed = tests_passed + 1;
            end
        end
    end

    task send_vectors(
        input integer aa0, aa1, aa2, aa3,
        input integer bb0, bb1, bb2, bb3
    );
    begin
        @(negedge clk);
        a0 = aa0; a1 = aa1; a2 = aa2; a3 = aa3;
        b0 = bb0; b1 = bb1; b2 = bb2; b3 = bb3;
        valid_in = 1;
    end
    endtask

    initial begin
        a0 = 0; a1 = 0; a2 = 0; a3 = 0;
        b0 = 0; b1 = 0; b2 = 0; b3 = 0;

        $display("Starting 4-lane INT8 dot-product verification...");

        repeat (3) @(negedge clk);
        rst = 0;

        // Directed tests
        send_vectors(1, 2, 3, 4, 5, 6, 7, 8);
        send_vectors(-1, -2, -3, -4, 5, 6, 7, 8);
        send_vectors(-128, -128, -128, -128,
                     -128, -128, -128, -128);
        send_vectors(127, 127, 127, 127,
                     127, 127, 127, 127);
        send_vectors(-128, 127, -128, 127,
                     127, -128, 127, -128);
        send_vectors(0, 0, 0, 0, 0, 0, 0, 0);

        // 10,000 randomized vectors
        for (i = 0; i < 10000; i = i + 1) begin
            @(negedge clk);
            a0 = $urandom_range(0,255) - 128;
            a1 = $urandom_range(0,255) - 128;
            a2 = $urandom_range(0,255) - 128;
            a3 = $urandom_range(0,255) - 128;

            b0 = $urandom_range(0,255) - 128;
            b1 = $urandom_range(0,255) - 128;
            b2 = $urandom_range(0,255) - 128;
            b3 = $urandom_range(0,255) - 128;

            valid_in = 1;
        end

        @(negedge clk);
        valid_in = 0;

        repeat (5) @(negedge clk);

        $display("--------------------------------------");
        $display("Tests passed: %0d", tests_passed);
        $display("Tests failed: %0d", tests_failed);
        $display("Total clock cycles: %0d", cycles);
        $display("--------------------------------------");

        if (tests_failed == 0 && tests_passed == 10006)
            $display("PASS: All 10006 dot products verified!");
        else
            $fatal(1, "Verification FAILED");

        $finish;
    end

endmodule
