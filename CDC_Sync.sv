`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 05:16:43 PM
// Design Name: 
// Module Name: CDC_Sync
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


module CDC_Sync #(
    parameter data_width = 32,
    parameter addr_width = 8
    )(
    // Write Domain
    input  logic wclk, wrst, winc,
    input  logic [data_width-1:0] wdata,
    output logic wfull,
    // Read Domain
    input  logic rclk, rrst, rinc,
    output logic [data_width-1:0] rdata,
    output logic rempty
    );
    
    // Gray Code Pointers
    logic [addr_width:0] wptr, rptr;         
    logic [addr_width:0] wq2_rptr, rq2_wptr; 
    
    // Binaray Pointers for Memory Index
    logic [addr_width:0] bptr_w, bptr_r;    
    
    // Write Pointers
    logic [addr_width:0] bptr_w_next, wptr_next;
    
    // Read Pointers
    logic [addr_width:0] bptr_r_next, rptr_next; 
    
    // Memory  
    logic [data_width-1:0] mem [1 << addr_width];
    
    // Memory Write
    always_ff @(posedge wclk) begin
        if (winc && !wfull) 
            mem[bptr_w[addr_width-1:0]] <= wdata;
    end
    
    // Memory Read 
    assign rdata = mem[bptr_r[addr_width-1:0]];

    // Synchronizers
    // Read to Write 
    FF #(.W(addr_width+1)) s_r2w (.clk(wclk), .rst(wrst), .d(rptr), .q(wq2_rptr));
    // Write to Read
    FF #(.W(addr_width+1)) s_w2r (.clk(rclk), .rst(rrst), .d(wptr), .q(rq2_wptr));

    // Write Logic
    // Gray Code Formula: G = B ^ ( B >> 1);
    assign bptr_w_next = bptr_w + (winc && !wfull);
    assign wptr_next   = bptr_w_next ^ (bptr_w_next >> 1); 
    
    // In Gray Code Logic, the write pointer laps the read pointer (goes around the circle) when,
    // the mathematical rule is: the first two MSBs are different while the remaining bits are the same,
    // therefore to check, I inverted the first two bits. The logic is simpler for read to write.
    assign wfull = (wptr == {~wq2_rptr[addr_width:addr_width-1], wq2_rptr[addr_width-2:0]});

    always_ff @(posedge wclk or posedge wrst) begin
        if (wrst) begin
            bptr_w <= '0;
            wptr   <= '0;
        end else begin
            bptr_w <= bptr_w_next;
            wptr   <= wptr_next;
        end
    end
   
    // Read logic
    // Gray Code Formula: G = B ^ ( B >> 1);
    assign bptr_r_next = bptr_r + (rinc && !rempty);
    assign rptr_next   = bptr_r_next ^ (bptr_r_next >> 1);
    
    // The write pointer hasn't moved from the read pointer.
    assign rempty = (rptr == rq2_wptr);

    always_ff @(posedge rclk or posedge rrst) begin
        if (rrst) begin
            bptr_r <= '0;
            rptr   <= '0;
        end else begin
            bptr_r <= bptr_r_next;
            rptr   <= rptr_next;
        end
    end
    
endmodule

//2-stage FF used as synchronizer
// The width(W) must be equal to addr_width + 1
// 8 is only a default value but will be changed in top file during instantiation
module FF #(parameter W = 8) (
    input  logic clk, rst,
    input  logic [W-1:0] d,
    output logic [W-1:0] q
);
    logic [W-1:0] q1;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q1 <= '0;
            q  <= '0;
        end else begin
            q1 <= d;
            q  <= q1;
        end
    end
endmodule
