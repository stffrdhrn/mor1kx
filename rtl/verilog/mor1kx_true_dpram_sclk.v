/******************************************************************************
 This Source Code Form is subject to the terms of the
 Open Hardware Description License, v. 1.0. If a copy
 of the OHDL was not distributed with this file, You
 can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt

 Description: True dual port ram with dual clock's

 Copyright (C) 2013 Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>

 ******************************************************************************/

module mor1kx_true_dpram_sclk
  #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
    )
   (
    /* Port A */
    input                   clk_a,
    input [ADDR_WIDTH-1:0]  addr_a,
    input                   we_a,
    input [DATA_WIDTH-1:0]  din_a,
    output [DATA_WIDTH-1:0] dout_a,

    /* Port B */
    input                   clk_b,
    input [ADDR_WIDTH-1:0]  addr_b,
    input                   we_b,
    input [DATA_WIDTH-1:0]  din_b,
    output [DATA_WIDTH-1:0] dout_b
    );

   reg [DATA_WIDTH-1:0]     mem[(1<<ADDR_WIDTH)-1:0];

   reg [DATA_WIDTH-1:0]     rdata_a;
   reg [DATA_WIDTH-1:0]     rdata_b;

   assign dout_a = rdata_a;
   assign dout_b = rdata_b;

   always @(posedge clk_a) begin
      if (we_a) begin
         mem[addr_a] <= din_a;
         rdata_a <= din_a;
      end else begin
         rdata_a <= mem[addr_a];
      end
   end

   always @(posedge clk_b) begin
      if (we_b) begin
         mem[addr_b] <= din_b;
         rdata_b <= din_b;
      end else begin
         rdata_b <= mem[addr_b];
      end
   end

/*------Formal Checking-------*/

`ifdef FORMAL

   reg t_past_ctrl;
   initial t_past_ctrl = 1'b0;
   (* gclk *) reg global_clock;

   always @(posedge global_clock) begin
      t_past_ctrl = 1'b1;
      assume (addr_a != addr_b);
   end

   always @(posedge global_clock) begin

      if ($rose(clk_a)) begin
         if ($past(we_a) & t_past_ctrl)
            assert (dout_a == $past(din_a));
         if ($past(!we_a) & t_past_ctrl)
            assert ($past(mem[addr_a]) == dout_a);
      end

      if ($rose(clk_b)) begin
         if ($past(we_b) & t_past_ctrl)
            assert (dout_b == $past(din_b));
         if ($past(!we_b) & t_past_ctrl)
            assert ($past(mem[addr_b]) == dout_b);
      end
   end

`endif

endmodule
