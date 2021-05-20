/****************************************************************************\
	Compute OFInit_CCore.cpp, Entry point of the OF_CCore. 

 How to use it:
	Compile under matlab with:
          mex OFInit_CCore.cpp OF_CCore.cpp OF_CObject.cpp
    then use as the matlab fonction:
	Distances=OFsubCalcDistances(world,Trajectory,Eye,Nb_thread)

 Input:
    - nlhs: The number of lhs (output) arguments.
    - plhs: Pointer to an array which will hold the output data,
        each element is type mxArray.
    - nrhs: The number of rhs (input) arguments.
    - prhs: Pointer to an array which holds the input data, each
        element is type const mxArray.

 here:
    prhs[i], with i=
    0   ->  Distances along the trajectory
            It is a 2D matrix, here a given row is at a given position,
                                    a given col is at a given viewing position
 
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
#include "OF_CCore.h"
/****************************************************************************\
	The function below is the entry point in matlab
\****************************************************************************/
void mexFunction(
            int nlhs, mxArray *plhs[],
            int nrhs, const mxArray *prhs[]){
/**----------------------------------**\
    Early check
\**----------------------------------**/
    if(nlhs!=1)
        mexErrMsgTxt ("OFCalcDistances_CCore::Only one output is required");
    if(nrhs!=3)
        mexErrMsgTxt ("OFCalcDistances_CCore::3 input parameters are required");
    OF_CCore* OFPointer=0;
    
    int dims[2];
    dims[0] = 1;
    dims[1] = sizeof(OF_CCore);
    plhs[0] = mxCreateNumericArray(2, dims, mxINT8_CLASS, mxREAL);
    OFPointer = (OF_CCore *)mxGetData(plhs[0]);
    OFPointer->set_model(prhs[0]);
    OFPointer->set_ommatidia(prhs[1]);
    OFPointer->set_Nb_thread(prhs[2]); 
}
