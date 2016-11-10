//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// email: alina.al.ivanova@gmail.com
// web: www.alinaivanovaoff.com
// cordic_kernel_testbench.sv
// Created: 11.01.2016
//
// Testbench for cordic_kernel.sv.
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
//`include "settings_pkg.sv"
`include "interfaces_pkg.sv";
`include "cordic_kernel_test_program.sv"
//-----------------------------------------------------------------------------
module cordic_kernel_testbench ();
//-----------------------------------------------------------------------------
// Variable declarations
//-----------------------------------------------------------------------------
    logic                                                 clk;
    logic                                                 reset;
//-----------------------------------------------------------------------------
    cordic_kernel_data_intf ICKData (
        .clk                                              (clk),
        .reset                                            (reset));
//-----------------------------------------------------------------------------
    cordic_kernel_result_intf ICKResult ();
//-----------------------------------------------------------------------------
// Function Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Process Section
//-----------------------------------------------------------------------------
    initial begin: CORDIC_KERNEL_TESTBENCH_INITIAL
        $display("Running testbench");
        reset                                             = 0;
        clk                                               = 0;
        #4  reset                                         = 1;
        #4  reset                                         = 0;
    end: CORDIC_KERNEL_TESTBENCH_INITIAL
//-----------------------------------------------------------------------------
    always begin: CORDIC_KERNEL_TESTBENCH_CLK
        #2 clk                                            = ~clk;
    end: CORDIC_KERNEL_TESTBENCH_CLK
//-----------------------------------------------------------------------------
// Sub Module Section
//-----------------------------------------------------------------------------
    cordic_kernel CordicKernel (
        .clk                                              (clk),
        .reset                                            (reset),
//-----------------------------------------------------------------------------
        .data_i                                           (ICKData.data_i),
        .data_q                                           (ICKData.data_q),
        .enable                                           (ICKData.enable),
//-----------------------------------------------------------------------------
        .output_data_i                                    (ICKResult.output_data_i),
        .output_data_q                                    (ICKResult.output_data_q),
        .output_data_theta                                (ICKResult.output_data_theta),
        .output_data_valid                                (ICKResult.output_data_valid));
//-----------------------------------------------------------------------------
// Program Section
//-----------------------------------------------------------------------------
    cordic_kernel_test_program CordicKernelTestProgram (
        .ICKData   (ICKData.master),
        .ICKResult (ICKResult.slave));
//-----------------------------------------------------------------------------
endmodule: cordic_kernel_testbench