/****************************************************************************\
 *
 *	Main classes of Optic flow toolbox, C++ parts
 *
 *  OF_CObject: represents an object in the world, ie vertices and triangles
 *are defines (normals are not defines, because there is no texture)
 *      It is the conversion of one structure in the world cell array (see matlab code)
 *on the creation of the world;
 *
 *  OF_CCore: is the main class of the toolbox. It contains the world information,
 *ie a list of OF_Cobject, The eye definition and the Trajectory. According to these
 *input variable, the distance can be computed, as well as the Optic flow.
 *  Both variable are ordered as: Ommatidia along the row, Position (ie Point
 *      in the trajectory) along the column
 *
 *  The function compute_distance and compute_OF are multithreaded
 *when PTHREAD is enable
 *
 *  This class can be initialised with matlab input, see OF_CalcDistances_CCore
 *for example. 
 *
\****************************************************************************/

/****************************************************************************\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright (C) 2009-2014 O.J.N. Bertrand, J.P. Lindemann
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
\****************************************************************************/

/****************************************************************************\
	Include and definition
\****************************************************************************/
#ifdef _WIN64
   //define something for Windows (64-bit)
#elif _WIN32
   //define something for Windows (32-bit)
#elif __APPLE__
    #include "TargetConditionals.h"
    #if TARGET_OS_IPHONE    
         // iOS device
    #elif TARGET_IPHONE_SIMULATOR
        // iOS Simulator
    #elif TARGET_OS_MAC
        // Other kinds of Mac OS
    #else
        // Unsupported platform
    #endif
#elif __linux
    // linux
    #define PTHREAD_ENABLE
#elif __unix // all unices not caught above
    // Unix
    #define PTHREAD_ENABLE
#elif __posix
    // POSIX
    #define PTHREAD_ENABLE
#endif


#include "mex.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <limits>
#ifdef PTHREAD_ENABLE
    #include <pthread.h>
#else
    #warning Multithreading is NOT supported
#endif
using namespace std;
class OF_CCore;
/****************************************************************************\
	OF_CObject class
\****************************************************************************/
class OF_CObject{
    private: 
        double ** Vertices;
        double ** Triangles;
        int Nb_Vertices;
        int Nb_Triangles;
        string label;
        
        void set_Vertices(double * Vertices,int Nb_Vertices);
        void set_Triangles(double * Triangles,int Nb_Triangles);        
    public:
        OF_CObject();
        ~OF_CObject();
        void set_label(string label_i);
        void set_Object_fMat(const mxArray *prhs);
        double get_Point(int Trig_i,int Trig_Corner_i,int VertComponent);
        int get_Nb_Vertices();
        int get_Nb_Triangles();
        string get_label();
};
/****************************************************************************\
	Structure for multithreading
\****************************************************************************/
struct Thread_arg{
    int Start;  //First Ommatidia
    int Stop;   //Last Ommatidia
    OF_CCore* OFCore_ptr;
    bool Verbose;               //Enable/disable verbose. (Disable if multithreaded, printf is not thread safe)
};
void* compute_distances_ThreadRun(void* ptr);
void* compute_OF_ThreadRun(void* ptr);
/****************************************************************************\
	OF_CCore class
\****************************************************************************/
class OF_CCore{
    private:
        OF_CObject* Model;
        int Nb_Object;
        double** OF_phi;        //[Nb_Ommatidia]    x [Nb_Points-1]
        double** OF_epsilon;    //[Nb_Ommatidia]    x [Nb_Points-1]
        double** Ommatidia;     //[Nb_Ommatidia]    x [2]
        double** Trajectory;    //[Nb_Points]       x [6]
        double** Distances;     //[Nb_Ommatidia]    x [Nb_Points]
        int Nb_Points;      //ie the size of the first component of trajectory
        int Nb_Ommatidia;   //ie the number of viewing direction
        int Nb_thread;
        bool distance_computed;
        bool OF_computed;
        //To compute distances
        void  Sub_compute_distances(int Ommatidia_i);
        
        //To compute Optic flow.
        void  Sub_compute_OF(int Ommatidia_i);
        
        //Init
        void init_Distances();
        void init_OF_phi_epsilon();
    public:
        OF_CCore();
        OF_CCore(int nrhs, const mxArray *prhs[]); //Matlab to C loader
        ~OF_CCore();
        
        void  compute_distances();
        void  compute_distances(Thread_arg* Thread_argument);        
        void  compute_OF();
        void  compute_OF(Thread_arg* Thread_argument);
        
        void set_model(const mxArray *prhs);
        void set_ommatidia(const mxArray *prhs);
        void set_trajectory(const mxArray *prhs);
        void set_Nb_thread(const mxArray *prhs);
        mxArray * get_Distances();
        mxArray * get_OF_phi();
        mxArray * get_OF_epsilon();
};
