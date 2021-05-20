function [ dist ] = OFCalcDistances( mod, tra, sp,Nb_thread,show_waitbar)
%OFCALCDISTANCES returns the distances to the environment
% at the sampling points for all trajectory steps.
% not needed to be called manually, is used by OFCalcOpticFlow
%   positive angular values rotate clockwise around the axis
%
%Input:
%   mod - is an model of object structs
%   tra  - Tx6 matrix x, y, z, yaw, pitch, roll
%       yaw is the rotation around z axis
%       pitch around y
%       roll around x
%   sp - Sx2 matrix azimuth, zenith (spheric coordinates)
%
%   Nb_thread    -  The  number of thread use for multithreading
%   show_waitbar -  if true, waitbar monitors function progress 
%
%Output:
%   dist - TxS matrix with environment distances
%       if there is no intersection whith enviroment: inf is returned
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




if ~exist('show_waitbar','var'),
    show_waitbar = false;
end;
if ~exist('Nb_thread','var'),
   Nb_thread=feature('numCores'); %querry the number of cores
end;
try %Try the c code
    dist=OFCalcDistances_CCore( mod, tra, sp,Nb_thread);
    dist=dist'; %In C it is transpose. 
catch
    warning('%s\n%s', ...
        'Use Matlab code to compute distances',...
        'Please compile the OFCalcDistances_CCore.cpp function to use the C++ function (see MatMakefile.m)');
    % because relative to kamera-knot objects move opposite direction:
    tra(:,1:3)=-tra(:,1:3); 
    dist=Inf(size(tra,1),size(sp,1));
    % RoK 31.01.2011
    % takes time; "the processor's attention turns to matlab repeatedly - no
    % word typing etc. in parallel to matlab running this fuction"
    % see below for related changes
    if show_waitbar,
        h=waitbar(0,'computing distances...');
    end;

    for m=1:size(tra,1) % for each trajectory step
        % apply the trajectory
        modTr=OFModTranslate(mod, tra(m,1), tra(m,2), tra(m,3));
        spTr=OFSubroutineSpToVector(sp);
        spTr=OFSubroutineYawPitchRoll(spTr,tra(m,4:6),false);
        spTr=OFSubroutineVectorToSp(spTr);    
        %Populate spline for each ommatidia
        spline=zeros(size(spTr,1),3);
        for s=1:size(sp,1)
            spline(s,:)=OFSubroutineSpToVector(spTr(s,:));
        end
        %Populate structure for OFSubroutineCalcDistances*
        InStruct.spline=spline;
        InStruct.mstuetzvektor=[];
        InStruct.Ax=[];
        InStruct.Ay=[];
        for k=1:length(mod) % for each object in the model               
                vert=modTr{k}.vert;
                tri=modTr{k}.tri;
                for t= 1:size(tri,1) % for all triangles in object     
                  b= -vert(tri(t,1),:)';                  % -stuetzvektor
                  InStruct.mstuetzvektor=[InStruct.mstuetzvektor b];
                  InStruct.Ax=[InStruct.Ax; -vert(tri(t,1),:)+vert(tri(t,2),:)];
                  InStruct.Ay=[InStruct.Ay; -vert(tri(t,1),:)+vert(tri(t,3),:)];
                end
        end
        %Loop on spline
        spDist=OFSubroutineCalcDistances_matlab(InStruct);
        % save distances of all sp for this trajectory
        dist(m,:)=spDist;
    % RoK 31.01.2011
        if show_waitbar
            waitbar(m/(size(tra,1)-1))
        end;
    end
    % RoK 31.01.2011
    if show_waitbar
        close(h);
    end;
end
end

%It is exactly the same function than the one written in c
%but in matlab, thus slower, and without multithreading
function spDist=OFSubroutineCalcDistances_matlab(InStruct)
    spline=InStruct.spline;
    mstuetzvektor=InStruct.mstuetzvektor;
    Ax=InStruct.Ax;
    Ay=InStruct.Ay;
    spDist=Inf(1,size(spline,1));
    for s= 1:size(spline,1) % for all sampling points
        for Trig_i=1:size(Ax,1) % for each triangle in the model 
           % check if there is an intersection with all triangles:
           b= mstuetzvektor(:,Trig_i);                  % -stuetzvektor
           A= [Ax(Trig_i,:); % rv1
               Ay(Trig_i,:); % rv2
              -spline(s,:)]';                          % -geradenV.
           % check if A is not singular
           if(abs(det(A))>0.001)
              % intersectPoint: [r*rv1, s*rv2, t*geradenV]
              intersectPoint=A\b;                 
              %now check if the intersectionPoint is inside the
              %triangle and distance is positive
              if((intersectPoint(1)>=0)&&(intersectPoint(2)>=0)&&...
                 (intersectPoint(1)+intersectPoint(2)<=1)&&(intersectPoint(3)>=0))
                  spDist(s)=min([spDist(s);intersectPoint(3)]);
              end                      
           end
        end 
    end
end

