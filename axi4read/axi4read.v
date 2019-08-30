`timescale 1 ns / 1 ps
/****************************************************************************
 * axi4read.v
 * Author: Lucas Brasilino <lucas.brasilino@gmail.com>/ Twitter: @lucas_brasilino
 ****************************************************************************/
`include "stddef.vh"

/**
 * Module: axi4read
 *
 * Read memory location
 */
/* verilator lint_off UNUSED */

module axi4read #(
        parameter integer                            PROP_DELAY = 0,
        parameter integer                            C_M_AXI_ADDR_WIDTH = 64,
        parameter integer                            C_M_AXI_DATA_WIDTH = 64,
        parameter integer                            C_M_AXI_THREAD_ID_WIDTH = 1
        ) (
        input wire                  ACLK,
        input wire                  ARESETN,

        // Master Interface Read Address
        output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]     M_AXI_ARID,
        output wire [C_M_AXI_ADDR_WIDTH-1:0]          M_AXI_ARADDR,
        output wire [8-1:0]                           M_AXI_ARLEN,
        output wire [3-1:0]                           M_AXI_ARSIZE,
        output wire [2-1:0]                           M_AXI_ARBURST,
        output wire [2-1:0]                           M_AXI_ARLOCK,
        output wire [4-1:0]                           M_AXI_ARCACHE,
        output wire [3-1:0]                           M_AXI_ARPROT,
        output wire [4-1:0]                           M_AXI_ARQOS,
        /*output wire [C_M_AXI_ARUSER_WIDTH-1:0]        M_AXI_ARUSER,*/
        output wire                                   M_AXI_ARVALID,
        input  wire                                   M_AXI_ARREADY,

        // Master Interface Read Data
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]     M_AXI_RID,
        input  wire [C_M_AXI_DATA_WIDTH-1:0]          M_AXI_RDATA,
        input  wire [2-1:0]                           M_AXI_RRESP,
        input  wire                                   M_AXI_RLAST,
        /*input  wire [C_M_AXI_RUSER_WIDTH-1:0]         M_AXI_RUSER,*/
        input  wire                                   M_AXI_RVALID,
        output wire                                   M_AXI_RREADY,

        output wire                                   OP_OK,
        output wire                                   OP_DONE,
        input  wire                                   OP_START,
        input  wire [C_M_AXI_ADDR_WIDTH-1:0]          ADDRESS,
        output wire [(C_M_AXI_DATA_WIDTH*2)-1:0]          RET_VAL);

    `include "functions.vh"

    localparam    NB_DELAY               = PROP_DELAY;
    localparam    A_DELAY                = PROP_DELAY;

    localparam    ST_IDLE                = 0;
    localparam    ST_WAIT_START          = 1;
    localparam    ST_WR_ADDR             = 2;
    localparam    ST_RD_DATA_0           = 3;
    localparam    ST_RD_DATA_1           = 4;
    localparam    ST_RET_VAL             = 5;
    localparam    ST_END                 = 6;
    localparam    ST_SIZE                = clog2(ST_END);

    reg     [ST_SIZE-1:0]               state, state_next;
    reg     [C_M_AXI_ADDR_WIDTH-1:0]    addr;
    reg     [C_M_AXI_DATA_WIDTH-1:0]    ret_val [ 0 : 1 ];
    reg                                 op_done, op_ok;
    reg                                 arvalid, rready;
    wire                                read_data_last;

    assign    OP_DONE                    = op_done;
    assign    OP_OK                      = op_ok;
    assign    M_AXI_ARVALID              = arvalid;
    assign    M_AXI_RREADY               = rready;
    assign    RET_VAL                    = {ret_val[1],ret_val[0]};
    assign    M_AXI_ARADDR               = ADDRESS;
    assign    read_data_last             = (M_AXI_RVALID && M_AXI_RLAST);

    /* assign fixed value to particular ports */
    assign M_AXI_ARID         = 1'h0;
    assign M_AXI_ARLEN        = 8'h1;
    assign M_AXI_ARSIZE       = 3'h3;
    assign M_AXI_ARBURST      = 2'h0;
    assign M_AXI_ARLOCK       = 2'h0;
    assign M_AXI_ARCACHE      = 4'h2;
    assign M_AXI_ARPROT       = 3'h0;
    assign M_AXI_ARQOS        = 4'h0;

    always @(posedge ACLK) begin : AXI_ADDR_DATA
        case (state)
            ST_IDLE: op_ok <= /*#NB_DELAY*/ `FALSE;
            ST_WAIT_START: op_ok <= /*#NB_DELAY*/ `FALSE;
            ST_RD_DATA_0: ret_val[0] <= /*#NB_DELAY*/ M_AXI_RDATA;
            ST_RD_DATA_1: begin
                ret_val[1] <= /*#NB_DELAY*/ M_AXI_RDATA;
                if (read_data_last) begin
                    op_ok <= /*#NB_DELAY*/ ~(|M_AXI_RRESP);
                end
            end
            ST_RET_VAL: op_ok <= /*#NB_DELAY*/ `FALSE;
            default: begin
                addr <= /*#NB_DELAY*/ addr;
                ret_val[0] <= /*#NB_DELAY*/ ret_val[0];
                ret_val[1] <= /*#NB_DELAY*/ ret_val[1];
            end
        endcase
    end//always

    always @(*) begin
        state_next = state;
        op_done = `FALSE;
        arvalid = `FALSE;
        rready = `FALSE;
        case (state)
            ST_IDLE: state_next = ST_WAIT_START;
            ST_WAIT_START: state_next = (OP_START) ? ST_WR_ADDR: ST_WAIT_START;
            ST_WR_ADDR: begin
                arvalid = `TRUE;
                state_next = (M_AXI_ARREADY) ? ST_RD_DATA_0 : ST_WR_ADDR;
            end
            /* begin of baby steps */
            ST_RD_DATA_0: begin
                rready = `TRUE;
                state_next = (M_AXI_RVALID) ? ST_RD_DATA_1 : ST_RD_DATA_0;
            end
            ST_RD_DATA_1: begin
                rready = `TRUE;
                state_next = (read_data_last) ? ST_RET_VAL : ST_RD_DATA_1;
            end
            /* end of baby steps */
            ST_RET_VAL: begin
                op_done = `TRUE;
                state_next = ST_WAIT_START;
            end
        endcase
    end//always

    always @(posedge ACLK) begin : FSM_STATE
        if (~ARESETN) begin
            state <= /*#NB_DELAY*/ ST_IDLE;
        end
        else begin
            state <= /*#NB_DELAY*/ state_next;
        end
    end//always

endmodule
