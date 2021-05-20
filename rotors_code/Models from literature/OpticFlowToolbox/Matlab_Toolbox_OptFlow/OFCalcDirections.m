function [directions] = OFCalcDirections( sp, hof, vof )
%OFCALCDIRECTIONS this function returns the directions in which the optic
%flow vectors point. 0 is upwards, pi/2 right, pi downwards and 3*pi/2 left
%Input:
% sp - Sx2 matrix with sample points
% hof, vof - Horizontal and vertical components of the OpticFlow TxS
%   to receive hof and vof: OFCalcOpticFlow
%
%Output:
% directions - a TxS matrix containing the angles of the OF-directions.
%   0 is upwards, pi/2 is right, pi is downwards and 3*pi/2 is left.
%   if this should be ploted, the sides have to be swaped (as always)
%   so if compared with OFDrawCylPlot then the angles in directions are:
%   0 is upwards, pi/2 is LEFT, pi is downwards and 3*pi/2 is RIGHT.
%
%
%   See also:
%       OFSubroutineSpToVector.m OFCalcOpticFlow.m 
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


% shift into positive values
vof=vof+pi/2;
spOrg=sp;
sp(:,2)=sp(:,2)+pi/2;
directions=NaN(size(hof));
for t=1:size(hof,1)
    
    for s=1:size(sp,1) 
        % horizontal component
        h=hof(t,s)-sp(s,1); % overlap has to be handled
        if(h<-pi)
            h=hof(t,s)+2*pi-sp(s,1);
        end
        h=h*cos(abs(spOrg(s,2))); % compensate the spheric coordinate warping
        if(h<0)
            h=2*pi+h;
        end
        %vertical component
        v=vof(t,s)-sp(s,2);
        if(abs(v)>pi/2) %skip elevation-overlap
            break;
        end

       
        
        x=-[1 0 0]+OFSubroutineSpToVector([h,v]);
        x(1)=0;
        y=[0 0 1]; % tis is the 0 mark
        alpha = acos(dot(x,y)/(norm(x)*norm(y))); %angle betwen o-mark and x
        c=cross(x,y);
        if(c(1)<0) % if negative orientated rotation
            alpha=2*pi-alpha;
        end
        directions(t,s)=alpha;
    end
end
end

