function [ hof, vof ] = OFCalcOpticFlowMovieWise(mod, tra, sp, indices)
% This function wraps the OFCalcOpticFlow for concatenated trajectories as
% used in clustering analysis.
%
% GETS 
%       mod = an model of object structs
%       tra = Tx6 matrix x, y, z, yaw, pitch, roll
%       CAREFUL: rotation between two trajectory steps must
%                not exceed pi/2 (90°)
%                yaw is the rotation around z axis
%                pitch around y
%                roll around x
%       sp = Sx2 matrix azimuth(0 - 2*pi), zenith(pi/2 - -pi/2
%            baisicly an spherical coordinate system but with GEOGRAPHICAL
%            LATITUDE (elevation / altitude)
%            [pi/2 0]= left, [3*pi/2 0]= right, [0 pi/2]= top, 
%            [0 -pi/2]= bottom
%       indices = The frame indices as the movie(s) was recorded
%
% RETURNS
%       hof(t,s)  = stores the horizontal and
%       vof(t, s) = the vertical components of the optic flow at sampling point s
%                   and trajectory position t
%
%FUNCTION CALL: [ hof, vof ] = OFCalcOpticFlowMovieWise(mod, tra,...
%                              sp,indices);
%
% Author: B. Geurten
%
% see also OFCalcOpticFlow, OFCalcDistance, OFCalcPMOF
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright (C) 2009-2014 O.J.N. Bertrand, J.P. Lindemann, C. Strub
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


%intialising variables
hof = [];
vof = [];

%%%%%%%%%%%%%%%%%%
% finding movies %
%%%%%%%%%%%%%%%%%%

indi_breaks = find(abs(diff(indices))>1);
movie_ends = [indi_breaks; length(indices)];
movie_starts = [1; indi_breaks+1];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Getting optic flow for each movie by calling get_saccades %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(movie_starts);
       
    [temph, tempv] = OFCalcOpticFlow( mod, tra(movie_starts(i):movie_ends(i),:), sp );
    hof = [hof; temph];
    vof = [vof; tempv];
    
end
