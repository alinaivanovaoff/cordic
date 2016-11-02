//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// program_test_cordic_kernel.v
// Created: 10.26.2016
//
// Program Test CORDIC Kernel.
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
program program_test_cordic_kernel (
    interface ICKData,
    interface ICKResult);

	logic [FULL_SIZE-1:0]                              amp_gm_fifo[$] = '{10 * ({{FULL_SIZE-2{0}}, 1'b1} << SIZE_FRAC};
	logic [FULL_SIZE-1:0]                              amp;
	logic [FULL_SIZE-1:0]                              ph_gm_fifo[$]  = '{23 * ({{FULL_SIZE-2{0}}, 1'b1} << SIZE_FRAC};
	logic [FULL_SIZE-1:0]                              ph;


    initial begin
    	@(poseadge ICKData.reset_n);
    	ICKData.data_i                                 = 9,205049 * ({{FULL_SIZE-2{0}}, 1'b1} << SIZE_FRAC);
    	ICKData.data_q                                 = 3,907311 * ({{FULL_SIZE-2{0}}, 1'b1} << SIZE_FRAC);
    	ICKData.enable                                 = 1;

    
    	while (ph_gm_fifo.size() != 0) begin
    		@(poseadge ICKData.clk);
    		if (ICKResult.ouput_data_valid) begin
    			amp                                    = amp_gm_fifo.pop_front();
    			if (amp != ICKResult.output_data_q) begin
    				$display("Error! Expetcted AMP %z != received AMP %z", amp, ICKResult.output_data_q);
    			end
    			if (amp != ICKResult.output_data_i) begin
    				$display("Error! Expetcted AMP %z != received AMP %z", amp, ICKResult.output_data_i);
    			end
    			ph                                     = ph_gm_fifo.pop_front();
    			if (ph != ICKResult.output_data_theta) begin
    				$display("Error! Expetcted AMP %z != received AMP %z", amp, ICKResult.output_data_theta);
    			end
    		end
    	end
    	$display("Test finished.");
    	$stop;
    end

endprogram: program_test_cordic_kernel