/****************************************************************************\
	Compute OFSubroutineCalcDistances. Multithreading is enable under linux
 via the pthread library. 

 How to use it:
	Compile under matlab with:
          mex OFsubCalcDistances.cpp
    then use as the matlab fonction:
	Distances=OFsubCalcDistances(InStruct,Nb_thread)

 Input:
    - nlhs: The number of lhs (output) arguments.
    - plhs: Pointer to an array which will hold the output data,
        each element is type mxArray.
    - nrhs: The number of rhs (input) arguments.
    - prhs: Pointer to an array which holds the input data, each
        element is type const mxArray.

 here:
    prhs[i], with i=
    0   ->  InStruct is a structure which contains:
                -Ax (size N*3) the 1st row of the matrix 3x3 A
                -Ay (size N*3) the 2nd row of the matrix 3x3 A
                -mstuetzvektor (Size N*3) 
                -spline (Size M*3)
            here N is the number of triangle in the model. M is the number of ommatidia (ie the number of viewing angle in cartesian coordinates)
    2   -> Nb_thread is the number of thread that you want to use (Ommatidia are split in different thread.) 
 
    plhs[i], with i=
	0	-> Return the Distance map, order as spline. 
  
 *********************************************************
 * Code Structure:                                       *
 *  1) Include and definition                            *
 *  2) Input class                                       *
 *  3) Output class                                      *
 *  4) Function between Input and Output class           *
 *  5) Thread struct and function                        *
 *  6) Matlab entry point                                *
 *********************************************************
 
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
/****************************************************************************\
	Input class
\****************************************************************************/
class myInput{
    private:
        double** Ax;
        double** Ay;
        double** mstuetzvektor;
        double** spline;
        int Size_A;
        int Size_spline;
    public:
        myInput();
        myInput(const mxArray* InStruct);
        ~myInput();
        double get_Distance(int ItemToTreat);
        int get_NbElement_toCompute();
};
myInput::myInput(){
    Size_A=0; Size_spline=0;
}
myInput::myInput(const mxArray* InStruct){
    mxArray* Field;
    double* Field_ptr=0;
    const int * Field_pSize=0;
    mwSize Field_nDims;
    std::string Field_name;
    char Message[100];
    //1) load Ax
    Field_name="Ax";
    Field=mxGetField(InStruct,0,Field_name.c_str());
    sprintf(Message,"CRITICAL:[%s] must be a member of mxArray in InStruct", Field_name.c_str());
    if(Field==0)    mexErrMsgTxt(Message);
    Field_ptr   = mxGetPr(Field);
    Field_pSize = mxGetDimensions(Field);
    Field_nDims = mxGetNumberOfDimensions(Field);
    sprintf(Message,"CRITICAL:[%s] must contains no more than two dimensions", Field_name.c_str());
    if((int)Field_nDims>2) mexErrMsgTxt(Message);
    sprintf(Message,"CRITICAL:[%s] should be of size N*3", Field_name.c_str());
    if(Field_pSize[1]>3) mexErrMsgTxt(Message);
    Size_A=Field_pSize[0];
    Ax=new double*[Field_pSize[0]];
    for(int row=0;row<Field_pSize[0];row++){
        Ax[row]=new double[Field_pSize[1]];
        for(int col=0;col<Field_pSize[1];col++){
            Ax[row][col]=Field_ptr[row+col*Field_pSize[0]];
        }
    }
    //2) load Ay
    Field_name="Ay";
    Field=mxGetField(InStruct,0,Field_name.c_str());
    sprintf(Message,"CRITICAL:%s must be a member of mxArray in InStruct", Field_name.c_str());
    if(Field==0)    mexErrMsgTxt(Message);
    Field_ptr   = mxGetPr(Field);
    Field_pSize = mxGetDimensions(Field);
    Field_nDims = mxGetNumberOfDimensions(Field);
    sprintf(Message,"CRITICAL:%s must contains no more than two dimensions", Field_name.c_str());
    if((int)Field_nDims>2)      mexErrMsgTxt(Message);
    sprintf(Message,"CRITICAL:%s should be of size N*3", Field_name.c_str());
    if(Field_pSize[1]>3)        mexErrMsgTxt(Message);
    sprintf(Message,"CRITICAL:%s and Ax must be of the same size", Field_name.c_str());
    if(Size_A!=Field_pSize[0])  mexErrMsgTxt(Message);
    Ay=new double*[Field_pSize[0]];
    for(int row=0;row<Field_pSize[0];row++){
        Ay[row]=new double[Field_pSize[1]];
        for(int col=0;col<Field_pSize[1];col++){
            Ay[row][col]=Field_ptr[row+col*Field_pSize[0]];
        }
    }   
    //3) load mstuetzvektor
    Field_name="mstuetzvektor";
    Field=mxGetField(InStruct,0,Field_name.c_str());
    sprintf(Message,"CRITICAL:%s must be a member of mxArray in InStruct", Field_name.c_str());
    if(Field==0)    mexErrMsgTxt(Message);
    Field_ptr   = mxGetPr(Field);
    Field_pSize = mxGetDimensions(Field);
    Field_nDims = mxGetNumberOfDimensions(Field);
    sprintf(Message,"CRITICAL:%s must contains no more than two dimensions", Field_name.c_str());
    if((int)Field_nDims>2)      mexErrMsgTxt(Message);
    sprintf(Message,"CRITICAL:%s should be of size N*3", Field_name.c_str());
    if(Field_pSize[0]>3)        mexErrMsgTxt(Message);
    sprintf(Message,"CRITICAL:%s and Ax must be of the same size", Field_name.c_str());
    if(Size_A!=Field_pSize[1])  mexErrMsgTxt(Message);
    mstuetzvektor=new double*[Field_pSize[0]];
    for(int row=0;row<Field_pSize[0];row++){
        mstuetzvektor[row]=new double[Field_pSize[1]];
        for(int col=0;col<Field_pSize[1];col++){
            mstuetzvektor[row][col]=Field_ptr[row+col*Field_pSize[0]];
        }
    }
    //3) load spline
    Field_name="spline";
    Field=mxGetField(InStruct,0,Field_name.c_str());
    sprintf(Message,"CRITICAL:%s must be a member of mxArray in InStruct", Field_name.c_str());
    if(Field==0)    mexErrMsgTxt(Message);
    Field_ptr   = mxGetPr(Field);
    Field_pSize = mxGetDimensions(Field);
    Field_nDims = mxGetNumberOfDimensions(Field);
    sprintf(Message,"CRITICAL:%s must contains no more than two dimensions", Field_name.c_str());
    if((int)Field_nDims>2)      mexErrMsgTxt(Message);
    sprintf(Message,"CRITICAL:%s should be of size 3*N", Field_name.c_str());
    if(Field_pSize[1]>3)        mexErrMsgTxt(Message);
    Size_spline=Field_pSize[0];
    spline=new double*[Field_pSize[0]];
    for(int row=0;row<Field_pSize[0];row++){
        spline[row]=new double[Field_pSize[1]];
        for(int col=0;col<Field_pSize[1];col++){
            spline[row][col]=Field_ptr[row+col*Field_pSize[0]];
        }
    }
};
myInput::~myInput(){
    for(int row=0;row<Size_A;row++)   delete [] Ax[row];
    delete [] Ax;
    for(int row=0;row<Size_A;row++)   delete [] Ay[row];
    delete [] Ay;
    for(int row=0;row<3;row++)   delete [] mstuetzvektor[row];
    delete [] mstuetzvektor;
    for(int row=0;row<Size_spline;row++){  delete [] spline[row];}
    delete [] spline;
}
int myInput::get_NbElement_toCompute(){return Size_spline;}
double myInput::get_Distance(int ItemToTreat){
    double invA[3][3];
    double a,b,c,d,e,f,g,h,k;
    double Determinant=0;
    double IntersectPoint[3];
    double spDist=INFINITY;
    for(int Trig_i=0;Trig_i<Size_A;Trig_i++){
        //Populate matrix A as:
        //      a b c
        //  A=  d e f
        //      g h k     
        a=Ax[Trig_i][0];
        d=Ay[Trig_i][0];
        g=-spline[ItemToTreat][0];
        
        b=Ax[Trig_i][1];
        e=Ay[Trig_i][1];
        h=-spline[ItemToTreat][1];
        
        c=Ax[Trig_i][2];
        f=Ay[Trig_i][2];
        k=-spline[ItemToTreat][2];
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
            
            //printf("%i\t%i\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\n",ItemToTreat,Trig_i,invA[0][0],invA[1][0],invA[2][0],invA[0][1],invA[1][1],invA[2][1],invA[0][2],invA[1][2],invA[2][2]);
            //Multiply invA with b
            IntersectPoint[0]=invA[0][0]*mstuetzvektor[0][Trig_i]
                             +invA[0][1]*mstuetzvektor[1][Trig_i]
                             +invA[0][2]*mstuetzvektor[2][Trig_i];
            IntersectPoint[1]=invA[1][0]*mstuetzvektor[0][Trig_i]
                             +invA[1][1]*mstuetzvektor[1][Trig_i]
                             +invA[1][2]*mstuetzvektor[2][Trig_i];
            IntersectPoint[2]=invA[2][0]*mstuetzvektor[0][Trig_i]
                             +invA[2][1]*mstuetzvektor[1][Trig_i]
                             +invA[2][2]*mstuetzvektor[2][Trig_i];
            if((IntersectPoint[0]>=0)&&
               (IntersectPoint[1]>=0)&&
               (IntersectPoint[2]>=0)&&
               (IntersectPoint[0]+IntersectPoint[1]<=1)){
               spDist=std::min(spDist,IntersectPoint[2]);
            }
        }
    }
    return spDist;
}
/****************************************************************************\
	Output class
\****************************************************************************/
class myOutput{
    private:
        double* Distances;
        mxArray* OutStruct;
    public:
        myOutput(myInput* InStruct);
        ~myOutput();
        void setDistance(double Distance, int ItemToTreat);
        mxArray* getStruct();
};
myOutput::myOutput(myInput* InStruct){
    int Argument_i=0;
    OutStruct = mxCreateDoubleMatrix(InStruct->get_NbElement_toCompute(),1,mxREAL); //mxReal is our data-type
    Distances=mxGetPr(OutStruct);
};
myOutput::~myOutput(){/*Nothing has been declare with new*/};
void myOutput::setDistance(double Distance, int ItemToTreat){
    Distances[ItemToTreat]=Distance;
}
mxArray* myOutput::getStruct(){return OutStruct;}
/****************************************************************************\
	Function between Input and Output class
\****************************************************************************/
void myFunction(myOutput* OutStruct, myInput* InStruct, int ItemToTreat){
    OutStruct->setDistance(InStruct->get_Distance(ItemToTreat),ItemToTreat);
};
/****************************************************************************\
	Thread struct and function
\****************************************************************************/
struct Thread_arg{
    int Start;  //First item
    int Stop;   //Last item
    myInput* InStruct;          //Input parameters
    myOutput* OutStruct;        //Output paramters
    bool Verbose;               //Enable/disable verbose. (Disable if multithreaded, printf is not thread safe)
};
void run(Thread_arg* Thread_argument){
    int status;  
    for(int i=Thread_argument->Start;i<Thread_argument->Stop;i++){
        //Call myFunction
        myFunction(Thread_argument->OutStruct,Thread_argument->InStruct,i);
    }
}
void* Thread_run(void* ptr){
//Convert pointer to Thread_arg struct
Thread_arg* Thread_argument;
Thread_argument=(Thread_arg*)ptr;
Thread_argument->Verbose=false; //otherwise not thread safe
run(Thread_argument);
}

/****************************************************************************\
	The function below is the entry point in matlab
\****************************************************************************/
void mexFunction(
            int nlhs, mxArray *plhs[],
            int nrhs, const mxArray *prhs[]){
/**----------------------------------**\
    Early check
\**----------------------------------**/
////printf("---START:Estimate_population.cpp---\n");    
if(nrhs!=2) mexErrMsgTxt("CRITICAL: 2 input argument must be given");
if(nlhs!=1) mexErrMsgTxt("CRITICAL: 1 output argument must be given");
//printf("Early check\t\t OK\n");
/**----------------------------------**\
    Retrieve Data from input
\**----------------------------------**/
const mxArray* Field;
double* Field_ptr=0;
const int * Field_pSize=0;
mwSize Field_nDims;
int Argument_i=0;

myInput* InStruct=new myInput(prhs[Argument_i]);
//1) Load InStruct via myInput class
//myInput InStruct(prhs[Argument_i]);

Argument_i++;
//2) Load Nb_thread
Field       =prhs[Argument_i];
Field_nDims = mxGetNumberOfElements(Field);
Field_pSize = mxGetDimensions(Field);
Field_ptr   = mxGetPr(Field);
if (mxIsComplex(Field)) mexErrMsgTxt("CRITICAL: Nb_thread has to be real (not imaginary)");
if (Field_pSize[0]<1) mexErrMsgTxt("CRITICAL: Nb_thread shouldn't be empty");
int NbThread=ceil(Field_ptr[0]);
if (NbThread<1) mexErrMsgTxt("CRITICAL: Nb_thread has to be greater or equal than 1");
Argument_i++;
//printf("Post checking\t\t OK\n");
/**----------------------------------**\
    Create output variable
\**----------------------------------**/
//0->is the output
myOutput* OutStruct=new myOutput(InStruct);
plhs[0]=OutStruct->getStruct();
Argument_i++;

/**----------------------------------**\
    Init thread parameter
\**----------------------------------**/
int Size_output=InStruct->get_NbElement_toCompute();
int SubThreadPop=floor(Size_output/NbThread)+1;
int NumberThreadToRun=0;
//Define number of thread to run
#ifdef PTHREAD_ENABLE
    if(Size_output>=NbThread) NumberThreadToRun=NbThread;
    else                      NumberThreadToRun=Size_output;
#else
    NumberThreadToRun=1; // Multithreading is not supported.
#endif
//printf("NumberThreadToRun %i \n",NumberThreadToRun);
//mexEvalString("drawnow"); //use to force matlab to display the previous string

//Thread param
Thread_arg Thread_argument[NumberThreadToRun]; //Thread argument
pthread_t pThread[NumberThreadToRun];       //Array of thread (Nbr_of_Thread is the maximum number of running thread)
int iThread[NumberThreadToRun];             //Array of thread id
//Enable/Disable Verbose . Note verbose is NOT Thread Safe
bool Verbose=false;
#ifdef PTHREAD_ENABLE //By default Verbose is enable when script use one thread
    if(NumberThreadToRun<=1) Verbose=true; //Because only one thread, thus the used of //printf is thread safe
    else                     Verbose=false; //because multithreaded
#endif

//Populate structure 
for(int Th_i=0;Th_i<NumberThreadToRun;Th_i++){
	//Sub population range (Note that it's the only difference between two thread)
	Thread_argument[Th_i].Start=Th_i*SubThreadPop;
	Thread_argument[Th_i].Stop=(Th_i+1)*SubThreadPop;
	if(Thread_argument[Th_i].Stop>Size_output)
		Thread_argument[Th_i].Stop=Size_output; //The last thread could have a smaller subpopulation
    //Function name, input and output
    Thread_argument[Th_i].InStruct=InStruct;
    Thread_argument[Th_i].OutStruct=OutStruct;
    //Verbose
    Thread_argument[Th_i].Verbose=(bool)Verbose;  
    if(Verbose){
        printf("Thread %i is fully populated",Th_i);
        mexEvalString("drawnow"); //use to force matlab to display the previous string
    }
}
//printf("Init thread parameter\t\t OK\n");
/**----------------------------------**\
    Thread main section
\**----------------------------------**/
//printf("Number of thread to run=%i\n",NumberThreadToRun);
//mexEvalString("drawnow"); //use to force matlab to display the previous string
#ifdef PTHREAD_ENABLE 
    if(NumberThreadToRun==1){run(&Thread_argument[0]);}
    else{
        //Create thread
        for(int Th_i=0;Th_i<NumberThreadToRun;Th_i++){
                iThread[Th_i]=pthread_create( &pThread[Th_i], NULL, Thread_run, (void*)&Thread_argument[Th_i]);	
        }	
        //wait thread
        for(int Th_i=0;Th_i<NumberThreadToRun ;Th_i++){
                pthread_join( pThread[Th_i], NULL);
        }
        //clean
        for(int Th_i=0;Th_i<NumberThreadToRun ;Th_i++){
                pThread[Th_i]=0;
                iThread[Th_i]=0;
        }
    }
#else
    run(&Thread_argument[0]); //Run just one thread since multihreading is not supported
#endif
/**----------------------------------**\
    Free memory
\**----------------------------------**/
//printf("---END:Estimate_population.cpp---\n");
//mexEvalString("drawnow"); //use to force matlab to display the previous string
delete InStruct;
delete OutStruct;
}


