//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// testbench_cordic_kernel.v
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
import package_settings::*;
include "interface_cordic_kernel.sv";
//-----------------------------------------------------------------------------
module testbench_cordic_kernel ();
//-----------------------------------------------------------------------------
// Variable declarations
//-----------------------------------------------------------------------------
    logic                                                 clk;
    logic                                                 reset_n;
//-----------------------------------------------------------------------------
    interface_cordic_kernel_data ICKData (
        .clk                                              (clk),
        .reset_n                                          (reset_n));
//-----------------------------------------------------------------------------
    interface_cordic_kernel_data ICKResult ();
//-----------------------------------------------------------------------------
// Function Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Process Section
//-----------------------------------------------------------------------------
    initial begin: TEST_CORDIC_KERNEL_INITIAL
        $display("Running testbench");
        #10 reset_n                                      <= 0;
        #10 reset_n                                      <= 1;
    end: TEST_CORDIC_KERNEL_INITIAL
//-----------------------------------------------------------------------------
    always begin: TEST_CORDIC_KERNEL_CLK
        #2 clk                                           <= ~clk;
    end: TEST_CORDIC_KERNEL_CLK
//-----------------------------------------------------------------------------
// Sub Module Section
//-----------------------------------------------------------------------------
    cordic_kernel CordicKernel (
        .clk                                              (clk),
        .reset                                            (reset_n),
//-----------------------------------------------------------------------------
        .data_i                                           (ICKData.slave.data_i),
        .data_q                                           (ICKData.slave.data_q),
        .enable                                           (ICKData.slave.enable),
//-----------------------------------------------------------------------------
        .output_data_i                                    (ICKResult.slave.output_data_i),
        .output_data_q                                    (ICKResult.slave.output_data_q),
        .output_data_theta                                (ICKResult.slave.output_data_theta),
        .output_data_valid                                (ICKResult.slaveoutput_data_valid));
//-----------------------------------------------------------------------------
// Program Section
//-----------------------------------------------------------------------------
    test Test(
        .ICKData   (ICKData.master),
        .ICKResult (ICKResult.master));
//-----------------------------------------------------------------------------
endmodule: testbench_cordic_kernel