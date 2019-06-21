`timescale 1ns / 1ps

module BTB(
    input wire clk,
    input wire rst,
    input wire [31:0] PCF,
    input wire [31:0] PCE,
    input wire BranchE,
    input wire [31:0] BranchTarget,
    output reg PredictF,
    output wire [31:0] PredictTarget
    );

    localparam LEN = 4;
    localparam SIZE = 1 << LEN;
    reg [31:0] BranchPC [0:SIZE-1];
    reg [31:0] PredictPC [0:SIZE-1];
    reg Extra [0:SIZE-1];

    wire [LEN-1:0] PCF_Index = PCF[LEN+1:2];
    wire [LEN-1:0] PCE_Index = PCE[LEN+1:2];

    assign PredictTarget = PredictPC[PCF_Index];

    always @ (*) begin
        if (Extra[PCF_Index] && (BranchPC[PCF_Index] == PCF))
            PredictF <= 1;
        else
            PredictF <= 0;
    end

    integer i;
    always @ (negedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < SIZE; i = i + 1) begin
                BranchPC[i] <= 0;
                PredictPC[i] <= 0;
                Extra[i] <= 0;
            end
        end
        else if (BranchE) begin
            BranchPC[PCE_Index] <= PCE;
            PredictPC[PCE_Index] <= BranchTarget;
            Extra[PCE_Index] <= 1;
        end
        else if (!BranchE && (BranchPC[PCE_Index] == PCE)) begin
            Extra[PCE_Index] <= 0;
        end
    end

endmodule