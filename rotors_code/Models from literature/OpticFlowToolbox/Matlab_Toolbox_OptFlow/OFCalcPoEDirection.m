function [ direction ] = OFCalcPoEDirection( tra )
%OFCALCPOEDIRECTION returns the PoE which results from the moving
%direction. Does not derive them from optic flow but only from trajectory
%Input:
%   tra - Tx6 matrix x, y, z, yaw, pitch, roll
%       yaw is the rotation around z axis
%       pitch around y
%       roll around x
%
%Output:
%   direction - Tx2 matrix with the spheric coordinates of the PoE.
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


dir        = zeros(size(tra,1)-1, 3);
dir_3d     = zeros(size(tra,1)-1, 3);
direction  = zeros(size(tra,1)-1, 2);

for t=1:size(tra,1)-1,
    dir(t,:)=-tra(t,1:3)+tra(t+1,1:3);
    dir_3d(t,:)=OFSubroutineYawPitchRoll(dir(t,:),-tra(t,4:6),false);
    direction(t,:)=OFSubroutineVectorToSp(dir_3d(t,:));
end

end

