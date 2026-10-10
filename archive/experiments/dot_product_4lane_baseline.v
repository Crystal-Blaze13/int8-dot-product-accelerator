module dot_product_4lane (
    input  wire               clk,
    input  wire               rst,
    input  wire               valid_in,

    input  wire signed [7:0]  a0, a1, a2, a3,
    input  wire signed [7:0]  b0, b1, b2, b3,

    output reg  signed [17:0] y,
    output reg                valid_out
);

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
            p0 <= a0 * b0;
            p1 <= a1 * b1;
            p2 <= a2 * b2;
            p3 <= a3 * b3;
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
