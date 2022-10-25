`timescale 1ns / 1ps
`include "my_macros.vh"
module CSRRegs(
    input clk, rst,
    input[11:0] raddr, waddr,
    input[31:0] wdata,
    input csr_w,
    input[1:0] csr_wsc_mode,
    output[31:0] rdata,
    output[31:0] mstatus,
    /* ports added */
    input[31:0] mepc_in,
    input[31:0] mcause_in,
    input[31:0] mtval_in,
    input trap,
    input mret,

    output[31:0] mtvec_out,
    output[31:0] mepc_out
    /***************/
);
    // You may need to modify this module for better efficiency
    // Define the CSR set
    reg[31:0] CSR [0:15];

    // Address mapping. The address is 12 bits, but only 4 bits are used in this module.
    wire raddr_valid = raddr[11:7] == 5'h6 && raddr[5:3] == 3'h0;
    wire[3:0] raddr_map = (raddr[6] << 3) + raddr[2:0];
    wire waddr_valid = waddr[11:7] == 5'h6 && waddr[5:3] == 3'h0;
    wire[3:0] waddr_map = (waddr[6] << 3) + waddr[2:0];

    assign mstatus = CSR[`MSTATUS];

    assign rdata = CSR[raddr_map];

    always@(posedge clk or posedge rst) begin
        if(rst) begin
			CSR[`MSTATUS] <= 32'h88;
			CSR[1] <= 0;
			CSR[2] <= 0;
			CSR[3] <= 0;
			CSR[`MIE] <= 32'hfff;
			CSR[`MTVEC] <= 0;
			CSR[6] <= 0;
			CSR[7] <= 0;
			CSR[`MSCRATCH] <= 0;
			CSR[`MEPC] <= 0;
			CSR[`MCAUSE] <= 0;
			CSR[`MTVAL] <= 0;
			CSR[12] <= 0;
			CSR[13] <= 0;
			CSR[14] <= 0;
			CSR[15] <= 0;
		end
        else if(csr_w) begin
            case(csr_wsc_mode)
                2'b01: CSR[waddr_map] = wdata;
                2'b10: CSR[waddr_map] = CSR[waddr_map] | wdata;
                2'b11: CSR[waddr_map] = CSR[waddr_map] & ~wdata;
                default: CSR[waddr_map] = wdata;
            endcase          
        end
        else if(mret) begin
            CSR[`MEPC]      <= mepc_in;
            CSR[`MCAUSE]    <= mcause_in;
            CSR[`MTVAL]     <= mtval_in;
            CSR[`MSTATUS][3]<= CSR[`MSTATUS][7]; // MPIE -> MIE
        end
        else if(trap) begin
            CSR[`MEPC]      <= mepc_in;
            CSR[`MCAUSE]    <= mcause_in;
            CSR[`MTVAL]     <= mtval_in;
            CSR[`MSTATUS][7]<= CSR[`MSTATUS][3];
            CSR[`MSTATUS][3]<= 1'b0; // Disable interupt
            CSR[`MSTATUS][12:11]<=2'b11;
        end
    end
    assign mtvec_out    = CSR[`MTVEC];
    assign mepc_out     = CSR[`MEPC];

endmodule