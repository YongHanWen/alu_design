/* Module:       tb.v
 * Description:  Comprehensive Self-Checking Testbench
 * Features:     - Directed Corner Case Testing
 * - Randomized Testing for ALL ALU Operations (Arithmetic, Logic, Shift, Compare)
 * - Automated Golden Model Verification
 */

module tb;
    // Signals
    reg        clk, rst_n, en;
    reg  [7:0] a, b;
    reg  [3:0] op;
    wire [7:0] out;
    wire [3:0] flags;

    // Test Variables
    integer errors = 0;
    integer i;

    // Instantiate Unit Under Test (UUT)
    alu uut (
        .clk(clk), .rst_n(rst_n), .en(en), 
        .a(a), .b(b), .op(op), 
        .out(out), .flags(flags)
    );

    // Clock Generation: 100MHz (Period = 10ns)
    always #5 clk = ~clk;

    // --- HELPER TASK: CHECK RESULTS ---
    // Calculates the expected value and compares it to the ALU output
    task check_result;
        input [7:0] expected;
        input [23:0] op_name; // Operation name for debug (e.g., "ADD")
        begin
            if (out !== expected) begin
                $display("❌ FAIL: %s | Inputs: A=%d, B=%d | Exp: %d vs Got: %d", 
                         op_name, a, b, expected, out);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Waveform Dump
        $dumpfile("alu.vcd"); 
        $dumpvars(0, tb);

        // Initialize
        clk = 0; rst_n = 0; en = 0; a = 0; b = 0; op = 0;
        
        // Reset Sequence
        #10 rst_n = 1; #10 en = 1;

        $display("\n=== 1. DIRECTED TESTS (Corner Cases) ===");
        
        // Test ADD
        a = 10; b = 20; op = 4'b0000; @(posedge clk); #1;
        check_result(30, "ADD");

        // Test CARRY Flag (255 + 1)
        a = 255; b = 1; op = 4'b0000; @(posedge clk); #1;
        if (flags[0] !== 1) begin 
            $display("❌ FAIL: CARRY Flag not set for 255+1"); errors++; 
        end else begin
            $display("✅ PASS: CARRY Flag detected correctly");
        end

        $display("\n=== 2. RANDOMIZED STRESS TEST (ALL OPS) ===");
        
        // Loop 200 times testing ALL 11 modes of the ALU
        for (i = 0; i < 200; i = i + 1) begin
            a = $random; 
            b = $random; 
            op = $random % 11; // Limit opcode to valid range (0-10)
            
            @(posedge clk); #1;
            
            // The Golden Model: Predicts what the hardware SHOULD do
            case(op)
                // Arithmetic
                4'b0000: check_result(a + b, "ADD");
                4'b0001: check_result(a - b, "SUB");
                4'b0010: check_result(a * b, "MUL");

                // Bitwise Logic
                4'b0011: check_result(a & b, "AND");
                4'b0100: check_result(a | b, "OR ");
                4'b0101: check_result(a ^ b, "XOR");
                4'b0110: check_result(~a,    "NOT");

                // Shift
                4'b0111: check_result(a << 1, "SHL");
                4'b1000: check_result(a >> 1, "SHR");

                // Compare (Condition ? 1 : 0)
                4'b1001: check_result((a == b) ? 8'd1 : 8'd0, "SEQ");
                4'b1010: check_result((a < b)  ? 8'd1 : 8'd0, "SLT");
            endcase
        end
        $display("✅ Completed 200 Random Vectors across ALL modes");

        // Summary
        $display("--------------------------------");
        if (errors == 0) $display("🎉 SUCCESS: ALL TESTS PASSED");
        else $display("❌ FAILURE: %d Errors Found", errors);
        $display("--------------------------------");
        
        $finish;
    end
endmodule