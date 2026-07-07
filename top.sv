`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2025 06:58:12 PM
// Design Name: 
// Module Name: top
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

// Synthesized on a Zynq-7020, part: xc7z020clg400-1
// Wrapper to make the CDC Synchronizer bidirectional
module top #(
    parameter data_width = 32,
    parameter addr_width = 8
)(
    // Domain A Interface
    input  logic clk_a, rst_a,
    input  logic [data_width-1:0] a_to_b_wdata,
    input  logic a_to_b_winc,
    output logic a_to_b_wfull,
    output logic [data_width-1:0] b_to_a_rdata,
    input  logic b_to_a_rinc,
    output logic b_to_a_rempty,

    // Domain B Interface
    input  logic clk_b, rst_b,
    input  logic [data_width-1:0] b_to_a_wdata,
    input  logic b_to_a_winc,
    output logic b_to_a_wfull,
    output logic [data_width-1:0] a_to_b_rdata,
    input  logic a_to_b_rinc,
    output logic a_to_b_rempty
);

    // Forward (A to B)
    CDC_Sync #(.data_width(data_width), .addr_width(addr_width)) fifo_fwd (
        .wclk(clk_a), .wrst(rst_a), .winc(a_to_b_winc), .wdata(a_to_b_wdata), .wfull(a_to_b_wfull),
        .rclk(clk_b), .rrst(rst_b), .rinc(a_to_b_rinc), .rdata(a_to_b_rdata), .rempty(a_to_b_rempty)
    );

    // Backwards (B to A)
    CDC_Sync #(.data_width(data_width), .addr_width(addr_width)) fifo_bac (
        .wclk(clk_b), .wrst(rst_b), .winc(b_to_a_winc), .wdata(b_to_a_wdata), .wfull(b_to_a_wfull),
        .rclk(clk_a), .rrst(rst_a), .rinc(b_to_a_rinc), .rdata(b_to_a_rdata), .rempty(b_to_a_rempty)
    );

endmodule
