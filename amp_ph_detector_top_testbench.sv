//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// email: alina.al.ivanova@gmail.com
// web: www.alinaivanovaoff.com
// amp_ph_detector_top_testbench.sv
// Created: 11.01.2016
//
// Testbench for amp_ph_detector_top.sv.
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
`include "interfaces_pkg.sv";
`include "amp_ph_test_program.sv"
//-----------------------------------------------------------------------------
module amp_ph_detector_top_testbench ();
//-----------------------------------------------------------------------------
// Variable declarations
//-----------------------------------------------------------------------------
    logic                                                 clk;
    logic                                                 reset;
//-----------------------------------------------------------------------------
    amp_ph_detector_data_intf ICKData (
        .clk                                              (clk),
        .reset                                            (reset));
//-----------------------------------------------------------------------------
    amp_ph_detector_result_intf ICKResult ();
//-----------------------------------------------------------------------------
// Function Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Process Section
//-----------------------------------------------------------------------------
    initial begin: AMP_PH_DETECTOR_TOP_TESTBENCH_INITIAL
        $display("Running testbench");
        reset                                             = 0;
        clk                                               = 0;
        #4  reset                                         = 1;
    end: AMP_PH_DETECTOR_TOP_TESTBENCH_INITIAL
//-----------------------------------------------------------------------------
    always begin: AMP_PH_DETECTOR_TOP_TESTBENCH_CLK
        #2 clk                                            = ~clk;
    end: AMP_PH_DETECTOR_TOP_TESTBENCH_CLK
//-----------------------------------------------------------------------------
// Sub Module Section
//-----------------------------------------------------------------------------
    amp_ph_detector_top AmpPhDetectorTop (
        .clk                                              (clk),
        .reset                                            (reset),
//-----------------------------------------------------------------------------
        .data_i                                           (ICKData.data_i),
        .data_q                                           (ICKData.data_q),
        .enable                                           (ICKData.enable),
//-----------------------------------------------------------------------------
        .output_amp                                       (ICKResult.output_amp),
        .output_ph                                        (ICKResult.output_ph),
        .output_data_valid                                (ICKResult.output_data_valid));
//-----------------------------------------------------------------------------
// Program Section
//-----------------------------------------------------------------------------
    amp_ph_test_program AmpPhTestProgram (
        .ICKData   (ICKData.master),
        .ICKResult (ICKResult.slave));
//-----------------------------------------------------------------------------
endmodule: amp_ph_detector_top_testbench