module mul8_csa (
    input  wire signed [7:0] a,
    input  wire signed [7:0] b,
    output wire signed [15:0] product
);

    // Signed Baugh-Wooley partial products.
    // Complement terms involving exactly one sign bit.
    wire [15:0] row [0:7];

    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_rows
            for (j = 0; j < 16; j = j + 1) begin : gen_bits
                if (j >= i && j < i + 8) begin
                    if ((i == 7) ^ ((j - i) == 7)) begin
                        assign row[i][j] = ~(a[j-i] & b[i]);
                    end else begin
                        assign row[i][j] = a[j-i] & b[i];
                    end
                end else begin
                    assign row[i][j] = 1'b0;
                end
            end
        end
    endgenerate

    wire [15:0] r0 = row[0];
    wire [15:0] r1 = row[1];
    wire [15:0] r2 = row[2];
    wire [15:0] r3 = row[3];
    wire [15:0] r4 = row[4];
    wire [15:0] r5 = row[5];
    wire [15:0] r6 = row[6];
    wire [15:0] r7 = row[7];

    // Carry-save compressor: three operands -> sum and shifted carry.
    wire [15:0] s0 = r0 ^ r1 ^ r2;
    wire [15:0] c0 = ((r0 & r1) | (r0 & r2) | (r1 & r2)) << 1;

    wire [15:0] s1 = r3 ^ r4 ^ r5;
    wire [15:0] c1 = ((r3 & r4) | (r3 & r5) | (r4 & r5)) << 1;

    wire [15:0] s2 = s0 ^ c0 ^ s1;
    wire [15:0] c2 = ((s0 & c0) | (s0 & s1) | (c0 & s1)) << 1;

    wire [15:0] s3 = c1 ^ r6 ^ r7;
    wire [15:0] c3 = ((c1 & r6) | (c1 & r7) | (r6 & r7)) << 1;

    wire [15:0] s4 = s2 ^ c2 ^ s3;
    wire [15:0] c4 = ((s2 & c2) | (s2 & s3) | (c2 & s3)) << 1;

    wire [15:0] s5 = s4 ^ c4 ^ c3;
    wire [15:0] c5 = ((s4 & c4) | (s4 & c3) | (c4 & c3)) << 1;

    // Signed multiplication correction: +2^8 + 2^15 (mod 2^16).
    assign product = s5 + c5 + 16'h8100;

endmodule
