`include "VX_define.vh"

`ifndef SYNTHESIS
`include "float_dpi.vh"
`endif

module VX_fp_sqrt #( 
    parameter TAGW = 1,
    parameter LANES = 1
) (
    input wire clk,
    input wire reset,   

    output wire ready_in,
    input wire  valid_in,

    input wire [TAGW-1:0] tag_in,

    input wire [LANES-1:0][31:0]  dataa,
    output wire [LANES-1:0][31:0] result, 

    output wire [TAGW-1:0] tag_out,

    input wire  ready_out,
    output wire valid_out
);    
    wire stall = ~ready_out && valid_out;
    wire enable = ~stall;
    
    for (genvar i = 0; i < LANES; i++) begin
    `ifdef QUARTUS
        acl_fsqrt fsqrt (
            .clk    (clk),
            .areset (1'b0),
            .en     (enable),
            .a      (dataa[i]),
            .q      (result[i])
        );
    `else
        always @(posedge clk) begin
           dpi_fsqrt(9*LANES+i, enable, dataa[i], result[i]);
        end
    `endif
    end

    VX_shift_register #(
        .DATAW(TAGW + 1),
        .DEPTH(`LATENCY_FSQRT)
    ) shift_reg (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .in ({tag_in,  valid_in}),
        .out({tag_out, valid_out})
    );

    assign ready_in = enable;

endmodule
