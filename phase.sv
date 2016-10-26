//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// phase.v
// Created: 10.26.2016
//
// Phase detector.
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
module phase (
//-----------------------------------------------------------------------------
// Input Ports
//-----------------------------------------------------------------------------
    input  wire                                           clk,
    input  wire                                           reset,
//-----------------------------------------------------------------------------
    input  wire        [SIZE_DATA-1:0]                    input_data,
    input  wire                                           enable,
//-----------------------------------------------------------------------------
// Output Ports
//-----------------------------------------------------------------------------
    output reg signed  [SIZE_DATA-1:0]                    output_data);
//-----------------------------------------------------------------------------
// Signal declarations
//-----------------------------------------------------------------------------
    reg signed         [SIZE_DATA-1:0]                    div_output;
    reg signed         [SIZE_DATA-1:0]                    arctg_output;
//-----------------------------------------------------------------------------
// Function Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Sub Module Section
//-----------------------------------------------------------------------------
    Divider divider (
        .clk                                              (clk),
        .reset                                            (reset),
//-----------------------------------------------------------------------------
        .data_a                                           (data_q),
        .data_b                                           (data_i),
//-----------------------------------------------------------------------------
        .output_data                                      (div_output));
//-----------------------------------------------------------------------------
    ArcTg arc_tg (
        .clk                                              (clk),
        .reset                                            (reset),
//-----------------------------------------------------------------------------
        .input_data                                       (div_output),
//-----------------------------------------------------------------------------
        .output_data                                      (arctg_output));
//-----------------------------------------------------------------------------
// Signal Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Process Section
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: PHASE_OUTPUT_DATA
        if (reset) begin
            output_data                                  <= '0;
        end else begin
            output_data                                  <= arctg_output;
        end
    end: PHASE_OUTPUT_DATA
//-----------------------------------------------------------------------------
endmodule: phase