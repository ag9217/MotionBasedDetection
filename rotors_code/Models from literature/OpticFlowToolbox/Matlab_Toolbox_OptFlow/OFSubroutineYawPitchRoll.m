function [ vec ] = OFSubroutineYawPitchRoll( vec, ypr, inverse )
%OFSUBROUTINEYAWPITCHROLL applies yaw pitch and roll to a vector
%   inverse = true to inverse the YawPitchRoll
%
%Input:
%   vec - a 3dim vector to rotate
%   ypr - [yaw pitch roll]
%   inverse - boolean to dertermine whether the inverse rotations or
%       the normal rotation should be computed
%
%Output:
%   rotated vector
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



% rotations around abselute fix-axis
% if (inverse==true)
%     vec=OFSubroutineRotate(vec,[1 0 0],-ypr(3));
%     vec=OFSubroutineRotate(vec,[0 1 0],-ypr(2));
%     vec=OFSubroutineRotate(vec,[0 0 1],-ypr(1));
% else
%     vec=OFSubroutineRotate(vec,[0 0 1],ypr(1));
%     vec=OFSubroutineRotate(vec,[0 1 0],ypr(2));
%     vec=OFSubroutineRotate(vec,[1 0 0],ypr(3));
% end

% rotations around relative rotatet axis
for k=1:size(vec,1)
    if (inverse==true)
        vec(k,:)=OFSubroutineRotate(vec(k,:),[1 0 0],-ypr(3));
        vec(k,:)=OFSubroutineRotate(vec(k,:),OFSubroutineRotate([0 1 0],[1 0 0],-ypr(3)),-ypr(2));
        vec(k,:)=OFSubroutineRotate(vec(k,:),OFSubroutineRotate(...
            OFSubroutineRotate([0 0 1],[1 0 0],-ypr(3)),[0 1 0],-ypr(2)),-ypr(1));
    else
        vec(k,:)=OFSubroutineRotate(vec(k,:),[0 0 1],ypr(1));
        vec(k,:)=OFSubroutineRotate(vec(k,:),OFSubroutineRotate([0 1 0],[0 0 1],ypr(1)),ypr(2));
        vec(k,:)=OFSubroutineRotate(vec(k,:),OFSubroutineRotate(...
            OFSubroutineRotate([1 0 0],[0 0 1],ypr(1)),[0 1 0],ypr(2)),ypr(3));
    end

end

end

