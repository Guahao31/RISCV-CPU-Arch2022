`timescale 1ns / 1ps

module core_sim;
    reg clk, rst;

    RV32core core(
        .debug_en(1'b0),
        .debug_step(1'b0),
        .debug_addr(7'b0),
        .debug_data(),
        .clk(clk),
        .rst(rst),
        .interrupter(1'b0)
    );

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(1, core_sim);
        $dumpvars(1, core);
        clk = 0;
        rst = 1;
        #2 rst = 0;
        #5000;
        $finish();
    end
    always begin
        #1 clk = ~clk;
    end

endmodule