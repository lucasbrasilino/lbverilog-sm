`timescale 1ns / 1ps
/****************************************************************************
 * swap_endianness.v
 * Author: Lucas Brasilino <lucas.brasilino@gmail.com>
 ****************************************************************************/

/**
 * Module: swap_endianness
 *
 */
module swap_endianness
        #(
            parameter WIDTH = 32
         )
        (
            input     wire [WIDTH-1 : 0] in_vect,
            output    wire [WIDTH-1 : 0] out_vect
        );

    localparam        WIDTH_BYTES = WIDTH/8;

    generate
        genvar i;
        for (i = 0; i < WIDTH_BYTES; i = i + 1)
            begin
                assign out_vect[ i*8 +: 8] = in_vect[ (WIDTH-1)-(i*8) -: 8];
            end
    endgenerate

endmodule
