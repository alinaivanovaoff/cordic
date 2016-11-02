//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// amplitude.v
// Created: 10.26.2016
//
// Amplitude detector.
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
module amplitude (
//-----------------------------------------------------------------------------
// Input Ports
//-----------------------------------------------------------------------------
    input  wire                                           clk,
    input  wire                                           reset,
//-----------------------------------------------------------------------------
    input  wire        [SIZE_DATA-1:0]                    data_i,
    input  wire        [SIZE_DATA-1:0]                    data_q,
//-----------------------------------------------------------------------------
// Output Ports
//-----------------------------------------------------------------------------
    output reg signed  [SIZE_DATA-1:0]                    output_data);
//-----------------------------------------------------------------------------
// Signal declarations
//-----------------------------------------------------------------------------
    reg                [SIZE_DATA-1:0]                    data_i_square;
    reg                [SIZE_DATA-1:0]                    data_q_square;
    reg                [SIZE_DATA-1:0]                    data_square_sum;
//-----------------------------------------------------------------------------
    reg                [SIZE_DATA-1:0]                    sqrt_output;   
//-----------------------------------------------------------------------------
// Function Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Sub Module Section
//-----------------------------------------------------------------------------
    Sqrt sqrt (
        .clk                                              (clk),
        .reset                                            (reset),
//-----------------------------------------------------------------------------
        .input_data                                       (data_square_sum),
//-----------------------------------------------------------------------------
        .output_data                                      (sqrt_output));
//-----------------------------------------------------------------------------
// Signal Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Process Section
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: AMPLITUDE_DATA_SQUARE
        if (reset) begin
            {data_i_square, data_q_square, data_square_sum} <= '0;
        end else begin
            data_i_square                                <= data_i * data_i;
            data_q_square                                <= data_q * data_q;
            data_square_sum                              <= data_i_square + data_q_square;
        end
    end: AMPLITUDE_TOP_OUTPUT_DATA
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: AMPLITUDE_OUTPUT_DATA
        if (reset) begin
            output_data                                  <= '0;
        end else begin
            output_data                                  <= sqrt_output;
        end
    end: AMPLITUDE_OUTPUT_DATA
//-----------------------------------------------------------------------------
endmodule: amplitude