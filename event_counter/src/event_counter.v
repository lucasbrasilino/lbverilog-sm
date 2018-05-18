
/****************************************************************************
 * event_counter.v
 * (c) 2018 Lucas Brasilino <lucas.brasilino@gmail.com>
 ****************************************************************************/


/**
 * Module: event_counter
 *
 *  A flexible event counter
 */

`timescale 1 ns / 1 ns
`define TRUE 1'b1
`define FALSE 1'b0

module event_counter #(
        parameter integer TARGET_WIDTH        = 4,
        parameter integer EVENT_IS_CLOCK      = 0,
        parameter integer HAS_ENABLE          = 1,
        parameter integer RESET_IF_REACHED    = 1
        ) (
        input wire                            ACLK,
        input wire                            ARESETN,
        input wire                            ENABLE,

        input  wire  [TARGET_WIDTH-1 : 0]     INITIAL,
        input  wire  [TARGET_WIDTH-1 : 0]     TARGET,
        input  wire                           TICK,
        output wire                           REACHED,
        output wire  [TARGET_WIDTH-1 : 0]     COUNTER
        );

    reg  [TARGET_WIDTH-1 : 0]                 counter_r;
    wire [TARGET_WIDTH : 0]                   counter_plus1;
    wire                                      tick;
    wire                                      enable;
    reg                                       reached;
    wire                                      rst_reached;

    /* generate what is tick */
    generate
        if (EVENT_IS_CLOCK == 1)
            assign tick = `TRUE;
        else
            assign tick = TICK;
    endgenerate

    /* generate enable */
    generate
        if (HAS_ENABLE == 1)
            assign enable = ENABLE;
        else
            assign enable = `TRUE;
    endgenerate

    /* generate reset if reached */
    generate
        if (RESET_IF_REACHED == 1)
            assign rst_reached = REACHED;
        else
            assign rst_reached = `FALSE;
    endgenerate

    assign REACHED = reached;
    assign COUNTER = counter_r;
    assign counter_plus1 = counter_r + 1'b1;

    always @(*) begin : RESET_REACHED
        if (~ARESETN)
            reached = `FALSE;
        else
            reached = (counter_r == TARGET) ? `TRUE : `FALSE;
    end//always

    always @(posedge ACLK) begin
        if (~ARESETN || rst_reached) begin
            counter_r <= INITIAL;
        end else
        if (enable)
            counter_r <= (tick == `TRUE) ? counter_plus1 : counter_r;
    end//always
endmodule


