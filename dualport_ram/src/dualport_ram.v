`timescale 1 ns / 1 ps

/****************************************************************************
 * dualport_ram.v
 * (c) 2018 Lucas Brasilino <lucas.brasilino@gmail.com>
 ****************************************************************************/

/**
 * Module: dualport_ram
 *
 * A dualport RAM (can also be single port :-) )
 */

`define TRUE 1'b1
`define FALSE 1'b0

module dualport_ram #(
        parameter            TYPE       = "DUALPORT",
        parameter integer    DATA_WIDTH = 32,
        parameter integer    ADDR_WIDTH = 4,
        parameter integer    PROP_DELAY = 0
        )
        (
        input  wire                      ACLK,
        /* PORT A */
        input  wire [ADDR_WIDTH-1:0]     PORTA_W_ADDR,
        input  wire [DATA_WIDTH-1:0]     PORTA_W_DATA,
        input  wire                      PORTA_W_EN,
        input  wire [ADDR_WIDTH-1:0]     PORTA_R_ADDR,
        output wire [DATA_WIDTH-1:0]     PORTA_R_DATA,
        /* PORT B */
        input  wire [ADDR_WIDTH-1:0]     PORTB_W_ADDR,
        input  wire [DATA_WIDTH-1:0]     PORTB_W_DATA,
        input  wire                      PORTB_W_EN,
        output wire                      PORTB_W_CONTENT,
        input  wire [ADDR_WIDTH-1:0]     PORTB_R_ADDR,
        output wire [DATA_WIDTH-1:0]     PORTB_R_DATA
        );

    localparam NB_DELAY                    = PROP_DELAY;
    localparam A_DELAY                     = PROP_DELAY;

    wire                        portb_w_content;

    reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];

    assign PORTA_R_DATA = ram[PORTA_R_ADDR];

    always @(posedge ACLK)
        if (PORTA_W_EN)
            ram[PORTA_W_ADDR] <= #NB_DELAY PORTA_W_DATA;

        generate
            if (TYPE == "DUALPORT") begin
                assign PORTB_R_DATA = ram[PORTB_R_ADDR];
                assign PORTB_W_CONTENT = portb_w_content;
                assign portb_w_content = ((PORTA_W_EN && PORTB_W_EN) && (PORTA_W_ADDR == PORTB_W_ADDR)) ? `TRUE : `FALSE;

                always @(posedge ACLK)
                    if (PORTB_W_EN && !portb_w_content)
                        ram[PORTB_W_ADDR] <= #NB_DELAY PORTB_W_DATA;
            end
            else if (TYPE == "SINGLEPORT") begin
                assign PORTB_W_CONTENT = `FALSE;
                assign PORTB_R_DATA = 0;
            end
        endgenerate
endmodule
