//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// interface_cordic_kernel.sv
// Created: 11.01.2016
//
// Interface CORDIC Kernel.
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
//-----------------------------------------------------------------------------
interface interface_cordic_kernel_data (
    wire                                                  clk,
    wire                                                  reset_n);
//-----------------------------------------------------------------------------
    wire signed [FULL_SIZE-1:0]                           data_i;
    wire signed [FULL_SIZE-1:0]                           data_q;
    wire                                                  enable;
//-----------------------------------------------------------------------------
    modport master                                        (output data_i, data_q, enable);
    modport slave                                         (input  data_i, data_q, enable);
endinterface: INTERFACE_CORDIC_KERNEL_DATA
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
interface interface_cordic_kernel_result ();
    wire signed [FULL_SIZE-1:0]                           output_data_i;
    wire signed [FULL_SIZE-1:0]                           output_data_q;
    wire signed [FULL_SIZE-1:0]                           output_data_theta;
    wire                                                  ouput_data_valid;
    modport master                                        (output output_data_i, output_data_q, output_data_theta, ouput_data_valid);
    modport slave                                         (input  output_data_i, output_data_q, output_data_theta, ouput_data_valid);
endinterface: INTERFACE_CORDIC_KERNEL_RESULT