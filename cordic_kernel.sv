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
//
//-----------------------------------------------------------------------------
// You can calculate the magnitude of a complex number C = Ic + jQc
// if you can rotate it to have a phase of zero; then its new Qc value
// would be zero, so the magnitude would be given entirely by the new Ic value.
//
// "So how do I rotate it to zero," you ask? Well, I thought you might ask:
//
// 1. You can determine whether or not the complex number "C" has a positive
// phase just by looking at the sign of the Qc value: positive Qc means
// positive phase. As the very first step, if the phase is positive,
// rotate it by -90 degrees; if it's negative, rotate it by +90 degrees. 
// To rotate by +90 degrees, just negate Qc, then swap Ic and Qc; 
// to rotate by -90 degrees, just negate Ic, then swap.
// The phase of C is now less than +/- 90 degrees, 
// so the "1 +/- jK" rotations to follow can rotate it to zero
//
// 2. Next, do a series of iterations with successively smaller values of K,
// starting with K=1 (45 degrees). For each iteration, simply look at the
// sign of Qc to decide whether to add or subtract phase; if Qc is negative,
// add a phase (by multiplying by "1 + jK"); if Qc is positive, subtract a
// phase (by multiplying by "1 - jK"). The accuracy of the result converges
// with each iteration: the more iterations you do, the more accurate it becomes.
//
// [Editorial Aside: Since each phase is a little more than half the previous
// phase, this algorithm is slightly underdamped. It could be made slightly
// more accurate, on average, for a given number of iterations, by using "ideal"
// K values which would add/subtract phases of 45.0, 22.5, 11.25 degrees, etc.
// However, then the K values wouldn't be of the form 2^-L, they'd be 1.0, 0.414, 0.199, etc.,
// and you couldn't multiply using just shift/add's 
// (which would eliminate the major benefit of the algorithm). 
// In practice, the difference in accuracy between the ideal K's and these 
// binary K's is generally negligible; therefore, for a multiplier-less CORDIC, 
// go ahead and use the binary Ks, and if you need more accuracy, just do more iterations.]
// Now, having rotated our complex number to have a phase of zero, 
// we end up with "C = Ic + j0". The magnitude of this complex value
// is just Ic, since Qc is zero. However, in the rotation process,
// C has been multiplied by a CORDIC Gain (cumulative magnitude) of about 1.647.
// Therefore, to get the true value of magnitude we must multiply
// by the reciprocal of 1.647, which is 0.607.
// (Remember, the exact CORDIC Gain is a function of the how many iterations you do.)
// Unfortunately, we can't do this gain-adjustment multiply using a simple shift/add; 
// however, in many applications this factor can be compensated 
// for in some other part of the system. 
// Or, when relative magnitude is all that counts (e.g. AM demodulation), it can simply be neglected.
//
// To calculate phase, just rotate the complex number to have zero phase,
// as you did to calculate magnitude. Just a couple of details are different.
// For each phase-addition/subtraction step, accumulate the actual number of
// degrees (or radians) you have rotated. The actuals will come from a table
// of "atan(K)" values like the "Phase of R" column in the table above.
// The phase of the complex input value is the negative of the accumulated
// rotation required to bring it to a phase of zero. Of course, you can skip
// compensating for the CORDIC Gain if you are interested only in phase.
//
//
//
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
    input  wire signed [FULL_SIZE-1:0]                    data_i,
    input  wire signed [FULL_SIZE-1:0]                    data_q,
    input                                                 enable,
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
    reg         signed [FULL_SIZE-1:0]                    data_i_rot       [STAGES],
    reg         signed [FULL_SIZE-1:0]                    data_q_rot       [STAGES],
    reg         signed [FULL_SIZE-1:0]                    theta_rot        [STAGES],
    reg                                                   data_valid_rot   [STAGES],

    reg         signed [FULL_SIZE-1:0]                    data_i_rot_a     [STAGES],
    reg         signed [FULL_SIZE-1:0]                    data_i_rot_b     [STAGES],
    reg         signed [FULL_SIZE-1:0]                    data_q_rot_a     [STAGES],
    reg         signed [FULL_SIZE-1:0]                    data_q_rot_b     [STAGES],
    reg         signed [FULL_SIZE-1:0]                    theta_rot_a      [STAGES],
    reg         signed [FULL_SIZE-1:0]                    theta_rot_b      [STAGES],
    reg                                                   data_valid_rot_a [STAGES],
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
    always_ff @(posedge clk) begin: CORDIC_KERNEL_ROTATE_REGISTERS
        if (reset) begin
            for (int i = 0; i < STAGES; i++) begin
                data_i_rot[i]                            <= '0;
                data_q_rot[i]                            <= '0;
                theta_rot[i]                             <= '0;
                data_valid_rot[i]                        <= '0;

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
                theta_rot[0]                             <= {{FULL_SIZE-2{1}}, 1'b0} <<< SIZE_FRAC;                    
            end else if (data_q < 0)
                data_i_rot[0]                            <= -data_q;
                data_q_rot[0]                            <= data_i;
                theta_rot[0]                             <= {{FULL_SIZE-3{0}}, 2'b10} <<< SIZE_FRAC;
            end
            data_valid_rot[0]                            <= enable;
            for (int i = 1; i < STAGES; i++) begin
                data_i_rot[i]                            <= (theta_rot[i-1] < 0) ? data_i_rot_a[i-1] + data_i_rot_b[i-1] : data_i_rot_a[i-1] - data_i_rot_b[i-1];
                data_i_rot_a[i-1]                        <= data_i_rot[i-1];
                data_i_rot_b[i-1]                        <= data_q_rot[i-1] >>> i-1;
//-----------------------------------------------------------------------------
                data_q_rot[i]                            <= (theta_rot[i-1] < 0) ? data_q_rot_a[i-1] - data_q_rot_b[i-1] : data_q_rot_a[i-1] + data_q_rot_b[i-1];
                data_q_rot_a[i-1]                        <= data_q_rot[i-1];
                data_q_rot_b[i-1]                        <= data_i_rot[i-1] >>> i-1;                
//-----------------------------------------------------------------------------
                theta_rot[i]                             <= (theta_rot[i-1] < 0) ? theta_rot_a[i-1]  + theta_rot_b[i-1]  : theta_rot_a[i-1]  - theta_rot_b[i-1];
                theta_rot_a[i-1]                         <= theta_rot[i-1];
                theta_rot_b[i-1]                         <= {1'b1, {SIZE_DATA-2{0}} >> i-1};
//-----------------------------------------------------------------------------
                data_valid_rot[i]                        <= data_valid_rot_a[i-1];
                data_valid_rot_a[i-1]                    <= data_valid_rot[i-1];
            end
        end
    end: CORDIC_KERNEL_ROTATE_REGISTERS
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: CORDIC_KERNEL_OUTPUT_DATA
        if (reset) begin
            {output_data_i, output_data_q, output_data_theta, output_data_valid} <= '0;
        end else begin
            output_data_i                                <= data_i_rot[STAGES-1] * K_SCALED;
            output_data_q                                <= data_q_rot[STAGES-1] * K_SCALED;
            output_data_theta                            <= -theta_rot[STAGES-1];
            output_data_valid                            <= data_valid_rot[STAGES-1];
        end
    end: CORDIC_KERNEL_OUTPUT_DATA
//-----------------------------------------------------------------------------
endmodule: cordic_kernel