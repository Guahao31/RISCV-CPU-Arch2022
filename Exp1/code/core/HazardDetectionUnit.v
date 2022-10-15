`timescale 1ps/1ps

module HazardDetectionUnit(
    input clk,
    input Branch_ID, rs1use_ID, rs2use_ID,
    input[1:0] hazard_optype_ID,
    input[4:0] rd_EXE, rd_MEM, rs1_ID, rs2_ID, rs2_EXE,
    /*############### adding inputs  ##################*/
    input mem_w_EXE, DatatoReg_EXE, RegWrite_EXE,
    input DatatoReg_MEM, RegWrite_MEM,
    /*#################################################*/
    output PC_EN_IF, reg_FD_EN, reg_FD_stall, reg_FD_flush,
        reg_DE_EN, reg_DE_flush, reg_EM_EN, reg_EM_flush, reg_MW_EN,
    output forward_ctrl_ls,
    output[1:0] forward_ctrl_A, forward_ctrl_B
    );
    
    // HDU for Hazard-Detection-Unit
    reg PC_EN_IF_HDU, reg_FD_EN_HDU, reg_FD_stall_HDU, reg_FD_flush_HDU, reg_DE_EN_HDU,
        reg_DE_flush_HDU, reg_EM_EN_HDU, reg_EM_flush_HDU, reg_MW_EN_HDU, forward_ctrl_ls_HDU;
    reg[1:0] forward_ctrl_A_HDU, forward_ctrl_B_HDU;

    /*############### initialization  ##################*/
    initial begin
        PC_EN_IF_HDU <= 1'b1;
        reg_FD_EN_HDU <= 1'b1;
        reg_FD_stall_HDU <= 1'b0;
        reg_FD_flush_HDU <= 1'b0;
        reg_DE_EN_HDU <= 1'b1;
        reg_DE_flush_HDU <= 1'b0;
        reg_EM_EN_HDU <= 1'b1;
        reg_EM_flush_HDU <= 1'b0;
        reg_MW_EN_HDU <= 1'b1;
        forward_ctrl_ls_HDU <= 1'b0;
        forward_ctrl_A_HDU <= 2'b0;
        forward_ctrl_B_HDU <= 2'b0;
    end
    /*##################################################*/

    /*###############   main logic    ##################*/

    /* deal with Rs1 */
    always @(*) begin
        if( (5'b0 != rs1_ID) && (1'b0 != rs1use_ID) ) begin
            /* Using of reg not x0 in ID & out for ID */
            // EXE Hazard
            if( RegWrite_EXE && (rd_EXE == rs1_ID) ) begin
                forward_ctrl_A_HDU = 2'b01;
            end
            // MEM Hazard
            else if( RegWrite_MEM && (rd_MEM == rs1_ID) ) begin
                if( DatatoReg_MEM == 1'b1 ) begin
                    forward_ctrl_A_HDU = 2'b11;
                end else begin
                    forward_ctrl_A_HDU = 2'b10;
                end
            end
            else begin
                forward_ctrl_A_HDU = 2'b00;
            end
        end else begin
            // Using x0, no need to forward
            forward_ctrl_A_HDU = 2'b0;
        end 
    end

    /* deal with Rs2 */
    always @(*) begin
        if( (5'b0 != rs2_ID) && (1'b0 != rs2use_ID) ) begin
            /* Using of reg not x0 in ID & out for ID */
            // EXE Hazard
            if( RegWrite_EXE && (rd_EXE == rs2_ID) ) begin
                forward_ctrl_B_HDU = 2'b01;
            end
            // MEM Hazard
            else if( RegWrite_MEM && (rd_MEM == rs2_ID) ) begin
                if( DatatoReg_MEM == 1'b1 ) begin
                    forward_ctrl_B_HDU = 2'b11;
                end else begin
                    forward_ctrl_B_HDU = 2'b10;
                end
            end
            else begin
                forward_ctrl_B_HDU = 2'b00;
            end
        end else begin
            // Using x0, no need to forward
            forward_ctrl_B_HDU = 2'b0;
        end 
    end

    /* deal with load-store hazard */
    always @(*) begin
        if( mem_w_EXE && RegWrite_MEM && DatatoReg_MEM && (rd_MEM == rs2_EXE) ) begin
            forward_ctrl_ls_HDU = 1'b1;
        end else begin
            forward_ctrl_ls_HDU = 1'b0;
        end
    end

    /* deal with enable ang flush signals which will not change by this unit */
    /*
    always reg_FD_EN_HDU = 1'b1;
    always reg_DE_EN_HDU = 1'b1;
    always reg_EM_EN_HDU = 1'b1;
    always reg_MW_EN_HDU = 1'b1;
    always reg_EM_flush_HDU = 1'b0; // never flush
    */

    /* deal with signals to judge stall */
    always @(*) begin
        if( (5'b0 != rs1use_ID) && (5'b0 != rs1_ID) && RegWrite_EXE && DatatoReg_EXE &&
            (rs1_ID == rd_EXE) ) begin
            // enable signals
            PC_EN_IF_HDU = 1'b0;
            // stall signals
            reg_FD_stall_HDU = 1'b1;
            // flush signals
            reg_DE_flush_HDU = 1'b1;
            reg_FD_flush_HDU = 1'b0;
        end
        else if( (5'b0 != rs2use_ID) && (5'b0 != rs2_ID) && RegWrite_EXE && DatatoReg_EXE &&
                (rs2_ID == rd_EXE) ) begin
            // enable signals
            PC_EN_IF_HDU = 1'b0;
            // stall signals
            reg_FD_stall_HDU = 1'b1;
            // flush signals
            reg_DE_flush_HDU = 1'b1;
            reg_FD_flush_HDU = 1'b0;
        end
        else if( Branch_ID ) begin
            // enable signals
            PC_EN_IF_HDU = 1'b1;
            // stall signals
            reg_FD_stall_HDU = 1'b0;
            // flush signals
            reg_DE_flush_HDU = 1'b0;
            reg_FD_flush_HDU = 1'b1;
        end
        else begin
            // Normal, no flush or stalls
            // enable signals
            PC_EN_IF_HDU = 1'b1;
            // stall signals
            reg_FD_stall_HDU = 1'b0;
            // flush signals
            reg_DE_flush_HDU = 1'b0;
            reg_FD_flush_HDU = 1'b0;
        end
    end
    /*##################################################*/

    /*###############  assign output  ##################*/
    assign PC_EN_IF =       PC_EN_IF_HDU;
    assign reg_FD_EN =      reg_FD_EN_HDU;
    assign reg_FD_stall =   reg_FD_stall_HDU;
    assign reg_FD_flush =   reg_FD_flush_HDU;
    assign reg_DE_EN =      reg_DE_EN_HDU;
    assign reg_DE_flush =   reg_DE_flush_HDU;
    assign reg_EM_EN =      reg_EM_EN_HDU;
    assign reg_EM_flush =   reg_EM_flush_HDU;
    assign reg_MW_EN =      reg_MW_EN_HDU;
    assign forward_ctrl_A = forward_ctrl_A_HDU;
    assign forward_ctrl_B = forward_ctrl_B_HDU;
    assign forward_ctrl_ls= forward_ctrl_ls_HDU;
    /*##################################################*/
endmodule