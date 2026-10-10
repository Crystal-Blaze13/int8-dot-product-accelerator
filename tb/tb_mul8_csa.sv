`timescale 1ns/1ps

module tb_mul8_csa;

    reg signed [7:0] a, b;
    wire signed [15:0] product;
    reg signed [15:0] expected;

    integer i, j;
    integer passed = 0;
    integer failed = 0;

    mul8_csa dut (
        .a(a),
        .b(b),
        .product(product)
    );

    initial begin
        for (i = -128; i <= 127; i = i + 1) begin
            for (j = -128; j <= 127; j = j + 1) begin
                a = i;
                b = j;
                expected = i * j;

                #1;

                if (product !== expected) begin
                    if (failed < 10)
                        $display("FAIL: %0d * %0d = %0d, expected %0d",
                                 i, j, product, expected);
                    failed = failed + 1;
                end else begin
                    passed = passed + 1;
                end
            end
        end

        $display("--------------------------------");
        $display("PASSED: %0d", passed);
        $display("FAILED: %0d", failed);
        $display("--------------------------------");

        if (failed == 0)
            $display("ALL 65536 TESTS PASSED");
        else
            $fatal(1, "Multiplier verification failed");

        $finish;
    end

endmodule
