function [ hvel, vvel ] = OFCalcVelocities( sp, hof, vof , show_waitbar )
%OFCALCVELOCITIES returns the velocities of the optic flow calculated by
%the OFCalcOpticFlow method. velocities can be negative!
%the velocities are the distance between sp and of on the spheric surface,
%hence to compute the norm of the velocities use acos(cos(hof)*cos(vof))
% (spherical law of cosines)
%
% Input:
%   sp - Sx2 matrix azimuth(0 - 2*pi), zenith(pi/2 - -pi/2
%       baisicly an spherical coordinate system but with GEOGRAPHICAL
%       LATITUDE (elevation / altitude)
%       [pi/2 0]= left, [3*pi/2 0]= right, [0 pi/2]= top, [0 -pi/2]= bottom
%
%   hof - txS matrix with the horizontal coordinates of the shifted
%       samplepoints
%
%   vof - txS matrix with the vertical coordinates of the shifted
%       samplepoints
%
%   show_waitbar -  if true, waitbar monitors function progress 
%
%Output:
%   hvel(t,s) - stores the horizontal and
%   vvel(t,s) - the vertical velocy of the optic flow 
%   these are positive, if the rotation from sp to OF-point
%       is negative and negative if rotation is positive
%
% see also OFCalcOpticFlow
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright (C) 2009-2014 O.J.N. Bertrand, J.P. Lindemann, R. Kern, C. Strub
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


if ~exist('show_waitbar','var'),
    show_waitbar = false;
end;

hvel = zeros([ size(hof,1) , size(hof,2) ]);
vvel = zeros([ size(hof,1) , size(hof,2) ]);
sp2=sp;
sp2(:,2)=sp(:,2)+pi;
%shifting the values of vertical coordinates into a positive interval 
vof=vof+pi;

% RoK 31.01.2011
% takes time; "the processor's attention turns to matlab repeatedly - no
% word typing etc. in parallel to matlab running this fuction"
% see below for related changes

if show_waitbar,
    h=waitbar(0,'computing velocities...');
end;
for k=1:(size(hof,1)-1)
    for m=1:size(hof,2)
        
        % calculating the velocities
        % horizontal velocities
        hvel(k,m)=hof(k,m)-sp2(m,1);
        
        if(hvel(k,m) > pi) % overlap 0->2pi
            hvel(k,m)=-2*pi+hvel(k,m);
        elseif(hvel(k,m) < -pi) % overlap 0<-2pi
            hvel(k,m)=2*pi+hvel(k,m);
        end
        
        % the horizontal velocity is scaled by the cos of the elevation 
        % angle due to the spheric coordinate system 
        % [vertical component is along the great-circles of the sphere, the
        % horizontal ones along the small circles]
        hvel(k,m)=hvel(k,m)*abs(cos(sp(m,2)));
        
        % vertical velocities
        vvel(k,m)=vof(k,m)-sp2(m,2);   
    end
    % RoK 31.01.2011
    if show_waitbar
        waitbar(k/(size(hof,1)-1))
    end;
end
% RoK 31.01.2011
if show_waitbar
    close(h);
end;
