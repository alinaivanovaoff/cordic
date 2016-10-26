//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// cordic_kernel.v
// Created: 10.26.2016
//
// Cordic kernel.
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
module cordic_kernel (
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
    reg signed         [SIZE_DATA-1:0]                    shift_reg  [SIZE_SHIFT_REG];
//-----------------------------------------------------------------------------
// Function Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Sub Module Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Signal Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Process Section
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: CORDIC_KERNEL_SHIFT_REG
        if (reset) begin
            for (int i = 0; i < SIZE_SHIFT_REG; i++) begin
                shift_reg[i]                             <= '0;
            end
        end else begin
            shift_reg[0]                                 <= input_data;
            for (int i = 1; i < SIZE_SHIFT_REG; i++) begin
                shift_reg[i]                             <= shift_reg[i-1];
            end
        end
    end: CORDIC_KERNEL_SHIFT_REG
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: CORDIC_KERNEL_OUTPUT_DATA
        if (reset) begin
            output_data                                  <= '0;
        end else begin
            output_data                                  <= enable ? shift_reg[SIZE_SHIFT_REG-1] : '0;
        end
    end: CORDIC_KERNEL_OUTPUT_DATA
//-----------------------------------------------------------------------------
endmodule: cordic_kernel