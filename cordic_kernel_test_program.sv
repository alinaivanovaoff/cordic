//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// cordic_kernel_test_program.sv
// Created: 10.26.2016
//
// Program for CORDIC Kernel Testbench.
//
//-----------------------------------------------------------------------------
// Copyright (c) 2016 by Alina Ivanova
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps
//-----------------------------------------------------------------------------
program cordic_kernel_test_program import settings_pkg::*; (
    interface ICKData,
    interface ICKResult);
//-----------------------------------------------------------------------------
    logic [FULL_SIZE-1:0]                              amp_gm_fifo[$] = '{10 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE)};
    logic [FULL_SIZE-1:0]                              amp;
    logic [FULL_SIZE-1:0]                              ph_gm_fifo[$]  = '{23 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE)};
    logic [FULL_SIZE-1:0]                              ph;
    logic [FULL_SIZE-1:0]                              data_i;
    logic [FULL_SIZE-1:0]                              data_q;
    logic [FULL_SIZE-1:0]                              precision;
    logic [2*FULL_SIZE-1:0]                            precision_sq;
    logic                                              enable;
    logic                                              error;
//-----------------------------------------------------------------------------
    logic [FULL_SIZE-1:0]                              rec_amp_int;
    logic [FULL_SIZE-1:0]                              rec_amp_frac;
    logic [FULL_SIZE-1:0]                              rec_ph_int;
    logic [FULL_SIZE-1:0]                              rec_ph_frac;
    logic [FULL_SIZE-1:0]                              exp_amp_int;
    logic [FULL_SIZE-1:0]                              exp_amp_frac;
    logic [FULL_SIZE-1:0]                              exp_ph_int;
    logic [FULL_SIZE-1:0]                              exp_ph_frac;
//-----------------------------------------------------------------------------
    assign ICKData.data_i                              = data_i;
    assign ICKData.data_q                              = data_q;
    assign ICKData.enable                              = enable;
//-----------------------------------------------------------------------------
    initial begin: CORDIC_KERNEL_TEST_PROGRAM_INITIAL
        $display("Running program");
        @(posedge ICKData.reset);
        $display("After reset_n");
        data_i                                         = 9.205049 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);
        data_q                                         = 3.907311 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);
        precision                                      = 0.001    * ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);
        enable                                         = 1;
        error                                          = 0;
        rec_amp_frac                                   = 0;
//-----------------------------------------------------------------------------
        fork
            begin
                while (ph_gm_fifo.size() != 0) begin
//                    $display("Inside cycle");
//                    $stop;
                    @(posedge ICKData.clk);
//                    $display("Inside clk");
//                    $stop;
                    if (ICKResult.output_data_valid) begin
//                        $display("Inside if");
//                        $stop;
                        amp                            = amp_gm_fifo.pop_front();
//                        $display("After amp_gm_fifo");
//                        $stop;
                        if ((amp - ICKResult.output_data_i) * (amp - ICKResult.output_data_i) > precision * precision) begin
                            $display("Error! Expetcted AMP %b != received AMP %b", amp, ICKResult.output_data_i);
                            error                      = 1'b1;
                        end
                        if ((0 - ICKResult.output_data_q) * (0 - ICKResult.output_data_q) > precision * precision) begin
                            $display("Error! Expetcted AMP %b != received AMP %b", amp, ICKResult.output_data_q);
                            error                      = 1'b1;
                        end
                        ph                             = ph_gm_fifo.pop_front();
//                        $display("After ph_gm_fifo");
//                        $stop;
                        if ((ph - ICKResult.output_data_theta) * (ph - ICKResult.output_data_theta) > precision * precision) begin
                            $display("Error! Expetcted PHASE %b != received PHASE %b", ph, ICKResult.output_data_theta);
                            error                      = 1'b1;
                        end
                        if (error == 0) begin
                            exp_amp_int                = amp >>> FRAC_SIZE;
                            exp_amp_frac               = (amp & {FRAC_SIZE{1'b1}}) * 1000000 / ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);
                            rec_amp_int                = ICKResult.output_data_i >>> FRAC_SIZE;
                            rec_amp_frac               = (ICKResult.output_data_i & {FRAC_SIZE{1'b1}}) * 1000000 / ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);

                            exp_ph_int                 = ph >>> FRAC_SIZE;
                            exp_ph_frac                = (ph & {FRAC_SIZE{1'b1}}) * 1000000 / ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);
                            rec_ph_int                 = ICKResult.output_data_theta >>> FRAC_SIZE;
                            rec_ph_frac                = (ICKResult.output_data_theta & {FRAC_SIZE{1'b1}}) * 1000000 / ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);

                            $display("Expetcted AMP = %6d.%06d; received AMP = %6d.%06d",
                                    exp_amp_int, exp_amp_frac, rec_amp_int, rec_amp_frac);
                            $display("Expetcted PHASE = %6d.%06d; received PHASE = %6d.%06d",
                                    exp_ph_int, exp_ph_frac, rec_ph_int, rec_ph_frac);
                        end
                    end
                end
                $display("Test finished.");
                $stop;
            end
            begin
                while ($time < 800) begin
                    @(posedge ICKData.clk);
                end
                $display("Timeout!");
                $stop;
            end
        join_any
    end: CORDIC_KERNEL_TEST_PROGRAM_INITIAL
//-----------------------------------------------------------------------------
endprogram: cordic_kernel_test_program
