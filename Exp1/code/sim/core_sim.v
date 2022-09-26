`timescale 1ns / 1ps

module core_sim;
    reg clk, rst;
    reg [7:0] counter;

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
        counter = 8'b0;
        #2 rst = 0;
    end
    always begin
        counter = counter + 8'b1;
        #1 clk = ~clk;
        if(!counter) begin
            $finish;
        end
    end

endmodule