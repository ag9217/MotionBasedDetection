/****************************************************************************\
 * Optic_flow C Object function definitions
 *
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
/* Class: OF_CObject
 *
 *
 *
 *
 **/

OF_CObject::OF_CObject(){
    Vertices=0;
    Triangles=0;
    Nb_Vertices=0;
    Nb_Triangles=0;
};

OF_CObject::~OF_CObject(){
    if(Vertices!=0){
        for(int row=0;row<Nb_Vertices;row++){  delete [] Vertices[row];}
        delete [] Vertices;
    }
    if(Triangles!=0){
        for(int row=0;row<Nb_Triangles;row++){  delete [] Triangles[row];}
        delete [] Triangles;
    }
};
// Private function
void OF_CObject::set_Vertices(double * Vertices_i,int Nb_Vertices_i){
    if(Vertices!=0){
        for(int row=0;row<Nb_Vertices;row++){  delete [] Vertices[row];}
        delete [] Vertices;
    }
    Vertices=0;
    Nb_Vertices=Nb_Vertices_i;
    Vertices   =new double*[Nb_Vertices];
    for(int row=0;row<Nb_Vertices;row++){
        Vertices[row]     =new double[3];
        for(int col=0;col<3;col++){
            Vertices[row][col]    =0;
        }
    }
    
    //Populate array
    for(int V_i=0;V_i<Nb_Vertices;V_i++){
        Vertices[V_i][0]=Vertices_i[V_i+0*Nb_Vertices];
        Vertices[V_i][1]=Vertices_i[V_i+1*Nb_Vertices];
        Vertices[V_i][2]=Vertices_i[V_i+2*Nb_Vertices];
    };
    /* Note:
     * Array elements are stored in column-major format, for example, A[m + M*n] (where 0< m<M-1 and
      0<n<N-1) corresponds to matrix element A(m+1,n+1).
    */
}
void OF_CObject::set_Triangles(double * Triangles_i,int Nb_Triangles_i){
    if(Triangles!=0){
        for(int row=0;row<Nb_Triangles;row++){  delete [] Triangles[row];}
        delete [] Triangles;
    }
    Triangles=0;
    Nb_Triangles =Nb_Triangles_i;
    Triangles   =new double*[Nb_Triangles];
    for(int row=0;row<Nb_Triangles;row++){
        Triangles[row]     =new double[3];
        for(int col=0;col<3;col++){
            Triangles[row][col]    =0;
        }
    }
    //Populate array
    for(int V_i=0;V_i<Nb_Triangles;V_i++){
        Triangles[V_i][0]=Triangles_i[V_i+0*Nb_Triangles]-1;
        Triangles[V_i][1]=Triangles_i[V_i+1*Nb_Triangles]-1;
        Triangles[V_i][2]=Triangles_i[V_i+2*Nb_Triangles]-1;
    };
    /* Note:
     * Array elements are stored in column-major format, for example, A[m + M*n] (where 0< m<M-1 and
      0<n<N-1) corresponds to matrix element A(m+1,n+1).
    */   
}
void OF_CObject::set_label(string label_i){label=label_i;};
// Public function
// Mat to C loader
void OF_CObject::set_Object_fMat(const mxArray *prhs){
    //Declare variable
    const mxArray* Field;
    double* Field_ptr=0;
    const int * Field_pSize=0;
    mwSize Field_nDims;
    char Message[100];
     
    //load vertices
    string Field_name="vert";
    Field=mxGetField(prhs,0,Field_name.c_str());
    sprintf(Message,"CRITICAL:[%s] must be a member of mxArray in prhs", Field_name.c_str());
    if(Field==0)    mexErrMsgTxt(Message);
    Field_ptr   = mxGetPr(Field);
    Field_pSize = mxGetDimensions(Field);
    Field_nDims = mxGetNumberOfDimensions(Field);
    sprintf(Message,"CRITICAL:[%s] must contains two dimensions", Field_name.c_str());
    if((int)Field_nDims!=2) mexErrMsgTxt(Message);
    sprintf(Message,"CRITICAL:[%s] should be of size N*3", Field_name.c_str());
    if(Field_pSize[1]!=3) mexErrMsgTxt(Message);
    Nb_Vertices=Field_pSize[0];
    set_Vertices(Field_ptr,Nb_Vertices);
    
    //load triangles
    Field_name="tri";
    Field=mxGetField(prhs,0,Field_name.c_str());
    sprintf(Message,"CRITICAL:[%s] must be a member of mxArray in prhs", Field_name.c_str());
    if(Field==0)    mexErrMsgTxt(Message);
    Field_ptr   = mxGetPr(Field);
    Field_pSize = mxGetDimensions(Field);
    Field_nDims = mxGetNumberOfDimensions(Field);
    sprintf(Message,"CRITICAL:[%s] must contains two dimensions", Field_name.c_str());
    if((int)Field_nDims!=2) mexErrMsgTxt(Message);
    sprintf(Message,"CRITICAL:[%s] should be of size N*3", Field_name.c_str());
    if(Field_pSize[1]!=3) mexErrMsgTxt(Message);
    Nb_Triangles=Field_pSize[0];
    set_Triangles(Field_ptr,Nb_Triangles);
}

double OF_CObject::get_Point(int Trig_i,int Trig_Corner_i,int VertComponent){
    if(Trig_i>=Nb_Triangles)
        mexErrMsgTxt("Trig_i exceed Triangles 1st dimension");
    if(Trig_Corner_i>=3)
        mexErrMsgTxt("Trig_i exceed Triangles 2nd dimension");
    
    if(VertComponent>=3)
        mexErrMsgTxt("VertComponent exceed Vertices 2nd dimension");
    if(Triangles[Trig_i][Trig_Corner_i]>=Nb_Vertices)
        mexErrMsgTxt("Exceed Vertices 1st dimension");
    
    return Vertices[(int)(Triangles[Trig_i][Trig_Corner_i])][VertComponent];
}

// Basic get function
int OF_CObject::get_Nb_Vertices(){return Nb_Vertices;}
int OF_CObject::get_Nb_Triangles(){return Nb_Triangles;}
string OF_CObject::get_label(){return label;}
