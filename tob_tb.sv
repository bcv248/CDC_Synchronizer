`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2026 07:07:44 PM
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb();
    parameter data_width = 32;
    parameter addr_width = 8;

    // Side A Signals
    logic clk_a = 0, rst_a = 0;
    logic [data_width-1:0] a_to_b_wdata = 0;
    logic a_to_b_winc = 0;
    logic a_to_b_wfull;
    logic [data_width-1:0] b_to_a_rdata;
    logic b_to_a_rinc = 0;
    logic b_to_a_rempty;

    // Side B Signals
    logic clk_b = 0, rst_b = 0;
    logic [data_width-1:0] b_to_a_wdata = 0;
    logic b_to_a_winc = 0;
    logic b_to_a_wfull;
    logic [data_width-1:0] a_to_b_rdata;
    logic a_to_b_rinc = 0;
    logic a_to_b_rempty;

    // Clocks 
    always #5   clk_a = ~clk_a; // 100 MHz
    always #10  clk_b = ~clk_b; // 50 MHz

    // Instantiate the Bidirectional Bridge
    top #(data_width, addr_width) dut (.*);

    // Simulation
    initial begin
        
        rst_a = 1; rst_b = 1;
        #100;
        rst_a = 0; rst_b = 0;
        #100;

        // SIDE A: Write items 
        repeat (5) begin
            @(posedge clk_a);
            if (!a_to_b_wfull) begin
                a_to_b_winc = 1;
                a_to_b_wdata = a_to_b_wdata + 32'hFFFF_0000;
                @(posedge clk_a);
                a_to_b_winc = 0;
            end
        end

        //repeat (10) @(posedge clk_b);

        // SIDE B: Read items
        while (!a_to_b_rempty) begin
            @(posedge clk_b);
            a_to_b_rinc = 1;
            @(posedge clk_b);
            a_to_b_rinc = 0;
            @(posedge clk_b); // Small gap between reads
        end

        #200;

        // SIDE B: Send a response back to Side A
        repeat (5) begin
            @(posedge clk_b);
            if (!b_to_a_wfull) begin
                b_to_a_winc = 1;
                // b_to_a_wdata = b_to_a_wdata + 32'h0000_3232;
                b_to_a_wdata = b_to_a_wdata + 32'h0000_3232;
                @(posedge clk_b);
                b_to_a_winc = 0;
            end
        end

        //repeat (10) @(posedge clk_a);

        // SIDE A: Read the response
        while (!b_to_a_rempty) begin
            @(posedge clk_a);
            b_to_a_rinc = 1;
            @(posedge clk_a);
            b_to_a_rinc = 0;
            @(posedge clk_a);
        end

        #500;
        $finish;
    end

endmodule
