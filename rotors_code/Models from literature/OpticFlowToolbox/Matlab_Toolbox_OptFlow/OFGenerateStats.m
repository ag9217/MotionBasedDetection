function [ stats ] = OFGenerateStats( sp, poe_poc )
%OFGENERATESTATS generates a matrix which stores the quantity of PoE or PoC
%seperated into as many columns as the azimuth-sp-density
%
%INPUT: 
%            sp = return value of OFGenerateSp
%       poe_poc = Point of expansion or contraction as calculated be
%                 OFCalcPoE_PoC
%
%OUTPUT:
%   stats - an mxn matrix where columns where the first data point is the
%   number of PoEs (or PoCs) in the most left sp column and top row. Where
%   the lastone reprensets the number of PoEs or PoCs in the most right column 
%   and lowest row
%
%SYNTAX: [ stats ] = OFGenerateStats( sp, poe_poc );
%
% see also OFCalcPoE_PoC, OFGenerateSp
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright (C) 2009-2014 B. Geurten, J.P. Lindemann, C. Strub
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


%generate Matrix of sp
spM=OFGenerateSpMatrix(sp);
%get dimensions
[dim2,dim1]=size(spM);
%create step size
stepH=2*pi/(dim1);

%is sp have a 360° range, then the real dim1 is one less because
% first and last sp are identical.
if(spM(:,1)==spM(:,end))
  stepH=2*pi/(dim1-1);
end
stepV=pi/dim2;
%inialsing return variable
stats = NaN(dim2,dim1);
border=[];
for k=1:dim1,
    if(pi-(stepH*k)>=0)% from left to middle
        r=find((pi-(stepH*(k-1)))>poe_poc(:,1)&poe_poc(:,1)>=pi-(stepH*k));
        %get vertical points
        cans = poe_poc(r,2);
        %add vertical vector to stats matrix
        stats(:,k)=vert_dist(cans,dim2,stepV);

        border=[border;k,pi-(stepH*(k-1)),pi-(stepH*(k))];

    elseif(pi-(stepH*k)<0 && pi-(stepH*(k-1))>=0)% middle overlap
        r=find((pi-(stepH*(k-1)))>poe_poc(:,1)|poe_poc(:,1)>=3*pi-(stepH*k));
        %get vertical points
        cans = poe_poc(r,2);
        %add vertical vector to stats matrix
        stats(:,k)=vert_dist(cans,dim2,stepV);
        
        border=[border;k,pi-(stepH*(k-1)),3*pi-(stepH*k)];

     else %from moddle to right
        r=find((3*pi-(stepH*(k-1)))>poe_poc(:,1)&poe_poc(:,1)>=3*pi-(stepH*k));
        %get vertical points
        cans = poe_poc(r,2);
        %add vertical vector to stats matrix
        stats(:,k)=vert_dist(cans,dim2,stepV);
        
        border=[border;k,3*pi-(stepH*(k-1)),3*pi-(stepH*(k))];
    end
    
end
border
end

function distV = vert_dist(candidates,dimV,stepV)
% change scope from -pi/2 -> pi/2 to 0 -> pi
candidates = candidates +pi/2;
%inialsing return variable
distV = NaN(dimV,1);
%main loop testting each bin
for k=1:dimV,
    %finding all points between the last edge (or zero in case of first iteration)
    % and edge k
    r=find(stepV*(k-1)<candidates & candidates<=(stepV*k));
    distV(k)=length(r);
end
% the lowest elevation is on top of the vector therefore we flip it
distV = flipud(distV);
end
