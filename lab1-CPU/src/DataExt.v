`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: qihao
// Create Date: 03/09/2019 09:03:05 PM
// Design Name: 
// Module Name: DataExt 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

`include "Parameters.v"   
module DataExt(
    input wire [31:0] IN,
    input wire [1:0] LoadedBytesSelect,
    input wire [2:0] RegWriteW,
    output reg [31:0] OUT
    );    

//功能说明
    //DataExt是用来处理非字对齐load的情形，同时根据load的不同模式对Data Mem中load的数进行符号或者无符号拓展，组合逻辑电路
//输入
    //IN                    是从Data Memory中load的32bit字
    //LoadedBytesSelect     等价于AluOutM[1:0]，是读Data Memory地址的低两位，
                            //因为DataMemory是按字（32bit）进行访问的，所以需要把字节地址转化为字地址传给DataMem
                            //DataMem一次返回一个字，低两位地址用来从32bit字中挑选出我们需要的字节
    //RegWriteW             表示不同的 寄存器写入模式 ，所有模式定义在Parameters.v中
//输出
    //OUT表示要写入寄存器的最终值
//实验要求  
    //实现DataExt模块  

    always@(*) begin
        case(RegWriteW)
            `NOREGWRITE: OUT = 0;
            `LB: begin
                case(LoadedBytesSelect)
                    2'b00: OUT = { {25{IN[7]}}, IN[6:0] };
                    2'b01: OUT = { {25{IN[15]}}, IN[14:8] };
                    2'b10: OUT = { {25{IN[23]}}, IN[22:16] };
                    2'b11: OUT = { {25{IN[31]}}, IN[30:24] };
                endcase
            end
            `LH: begin
                casex (LoadedBytesSelect[1])
                    1'b0: OUT = { {17{IN[15]}}, IN[14:0] };
                    1'b1: OUT = { {17{IN[31]}}, IN[30:16] }; 
                endcase
            end
            `LW: begin
                OUT = IN;
            end
            `LBU: begin
                case (LoadedBytesSelect)
                    2'b00: OUT = { 24'b0, IN[7:0] };
                    2'b01: OUT = { 24'b0, IN[15:8] };
                    2'b10: OUT = { 24'b0, IN[23:16] };
                    2'b11: OUT = { 24'b0, IN[31:24] };
                endcase
            end
            `LHU: begin
                case (LoadedBytesSelect[1])
                    1'b0: OUT = { 16'b0, IN[15:0] };
                    1'b1: OUT = { 16'b0, IN[31:16] };
                endcase
            end
        endcase
    end

endmodule