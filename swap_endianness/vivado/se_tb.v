`timescale 1ns / 1ps
/****************************************************************************
 * se_tb.v
 * Author: Lucas Brasilino <lucas.brasilino@gmail.com>
 ****************************************************************************/

/**
 * Module: swap_endianness testbench
 *
 */
module se_tb;
    reg     [31:0]    in_val1;
    wire    [31:0]    out_val1;
    reg     [63:0]    in_val2;
    wire    [63:0]    out_val2;
    reg     [255:0]    in_val3;
    wire    [255:0]    out_val3;

    initial begin
        in_val1 = 32'h00;
        in_val2 = 64'h00;
        in_val3 = 256'h00;

        #20 in_val1 = 32'haabbccdd;
        #20 in_val2 = 64'h0001020304050607;
        #20 in_val3 = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
    end

    swap_endianness dut1 (
        .in_vect (in_val1),
        .out_vect (out_val1)
     );

    swap_endianness #(.WIDTH(64)) dut2 (
            .in_vect (in_val2),
            .out_vect (out_val2)
        );

    swap_endianness #(.WIDTH(256)) dut3 (
            .in_vect (in_val3),
            .out_vect (out_val3)
        );
endmodule
