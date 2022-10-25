`ifndef MY_MACROS_VH
`define MY_MACROS_VH

  `define MSTATUS     0
  `define MISA        1
  `define MEDELEG     2
  `define MIDELEG     3
  `define MIE         4
  `define MTVEC       5
  `define MSCRATCH    8
  `define MEPC        9
  `define MCAUSE      10
  `define MTVAL       11

  `define M_SOFT_INT            (32'h80000003)
  `define M_TIME_INT            (32'h80000007)
  `define M_EXT_INT             (32'h8000000B)
  `define INST_ADDR_MISALIGNED  (32'h00000000)
  `define INST_ACCESS_FAULT     (32'h00000001)
  `define INST_ILLEGAL          (32'h00000002)
  `define LOAD_ADDR_FAULT       (32'h00000005)
  `define STORE_ADDR_FAULT      (32'h00000007)
  `define ECALL_M               (32'h0000000B)


`endif