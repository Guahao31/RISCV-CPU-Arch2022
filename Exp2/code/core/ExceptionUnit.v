`timescale 1ns / 1ps
`include "my_macros.vh"

module ExceptionUnit(
    input clk, rst,
    input csr_rw_in,
    // write/set/clear (funct bits from instruction)
    input[1:0] csr_wsc_mode_in,
    input csr_w_imm_mux,
    input[11:0] csr_rw_addr_in,
    input[31:0] csr_w_data_reg,
    input[4:0] csr_w_data_imm,
    output[31:0] csr_r_data_out,

    input interrupt,
    input illegal_inst,
    input l_access_fault,
    input s_access_fault,
    input ecall_m,

    input mret,

    input[31:0] epc_cur,
    input[31:0] epc_next,
    output[31:0] PC_redirect,
    output redirect_mux,

    output reg_FD_flush, reg_DE_flush, reg_EM_flush, reg_MW_flush, 
    output RegWrite_cancel
);
    // According to the diagram, design the Exception Unit
    // You can modify any code in this file if needed!
    reg[11:0] csr_waddr;
    reg[31:0] csr_wdata;
    reg csr_w;
    reg[1:0] csr_wsc;
    reg[11:0] csr_raddr;

    wire[31:0] mstatus;
    wire[31:0] csr_rdata;

    reg[31:0] mepc;
    reg[31:0] mcause;
    reg[31:0] mtval;

    wire[31:0] mtvec_out;
    wire[31:0] mepc_out;
    
    wire trap_maybe;
    assign trap_maybe = interrupt | (illegal_inst | l_access_fault | s_access_fault) | ecall_m;

    CSRRegs csr(.clk(clk),.rst(rst),.csr_w(csr_w),.raddr(csr_raddr),.waddr(csr_waddr),
        .wdata(csr_wdata),.rdata(csr_rdata),.mstatus(mstatus),.csr_wsc_mode(csr_wsc),
        .mepc_in(mepc), .mcause_in(mcause), .mtval_in(mtval), 
        .trap(mstatus[3] & trap_maybe), .mret(mret));

    /* deal with csr r/w */
    always @(*) begin
        if(csr_rw_in) begin
            csr_waddr   <= csr_rw_addr_in;
            csr_wdata   <= csr_w_imm_mux ? csr_w_data_imm : csr_w_data_reg;
            csr_w       <= 1'b1;
            csr_wsc     <= csr_wsc_mode_in;
            csr_raddr   <= csr_rw_addr_in; 
        end else begin
            csr_waddr   <= 0;
            csr_wdata   <= 0;
            csr_w       <= 0;
            csr_wsc     <= 0;
            csr_raddr   <= 0;
        end
    end

    /* deal with interrupt/trap */
    always @(*) begin
        if(mstatus[3]) begin
            if(interrupt) begin
                mepc    <= epc_next;
                mcause  <= `M_EXT_INT;
                mtval   <= 0;
            end else if(illegal_inst) begin
                mepc    <= eppc_cur;
                mcause  <= `INST_ILLEGAL;
                mtval   <= 0;
            end else if(l_access_fault) begin
                mepc    <= epc_cur;
                mcause  <= `LOAD_ADDR_FAULT;
                mtval   <= 0;
            end else if(s_access_fault) begin
                mepc    <= ecp_cur;
                mcause  <= `STORE_ADDR_FAULT;
                mtval   <= 0;
            end else if(ecall_m) begin
                mepc    <= epc_cur;
                mcause  <= `ECALL_M;
                mtval   <= 0;
            end else begin
                mepc    <= 0;
                mcause  <= 0;
                mtval   <= 0;
            end
        end else begin
            mepc    <= 0;
            mcause  <= 0;
            mtval   <= 0;
        end
    end

    /* EU for ExceptionUnit */
    reg reg_FD_flush_EU, reg_DE_flush_EU, reg_EM_flush_EU, reg_MW_flush_EU;
    reg RegWrite_cancel_EU;
    /* deal with control signals when trap */
    alway @(*) begin
        if(mstatus[3] & trap_maybe) begin
            reg_FD_flush_EU     <= 1'b1;
            reg_DE_flush_EU     <= 1'b1;
            reg_EM_flush_EU     <= 1'b1;
            reg_MW_flush_EU     <= 1'b1;
            RegWrite_cancel_EU  <= 1'b1;
        end else begin
            reg_FD_flush_EU     <= 0;
            reg_DE_flush_EU     <= 0;
            reg_EM_flush_EU     <= 0;
            reg_MW_flush_EU     <= 0;
            RegWrite_cancel_EU  <= 0;
        end
    end

    assign csr_r_data_out   = csr_rdata;
    assign PC_redirect      = mret ? mepc_o : mtvec;
    assign redirect_mux     = mret | (mstatus[3] & trap_maybe);
    assign reg_FD_flush     = reg_FD_flush_EU;
    assign reg_DE_flush     = reg_DE_flush_EU;
    assign reg_EM_flush     = reg_EM_flush_EU;
    assign reg_MW_flush     = reg_MW_flush_EU;
    assign RegWrite_cancel  = RegWrite_cancel_EU;
endmodule