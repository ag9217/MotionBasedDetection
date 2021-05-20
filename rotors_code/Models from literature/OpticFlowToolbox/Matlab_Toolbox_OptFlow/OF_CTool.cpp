/****************************************************************************\
	Tools used by the optic-flow c core
\****************************************************************************/
/****************************************************************************\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright (C) 2009-2014 O.J.N. Bertrand, J.P. Lindemann
%
%   This file is part of the Optic-Flow toolbox.
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
\****************************************************************************/
#include <math.h>
#include <limits>
//OFSubroutineSpToVector
void OFSubroutineSpToVector(double Azimuth,double Elevation,double* CartView){
    /*OFSUBROUTINESPTOVECTOR recieves a pair of spheric coordinates and
      converts them into a 3dim vector.
    %
    %Input:
    %   Azimuth
    %   Elevation
    %
    %Output:
    %   CartView a 3 matrix with the transformed coordinates
    %
    %NOTE: this is NOT the normal spheic coordinate system!
    %   spheric coordinates given as azimuth (Longitude) and
    %   zenith (Latitude) given in geographic coordinate system) in radian
    %   [pi/2 0]= [0 1 0] left, [3*pi/2 0]= [0 -1 0] right,
    %   [0 pi/2]= [0 0 1] top,  [0 -pi/2]= [0 0 -1] bottom
    */
    
    CartView[0]=cos(Elevation)*cos(Azimuth);
    CartView[1]=cos(Elevation)*sin(Azimuth);
    CartView[2]=sin(Elevation);
};

void OFSubroutineVectorToSp(double &Azimuth,double &Elevation,const double* CartView){
    /*OFSUBROUTINEVECTORTOSP converts an 3dim vector to spheric coordinates
    %
    %Input:
    %   CartView a 3 matrix with the transformed coordinates
    %
    %Output:
    %    Azimuth
    %    Elevation
    %
    %NOTE: this is NOT the normal spheic coordinate system!
    %   azimuth (Longitude) 
    %   zenith (Latitude) given in geographic coordinate system in radian
    %   [pi/2 0]= [0 1 0] left, [3*pi/2 0]= [0 -1 0] right,
    %   [0 pi/2]= [0 0 1] top,  [0 -pi/2]= [0 0 -1] bottom
    */
    Azimuth=0;
    Elevation=0;
    double pi=M_PI;
    // to prevent a devision by 0:
    if(!(CartView[0]==0 && CartView[1]==0)){
        // to prevent of geting an negative azimuth angle:
        if(CartView[1]>=0){
            Azimuth=acos(CartView[0]/sqrt(CartView[0]*CartView[0]+CartView[1]*CartView[1]));
        }
        else{
            Azimuth=2*pi-acos(CartView[0]/sqrt(CartView[0]*CartView[0]+CartView[1]*CartView[1]));
        }
        Elevation=atan(CartView[2]/sqrt(CartView[0]*CartView[0]+CartView[1]*CartView[1]));
    }
    else{ // x and y coordinates of vector are 0 so:
        Azimuth=0;
        Elevation=(2*(CartView[2]>=0-1))*pi/2;
    }
};
//OFSubroutineRotate
void OFSubroutineRotate(const double* vector_i,double* rotAx,double alpha,double* RotatedVector ){
    /*
    %OFSUBROUTINEROTATE rotates the given vector through the rotAxis as
    %UNIT-vector
    % 
    %Input:
    %   vector - 3D  vectors to rotate
    %   rotAx - the axis to rotate around
    %   alpha - the angle to rotate in radian
    %
    %Output:
    %   RotatedVector - the rotated vectors in the input matrix
    */
    double vector_copy[3];
    vector_copy[0]=vector_i[0];
    vector_copy[1]=vector_i[1];
    vector_copy[2]=vector_i[2];
    // scaling the axis to unit vector
    double NormAx=sqrt(rotAx[0]*rotAx[0]+
                       rotAx[1]*rotAx[1]+
                       rotAx[2]*rotAx[2]);
    rotAx[0]=rotAx[0]/NormAx;
    rotAx[1]=rotAx[1]/NormAx;
    rotAx[2]=rotAx[2]/NormAx;

    // this is an rotation matrix:
    double RotMatrix[3][3];
    RotMatrix[0][0]=cos(alpha)+(rotAx[0]*rotAx[0])*(1-cos(alpha));
    RotMatrix[0][1]=rotAx[0]*rotAx[1]*(1-cos(alpha))-rotAx[2]*sin(alpha);
    RotMatrix[0][2]=rotAx[0]*rotAx[2]*(1-cos(alpha))+rotAx[1]*sin(alpha);
    
    RotMatrix[1][0]=rotAx[1]*rotAx[0]*(1-cos(alpha))+rotAx[2]*sin(alpha);
    RotMatrix[1][1]=cos(alpha)+(rotAx[1]*rotAx[1])*(1-cos(alpha));
    RotMatrix[1][2]=rotAx[1]*rotAx[2]*(1-cos(alpha))-rotAx[0]*sin(alpha);
    
    RotMatrix[2][0]=rotAx[2]*rotAx[0]*(1-cos(alpha))-rotAx[1]*sin(alpha);
    RotMatrix[2][1]=rotAx[2]*rotAx[1]*(1-cos(alpha))+rotAx[0]*sin(alpha);
    RotMatrix[2][2]=cos(alpha)+(rotAx[2]*rotAx[2])*(1-cos(alpha));
    
    // Rotated Vector =RotMatrix*Vector
    RotatedVector[0]=RotMatrix[0][0]*vector_copy[0]
                +RotMatrix[0][1]*vector_copy[1]
                +RotMatrix[0][2]*vector_copy[2];
    RotatedVector[1]=RotMatrix[1][0]*vector_copy[0]
                +RotMatrix[1][1]*vector_copy[1]
                +RotMatrix[1][2]*vector_copy[2];
    RotatedVector[2]=RotMatrix[2][0]*vector_copy[0]
                +RotMatrix[2][1]*vector_copy[1]
                +RotMatrix[2][2]*vector_copy[2];
};

void OFSubroutineYawPitchRoll(const double*CartView,double*YawPitchRoll,bool inverse, double*TransCartView){
    /*OFSUBROUTINEYAWPITCHROLL applies yaw pitch and roll to a vector
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
     *
     *
     */
    double CartView_copy[3];
    CartView_copy[0]=CartView[0];
    CartView_copy[1]=CartView[1];
    CartView_copy[2]=CartView[2];
    
    
    double XRotAx[3];
    double YRotAx[3];
    double ZRotAx[3];
    double CRotAx[3];
    XRotAx[0]=1;    XRotAx[1]=0;    XRotAx[2]=0;
    YRotAx[0]=0;    YRotAx[1]=1;    YRotAx[2]=0;
    ZRotAx[0]=0;    ZRotAx[1]=0;    ZRotAx[2]=1;
    if (inverse==true){
        OFSubroutineRotate(CartView_copy,XRotAx,-YawPitchRoll[2],TransCartView);
        OFSubroutineRotate(YRotAx,XRotAx,-YawPitchRoll[2],CRotAx);
        OFSubroutineRotate(TransCartView,CRotAx,-YawPitchRoll[1],TransCartView);
        OFSubroutineRotate(ZRotAx,XRotAx,-YawPitchRoll[2],CRotAx);
        OFSubroutineRotate(CRotAx,YRotAx,-YawPitchRoll[1],CRotAx);
        OFSubroutineRotate(TransCartView,CRotAx,-YawPitchRoll[0],TransCartView);
    }
    else{
        OFSubroutineRotate(CartView_copy,ZRotAx,+YawPitchRoll[0],TransCartView);
        OFSubroutineRotate(YRotAx,ZRotAx,+YawPitchRoll[0],CRotAx);
        OFSubroutineRotate(TransCartView,CRotAx,+YawPitchRoll[1],TransCartView);
        OFSubroutineRotate(XRotAx,ZRotAx,+YawPitchRoll[0],CRotAx);
        OFSubroutineRotate(CRotAx,YRotAx,+YawPitchRoll[1],CRotAx);
        OFSubroutineRotate(TransCartView,CRotAx,+YawPitchRoll[2],TransCartView);
    }
}



