//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// amp_ph_detector_top_testbench_program.sv
// Created: 10.26.2016
//
// Program for Amplitude and Phase Detector Top Module Testbench.
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
program amp_ph_detector_top_testbench_program import settings_pkg::*;  (
    interface ICKData,
    interface ICKResult);
//-----------------------------------------------------------------------------
    logic [FULL_SIZE-1:0]                              amp_gm_fifo[$] = '{10 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE)};
    logic [FULL_SIZE-1:0]                              amp;
    logic [FULL_SIZE-1:0]                              ph_gm_fifo[$]  = '{23 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE)};
    logic [FULL_SIZE-1:0]                              ph;
    logic [DATA_SIZE-1:0]                              data_i;
    logic [DATA_SIZE-1:0]                              data_q;
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
    initial begin: AMP_PH_DETECTOR_TOP_TESTBENCH_PROGRAM_INITIAL
        $display("Running program");
        @(posedge ICKData.reset);
        $display("After reset");
        data_i                                         = 9.205049 * ({{DATA_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);
        data_q                                         = 3.907311 * ({{DATA_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);
        precision                                      = 0.001    * ({{DATA_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);
        enable                                         = 1;
//-----------------------------------------------------------------------------
        fork
            begin
                while (ph_gm_fifo.size() != 0) begin
//                    $display("Inside cycle");
//                    $stop;
//                    $display("Clk %z != received AMP %z", ICKData.clk);
                    @(posedge ICKData.clk);
//                    $display("Inside clk");
//                    $stop;
                    if (ICKResult.output_data_valid) begin
//                        $display("Inside if");
//                        $stop;
                        amp                            = amp_gm_fifo.pop_front();
//                        $display("After amp_gm_fifo");
//                        $stop;
                        if ((amp - ICKResult.output_amp) * (amp - ICKResult.output_amp) > precision * precision) begin
                            $display("Error! Expetcted AMP %b != received AMP %b", amp, ICKResult.output_amp);
                            error                      = 1'b1;
                        end
                        ph                             = ph_gm_fifo.pop_front();
//                        $display("After ph_gm_fifo");
//                        $stop;
                        if ((ph - ICKResult.output_ph) * (ph - ICKResult.output_ph) > precision * precision) begin
                            $display("Error! Expetcted PHASE %b != received PHASE %b", ph, ICKResult.output_ph);
                            error                      = 1'b1;
                        end
                        if (error == 0) begin
                            exp_amp_int                = amp >>> FRAC_SIZE;
                            exp_amp_frac               = (amp & {FRAC_SIZE{1'b1}}) * 1000000 / ({{DATA_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);
                            rec_amp_int                = ICKResult.output_amp >>> FRAC_SIZE;
                            rec_amp_frac               = (ICKResult.output_amp & {FRAC_SIZE{1'b1}}) * 1000000 / ({{DATA_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);

                            exp_ph_int                 = ph >>> FRAC_SIZE;
                            exp_ph_frac                = (ph & {FRAC_SIZE{1'b1}}) * 1000000 / ({{DATA_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);
                            rec_ph_int                 = ICKResult.output_ph >>> FRAC_SIZE;
                            rec_ph_frac                = (ICKResult.output_ph & {FRAC_SIZE{1'b1}}) * 1000000 / ({{DATA_SIZE-2{1'b0}}, 1'b1} << FRAC_SIZE);

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
    end: AMP_PH_DETECTOR_TOP_TESTBENCH_PROGRAM_INITIAL
//-----------------------------------------------------------------------------
endprogram: amp_ph_detector_top_testbench_program
