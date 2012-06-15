//=========================================================
//
//This is a prog in the MutualInfo 0.9 package written by
// Hanchuan Peng.
//
//Disclaimer: The author of program is Hanchuan Peng
//      at <penghanchuan@yahoo.com> and <phc@cbmv.jhu.edu>.
//
//The CopyRight is reserved by the author.
//
//Last modification: April/19/2002
//
//========================================================
//
// findjointstateab.cpp
// find the joint state list of two variables a and b 
// By Hanchuan Peng
// April/18/2002

#include "miinclude.h"

//return the number of states
template <class T> void copyvecdata(T * srcdata, long len, int * desdata, int& nstate,int &minn, int&maxx);

template <class T> void copyvecdata(T * srcdata, long len, int * desdata, int& nstate,int &minn, int&maxx)
{
  if(!srcdata || !desdata)
  {
    printf("NULL points in copyvecdata()!\n");
    return;
  } 

  long i;

  //note: originally I added 0.5 before rounding, however seems the negative numbers and 
  //      positive numbers are all rounded towarded 0; hence int(-1+0.5)=0 and int(1+0.5)=1;
  //      This is unwanted because I need the above to be -1 and 1.
  // for this reason I just round with 0.5 adjustment for positive and negative differently

  //copy data
  //int minn,maxx;
  if (srcdata[0]>0)
    maxx = minn = int(srcdata[0]+0.5);
  else
    maxx = minn = int(srcdata[0]-0.5);

  int tmp;
  double tmp1;
  for (i=0;i<len;i++)
  {
    tmp1 = double(srcdata[i]);
    tmp = (tmp1>0)?(int)(tmp1+0.5):(int)(tmp1-0.5);//round to integers
    minn = (minn<tmp)?minn:tmp;
    maxx = (maxx>tmp)?maxx:tmp;
    desdata[i] = tmp;
    //    printf("%i ",desdata[i]);
  }
  //printf("\n");

  //make the vector data begin from 0 (i.e. 1st state)
  for (i=0;i<len;i++){desdata[i] -= minn;}

  //return the #state
  nstate = (maxx-minn+1);

  return;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  // check the arguments

  if(nrhs != 3 && nrhs !=2 && nrhs!=4)
  {
    printf("Usage [joint_state_list, joint_state_table,joint_prob_ab, marginprob_a, marginprob_b]\n");
    printf("    = progname(vector1, vector2, maxstatenum, b_returnprob).\n");
    printf("(Both vectors can be images). Max range handled: INT type of the OS\n");
    mexErrMsgTxt("--end help.");
  }
  if(nlhs > 5)     
    mexErrMsgTxt("Too many output arguments.");

  if (!mxIsInt8(prhs[0]) && !mxIsUint8(prhs[0]) && !mxIsDouble(prhs[0]) ) 
    mexErrMsgTxt("The first input argument must be types of INT8 or UINT8 or DOUBLE.");
  if (!mxIsInt8(prhs[1]) && !mxIsUint8(prhs[1]) && !mxIsDouble(prhs[1]) ) 
    mexErrMsgTxt("The second input argument must be types of INT8 or UINT8 or DOUBLE.");

  //get and check size information

  long i,j;

  void *img1 = (void *)mxGetData(prhs[0]);
  long len1 = mxGetNumberOfElements(prhs[0]);
  mxClassID type1 = mxGetClassID(prhs[0]);

  void *img2 = (void *)mxGetData(prhs[1]);
  long len2 = mxGetNumberOfElements(prhs[1]);
  mxClassID type2 = mxGetClassID(prhs[1]);
	
  if (!img1 || !img2 || !len1 || !len2)
    mexErrMsgTxt("At least one of the input vectors is invalid.");
  if (len1!=len2)
    mexErrMsgTxt("The two vectors/images should have the same length.");

  int b_findstatenum = 1;
  int nstate1 = 0, nstate2 = 0;
  if (nrhs>=3)
  {
    b_findstatenum = 0;
    long MaxGrayLevel = (long) mxGetScalar(prhs[2]);
    nstate1 = nstate2 = MaxGrayLevel;
    if (MaxGrayLevel<=1)
    {
      printf("The argument #state is invalid. This program will decide #state itself.\n");
      b_findstatenum = 1;
    }
  }

  int b_returnprob = 1;
  if (nrhs>=4)
  {
    b_returnprob = (mxGetScalar(prhs[3])!=0);
  }

  //copy data into new INT type array (hence quantization) and then reange them begin from 0 (i.e. state1)

  int * vec1 = new int[len1];
  int * vec2 = new int[len2];
  int nrealstate1=0, nrealstate2=0;
  int minn1,maxx1,minn2,maxx2;
  switch(type1)
  {
    case mxINT8_CLASS: copyvecdata((char *)img1,len1,vec1,nrealstate1,minn1,maxx1); break;
    case mxUINT8_CLASS: copyvecdata((unsigned char *)img1,len1,vec1,nrealstate1,minn1,maxx1); break;
    case mxDOUBLE_CLASS: copyvecdata((double *)img1,len1,vec1,nrealstate1,minn1,maxx1); break;
  }  
  switch(type2)
  {
    case mxINT8_CLASS: copyvecdata((char *)img2,len2,vec2,nrealstate2,minn2,maxx2); break;
    case mxUINT8_CLASS: copyvecdata((unsigned char *)img2,len2,vec2,nrealstate2,minn2,maxx2); break;
    case mxDOUBLE_CLASS: copyvecdata((double *)img2,len2,vec2,nrealstate2,minn2,maxx2); break;
  }  

  //update the #state when necessary
  if (nstate1<nrealstate1)
  {
    nstate1 = nrealstate1;
    // printf("First vector #state = %i\n",nrealstate1);
  }
  if (nstate2<nrealstate2)
  {
    nstate2 = nrealstate2;
    // printf("Second vector #state = %i\n",nrealstate2);
  }

  //generate the joint-distribution table

  mxArray * m_JointProbab = mxCreateDoubleMatrix(nstate1,nstate2,mxREAL);
  double *hab = (double *) mxGetPr(m_JointProbab);
  double **hab2d = new double * [nstate2];
  for(j=0;j<nstate2;j++)
    hab2d[j] = hab + (long)j*nstate1;

  for (i=0; i<nstate1;i++)
  for (j=0; j<nstate2;j++)
  {
    hab2d[j][i] = 0;
  }
  
  for (i=0;i<len1;i++)
  {
    //old method -- slow
    //     indx = (long)(vec2[i]) * nstate1 + vec1[i];
    //     hab[indx] += 1;

    //new method -- fast
    hab2d[vec2[i]][vec1[i]] += 1;
  }
  
  //return the probabilities, otherwise return count numbers
  if(b_returnprob)
  {
    for (i=0; i<nstate1;i++)
    for (j=0; j<nstate2;j++)
    {
      hab2d[j][i] /= len1;
    }
  }

  //plhs[0] = JointStateList
  plhs[0] = mxCreateDoubleMatrix(len1,1,mxREAL);
  double * jslist = (double *)mxGetPr(plhs[0]);
  
  long * tmphab = new long [long(nstate1)*nstate2];
  long nmaxstate = 0;
  for (i=0;i<(long)nstate1*nstate2;i++)
  {
    if (hab[i]!=0) {nmaxstate++;tmphab[i]=nmaxstate;}
    else tmphab[i]=-1;
  }

  for (i=0;i<len1;i++)
  {
    jslist[i] = tmphab[vec2[i]*nstate1+vec1[i]];
  }

  //for nlhs>=2;

  if (nlhs>=2)
  {
    int curn = 2; //plhs[1] = JointSatetTable
    plhs[curn-1] = mxCreateDoubleMatrix(nmaxstate,4,mxREAL);
    double * jstable = (double *)mxGetPr(plhs[curn-1]);

    double **jtable2d = new double * [4];
    for (i=0;i<4;i++) jtable2d[i] = jstable + (long)i*nmaxstate;

    long k=0;
    for (j=0;j<nstate2;j++)
    for (i=0;i<nstate1;i++)
    {
      if (hab2d[j][i]!=0) 
      {
	jtable2d[0][k] = k+1;
	jtable2d[1][k] = minn1+i;
	jtable2d[2][k] = minn2+j;
	jtable2d[3][k] = hab2d[j][i];
	k++;
      }
    }

    if (jtable2d) delete []jtable2d;
  }
  
  if (nlhs>=3)
  {
    int curn = 3;
    plhs[curn-1] = m_JointProbab;
  }
  else
  {
    mxDestroyArray(m_JointProbab);
  }

  if (nlhs>=4)
  {
    int curn = 4;
    plhs[curn-1] = mxCreateDoubleMatrix(nstate1,1,mxREAL);
    double *ha = (double *)mxGetPr(plhs[curn-1]);
    for (i=0;i<nstate1;i++) {ha[i] = 0;}
    for (i=0;i<nstate1;i++)
    for (j=0;j<nstate2;j++)
    {
      ha[i] += hab2d[j][i];
    }
  }
  
  if (nlhs>=5)
  {
    int curn = 5;
    plhs[curn-1] = mxCreateDoubleMatrix(nstate2,1,mxREAL);
    double *hb = (double *)mxGetPr(plhs[curn-1]);
    for (j=0;j<nstate2;j++) {hb[j] = 0;}
    for (i=0;i<nstate1;i++)
    for (j=0;j<nstate2;j++)
    {
      hb[j] += hab2d[j][i];
    }
  }

  //finish
  if (hab2d) {delete []hab2d;}
  if (vec1) delete []vec1;
  if (vec2) delete []vec2;
  if (tmphab) delete []tmphab;

  return;
}
