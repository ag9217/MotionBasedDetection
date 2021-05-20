function [ rotVec ] = OFSubroutineRotate( vec, rotAx, alpha )
%OFSUBROUTINEROTATE rotates the given vector through the rotAxis as
%UNIT-vector
% 
%Input:
%   vec - Vx3 matrix with  vectors to rotate
%   rotAx - the axis to rotate around
%   alpha - the angle to rotate in radian
%
%Output:
%   rotVec - the rotated vectors in the input matrix
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


% scaling the axis to unit vector
rotAx=rotAx./norm(rotAx);

% this is an rotation matrix: 
Rot=[cos(alpha)+rotAx(1)^2*(1-cos(alpha)), rotAx(1)*rotAx(2)*(1-cos(alpha))-rotAx(3)*sin(alpha),...
    rotAx(1)*rotAx(3)*(1-cos(alpha))+rotAx(2)*sin(alpha);...
 rotAx(2)*rotAx(1)*(1-cos(alpha))+rotAx(3)*sin(alpha),...
    cos(alpha)+rotAx(2)^2*(1-cos(alpha)), rotAx(2)*rotAx(3)*(1-cos(alpha))-rotAx(1)*sin(alpha);...
 rotAx(3)*rotAx(1)*(1-cos(alpha))-rotAx(2)*sin(alpha),...
    rotAx(3)*rotAx(2)*(1-cos(alpha))+rotAx(1)*sin(alpha), cos(alpha)+rotAx(3)^2*(1-cos(alpha))];

rotVec = zeros([ size(vec,1) , size(vec,2)]);

for k=1:size(vec,1)
    rotVec(k,:)=(Rot*vec(k,:)')'; 
end
end

