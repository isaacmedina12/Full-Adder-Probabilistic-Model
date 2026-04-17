//=========================================================
// 16-bit Full-Adder in SystemVerilog for EE24 Final Project | Sim Target Only
// Implemented with XOR and AND/OR logic only
// Made by: Isaac Medina and Asher Milberg | Tufts University Department of Electrical and Computer Engineering
// Class of 2027
// Date Created: 4/5/2026
//=========================================================

module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module adder16 (
    input  logic [15:0] A,
    input  logic [15:0] B,
    input  logic        Cin,
    output logic [15:0] Sum,
    output logic        Cout
);
    logic [15:0] carry;

    full_adder fa0 (
        .a    (A[0]),
        .b    (B[0]),
        .cin  (Cin),
        .sum  (Sum[0]),
        .cout (carry[0])
    );

    genvar i;
    generate
        for (i = 1; i < 16; i++) begin : adder_chain
            full_adder fai (
                .a    (A[i]),
                .b    (B[i]),
                .cin  (carry[i-1]),
                .sum  (Sum[i]),
                .cout (carry[i])
            );
        end
    endgenerate

    assign Cout = carry[15];
endmodule
