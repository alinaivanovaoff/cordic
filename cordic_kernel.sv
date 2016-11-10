//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// cordic_kernel.sv
// Created: 10.26.2016
//
// Cordic kernel.
//
// Given a complex value:  C  = Ic  + jQc
// we will create a rotated value: C' = Ic' + jQc'
// by multiplying by a rotation value: R  = Ir  + jQr

// To add R's phase to C: 
// C'  = C·R 
// Ic' = Ic·Ir - Qc·Qr
// Qc' = Qc·Ir + Ic·Qr

// To subtract R's phase from C:   
// C'  = C·R*
// Ic' = Ic·Ir + Qc·Qr
// Qc' = Qc·Ir - Ic·Qr

// To add 90 degrees, multiply by R   = 0 + j1: 
// Ic' = -Qc 
// Qc' =  Ic   (negate Q, then swap)

// To subtract 90 degrees, multiply by R   = 0 - j1: 
// Ic' =  Qc
// Qc' = -Ic   (negate I, then swap)

// To add a phase, multiply by R = 1 + jK: 
// Ic' = Ic - K·Qc = Ic - (2^-L)·Qc = Ic - (Qc >> L)
// Qc' = Qc + K·Ic = Qc + (2^-L)·Ic = Qc + (Ic >> L)

// To subtract a phase, multiply by R = 1 - jK: 
// Ic' = Ic + K·Qc = Ic + (2^-L)·Qc = Ic + (Qc >> L)
// Qc' = Qc - K·Ic = Qc - (2^-L)·Ic = Qc - (Ic >> L
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
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps
//-----------------------------------------------------------------------------
`include "functions_pkg.sv"
`include "settings_pkg.sv"
//-----------------------------------------------------------------------------
module cordic_kernel import settings_pkg::*; (
//-----------------------------------------------------------------------------
// Input Ports
//-----------------------------------------------------------------------------
    input  wire                                           clk,
    input  wire                                           reset,
//-----------------------------------------------------------------------------
    input  wire signed [FULL_SIZE-1:0]                    data_i,
    input  wire signed [FULL_SIZE-1:0]                    data_q,
    input  wire                                           enable,
//-----------------------------------------------------------------------------
// Output Ports
//-----------------------------------------------------------------------------
    output reg  signed [FULL_SIZE-1:0]                    output_data_i,
    output reg  signed [FULL_SIZE-1:0]                    output_data_q,
    output reg  signed [FULL_SIZE-1:0]                    output_data_theta,
    output reg                                            output_data_valid);
//-----------------------------------------------------------------------------
// Signal declarations
//-----------------------------------------------------------------------------
    reg         signed [FULL_SIZE-1:0]                    data_i_rot       [STAGES];
    reg         signed [FULL_SIZE-1:0]                    data_q_rot       [STAGES];
    reg         signed [FULL_SIZE-1:0]                    theta_rot        [STAGES];
    reg                                                   data_valid_rot   [STAGES];
//-----------------------------------------------------------------------------
    reg         signed [FULL_SIZE-1:0]                    data_i_rot_a     [STAGES];
    reg         signed [FULL_SIZE-1:0]                    data_i_rot_b     [STAGES];
    reg         signed [FULL_SIZE-1:0]                    data_q_rot_a     [STAGES];
    reg         signed [FULL_SIZE-1:0]                    data_q_rot_b     [STAGES];
    reg         signed [FULL_SIZE-1:0]                    theta_rot_a      [STAGES];
    reg         signed [FULL_SIZE-1:0]                    theta_rot_b      [STAGES];
    reg                                                   data_valid_rot_a [STAGES];
//-----------------------------------------------------------------------------
    reg         signed [2*FULL_SIZE-1:0]                  data_i_scaled;
    reg         signed [2*FULL_SIZE-1:0]                  data_q_scaled;
    reg         signed [2*FULL_SIZE-1:0]                  theta_scaled;
    reg                                                   data_valid_scaled;
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
    always_ff @(posedge clk) begin: CORDIC_KERNEL_ROTATE_REGISTERS
        if (reset) begin
            for (int i = 0; i < STAGES; i++) begin
                data_i_rot[i]                            <= '0;
                data_q_rot[i]                            <= '0;
                theta_rot[i]                             <= '0;
                data_valid_rot[i]                        <= '0;
//-----------------------------------------------------------------------------
                data_i_rot_a[i]                          <= '0;
                data_i_rot_b[i]                          <= '0;
                data_q_rot_a[i]                          <= '0;
                data_q_rot_b[i]                          <= '0;
                theta_rot_a[i]                           <= '0;
                theta_rot_b[i]                           <= '0;
                data_valid_rot_a[i]                      <= '0;
            end 
        end else begin
            if (data_q >= 0) begin
                data_i_rot[0]                            <= data_q;
                data_q_rot[0]                            <= -data_i;
                theta_rot[0]                             <= PI_2_SCALED;
            end else if (data_q < 0) begin
                data_i_rot[0]                            <= -data_q;
                data_q_rot[0]                            <= data_i;
                theta_rot[0]                             <= -PI_2_SCALED;
            end
            data_valid_rot[0]                            <= enable;
            for (int i = 1; i < STAGES; i++) begin
                data_i_rot[i]                            <= data_q_rot_a[i-1][FULL_SIZE-1] ? data_i_rot_a[i-1] - data_i_rot_b[i-1] : data_i_rot_a[i-1] + data_i_rot_b[i-1];
                data_i_rot_a[i-1]                        <= data_i_rot[i-1];
                data_i_rot_b[i-1]                        <= data_q_rot[i-1] >>> i-1;
//-----------------------------------------------------------------------------
                data_q_rot[i]                            <= data_q_rot_a[i-1][FULL_SIZE-1] ? data_q_rot_a[i-1] + data_q_rot_b[i-1] : data_q_rot_a[i-1] - data_q_rot_b[i-1];
                data_q_rot_a[i-1]                        <= data_q_rot[i-1];
                data_q_rot_b[i-1]                        <= data_i_rot[i-1] >>> i-1;                
//-----------------------------------------------------------------------------
                theta_rot[i]                             <= data_q_rot_a[i-1][FULL_SIZE-1] ? theta_rot_a[i-1]  - theta_rot_b[i-1]  : theta_rot_a[i-1]  + theta_rot_b[i-1];
                theta_rot_a[i-1]                         <= theta_rot[i-1];
                theta_rot_b[i-1]                         <= (i > TAN_STAGES) ? TAN_SCALED[TAN_STAGES-1] : TAN_SCALED[i-1];
//-----------------------------------------------------------------------------
                data_valid_rot[i]                        <= data_valid_rot_a[i-1];
                data_valid_rot_a[i-1]                    <= data_valid_rot[i-1];
            end
        end
    end: CORDIC_KERNEL_ROTATE_REGISTERS
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: CORDIC_KERNEL_SCALED
        if (reset) begin
            {data_i_scaled, data_q_scaled, theta_scaled, data_valid_scaled} <= '0;
        end else begin
            data_i_scaled                                <= (STAGES > K_STAGES) ? data_i_rot[STAGES-1] * K_SCALED[K_STAGES-1] : data_i_rot[STAGES-1] * K_SCALED[STAGES-1];
            data_q_scaled                                <= (STAGES > K_STAGES) ? data_q_rot[STAGES-1] * K_SCALED[K_STAGES-1] : data_q_rot[STAGES-1] * K_SCALED[STAGES-1];
            theta_scaled                                 <= theta_rot[STAGES-1] * T_SCALED;
            data_valid_scaled                            <= data_valid_rot[STAGES-1];
        end
    end: CORDIC_KERNEL_SCALED
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: CORDIC_KERNEL_OUTPUT_DATA
        if (reset) begin
            {output_data_i, output_data_q, output_data_theta, output_data_valid} <= '0;
        end else begin
            output_data_i                                <= data_i_scaled >>> FRAC_SIZE;
            output_data_q                                <= data_q_scaled >>> FRAC_SIZE;
            output_data_theta                            <= theta_scaled  >>> FRAC_SIZE;
            output_data_valid                            <= data_valid_scaled;
        end
    end: CORDIC_KERNEL_OUTPUT_DATA
//-----------------------------------------------------------------------------
endmodule: cordic_kernel