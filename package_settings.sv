//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// package_setting.v
// Created: 10.26.2016
//
// Package setting.
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
package package_settings;
//-----------------------------------------------------------------------------
// Parameter Declaration(s)
//-----------------------------------------------------------------------------
    parameter SIZE_DATA                       = 16; 
    parameter SIZE_FRAC                       = 16;
    parameter FULL_SIZE                       = SIZE_FRAC + SIZE_DATA;
//-----------------------------------------------------------------------------
	parameter STAGES                          = 32; 
//-----------------------------------------------------------------------------
	parameter STAGES_K                        = 9;               
	parameter logic [FULL_SIZE-1:0] K_SCALED [STAGES_K] = '{
		0.70711 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.63246 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.61357 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.60883 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.60765 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.60735 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.60728 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.60726 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.60725 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC)};
//-----------------------------------------------------------------------------
	parameter T                               = 57.29578;
	parameter logic [FULL_SIZE-1:0] T_SCALED  = T * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC);
//-----------------------------------------------------------------------------
	parameter STAGES_TAN                      = 19;  
	parameter logic [FULL_SIZE-1:0] TAN_SCALED [STAGES_TAN] = '{
		0.78540 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.46365 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.24498 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.12435 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.06242 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.03124 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.01562 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00781 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00391 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00195 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00098 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00049 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00024 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00012 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00006 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00003 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00002 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00001 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC),
		0.00000 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC)};
//-----------------------------------------------------------------------------
	parameter PI_2                            = 1.57079;
	parameter PI_2_SCALED                     = PI_2 * ({{FULL_SIZE-2{1'b0}}, 1'b1} << SIZE_FRAC);
//-----------------------------------------------------------------------------
endpackage: package_settings
                                                