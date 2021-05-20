/****************************************************************************\
 *  OF_CCore.cpp is the code file of the main class OF_CCore of the Optic
 *flow toolbox for its C++ part.
 *
 *  See OF_CCore.h for more details
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
#include "OF_CTool.cpp"
#include <sstream>
/*--------------------------------------------------------*\
                      PThread:
\*--------------------------------------------------------*/
void* compute_distances_ThreadRun(void* ptr){

    //Convert pointer to Thread_arg struct
    Thread_arg* Thread_argument;
    Thread_argument=(Thread_arg*)ptr;
    Thread_argument->Verbose=false;
    Thread_argument->OFCore_ptr->compute_distances(Thread_argument);
}
void* compute_OF_ThreadRun(void* ptr){
    //Convert pointer to Thread_arg struct
    Thread_arg* Thread_argument;
    Thread_argument=(Thread_arg*)ptr;
    Thread_argument->Verbose=false;
    Thread_argument->OFCore_ptr->compute_OF(Thread_argument);
}


/*--------------------------------------------------------*\
                      Constructor:
\*--------------------------------------------------------*/
// Default constructor
OF_CCore::OF_CCore(){
    Model=0;
    OF_phi=0;        //[Nb_Ommatidia]    x [Nb_Points]
    OF_epsilon=0;    //[Nb_Ommatidia]    x [Nb_Points]
    Ommatidia=0;     //[Nb_Ommatidia]    x [2]
    Trajectory=0;    //[Nb_Points]       x [6]
    Distances=0;     //[Nb_Ommatidia]    x [Nb_Points]
    Nb_Points=0;      //ie the size of the first component of trajectory
    Nb_Ommatidia=0;   //ie the number of viewing direction
    Nb_thread=0;
    distance_computed=false;
    OF_computed=false;
};
// Constructor with matlab parameters
OF_CCore::OF_CCore(int nrhs, const mxArray *prhs[]){
    /* Parameters:
     * 0->model: A cell array, with structure in each cell
       1->tra:   A Tx6 matrix, T is time, 6col are X,Y,Z,Yaw,Pitch,Roll
       2->sp:    A Sx2 matrix, S is the number of viewing direction
                        the 2 column are Azimuth, Elevation respectivly
       3->Nb_thread: An integer for multithreading
    */
    //Check number of paramters
    if(nrhs!=4)
        mexErrMsgTxt ("OFCalcDistances_CCore::4 input parameters are required");
    //Init to zero
    Model=0;
    OF_phi=0;        //[Nb_Ommatidia]    x [Nb_Points]
    OF_epsilon=0;    //[Nb_Ommatidia]    x [Nb_Points]
    Ommatidia=0;     //[Nb_Ommatidia]    x [2]
    Trajectory=0;    //[Nb_Points]       x [6]
    Distances=0;     //[Nb_Ommatidia]    x [Nb_Points]
    Nb_Points=0;      //ie the size of the first component of trajectory
    Nb_Ommatidia=0;   //ie the number of viewing direction
    Nb_thread=0;
    distance_computed=false;
    OF_computed=false;
    
    //Populate with mxArray
    set_model(prhs[0]);
    set_trajectory(prhs[1]);
    set_ommatidia(prhs[2]);
    set_Nb_thread(prhs[3]);    
};

/*--------------------------------------------------------*\
                      Destructor:
\*--------------------------------------------------------*/
OF_CCore::~OF_CCore(){
    if(Model!=0){
        Model->~OF_CObject();
    }
    if(OF_phi!=0){
        for(int row=0;row<Nb_Ommatidia;row++){  delete [] OF_phi[row];}
        delete [] OF_phi;
    }
    if(OF_epsilon!=0){
        for(int row=0;row<Nb_Ommatidia;row++){  delete [] OF_epsilon[row];}
        delete [] OF_epsilon;
    }
    if(Ommatidia!=0){
        for(int row=0;row<Nb_Ommatidia;row++){  delete [] Ommatidia[row];}
        delete [] Ommatidia;
    }
    if(Distances!=0){
        for(int row=0;row<Nb_Ommatidia;row++){  delete [] Distances[row];}
        delete [] Distances;
    }
    if(Trajectory!=0){
        for(int row=0;row<Nb_Points;row++){  delete [] Trajectory[row];}
        delete [] Trajectory;
    }
};
/*--------------------------------------------------------*\
                      Init distances
\*--------------------------------------------------------*/
void OF_CCore::init_Distances(){
    if(Distances!=0){
        for(int row=0;row<Nb_Ommatidia;row++){  delete [] Distances[row];}
        delete [] Distances;
        Distances=0;
    }
    if(Nb_Ommatidia>0 && Nb_Points>0){
        Distances   =new double*[Nb_Ommatidia];
        for(int row=0;row<Nb_Ommatidia;row++){
            Distances[row]  =new double[Nb_Points];
            for(int col=0;col<Nb_Points;col++){
                Distances[row][col] =INFINITY;
            }
        }
    }
}
void OF_CCore::init_OF_phi_epsilon(){
    if(OF_phi!=0){
        for(int row=0;row<Nb_Ommatidia;row++){  delete [] OF_phi[row];}
        delete [] OF_phi;
        OF_phi=0;
    }
    if(OF_epsilon!=0){
        for(int row=0;row<Nb_Ommatidia;row++){  delete [] OF_epsilon[row];}
        delete [] OF_epsilon;
        OF_epsilon=0;
    }
    if(Nb_Ommatidia>0 && (Nb_Points-1)>0){
        OF_phi      =new double*[Nb_Ommatidia];
        OF_epsilon  =new double*[Nb_Ommatidia];
        for(int row=0;row<Nb_Ommatidia;row++){
            OF_phi[row]     =new double[Nb_Points-1];
            OF_epsilon[row] =new double[Nb_Points-1];
            for(int col=0;col<(Nb_Points-1);col++){
                OF_phi[row][col]    =0;
                OF_epsilon[row][col]=0;
            }
        }
    }
}
/*--------------------------------------------------------*\
                      Compute distances
\*--------------------------------------------------------*/
void OF_CCore::compute_distances(){
    if(distance_computed)
        return;
    if(Nb_thread<=1){
        Thread_arg Thread_argument;
        Thread_argument.Start=0;
        Thread_argument.Stop=Nb_Ommatidia;
        Thread_argument.OFCore_ptr=this;
        compute_distances(&Thread_argument);
    }
    else{
        #ifdef PTHREAD_ENABLE
            //Init Thread variable
            int SubThreadPop=floor(Nb_Ommatidia/Nb_thread)+1;
            Thread_arg Thread_argument[Nb_thread]; //Thread argument
            pthread_t pThread[Nb_thread];       //Array of thread (Nbr_of_Thread is the maximum number of running thread)
            int iThread[Nb_thread];             //Array of thread id
            //Populate Thread_arguments
            for(int Th_i=0;Th_i<Nb_thread;Th_i++){
                //Sub population range (Note that it's the only difference between two thread)
                Thread_argument[Th_i].Start=Th_i*SubThreadPop;
                Thread_argument[Th_i].Stop=(Th_i+1)*SubThreadPop;
                if(Thread_argument[Th_i].Stop>Nb_Ommatidia)
                    Thread_argument[Th_i].Stop=Nb_Ommatidia; //The last thread could have a smaller subpopulation
                Thread_argument[Th_i].OFCore_ptr=this;
            }
            //Run 
            //Create thread
            for(int Th_i=0;Th_i<Nb_thread;Th_i++){
                    iThread[Th_i]=pthread_create( &pThread[Th_i], NULL, compute_distances_ThreadRun, (void*)&Thread_argument[Th_i]);	
            }
            //wait thread
            for(int Th_i=0;Th_i<Nb_thread ;Th_i++){
                    pthread_join( pThread[Th_i], NULL);
            }
            //clean
            for(int Th_i=0;Th_i<Nb_thread ;Th_i++){
                    pThread[Th_i]=0;
                    iThread[Th_i]=0;
            }
         #else //Multithreading is not enable
            Nb_thread=1;
            Thread_arg Thread_argument;
            Thread_argument.Start=0;
            Thread_argument.Stop=Nb_Ommatidia;
            compute_distances(&Thread_argument);
         #endif                    
    }
    distance_computed=true;
};
//compute_distances for a given Thread_arg
void OF_CCore::compute_distances(Thread_arg* Thread_argument){
    int status;  
    for(int Ommatidia_i=Thread_argument->Start;Ommatidia_i<Thread_argument->Stop;Ommatidia_i++){
        Sub_compute_distances(Ommatidia_i);
    }
}
//Compute Distance along a trajectory for a given Ommatidia
void OF_CCore::Sub_compute_distances(int Ommatidia_i){
    //** Declare Variable
    //For Spline
    double spTr[3];
    double YawPitchRoll[3];
    double XYZ_trans[3];
    double Azimuth;
    double Elevation;
    //For Distnace computation
    double invA[3][3];
    double a,b,c,d,e,f,g,h,k;
    double Determinant=0;
    double IntersectPoint[3];
    double spDist=INFINITY;
    //For current Object
    OF_CObject* CurrentObject=0;
    //Loop on point in the trajectory    
    for(int Point_i=0;Point_i<Nb_Points;Point_i++){
        //Convert Ommatidia to spline
        XYZ_trans[0]=Trajectory[Point_i][0];
        XYZ_trans[1]=Trajectory[Point_i][1];
        XYZ_trans[2]=Trajectory[Point_i][2];
        YawPitchRoll[0]=Trajectory[Point_i][3];
        YawPitchRoll[1]=Trajectory[Point_i][4];
        YawPitchRoll[2]=Trajectory[Point_i][5];
        OFSubroutineSpToVector(Ommatidia[Ommatidia_i][0],
                               Ommatidia[Ommatidia_i][1], spTr);
        OFSubroutineYawPitchRoll(spTr,YawPitchRoll,false,spTr);        
        //Loop on Object
        spDist=INFINITY; //Init distance to infinity
        for(int Object_i=0;Object_i<Nb_Object;Object_i++){
            CurrentObject=&Model[Object_i];
            //Loop on Triangle in the model
            for(int Trig_i=0;Trig_i<CurrentObject->get_Nb_Triangles();Trig_i++){
                //Populate matrix A as:
                //      a b c
                //  A=  d e f
                //      g h k
                a=-CurrentObject->get_Point(Trig_i,0,0)
                  +CurrentObject->get_Point(Trig_i,1,0);
                d=-CurrentObject->get_Point(Trig_i,0,0)
                  +CurrentObject->get_Point(Trig_i,2,0);
                g=-spTr[0];

                b=-CurrentObject->get_Point(Trig_i,0,1)
                  +CurrentObject->get_Point(Trig_i,1,1);
                e=-CurrentObject->get_Point(Trig_i,0,1)
                  +CurrentObject->get_Point(Trig_i,2,1);
                h=-spTr[1];

                c=-CurrentObject->get_Point(Trig_i,0,2)
                  +CurrentObject->get_Point(Trig_i,1,2);
                f=-CurrentObject->get_Point(Trig_i,0,2)
                  +CurrentObject->get_Point(Trig_i,2,2);
                k=-spTr[2];
                
                //Compute determinant
                Determinant=a*(e*k-f*h)-b*(k*d-f*g)+c*(d*h-e*g);
                if(abs(Determinant)>0.001){ //ie A can be inverted
                    invA[0][0] =  (e*k-f*h)/Determinant;
                    invA[0][1] =  (f*g-d*k)/Determinant;
                    invA[0][2] =  (d*h-e*g)/Determinant;
                    invA[1][0] =  (c*h-b*k)/Determinant;
                    invA[1][1] =  (a*k-c*g)/Determinant;
                    invA[1][2] =  (g*b-a*h)/Determinant;
                    invA[2][0] =  (b*f-c*e)/Determinant;
                    invA[2][1] =  (c*d-a*f)/Determinant;
                    invA[2][2] =  (a*e-b*d)/Determinant;
                    
                    IntersectPoint[0]=invA[0][0]*(-CurrentObject->get_Point(Trig_i,0,0)+XYZ_trans[0])
                                     +invA[0][1]*(-CurrentObject->get_Point(Trig_i,0,1)+XYZ_trans[1])
                                     +invA[0][2]*(-CurrentObject->get_Point(Trig_i,0,2)+XYZ_trans[2]);
                    IntersectPoint[1]=invA[1][0]*(-CurrentObject->get_Point(Trig_i,0,0)+XYZ_trans[0])
                                     +invA[1][1]*(-CurrentObject->get_Point(Trig_i,0,1)+XYZ_trans[1])
                                     +invA[1][2]*(-CurrentObject->get_Point(Trig_i,0,2)+XYZ_trans[2]);
                    IntersectPoint[2]=invA[2][0]*(-CurrentObject->get_Point(Trig_i,0,0)+XYZ_trans[0])
                                     +invA[2][1]*(-CurrentObject->get_Point(Trig_i,0,1)+XYZ_trans[1])
                                     +invA[2][2]*(-CurrentObject->get_Point(Trig_i,0,2)+XYZ_trans[2]);
                    if((IntersectPoint[0]>=0)&&
                       (IntersectPoint[1]>=0)&&
                       (IntersectPoint[2]>=0)&&
                       (IntersectPoint[0]+IntersectPoint[1]<=1)){
                       spDist=std::min(spDist,IntersectPoint[2]);
                    }
                }//End check Determinant
            }//End loop triangles
        }//End loop on Object
        Distances[Ommatidia_i][Point_i]=spDist;
    }//End loop on trajectory
}
/*--------------------------------------------------------*\
                      Compute Opticflow
\*--------------------------------------------------------*/
void OF_CCore::compute_OF(){
    if(OF_computed)
        return;
    if(~distance_computed)
        compute_distances();    //Distance are required to compute OF
    if(Nb_thread<=1){
        Thread_arg Thread_argument;
        Thread_argument.Start=0;
        Thread_argument.Stop=Nb_Ommatidia;
        compute_OF(&Thread_argument);
    }
    else{
        #ifdef PTHREAD_ENABLE
            //Init Thread variable
            int SubThreadPop=floor(Nb_Ommatidia/Nb_thread)+1;
            Thread_arg Thread_argument[Nb_thread]; //Thread argument
            pthread_t pThread[Nb_thread];       //Array of thread (Nbr_of_Thread is the maximum number of running thread)
            int iThread[Nb_thread];             //Array of thread id
            //Populate Thread_arguments
            for(int Th_i=0;Th_i<Nb_thread;Th_i++){
                //Sub population range (Note that it's the only difference between two thread)
                Thread_argument[Th_i].Start=Th_i*SubThreadPop;
                Thread_argument[Th_i].Stop=(Th_i+1)*SubThreadPop;
                if(Thread_argument[Th_i].Stop>Nb_Ommatidia)
                    Thread_argument[Th_i].Stop=Nb_Ommatidia; //The last thread could have a smaller subpopulation
                Thread_argument[Th_i].OFCore_ptr=this;
            }
            //Run 
            //Create thread
            for(int Th_i=0;Th_i<Nb_thread;Th_i++){
                    iThread[Th_i]=pthread_create( &pThread[Th_i], NULL, compute_OF_ThreadRun, (void*)&Thread_argument[Th_i]);	
            }	
            //wait thread
            for(int Th_i=0;Th_i<Nb_thread ;Th_i++){
                    pthread_join( pThread[Th_i], NULL);
            }
            //clean
            for(int Th_i=0;Th_i<Nb_thread ;Th_i++){
                    pThread[Th_i]=0;
                    iThread[Th_i]=0;
            }
         #else //Multithreading is not enable
            Nb_thread=1;
            Thread_arg Thread_argument;
            Thread_argument.Start=0;
            Thread_argument.Stop=Nb_Ommatidia;
            compute_OF(&Thread_argument);
         #endif                    
    }
    OF_computed=true;
};
//compute_distances for a given Thread_arg
void OF_CCore::compute_OF(Thread_arg* Thread_argument){
    int status;  
    for(int Ommatidia_i=Thread_argument->Start;Ommatidia_i<Thread_argument->Stop;Ommatidia_i++){
        Sub_compute_OF(Ommatidia_i);
    }
}
void OF_CCore::Sub_compute_OF(int Ommatidia_i){
    //** Declare Variable
    //For Spline
    double rYaw[3];
    double rRoll[3];
    double rPitch[3];
    double UnitTransVector[3];
    double Vec1[3];
    double Vec2[3];
    double VecNow[3];
    double VecNext[3];
    double spline[3];
    double Speed,CDistance,tmp;
    double opticFlowT[3];
    //For current Object
    OF_CObject* CurrentObject=0;
    //Loop on point in the trajectory    
    for(int Point_i=0;Point_i<Nb_Points-1;Point_i++){
        // check if one rotation (yaw, pitch, or roll) exceeds pi/2
        if(abs(Trajectory[Point_i][3]-Trajectory[Point_i+1][3])>M_PI/2 ||
           abs(Trajectory[Point_i][4]-Trajectory[Point_i+1][4])>M_PI/2 ||
           abs(Trajectory[Point_i][5]-Trajectory[Point_i+1][5])>M_PI/2 ){
            mexErrMsgTxt("one trayectory rotation exceeds 90deg, computation aborted");
        }
        //Compute TranVector
        UnitTransVector[0]=Trajectory[Point_i+1][0]-Trajectory[Point_i][0];
        UnitTransVector[1]=Trajectory[Point_i+1][1]-Trajectory[Point_i][1];
        UnitTransVector[2]=Trajectory[Point_i+1][2]-Trajectory[Point_i][2];
        Speed=sqrt(  UnitTransVector[0]*UnitTransVector[0]
                    +UnitTransVector[1]*UnitTransVector[1]
                    +UnitTransVector[2]*UnitTransVector[2]);
        if(Speed==0){
            UnitTransVector[0]=0;
            UnitTransVector[1]=0;
            UnitTransVector[2]=0;
        }
        else{
            UnitTransVector[0]=UnitTransVector[0]/Speed;
            UnitTransVector[1]=UnitTransVector[1]/Speed;
            UnitTransVector[2]=UnitTransVector[2]/Speed;
        }
        /*
        % yaw pitch roll need to be computed seperatly
        % the CrossProduct determines the MAXIMAL ROTATION of 90� per
        % trajectory step!
        % rotation around z-axis
         */
        Vec1[0]=1;                          Vec1[1]=0;  Vec1[2]=0;
        Vec2[0]=Trajectory[Point_i][3];     Vec2[1]=0;  Vec2[2]=0;
        OFSubroutineYawPitchRoll(Vec1,Vec2,false,VecNow);
        Vec1[0]=1;                          Vec1[1]=0;  Vec1[2]=0;
        Vec2[0]=Trajectory[Point_i+1][3];   Vec2[1]=0;  Vec2[2]=0;
        OFSubroutineYawPitchRoll(Vec1,Vec2,false,VecNext);
        //Cross product between VecNow and VecNext;
        rYaw[0]=VecNow[1]*VecNext[2]-VecNow[2]*VecNext[1];
        rYaw[1]=VecNow[2]*VecNext[0]-VecNow[0]*VecNext[2];
        rYaw[2]=VecNow[0]*VecNext[1]-VecNow[1]*VecNext[0];
        
        // now rotation around y-axis
        Vec1[0]=1;  Vec1[1]=0;                      Vec1[2]=0;
        Vec2[0]=0;  Vec2[1]=Trajectory[Point_i][4]; Vec2[2]=0;
        OFSubroutineYawPitchRoll(Vec1,Vec2,false,VecNow);
        Vec1[0]=1;  Vec1[1]=0;                          Vec1[2]=0;
        Vec2[0]=0;  Vec2[1]=Trajectory[Point_i+1][4];   Vec2[2]=0;
        OFSubroutineYawPitchRoll(Vec1,Vec2,false,VecNext);
        //Cross product between VecNow and VecNext;
        rPitch[0]=VecNow[1]*VecNext[2]-VecNow[2]*VecNext[1];
        rPitch[1]=VecNow[2]*VecNext[0]-VecNow[0]*VecNext[2];
        rPitch[2]=VecNow[0]*VecNext[1]-VecNow[1]*VecNext[0];
        
        //and roatation around x-baxis
        Vec1[0]=0;  Vec1[1]=0; Vec1[2]=1;
        Vec2[0]=0;  Vec2[1]=0; Vec2[2]=Trajectory[Point_i][5];
        OFSubroutineYawPitchRoll(Vec1,Vec2,false,VecNow);
        Vec1[0]=0;  Vec1[1]=0; Vec1[2]=1;
        Vec2[0]=0;  Vec2[1]=0; Vec2[2]=Trajectory[Point_i+1][5];
        OFSubroutineYawPitchRoll(Vec1,Vec2,false,VecNext);
        //Cross product between VecNow and VecNext;
        rRoll[0]=VecNow[1]*VecNext[2]-VecNow[2]*VecNext[1];
        rRoll[1]=VecNow[2]*VecNext[0]-VecNow[0]*VecNext[2];
        rRoll[2]=VecNow[0]*VecNext[1]-VecNow[1]*VecNext[0];
        
        //If there no optic flow
        if(Distances[Ommatidia_i][Point_i]==INFINITY){
            OF_phi[Ommatidia_i][Point_i]=0;
            OF_epsilon[Ommatidia_i][Point_i]=0;
        }
        else{
            OFSubroutineSpToVector( Ommatidia[Ommatidia_i][0],
                                    Ommatidia[Ommatidia_i][1],spline);
            Vec1[0]=Trajectory[Point_i][3];  
            Vec1[1]=Trajectory[Point_i][4]; 
            Vec1[2]=Trajectory[Point_i][5];
            OFSubroutineYawPitchRoll(spline, Vec1,false,spline);             
            // p =the distance to next object
            CDistance=Distances[Ommatidia_i][Point_i];
            if(CDistance<=0) CDistance;
            
            //Compute Translational optic flow
            //opticFlowT=-(v*u-(v*u*d')*d)/p; for the translation part
            tmp=UnitTransVector[0]*spline[0]
               +UnitTransVector[1]*spline[1]
               +UnitTransVector[2]*spline[2];     
            opticFlowT[0]=-(Speed/CDistance)*(UnitTransVector[0]-tmp*spline[0]);
            opticFlowT[1]=-(Speed/CDistance)*(UnitTransVector[1]-tmp*spline[1]);
            opticFlowT[2]=-(Speed/CDistance)*(UnitTransVector[2]-tmp*spline[2]);
            
            //Add Rotational optic flow
            //check if there actualy is a rotation and if compute
            // surface-normal and scale it with angle between vectors
            // negative because flow relative to observer
            //Add Optic flow due to Yaw rotation
            tmp=sqrt(rYaw[0]*rYaw[0]
                    +rYaw[1]*rYaw[1]
                    +rYaw[2]*rYaw[2]);
            if(tmp>0.000001){ //if the rotation is not too small
                Vec1[0]=rYaw[0]/(tmp*asin(tmp));
                Vec1[1]=rYaw[1]/(tmp*asin(tmp));
                Vec1[2]=rYaw[2]/(tmp*asin(tmp));
                //The following is done:
                //opticFlowRyaw=-cross(rYawN,d);
                //opticFlowT=opticFlowT+opticFlowRyaw
                //--
                opticFlowT[0]-=Vec1[1]*spline[2]-Vec1[2]*spline[1];
                opticFlowT[1]-=Vec1[2]*spline[0]-Vec1[0]*spline[2];
                opticFlowT[2]-=Vec1[0]*spline[1]-Vec1[1]*spline[0];
            }
            //Add Optic flow due to Ptuch rotation
            tmp=sqrt(rPitch[0]*rPitch[0]
                    +rPitch[1]*rPitch[1]
                    +rPitch[2]*rPitch[2]);
            if(tmp>0.000001){ //if the rotation is not too small
                Vec1[0]=rPitch[0]/(tmp*asin(tmp));
                Vec1[1]=rPitch[1]/(tmp*asin(tmp));
                Vec1[2]=rPitch[2]/(tmp*asin(tmp));
                //The following is done:
                //opticFlowRyaw=-cross(rYawN,d);
                //opticFlowT=opticFlowT+opticFlowRyaw
                //--
                opticFlowT[0]-=Vec1[1]*spline[2]-Vec1[2]*spline[1];
                opticFlowT[1]-=Vec1[2]*spline[0]-Vec1[0]*spline[2];
                opticFlowT[2]-=Vec1[0]*spline[1]-Vec1[1]*spline[0];
            }       
            //Add Optic flow due to Roll rotation
            tmp=sqrt(rRoll[0]*rRoll[0]
                    +rRoll[1]*rRoll[1]
                    +rRoll[2]*rRoll[2]);
            if(tmp>0.000001){ //if the rotation is not too small
                Vec1[0]=rRoll[0]/(tmp*asin(tmp));
                Vec1[1]=rRoll[1]/(tmp*asin(tmp));
                Vec1[2]=rRoll[2]/(tmp*asin(tmp));
                //The following is done:
                //opticFlowRyaw=-cross(rYawN,d);
                //opticFlowT=opticFlowT+opticFlowRyaw
                //--
                opticFlowT[0]-=Vec1[1]*spline[2]-Vec1[2]*spline[1];
                opticFlowT[1]-=Vec1[2]*spline[0]-Vec1[0]*spline[2];
                opticFlowT[2]-=Vec1[0]*spline[1]-Vec1[1]*spline[0];
            }
            //Convert Optic flow from Cartesian coordinates to Spherical coordinates
            Vec1[0]=Trajectory[Point_i][3];  
            Vec1[1]=Trajectory[Point_i][4]; 
            Vec1[2]=Trajectory[Point_i][5];
            OFSubroutineYawPitchRoll(opticFlowT,Vec1,true,opticFlowT);
            
            /** Note 
             The equivalent of that
                rof=    +OFT_x.*cos(epsilon).*cos(phi)+OFT_y.*cos(epsilon).*sin(phi)+OFT_z.*sin(epsilon); %OFT_rho should be equal to zero
                vof=    -OFT_x.*sin(epsilon).*cos(phi)-OFT_y.*sin(epsilon).*sin(phi)+OFT_z.*cos(epsilon);
                hof=    -OFT_x.*sin(phi)              +OFT_y.*cos(phi);
             *is done below
             **/            
            OF_phi[Ommatidia_i][Point_i]=   -opticFlowT[0]*sin(Ommatidia[Ommatidia_i][0])
                                            +opticFlowT[1]*cos(Ommatidia[Ommatidia_i][0]);
            OF_epsilon[Ommatidia_i][Point_i]=   -opticFlowT[0]*sin(Ommatidia[Ommatidia_i][1])*cos(Ommatidia[Ommatidia_i][0])
                                                -opticFlowT[1]*sin(Ommatidia[Ommatidia_i][1])*sin(Ommatidia[Ommatidia_i][0])
                                                +opticFlowT[2]*cos(Ommatidia[Ommatidia_i][1]);
        }//End if condition
    }//End for on Trajectory
}

/*--------------------------------------------------------*\
                      Set/get Function
\*--------------------------------------------------------*/
void OF_CCore::set_model(const mxArray *Field){
    if(Model!=0){
        Model->~OF_CObject();
    }
    //Populate with mxArray
    double* Field_ptr=0;
    const int * Field_pSize=0;
    mwSize Field_nDims;
    char Message[100];
    std::string Field_name;
    
    //Model here
    if (!mxIsCell(Field))
        mexErrMsgTxt ("First paramter should be a cell, prhs[0] is not");
    Nb_Object=mxGetNumberOfElements(Field);
    Model=new OF_CObject[Nb_Object];
    mxArray* CObject;
    mxArray* subField=0;
    int Nb_vert;
    for (int Object_i = 0; Object_i < Nb_Object; Object_i++){
        CObject=mxGetCell(Field, Object_i);
        stringstream ss;//create a stringstream
        ss << Object_i;//add number to the stream
        Model[Object_i].set_label(ss.str()); //set label name for current Object
        Model[Object_i].set_Object_fMat(CObject); //Load Object
    }
    distance_computed=false;
    OF_computed=false;
}
void OF_CCore::set_ommatidia(const mxArray *Field){
    if(Ommatidia!=0){
        for(int row=0;row<Nb_Ommatidia;row++){  delete [] Ommatidia[row];}
        delete [] Ommatidia;
    }
    //Populate with mxArray
    double* Field_ptr=0;
    const int * Field_pSize=0;
    mwSize Field_nDims;
    char Message[100];
    std::string Field_name;
    
    int Nb_Ommatidia_old=Nb_Ommatidia;
    //Ommatidia here
    Field_name="Ommatidia";
    Field_ptr   = mxGetPr(Field);
    Field_pSize = mxGetDimensions(Field);
    Field_nDims = mxGetNumberOfDimensions(Field);
    sprintf(Message,"CRITICAL:[%s] must contains no more than two dimensions", Field_name.c_str());
    if((int)Field_nDims>2) mexErrMsgTxt(Message);
    sprintf(Message,"CRITICAL:[%s] should be of size N*2", Field_name.c_str());
    if(Field_pSize[1]!=2) mexErrMsgTxt(Message);
    Nb_Ommatidia=Field_pSize[0];
    Ommatidia=new double*[Field_pSize[0]];
    for(int row=0;row<Field_pSize[0];row++){
        Ommatidia[row]=new double[Field_pSize[1]];
        for(int col=0;col<Field_pSize[1];col++){
            Ommatidia[row][col]=Field_ptr[row+col*Field_pSize[0]];
        }
    }
    if(Nb_Ommatidia_old!=Nb_Ommatidia){
        init_Distances();
        init_OF_phi_epsilon();
    }
    distance_computed=false;
    OF_computed=false;
}
void OF_CCore::set_trajectory(const mxArray *Field){
    if(Trajectory!=0){
        for(int row=0;row<Nb_Points;row++){  delete [] Trajectory[row];}
        delete [] Trajectory;
    }
    //Populate with mxArray
    double* Field_ptr=0;
    const int * Field_pSize=0;
    mwSize Field_nDims;
    char Message[100];
    std::string Field_name;
    int Nb_Points_old=Nb_Points;
    //Trajectory here
    Field_name="Trajectory";
    Field_ptr   = mxGetPr(Field);
    Field_pSize = mxGetDimensions(Field);
    Field_nDims = mxGetNumberOfDimensions(Field);
    sprintf(Message,"CRITICAL:[%s] must contains no more than two dimensions", Field_name.c_str());
    if((int)Field_nDims>2) mexErrMsgTxt(Message);
    sprintf(Message,"CRITICAL:[%s] should be of size N*6", Field_name.c_str());
    if(Field_pSize[1]!=6) mexErrMsgTxt(Message);
    Nb_Points=Field_pSize[0];
    Trajectory=new double*[Field_pSize[0]];
    for(int row=0;row<Field_pSize[0];row++){
        Trajectory[row]=new double[Field_pSize[1]];
        for(int col=0;col<Field_pSize[1];col++){
            Trajectory[row][col]=Field_ptr[row+col*Field_pSize[0]];
        }
    }
    if(Nb_Points_old!=Nb_Points){
        init_Distances();
        init_OF_phi_epsilon();
    }
    distance_computed=false;
    OF_computed=false;
}

void OF_CCore::set_Nb_thread(const mxArray *Field){
    int Nb_thread_i=mxGetScalar(Field);
    int SubThreadPop=floor(Nb_Ommatidia/Nb_thread_i)+1;
    //Define number of thread to run
    #ifdef PTHREAD_ENABLE
        if(Nb_Ommatidia>=Nb_thread_i)   Nb_thread=Nb_thread_i;
        else                            Nb_thread=Nb_Ommatidia;
    #else
        Nb_thread=1; // Multithreading is not supported.
    #endif
};
mxArray * OF_CCore::get_Distances(){
    compute_distances();
    //Populate output
    mxArray* MatArray=mxCreateDoubleMatrix(Nb_Ommatidia,Nb_Points,mxREAL); //[Nb_Ommatidia]    x [Nb_Points]
    double* Array=mxGetPr(MatArray);
    for(int row=0;row<Nb_Ommatidia;row++){
        for(int col=0;col<Nb_Points;col++){
            Array[row+col*Nb_Ommatidia]=Distances[row][col];
        }
    }
    return MatArray;
};
mxArray * OF_CCore::get_OF_phi(){
    compute_OF();
    //Populate output
    mxArray* MatArray=mxCreateDoubleMatrix(Nb_Ommatidia,Nb_Points-1,mxREAL); //[Nb_Ommatidia]    x [Nb_Points]
    double* Array=mxGetPr(MatArray);
    for(int row=0;row<Nb_Ommatidia;row++){
        for(int col=0;col<Nb_Points-1;col++){
            Array[row+col*Nb_Ommatidia]=OF_phi[row][col];
        }
    }
    return MatArray;
};
mxArray * OF_CCore::get_OF_epsilon(){
    compute_OF();
    //Populate output
    mxArray* MatArray=mxCreateDoubleMatrix(Nb_Ommatidia,Nb_Points-1,mxREAL); //[Nb_Ommatidia]    x [Nb_Points]
    double* Array=mxGetPr(MatArray);
    for(int row=0;row<Nb_Ommatidia;row++){
        for(int col=0;col<Nb_Points-1;col++){
            Array[row+col*Nb_Ommatidia]=OF_epsilon[row][col];
        }
    }
    return MatArray;
};
