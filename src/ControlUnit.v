`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB (Embeded System Lab)
// Engineer: Haojun Xia
// Create Date: 2019/02/08
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
`include "Parameters.v"   
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,
    output wire JalD,
    output wire JalrD,
    output reg [2:0] RegWriteD,
    output wire MemToRegD,
    output reg [3:0] MemWriteD,
    output wire LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    output wire [1:0] AluSrc2D,
    output wire AluSrc1D,
    output reg [2:0] ImmType 
    );

//功能说明
    //ControlUnit       是本CPU的指令译码器，组合逻辑电路
//输入
    // Op               是指令的操作码部分
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的 寄存器写入模式 ，所有模式定义在Parameters.v中
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的值写入寄存器,
    // MemWriteD        共4bit，采用独热码格式，对于data memory的32bit字按byte进行写入,MemWriteD=0001表示只写入最低1个byte，和xilinx bram的接口类似
    // LoadNpcD==1      表示将NextPC输出到ResultM
    // RegReadD[1]==1   表示A1对应的寄存器值被使用到了，RegReadD[0]==1表示A2对应的寄存器值被使用到了，用于forward的处理
    // BranchTypeD      表示不同的分支类型，所有类型定义在Parameters.v中
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v中
    // AluSrc2D         表示Alu输入源2的选择
    // AluSrc1D         表示Alu输入源1的选择
    // ImmType          表示指令的立即数格式，所有类型定义在Parameters.v中   
//实验要求  
    //实现ControlUnit模块   

    assign JalD = (Op == 7'b1101111);
    assign JalrD = (Op == 7'b1100111);
    assign MemToRegD = (Op == 7'b0000011);
    assign LoadNpcD = (Op == 7'b1101111 || Op == 7'b1100111);

    assign AluSrc1D = (Op == 7'b0010111);
    assign AluSrc2D = (Op == 7'b0010011) && ((Fn3 == 3'b001) || (Fn3 == 3'b101)) ? 2'b01 : ((Op == 7'b0110011 || Op == 7'b1100011) ? 2'b00 : 2'b10);
    
    always@(Op or Fn3 or Fn7) begin
        BranchTypeD = `NOBRANCH;
        RegWriteD = `NOREGWRITE;
        MemWriteD = 0;

        case(Op)
            7'b0110011: begin       // add sub sll slt sltu xor srl sra or and
                RegWriteD = `LW;
                RegReadD = 2'b11;
                ImmType = `RTYPE;

                case(Fn3)
                    3'b000: begin   // add sub
                        if (Fn7 == 7'b0000000) begin        // add
                            AluContrlD = `ADD;
                        end
                        else if (Fn7 == 7'b0100000) begin   // sub
                            AluContrlD = `SUB;
                        end
                    end
                    3'b001: begin   // sll
                        AluContrlD = `SLL;
                    end
                    3'b010: begin   // slt
                        AluContrlD = `SLT;
                    end
                    3'b011: begin   // sltu
                        AluContrlD = `SLTU;
                    end
                    3'b100: begin   // xor
                        AluContrlD = `XOR;
                    end
                    3'b101: begin   // srl sra
                        if (Fn7 == 7'b0000000) begin    // srl
                            AluContrlD = `SRL;
                        end
                        else if (Fn7 == 7'b0100000) begin   // sra
                            AluContrlD = `SRA;
                        end
                    end
                    3'b110: begin   // or
                        AluContrlD = `OR;
                    end
                    3'b111: begin   // and
                        AluContrlD = `AND;
                    end
                endcase
            end
            7'b0010011: begin       // addi slti sltiu xori ori andi slli srli srai
                RegReadD = 2'b01;
                ImmType = `ITYPE;
                RegWriteD = `LW;

                case(Fn3)
                    3'b000: begin   // addi
                        AluContrlD = `ADD;
                    end
                    3'b001: begin   // slli
                        AluContrlD = `SLL;
                    end
                    3'b010: begin   // slti
                        AluContrlD = `SLT;
                    end
                    3'b011: begin   // sltiu
                        AluContrlD = `SLTU;
                    end
                    3'b100: begin   // xori
                        AluContrlD = `XOR;
                    end
                    3'b101: begin   // srli srai
                        if (Fn7 == 7'b0000000) begin    // srli
                            AluContrlD = `SRL;
                        end
                        else if (Fn7 == 7'b0100000) begin   // srai
                            AluContrlD = `SRA;
                        end
                    end
                    3'b110: begin   // ori
                        AluContrlD = `OR;
                    end
                    3'b111: begin   // andi
                        AluContrlD = `AND;
                    end
                endcase
            end
            7'b0110111: begin       // lui
                ImmType = `UTYPE;
                RegWriteD = `LW;
                RegReadD = 0;
                AluContrlD = `LUI;
            end
            7'b0010111: begin       // auipc
                ImmType = `UTYPE;
                RegWriteD = `LW;
                RegReadD = 0;
                AluContrlD = `ADD;
            end
        endcase
    end

endmodule