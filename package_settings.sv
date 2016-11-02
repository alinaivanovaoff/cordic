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
	parameter STAGES                          = 16;
//-----------------------------------------------------------------------------
	parameter K                               = 0.607252935;
	parameter logic [FULL_SIZE-1:0] K_SCALED  = K * ({{FULL_SIZE-2{0}}, 1'b1} << SIZE_FRAC);
//-----------------------------------------------------------------------------
endpackage: package_settings
                                                