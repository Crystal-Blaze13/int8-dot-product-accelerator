module dot_product_4lane (
    input  wire               clk,
    input  wire               rst,
    input  wire               valid_in,

    input  wire signed [7:0]  a0, a1, a2, a3,
    input  wire signed [7:0]  b0, b1, b2, b3,

    output reg  signed [17:0] y,
    output reg                valid_out
);


    // Four parallel signed INT8 carry-save multipliers
    wire signed [15:0] mul0_result, mul1_result;
    wire signed [15:0] mul2_result, mul3_result;

    mul8_csa mul0 (.a(a0), .b(b0), .product(mul0_result));
    mul8_csa mul1 (.a(a1), .b(b1), .product(mul1_result));
    mul8_csa mul2 (.a(a2), .b(b2), .product(mul2_result));
    mul8_csa mul3 (.a(a3), .b(b3), .product(mul3_result));

    // Stage 1: four signed 8x8 multiplications
    reg signed [15:0] p0, p1, p2, p3;
    reg valid_s1;

    // Stage 2: pairwise addition
    reg signed [16:0] s0, s1;
    reg valid_s2;

    always @(posedge clk) begin
        if (rst) begin
            p0 <= 0;
            p1 <= 0;
            p2 <= 0;
            p3 <= 0;

            s0 <= 0;
            s1 <= 0;
            y  <= 0;

            valid_s1 <= 0;
            valid_s2 <= 0;
            valid_out <= 0;
        end else begin
            // Stage 1
            p0 <= mul0_result;
            p1 <= mul1_result;
            p2 <= mul2_result;
            p3 <= mul3_result;
            valid_s1 <= valid_in;

            // Stage 2: explicitly sign-extend to 17 bits
            s0 <= {p0[15], p0} + {p1[15], p1};
            s1 <= {p2[15], p2} + {p3[15], p3};
            valid_s2 <= valid_s1;

            // Stage 3: explicitly sign-extend to 18 bits
            y <= {s0[16], s0} + {s1[16], s1};
            valid_out <= valid_s2;
        end
    end

endmodule
