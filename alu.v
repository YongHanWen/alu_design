/* Module:       alu.v
 * Project:      Automated RTL-to-Synthesis & Timing Flow
 * Description: 8-bit Arithmetic Logic Unit (ALU)
 */

module alu (
    input        clk,    // System Clock (Synchronous Design)
    input        rst_n,  // Active Low Asynchronous Reset
    input        en,     // Clock Enable (Gated Clock logic support)
    input  [7:0] a,      // Operand A
    input  [7:0] b,      // Operand B
    input  [3:0] op,     // Operation Code (16 possible ops)
    output reg [7:0] out,   // 8-bit Data Output
    output reg [3:0] flags  // Status Flags: {Negative, Zero, Overflow, Carry}
);

    // 9-bit register to capture Carry-out bit during arithmetic
    reg [8:0] res_temp;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset State: Clear all outputs
            out   <= 8'b0;
            flags <= 4'b0;
        end else if (en) begin
            // --- 1. EXECUTE OPERATION ---
            case(op)
                // Arithmetic
                4'b0000: res_temp = a + b;       // ADD
                4'b0001: res_temp = a - b;       // SUB
                4'b0010: res_temp = a * b;       // MUL (Lower 8 bits)

                // Bitwise Logic
                4'b0011: res_temp = {1'b0, a & b}; // AND
                4'b0100: res_temp = {1'b0, a | b}; // OR
                4'b0101: res_temp = {1'b0, a ^ b}; // XOR
                4'b0110: res_temp = {1'b0, ~a};    // NOT (Invert)

                // Shifting
                4'b0111: res_temp = {1'b0, a << 1}; // Shift Left
                4'b1000: res_temp = {1'b0, a >> 1}; // Shift Right

                // Comparisons (Output 1 if True)
                4'b1001: res_temp = (a == b) ? 9'd1 : 9'd0; // SEQ (Equal)
                4'b1010: res_temp = (a < b)  ? 9'd1 : 9'd0; // SLT (Less Than)

                default: res_temp = 9'b0;
            endcase

            // --- 2. UPDATE OUTPUTS ---
            out <= res_temp[7:0];

            // --- 3. GENERATE STATUS FLAGS ---
            // Zero (Z): True if result is exactly 0
            flags[2] <= (res_temp[7:0] == 8'b0);
            
            // Negative (N): True if MSB (Sign Bit) is 1
            flags[3] <= res_temp[7];

            // Carry (C): True if 9th bit is 1 (Unsigned Overflow)
            flags[0] <= res_temp[8];

            // Overflow (V): Signed Arithmetic Overflow Check
            if (op == 4'b0000)      // ADD
                flags[1] <= ~(a[7] ^ b[7]) & (a[7] ^ res_temp[7]);
            else if (op == 4'b0001) // SUB
                flags[1] <= (a[7] ^ b[7]) & (a[7] ^ res_temp[7]);
            else
                flags[1] <= 1'b0;
        end
    end
endmodule