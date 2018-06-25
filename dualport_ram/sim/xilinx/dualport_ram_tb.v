`timescale 1 ns / 1 ps

/****************************************************************************
 * dualport_ram_tb.v
 * (c) 2018 Lucas Brasilino <lucas.brasilino@gmail.com>
 ****************************************************************************/

/**
 * Module: bram_test_tb
 *
 * TODO: Add module documentation
 */

`define TRUE 1'b1
`define FALSE 1'b0

module dualport_ram_tb;

    localparam           PERIOD         = 10;
    localparam           HALF_CORE_PERIOD = PERIOD/2;
    localparam           RESET_CLK_NUM  = 10;
    localparam           PROP_DELAY     = 0;

    parameter            DATA_WIDTH     = 8;
    parameter            ADDR_WIDTH     = 4;
    parameter            DEPTH          = 16;
    reg                  aclk;
    reg                  aresetn;

    reg [ADDR_WIDTH-1:0]     PORTA_W_ADDR;
    reg [DATA_WIDTH-1:0]     PORTA_W_DATA;
    reg                      PORTA_W_EN;
    reg [ADDR_WIDTH-1:0]     PORTA_R_ADDR;
    wire [DATA_WIDTH-1:0]     PORTA_R_DATA;
    reg [ADDR_WIDTH-1:0]     PORTB_W_ADDR;
    reg [DATA_WIDTH-1:0]     PORTB_W_DATA;
    reg                      PORTB_W_EN;
    wire                     PORTB_W_CONTENT;
    reg [ADDR_WIDTH-1:0]     PORTB_R_ADDR;
    wire [DATA_WIDTH-1:0]     PORTB_R_DATA;

    task print;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        begin
            $display("time = %d | Mem[%x] = %x",$time, addr, data);
        end
    endtask

    initial begin
        aclk = 1'b0;
        #(HALF_CORE_PERIOD);
        forever
            #(HALF_CORE_PERIOD) aclk = ~aclk;
    end

    initial begin
        aresetn = 1'b0;
        repeat (RESET_CLK_NUM) @(posedge aclk);
        aresetn = 1'b1;
        $display("Reset Deasserted");
    end

    initial begin
        PORTA_W_EN = 1'b0;
        PORTA_W_ADDR = 0;
        PORTA_R_ADDR = 0;
        wait (aresetn == 1'b1);
        @(posedge aclk) PORTA_W_ADDR = 1;
        PORTA_W_DATA = 8'hca;
        PORTA_W_EN = 1'b1;
        @(posedge aclk) PORTA_W_EN = 0;
        PORTA_R_ADDR = 1;
        @(posedge aclk);
        #1 print(PORTA_R_ADDR, PORTA_R_DATA);
        @(posedge aclk) PORTB_R_ADDR = 1;
        PORTA_W_ADDR = 2;
        PORTA_W_DATA = 8'hba;
        PORTA_W_EN = 1'b1;
        #1 print(PORTB_R_ADDR,PORTB_R_DATA);
        @(posedge aclk) PORTB_R_ADDR = 2;
        PORTA_W_EN = `FALSE;
        #1 print(PORTB_R_ADDR,PORTB_R_DATA);
        @(posedge aclk) PORTB_W_ADDR = 1;
        PORTB_W_DATA = 8'hea;
        PORTB_W_EN = `TRUE;
        @(posedge aclk) PORTA_R_ADDR = 1;
        #1 print(PORTA_R_ADDR,PORTA_R_DATA);
        @(posedge aclk) PORTA_W_ADDR = 3;
        PORTA_W_EN = `TRUE;
        PORTA_W_DATA = 8'hff;
        PORTB_W_ADDR = 3;
        PORTB_W_DATA = 8'h00;
        PORTB_W_EN = `TRUE;
        @(posedge aclk) PORTA_R_ADDR = 3;
        #1 print(PORTA_R_ADDR,PORTA_R_DATA);
        repeat (10) @(posedge aclk);
        $finish;
    end

    dualport_ram #(
        .DATA_WIDTH       (DATA_WIDTH      ),
        .ADDR_WIDTH       (ADDR_WIDTH      ),
        .PROP_DELAY       (PROP_DELAY      )
        ) dualport_ram (
        .ACLK             (aclk            ),
        .PORTA_W_ADDR     (PORTA_W_ADDR    ),
        .PORTA_W_DATA     (PORTA_W_DATA    ),
        .PORTA_W_EN       (PORTA_W_EN      ),
        .PORTA_R_ADDR     (PORTA_R_ADDR    ),
        .PORTA_R_DATA     (PORTA_R_DATA    ),
        .PORTB_W_ADDR     (PORTB_W_ADDR    ),
        .PORTB_W_DATA     (PORTB_W_DATA    ),
        .PORTB_W_EN       (PORTB_W_EN      ),
        .PORTB_W_CONTENT  (PORTB_W_CONTENT ),
        .PORTB_R_ADDR     (PORTB_R_ADDR    ),
        .PORTB_R_DATA     (PORTB_R_DATA    ));

endmodule


