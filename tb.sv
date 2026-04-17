//=========================================================
// 16-bit Full-Adder Testbench in SystemVerilog for EE24 Final Project
// Drives 10,000 random samples, dumps a VCD, and logs a CSV summary.
//=========================================================

`timescale 1ns/1ps

module tb;
    localparam int NUM_SAMPLES = 10000;

    logic [15:0] tb_A;
    logic [15:0] tb_B;
    logic        tb_Cin;
    logic [15:0] dut_Sum;
    logic        dut_Cout;
    logic [16:0] expected_total;

    integer sample_idx;
    integer vector_fd;
    integer results_fd;
    integer scan_count;
    integer loaded_samples;
    integer error_count;
    integer i;
    integer vec_cin_int;
    logic [15:0] vec_A;
    logic [15:0] vec_B;

    adder16 dut (
        .A   (tb_A),
        .B   (tb_B),
        .Cin (tb_Cin),
        .Sum (dut_Sum),
        .Cout(dut_Cout)
    );

    initial begin
        tb_A           = '0;
        tb_B           = '0;
        tb_Cin         = 1'b0;
        expected_total = '0;
        sample_idx     = -1;
        loaded_samples = 0;
        error_count    = 0;

        $dumpfile("adder16_random.vcd");
        $dumpvars(0, tb);

        vector_fd = $fopen("test_vectors.mem", "r");
        if (vector_fd == 0) begin
            $display("ERROR: Could not open test_vectors.mem");
            $finish;
        end

        results_fd = $fopen("simulation_results.csv", "w");
        if (results_fd == 0) begin
            $display("ERROR: Could not open simulation_results.csv for writing");
            $finish;
        end

        $fdisplay(results_fd,
            "sample_idx,time_ns,A_hex,B_hex,Cin,Sum_hex,Cout,Expected_total_hex,Match");

        #1;

        begin : run_vectors
            for (i = 0; i < NUM_SAMPLES; i = i + 1) begin
                scan_count = $fscanf(vector_fd, "%h %h %d\n", vec_A, vec_B, vec_cin_int);
                if (scan_count != 3) begin
                    loaded_samples = i;
                    disable run_vectors;
                end

                sample_idx     = i;
                tb_A           = vec_A;
                tb_B           = vec_B;
                tb_Cin         = vec_cin_int[0];
                expected_total = {1'b0, vec_A} + {1'b0, vec_B} + vec_cin_int[0];
                loaded_samples = i + 1;

                #1;

                if ({dut_Cout, dut_Sum} !== expected_total) begin
                    error_count = error_count + 1;
                    $display(
                        "MISMATCH sample=%0d A=%04h B=%04h Cin=%0d DUT=%05h EXPECTED=%05h",
                        sample_idx,
                        tb_A,
                        tb_B,
                        tb_Cin,
                        {dut_Cout, dut_Sum},
                        expected_total
                    );
                end

                $fdisplay(
                    results_fd,
                    "%0d,%0t,%04h,%04h,%0d,%04h,%0d,%05h,%0d",
                    sample_idx,
                    $time,
                    tb_A,
                    tb_B,
                    tb_Cin,
                    dut_Sum,
                    dut_Cout,
                    expected_total,
                    ({dut_Cout, dut_Sum} === expected_total)
                );

                #9;
            end
        end

        $display("Simulation complete.");
        $display("Loaded samples: %0d", loaded_samples);
        $display("Mismatches: %0d", error_count);

        $fclose(vector_fd);
        $fclose(results_fd);
        $finish;
    end
endmodule
