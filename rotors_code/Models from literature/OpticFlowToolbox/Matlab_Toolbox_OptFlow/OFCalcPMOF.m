function [hof, vof, tra] = OFCalcPMOF(mod,sp,orientation,pm)
% This function calculates teh opic flow for a set of movements. Instead of
% entering a complete trajectory we add the movement to the standard 
% position of the animal to creat a trajectory.
%
% GETS 
%       mod = an model of object structs
%       sp  = Sx2 matrix azimuth(0 - 2*pi), zenith(pi/2 - -pi/2
%            baisicly an spherical coordinate system but with GEOGRAPHICAL
%            LATITUDE (elevation / altitude)
%            [pi/2 0]= left, [3*pi/2 0]= right, [0 pi/2]= top, 
%            [0 -pi/2]= bottom
%       orientation = standard yaw pitch and roll of the animal in radians
%       pm  = mxn matrix with m features and 6 rows containg the:
%            * rows 1-3 translational speed in ARENA coordinates NOT 
%              thrust, slip and lift
%            * rows 4-6 rotational speeds of the Fick passive angles
%
% RETURNS
%       hof(t,s)  = stores the horizontal and
%       vof(t, s) = the vertical components of the optic flow at sampling point s
%                   and t. All uneven ts show fowfields of the movements.
%                   even ts show the switchback to the standard position
%       tra       = trajectory used to create optic flow
%
%FUNCTION CALL: [hof, vof, tra] = OFCalcPMOF(mod,sp,orientation,pm);
%
% Author: B. Geurten
%
% see also OFCalcOpticFlow, OFCalcDistance, OFCalcOpticFlowMovieWise
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright (C) 2009-2014 B. Geurten, J.P. Lindemann
%		
%   This file is part of the ivtools.
%   https://opensource.cit-ec.de/projects/ivtools
%
%   the Optic-Flow toolbox is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%   the Optic-Flow toolbox is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%getting number of PMs
pm_nb = size(pm,1);

%creating start position
start_pos = [zeros(pm_nb,3) orientation];

%creating trajectory
tra = NaN(2*pm_nb,6);
for i =2:2:2*pm_nb,
    tra(i-1,:) = start_pos(i);
    tra(i,:)= start_pos(i)+pm(i/2,:);
end

% calculating optic flow 
[hof,vof] = OFCalcOpticFlow(mod,tra,sp);
