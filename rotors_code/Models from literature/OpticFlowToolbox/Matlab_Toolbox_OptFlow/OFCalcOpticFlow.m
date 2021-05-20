function [ hof, vof, distances ] = OFCalcOpticFlow( mod, tra, sp, Nb_thread, method)
%OFCALCOPTICFLOW returns the horizontal and vertical components
%of the new samplepoints after movement has taken place
%
%Input:
%   mod - an model of object structs
%   tra - Tx6 matrix x, y, z, yaw, pitch, roll
%       yaw is the rotation around z axis
%       pitch around y
%       roll around x
%   sp - Sx2 matrix azimuth(0 - 2*pi), zenith(pi/2 - -pi/2
%       baisicly an spherical coordinate system but with GEOGRAPHICAL
%       LATITUDE (elevation / altitude)
%       [pi/2 0]= left, [3*pi/2 0]= right, [0 pi/2]= top, [0 -pi/2]= bottom
%   method -    Method to convert OF from cartesian coordinates to spherical
%               coordinates. (See Supported method below)
%   show_waitbar -  if true, waitbar monitors function progress 
%
%Output:
%   hof(t,s) - stores the horizontal and
%   vof(t, s) - the vertical components of the samplepoint + optic flow at
%       sampling point s and trajectory position t
%   distances - TxS matrix, the distances from each Sp to the
%           next object for each trajectory step.
%           see also OFCalcDistances
%
% Supported method:
%       -'Matrix_transform' : use a Matrix transformation to convert the OF
%       component in the cartesian coordinates to OF component in the
%       spherical coordinates. Only components along the elevation and the
%       azimuth will be return, because the one along the viewing direction
%       is null
%       -'Old_transform' : Transform the point (samplepoint+OF) in spherical
%       coordinates. Thus hof and vof are the sum of OF and samplepoint.
%       They are constrain to [0,2pi].
%
%CAREFUL: rotation between two trajectory steps must
%            not exceed pi/2 (90�)
%
%   See also 
%       OFCalcOpticFlow_CCore.cpp OFCalcDistances.m
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


if ~exist('method','var'),
    warning('mode Matrix_transform is used: OFCalcOpticFlow will return OF along elevation and azimuth, instead of the angles of OF+Samplingpoint')
    method='Matrix_transform';
end;
if ~exist('Nb_thread','var'),
    Nb_thread=feature('numCores'); %querry the number of cores
end;
if ~exist('show_waitbar','var'),
    show_waitbar = false;
end;

if(~ischar(method))
    error('method has to be of type char')
end
try %Try the c code
    if(~strcmp(method,'Matrix_transform'))
        error('C_Code support only Matrix_transform mode to compute OF')
    end
    [ hof, vof, distances ]=OFCalcOpticFlow_CCore( mod, tra, sp,Nb_thread);
    hof=hof';   %in C it is transpose
    vof=vof';
catch
    if(~strcmp(method,'Matrix_transform'))
        warning('%s\n%s %s\n', ...
            'Use Matlab code to compute OF',...
            method,'is not supported by OFCalcOF_CCore');
    else
        warning('%s\n%s\n', ...
            'Use Matlab code to compute OF',...
            'Please compile the OFCalcOF_CCore.cpp function to use the C++ function (see MatMakefile.m)');
    end

    %Compute Distances
    if(size(mod,1)==1)
        distances=OFCalcDistances(mod,tra,sp);
    elseif(size(mod,1)==size(tra,1))
        distances=mod;
    else
        error('model / distances are invalid');
    end

    hof = zeros( size(tra,1)-1 , size(sp,1) );
    vof = zeros( size(tra,1)-1 , size(sp,1) );
    rof = zeros( size(tra,1)-1 , size(sp,1) );
    % RoK 31.01.2011
    % takes time; "the processor's attention turns to matlab repeatedly - no
    % word typing etc. in parallel to matlab running this fuction"
    % see below for related and addtional changes
    if show_waitbar,
        h=waitbar(0,'computing Optic Flow...');
    end;
    for k=1:size(tra,1)-1

        % check if one rotation (yaw, pitch, or roll) exceeds pi/2
        if(abs(tra(k,4)-tra(k+1,4))>pi/2 && 2*pi-abs(tra(k,4)-tra(k+1,4))>pi/2)||...
          (abs(tra(k,5)-tra(k+1,5))>pi/2 && 2*pi-abs(tra(k,5)-tra(k+1,5))>pi/2)||...
          (abs(tra(k,6)-tra(k+1,6))>pi/2 && 2*pi-abs(tra(k,6)-tra(k+1,6))>pi/2)
            error('one trayectory rotation exceeds 90�, computation aborted')
        end

        if(min(sp(:,1))<0)
            error('azimuth contains negative values, see help for definition of sp');
        end    

        u=-tra(k,1:3)+tra(k+1,1:3);
        % v =the translation speed
        v=norm(u);
        % u =the translation direction
        if(v==0)
            u=[0 0 0];
        else
            u=u/norm(u); 
        end
        % yaw pitch roll need to be computed seperatly
        % the CrossProduct determines the MAXIMAL ROTATION of 90� per
        % trajectory step!
        % rotation around z-axis
        yawNow=OFSubroutineYawPitchRoll([1 0 0],[tra(k,4) 0 0],false);
        yawNext=OFSubroutineYawPitchRoll([1 0 0],[tra(k+1,4) 0 0],false);
        rYaw=cross(yawNow,yawNext);

        % now rotation around y-axis
        pitchNow=OFSubroutineYawPitchRoll([1 0 0],[0 tra(k,5) 0],false);
        pitchNext=OFSubroutineYawPitchRoll([1 0 0],[0 tra(k+1,5) 0],false);   
        rPitch=cross(pitchNow,pitchNext);

        %and roatation around x-baxis
        rollNow=OFSubroutineYawPitchRoll([0 0 1],[0 0 tra(k,6)],false);
        rollNext=OFSubroutineYawPitchRoll([0 0 1],[0 0 tra(k+1,6)],false);    
        rRoll=cross(rollNow,rollNext); 
        %time_header=tic();
        for m=1:size(sp,1)

            % if there is no Optic Flow:
            if(distances(k,m)==inf)
    %             hof(k,m)=sp(m,1);
    %             vof(k,m)=sp(m,2);
                hof(k,m)=0;
                vof(k,m)=0;
                m=m+1;
                if(m>size(sp,1))
                    break;
                end
            end

            spline=OFSubroutineSpToVector(sp(m,:));
            spline=OFSubroutineYawPitchRoll(spline, tra(k,4:6),false);
            % d =samplePoint
            d=spline;               
            % p =the distance to next object
            p=distances(k,m);
            if(p==0)
                % if object touches the enviroment, OpticFlow dosnt need to be
                % scaled -> distance=1
                p=1;
            end
            % the Translation-part of the Optic Flow:
            opticFlowT=-(v*u-(v*u*d')*d)/p;
            % check if there actualy is a rotation and if compute
            % surface-normal and scale it with angle between vectors
            % negative because flow relative to observer
            if norm(rYaw)<=0.000001
                opticFlowRyaw=0;
            else
                rYawN=rYaw/norm(rYaw)*asin(norm(rYaw));
                opticFlowRyaw=-cross(rYawN,d);
            end
            if norm(rPitch)<=0.000001
                opticFlowRpitch=0;
            else
                rPitchN=rPitch/norm(rPitch)*asin(norm(rPitch));
                opticFlowRpitch=-cross(rPitchN,d);
            end
            if norm(rRoll)<=0.000001
                opticFlowRroll=0;
            else
                rRollN=rRoll/norm(rRoll)*asin(norm(rRoll));
                opticFlowRroll=-cross(rRollN,d);
            end
            % combine the rotations
            opticFlowR=opticFlowRyaw+opticFlowRpitch+opticFlowRroll;

            % and add Translation and Rotation to get the Optic Flow
            opticFlow=opticFlowT+opticFlowR;

            %Transform OF from Cartesian coordinates to Spherical coordinates
            %according to method
            [OF_rho,OF_phi,OF_epsilon]=feval(method, opticFlow,tra,sp,m,k);

            rof(k,m)=OF_rho;
            hof(k,m)=OF_phi;
            vof(k,m)=OF_epsilon;
        end  
        %disp(toc(time_header));
    % RoK 31.01.2011
        if show_waitbar
            waitbar(k/(size(tra,1)-1))
        end;
    end
    % RoK 31.01.2011
    if show_waitbar
        close(h);
    end;
end
end

function [rof,hof,vof]=Old_transform(opticFlow,tra,sp,m,k) %#ok it is used via method
        %-------------------------------------------------------------
        % now we have the optic Flow which must be transformed to 2D
        % spheric coordinates which describe horizontal and vertical
        % movement of the SP
        
        % reverse tayectory
        opticFlow=OFSubroutineYawPitchRoll(opticFlow,tra(k,4:6),true);
        
        % convert the SP to 3d vector
        spline=OFSubroutineSpToVector(sp(m,:));
        
        % to get the rotation-axis, the crossproduct of the
        % x-y components of the SP-vector and the OpticFlow is computed
% % %         spline2=spline;
% % %         spline2(3)=0;
% % %         rotax=cross(spline2, opticFlow);
% % %         % now the SP-vector is rotated by the length of OpticFlow to
% % %         % receive the new position of the SP after trajectory step.
% % %         % finaly this vector is transfomed to spheric coordinates again.
% % %         opticFlowSp=OFSubroutineVectorToSp(...
% % %                         OFSubroutineRotate(spline,rotax,norm(opticFlow)));            
% % %     

        % this version should be correct: (previous version)
        opticFlowSp=OFSubroutineVectorToSp(spline+opticFlow);    
        rof=0;
        hof=opticFlowSp(1);
        vof=opticFlowSp(2);
end

function [rof,hof,vof]=Matrix_transform(opticFlow,tra,sp,m,k) %#ok it is used via method
        %-------------------------------------------------------------
        %Now we need the optic Flow in the spherical coordinates.
        %   A vector in cartesian coordinates can be transform as one in
        %   the spherical coordinates following the transformation:
        %
        %   A_rho    =+A_x.*cos(epsilon).*cos(phi)+A_y.*cos(epsilon).*sin(phi)+A_z.*sin(epsilon);
        %   A_epsilon=-A_x.*sin(epsilon).*cos(phi)-A_y.*sin(epsilon).*sin(phi)+A_z.*cos(epsilon);
        %   A_phi    =-A_x.*sin(phi)              +A_y.*cos(phi);
        %
        %   for epsilon in [-pi/2 +pi/2] and phi in [0 2pi]
        %
        % reverse tajectory, needed because the frame x,y,z is expressed in
        % the orientation Yaw=pitch=roll=0;
        opticFlow=OFSubroutineYawPitchRoll(opticFlow,tra(k,4:6),true);
        OFT_x=opticFlow(1);
        OFT_y=opticFlow(2);
        OFT_z=opticFlow(3);
        
        epsilon     =sp(m,2);
        phi         =sp(m,1);
        rof=    +OFT_x.*cos(epsilon).*cos(phi)+OFT_y.*cos(epsilon).*sin(phi)+OFT_z.*sin(epsilon); %OFT_rho should be equal to zero
        vof=    -OFT_x.*sin(epsilon).*cos(phi)-OFT_y.*sin(epsilon).*sin(phi)+OFT_z.*cos(epsilon);
        hof=    -OFT_x.*sin(phi)              +OFT_y.*cos(phi);
end

