`timescale 1ns / 1ps
/****************************************************************************
 * event_counter_tb.v
 * Author: Lucas Brasilino <lucas.brasilino@gmail.com>
 ****************************************************************************/

/**
 * Module: testbench for event counter
 *
 */

module event_counter_tb;
    reg                  ACLK;
    reg                  ARESETN;
    wire                 REACHED;
    wire [3:0]           COUNTER;
    reg                  TICK;
    reg                  ENABLE;

    localparam HALF_CORE_PERIOD = 5; // 100Mhz
    localparam PERIOD = HALF_CORE_PERIOD*2;
    localparam TARGET_WIDTH      = 4;

    wire [TARGET_WIDTH-1 : 0] INIT;
    wire [TARGET_WIDTH-1 : 0] TARGET;

    assign INIT = 4'h0;
    assign TARGET  = 4'h6;

    initial begin
        ACLK = 1'b0;
        #(HALF_CORE_PERIOD);
        forever
            #(HALF_CORE_PERIOD) ACLK = ~ACLK;
    end

    initial begin
        ARESETN = 1'b0;
        #(PERIOD * 8);
        ARESETN = 1'b1;
        $display("Reset Deasserted");
    end

    initial begin
        TICK = 1'b0;
        wait (ARESETN == 1'b1);
       // #(PERIOD);
        forever
            #(HALF_CORE_PERIOD*2) TICK = ~TICK;
        #(PERIOD * 32);
        $display ("End simulation");
    end

    initial begin
        ENABLE = 1'b0;
        wait (ARESETN == 1'b1);
        #(PERIOD * 4);
        ENABLE = 1'b1;
    end

    initial begin
        wait (REACHED == 1'b1);
        #(PERIOD * 2);
        $display ("End simulation");
        $finish;
    end

    always @(posedge ACLK) begin
        $display("Tick = %d | Enable = %d | Counter = %d | Reached = %d", TICK, ENABLE, COUNTER, REACHED);
    end

    event_counter #(
        .TARGET_WIDTH    (4),
        .EVENT_IS_CLOCK  (0),
        .HAS_ENABLE      (1),
        .RESET_IF_REACHED(1)
        ) ec_0 (
        .ACLK            (ACLK           ),
        .ARESETN         (ARESETN        ),
        .ENABLE          (ENABLE         ),
        .INIT_VAL        (INIT           ),
        .TARGET          (TARGET         ),
        .TICK            (TICK           ),
        .REACHED         (REACHED        ),
        .COUNTER         (COUNTER        ));
endmodule
