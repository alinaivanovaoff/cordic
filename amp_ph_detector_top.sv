//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// amp_ph_detector_top.sv
// Created: 10.26.2016
//-----------------------------------------------------------------------------
// Amplitude and Phase Detector Top Module.
//-----------------------------------------------------------------------------
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
`include "functions_pkg.sv"
`include "settings_pkg.sv"
`include "cordic_kernel.sv"
//-----------------------------------------------------------------------------
module amp_ph_detector_top import settings_pkg::*; (
//-----------------------------------------------------------------------------
// Input Ports
//-----------------------------------------------------------------------------
    input  wire                                           clk,
    input  wire                                           reset,
//-----------------------------------------------------------------------------
    input  wire        [DATA_SIZE-1:0]                    data_i,
    input  wire        [DATA_SIZE-1:0]                    data_q,
    input  wire                                           enable,
//-----------------------------------------------------------------------------
// Output Ports
//-----------------------------------------------------------------------------
    output reg         [FULL_SIZE-1:0]                    output_amp,
    output reg         [FULL_SIZE-1:0]                    output_ph,
    output reg                                            output_data_valid);
//-----------------------------------------------------------------------------
// Signal declarations
//-----------------------------------------------------------------------------
    reg                                                   reset_synch;
    reg                [2:0]                              reset_z;
//-----------------------------------------------------------------------------
    reg                [FULL_SIZE-1:0]                    data_reg_i;
    reg                [FULL_SIZE-1:0]                    data_reg_q;
    reg                                                   enable_reg;
//-----------------------------------------------------------------------------
    reg                [FULL_SIZE-1:0]                    cordic_data_q;
//-----------------------------------------------------------------------------
// Function Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Sub Module Section
//-----------------------------------------------------------------------------
   cordic_kernel CordicKernel (
        .clk                                              (clk),
        .reset                                            (reset_synch),
//-----------------------------------------------------------------------------
        .data_i                                           (data_reg_i),
        .data_q                                           (data_reg_q),
        .enable                                           (enable_reg),
//-----------------------------------------------------------------------------
        .output_data_i                                    (output_amp),
        .output_data_q                                    (cordic_data_q),
        .output_data_theta                                (output_ph),
        .output_data_valid                                (output_data_valid));
//-----------------------------------------------------------------------------
// Signal Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Process Section
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: AMP_PH_DETECTOR_TOP_RESET_SYNCH
        reset_z                                         <= {reset_z[1:0], reset};
        reset_synch                                     <= (reset_z[1] & (~reset_z[2])) ? '1 : '0 ;
    end: AMP_PH_DETECTOR_TOP_RESET_SYNCH
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: AMP_PH_DETECTOR_TOP_REGISTERS
        if (reset_synch) begin
            {data_reg_i, data_reg_q, enable_reg}         <= '0;
        end else begin
            data_reg_i                                   <= (data_i[DATA_SIZE-1]) ? {{EXTRA_BITS{1'b1}}, data_i} : {{EXTRA_BITS{1'b0}}, data_i};
            data_reg_q                                   <= (data_q[DATA_SIZE-1]) ? {{EXTRA_BITS{1'b1}}, data_q} : {{EXTRA_BITS{1'b0}}, data_q};
            enable_reg                                   <= enable;                            
        end
    end: AMP_PH_DETECTOR_TOP_REGISTERS
//-----------------------------------------------------------------------------
endmodule: amp_ph_detector_top
