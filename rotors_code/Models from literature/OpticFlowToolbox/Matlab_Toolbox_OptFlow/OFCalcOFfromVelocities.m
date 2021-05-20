function [ hof, vof ] = OFCalcOFfromVelocities( sp, hvel, vvel )
%OFCALCOFFROMVELOCITIES computes the Optic Flow from the
%optic-flow-velocities.
%see also OFCalcVelocities.m
%
% Input:
%   sp - Sx2 matrix azimuth(0 - 2*pi), zenith(pi/2 - -pi/2
%       baisicly an spherical coordinate system but with GEOGRAPHICAL
%       LATITUDE (elevation / altitude)
%       [pi/2 0]= left, [3*pi/2 0]= right, [0 pi/2]= top, [0 -pi/2]= bottom
%
%   hvel - txS matrix with the horizontal velocities of the opticFlow
%
%   vvel - txS matrix with the vertical velocities of the opticFlow
%
%Output:
%   hof(t,s) - stores the horizontal and
%   vof(t, s) - the vertical components of the samplepoint + optic flow at
%       sampling point s and trajectory position t
%
% see also OFCalcOpticFlow
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


sp3=OFSubroutineSpToVector(sp);
hof=zeros(size(hvel));
vof=zeros(size(hvel));

h=waitbar(0,'computing OpticFlow...');
for k=1:size(hvel,1)
    for l=1:size(sp,1);
        orthoVec=([sp3(l,2),-sp3(l,1),0]/norm([sp3(l,2),-sp3(l,1),0]));
        temp=OFSubroutineVectorToSp(...
            sp3(l,:)+orthoVec*(-hvel(k,l)));
        hof(k,l)=temp(1,1);
        temp=OFSubroutineVectorToSp(...
            sp3(l,:)+cross(orthoVec,sp3(l,:))*(vvel(k,l)));
        vof(k,l)=temp(1,2);
    end
    waitbar(k/size(hof,1));
end
close(h);

end

