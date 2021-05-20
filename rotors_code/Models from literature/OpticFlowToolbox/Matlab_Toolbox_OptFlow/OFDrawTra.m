function [  ] = OFDrawTra( mod, tra, mdist, flags )
%OFDRAWTRA draws the model and the trajectory represented by a line and
%markers. markers are dots on the trajectory and short line segments
%illustrating yaw pitch angles
%
%Input:
%   mod - is an model of object structs
%   tra - the trajectory steps
%   mdist - gives the distence between markers
%   flags - modifiers for OFDrawMesh (optional)
%
%Output:
%   draws a 3dplot with the trajectory.
%   trajectory steps are represented with circles,
%   the viewing direction is repreented by a line in viewing direction
%
%   trajectory is compleatly abselut, no relative values
% see also OFCalcOpticFlow, OFDrawMesh
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright (C) 2009-2014 J.P. Lindemann, C. Strub
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


if exist ('flags', 'var')
    OFDrawMesh(mod,false,flags);
else
    OFDrawMesh(mod,false);
end
hold on

if(mdist<=0||mdist>size(tra,1))
    error('chosen mdist is out of range');
end

for k=int32(2:size(tra,1))
    X=tra(k-1:k,1)';
    Y=tra(k-1:k,2)';
    Z=tra(k-1:k,3)';
    plot3(X,Y,Z);
    % every mdist point gets a marker
    if(idivide(k,mdist,'ceil')==idivide(k,mdist,'floor'))
        % a single marker on the trajectory line
        plot3(X(2),Y(2),Z(2),':o'); 
        % scales the markers relative to trajectory
        scale=max(max(tra(:,1:3)))/20; 
        marker=[scale 0 0]; % marker abselut value, not relative
        marker=OFSubroutineYawPitchRoll(marker,tra(k,4:6),false);
        V=[tra(k,1:3);tra(k,1:3)+marker];
        plot3(V(:,1),V(:,2),V(:,3),'-r'); % visualisation of yaw and pitch
    end
end
hold off;
end

