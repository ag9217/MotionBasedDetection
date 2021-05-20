function [ ] = OFDraw3dPlot(tra, sp, hof, vof, t, varargin)
%OFDRAW3DPLOT plots the optic flow field from hof and vof on an unitSphere
% and translatees it to trajectory translation
%
%Input:
% tra - Tx6 matrix with the trajectory positions
% sp - Sx2 matrix with sample points
% hof, vof - Horizontal and vertical components of the OpticFlow
%   to receive hof and vof: OFCalcOpticFlow
% t - trajectory position of the Optoc Flow
% OPTIONAL (have to be in this order):
%   scale - double, scales the flow vectors and is analog to scale
%       in function quiver: 1= no scale, 0.5= half length, 2= double length
%   density - integer, specifies the density of the unit-sphere-surfaces
%
%Output:
% A 3d Plot with an unitsphere on wich the Optic Flow is Ploted
% The Unit Sphere is translated to trajectoryposition t,
% so if OFDrawTra is ploted first, the unitsphere will be inserted in the
% exsiting plot.
%
% see also OFDrawTra, OFCalcOpticFlow
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


optargin=size(varargin,2);

if(optargin==1)
    scale=varargin{1};
    density=10;
elseif(optargin==2)
    scale=varargin{1};
    density=varargin{2};
else
    if(optargin>2)
        error('to many input arguments');
    end
    scale=1;
    density=10;
end



hold on
axis equal;
if(t>=size(tra,1)||t<0)
    error('chosen trajectory position t is out of range');
end
% draw a unit-sphere where OF is drawn on
proj=OFModSphere('unitSphere',1,density);
proj=OFModTranslate(proj,tra(t,1),tra(t,2),tra(t,3));
OFDrawMesh(proj,false);
sightDir=OFSubroutineYawPitchRoll([2 0 0],tra(t,4:6),false);
temp=[tra(t,1:3); (tra(t,1:3)+sightDir)];
plot3(temp(:,1),temp(:,2),temp(:,3),'.-');
% parameter for quiver3
qx=[];
qy=[];
qz=[];
qu=[];
qv=[];
qw=[];

for k=1:size(sp,1)
    spline=OFSubroutineSpToVector(sp(k,:));
    %sp(i,:)+
    flowPoint=OFSubroutineSpToVector([hof(t,k) vof(t,k)]);
    
    % restore the optic Flow, which was crippled in OFCalcOpticFlow
    % when transformed into geographic coordinates
%     scale=dot(spline, flowPoint);
%     flowPoint=flowPoint*abs(1/scale);
    
    % yaw, pitch and roll at trajectory step t
    spline=OFSubroutineYawPitchRoll(spline,tra(t,4:6),false);
    flowPoint=OFSubroutineYawPitchRoll(flowPoint,tra(t,4:6),false);
        
    % and the translation to trajectory step t
    spline=tra(t,1:3)+spline;
    flowPoint=tra(t,1:3)+flowPoint;
    
    qx=[qx spline(1)];
    qy=[qy spline(2)];
    qz=[qz spline(3)];
    qu=[qu (-spline(1)+flowPoint(1))*scale];
    qv=[qv (-spline(2)+flowPoint(2))*scale];
    qw=[qw (-spline(3)+flowPoint(3))*scale];

end

%quiver3(qx, qy, qz, qu, qv, qw,0,'r','LineWidth',1);
flowfield=coneplot(qx, qy, qz, qu, qv, qw,0, 'nointerp');
set(flowfield,'FaceColor','red','EdgeColor','none')
hold off;
material dull;
axis equal;
end

