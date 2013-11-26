 /****************************************************
 *
 * Robert F.K. Martin
 * ID 1505151
 * CSci 5551 - Intelligent Robotics
 *
 * Project:
 * This program allows the user to generate a robotic
 * manipulator with up to 10 joints, either revolute
 * or prismatic. The joint angles or offsets can
 * either be controlled via the keyboard or entered
 * manually.
 *
 ***************************************************/

#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#define pi 3.1416
#define MAX_JOINT 10
#define MAX_VIA 4

int i;
float X=-10.0, Y=0.0, Z=5.0;                 // Camera location
float A=0.0, B=0.0, C=1.0;                   // target location
float alpha[MAX_JOINT], a[MAX_JOINT];        // DH parameters 
float d[MAX_JOINT], theta[MAX_JOINT];        // DH parameters
float TMatrix[MAX_JOINT + 1][4][4];          // T Matrices
float a0[MAX_JOINT];
float a1[MAX_JOINT];                         // Coefficients for trajectory
float a2[MAX_JOINT];
float a3[MAX_JOINT];

enum manip_type {puma, moto, stan, arb};     // Robot type
enum manip_type mtype;                       // puma = PUMA
                                             // moto = Motoman L-3
                                             // stan = Stanford Manipulator
                                             // arb = arbitrary DH robot

enum joint_type {f,r,p};                     // Joint type
enum joint_type type[MAX_JOINT];             // f = fixed
                                             // r = revolute
                                             // p = prismatic

/****************************************************
 *
 * void loadPuma()
 *
 * load the preset values for the PUMA 560
 *
 ***************************************************/
void loadPUMA()
{
  int scale=1;
  i = 6;
  mtype=puma;
  alpha[0]=0;
  alpha[1]=-90;
  alpha[2]=0;
  alpha[3]=-90;
  alpha[4]=90;
  alpha[5]=-90;
  a[0]=0;
  a[1]=0;
  a[2]=scale*0.4318;
  a[3]=scale*-0.0203;
  a[4]=0;
  a[5]=0;
  d[0]=0;
  d[1]=0;
  d[2]=scale*0.15;
  d[3]=scale*0.4331;
  d[4]=0;
  d[5]=0;
  theta[0]=0;
  theta[1]=0;
  theta[2]=0;
  theta[3]=0;
  theta[4]=0;
  theta[5]=0;
  type[0]=r;
  type[1]=r;
  type[2]=r;
  type[3]=r;
  type[4]=r;
  type[5]=r;
}

/****************************************************
 *
 * void loadMoto()
 *
 * load the preset values for the Motoman L-3
 *
 ***************************************************/
void loadMoto()
{
  i = 5;
  mtype=moto;
  alpha[0]=0;
  alpha[1]=-90;
  alpha[2]=0;
  alpha[3]=0;
  alpha[4]=90;
  a[0]=0;
  a[1]=0;
  a[2]=2.5;
  a[3]=1.75;
  a[4]=0;
  d[0]=2.22;
  d[1]=0;
  d[2]=0;
  d[3]=0;
  d[4]=0;
  theta[0]=0;
  theta[1]=0;
  theta[2]=0;
  theta[3]=0;
  theta[4]=0;
  type[0]=r;
  type[1]=r;
  type[2]=r;
  type[3]=r;
  type[4]=r;
}

/****************************************************
 *
 * void loadStan()
 *
 * load the preset values for the Stanford Manipulator
 *
 ***************************************************/
void loadStan()
{
  i = 6;
  mtype=stan;
  alpha[0]=0;
  alpha[1]=-90;
  alpha[2]=90;
  alpha[3]=0;
  alpha[4]=-90;
  alpha[5]=90;
  a[0]=0;
  a[1]=0;
  a[2]=0;
  a[3]=0;
  a[4]=0;
  a[5]=0;
  d[0]=2.22;
  d[1]=1.11;
  d[2]=0;
  d[3]=0;
  d[4]=0;
  d[5]=0;
  theta[0]=0;
  theta[1]=0;
  theta[2]=0;
  theta[3]=0;
  theta[4]=0;
  theta[5]=0;
  type[0]=r;
  type[1]=r;
  type[2]=p;
  type[3]=r;
  type[4]=r;
  type[5]=r;
}

/****************************************************
 *
 * void makeTMatrix(int index)
 *
 * computes the 4x4 T Matrix of joint index for the
 * current values of theta and d.
 *
 ***************************************************/
void makeTMatrix(int index)
{
  TMatrix[index][0][0]=cos(theta[index]*pi/180);
  TMatrix[index][0][1]=-1.0*sin(theta[index]*pi/180);
  TMatrix[index][0][2]=0.0;
  TMatrix[index][0][3]=a[index];
  TMatrix[index][1][0]=sin(theta[index]*pi/180)*cos(alpha[index]*pi/180);
  TMatrix[index][1][1]=cos(theta[index]*pi/180)*cos(alpha[index]*pi/180);
  TMatrix[index][1][2]=-1.0*sin(alpha[index]*pi/180);
  TMatrix[index][1][3]=-1.0*sin(alpha[index]*pi/180)*d[index];
  TMatrix[index][2][0]=sin(theta[index]*pi/180)*sin(alpha[index]*pi/180);
  TMatrix[index][2][1]=cos(theta[index]*pi/180)*sin(alpha[index]*pi/180);
  TMatrix[index][2][2]=cos(alpha[index]*pi/180);
  TMatrix[index][2][3]=cos(alpha[index]*pi/180)*d[index];
  TMatrix[index][3][0]=0.0;
  TMatrix[index][3][1]=0.0;
  TMatrix[index][3][2]=0.0;
  TMatrix[index][3][3]=1.0;
}

/****************************************************
 *
 * void printTMatrix(int index)
 *
 * prints the T Matrix of joint index
 *
 ***************************************************/
void printTMatrix(int index)
{
  printf("====TMatrix====\n");
  printf("T[%d]=\n", index);
  printf("%5.2f %5.2f %5.2f %5.2f\n", TMatrix[index][0][0], TMatrix[index][0][1], TMatrix[index][0][2], TMatrix[index][0][3]);
  printf("%5.2f %5.2f %5.2f %5.2f\n", TMatrix[index][1][0], TMatrix[index][1][1], TMatrix[index][1][2], TMatrix[index][1][3]);
  printf("%5.2f %5.2f %5.2f %5.2f\n", TMatrix[index][2][0], TMatrix[index][2][1], TMatrix[index][2][2], TMatrix[index][2][3]);
  printf("%5.2f %5.2f %5.2f %5.2f\n", TMatrix[index][3][0], TMatrix[index][3][1], TMatrix[index][3][2], TMatrix[index][3][3]);
}

/****************************************************
 *
 * void makeIdentity(int index)
 *
 * makes T Matrix of index an identity matrix
 *
 ***************************************************/
void makeIdentity(int index)
{
  int j;
  for (j = 0; j < 4; j++)
    TMatrix[index][j][j] = 1;
}

/****************************************************
 *
 * void makeZero(int index)
 *
 * initializes T Matrix of index to all zeros.
 *
 ***************************************************/
void makeZero(int index)
{
  int j,k;
  for (j = 0; j < 4; j++)
    for (k = 0; k < 4; k++)
      TMatrix[index][j][k] = 0;
}

/****************************************************
 *
 * void multiplyTMatrix
 *
 * multiplies all T Matrices to compute T Matrix
 * of end-effector relative to base
 *
 ***************************************************/
void multiplyTMatrix(int index)
{
  int a;
  int j,k,l;
  float tempTMatrix[4][4];

  a = 0;

  while(a < index)
    {
      if (a == 0)
	makeIdentity(index);

      for (j = 0; j < 4; j++)
	for (k = 0; k < 4; k++)
	  tempTMatrix[j][k] = TMatrix[index][j][k];

      makeZero(index);

      for (j = 0; j < 4; j++)
        for (k = 0; k < 4; k ++)
	  for (l = 0; l < 4; l++)
	    TMatrix[index][j][k] = TMatrix[index][j][k] +  tempTMatrix[j][l]*TMatrix[a][l][k];
    a++;
    }
}

/****************************************************
 *
 * void printEndPts
 *
 * prints the Cartesian coordinates of the end
 * effector
 *
 ***************************************************/
void printEndPts()
{
  printf("====Cartesian space====\n");
  printf("X=%5.2f Y=%5.2f Z=%5.2f\n", TMatrix[i][0][3], TMatrix[i][1][3], TMatrix[i][2][3]);
  printTMatrix(i);
}


/****************************************************
 *
 * float mod(float num)
 *
 * floatint point mod operator
 *
 ***************************************************/
float mod(float num)
{
  if (num > 360)
    return (num - 360.0);
  else if (num < -360)
    return (num + 360.0);
  else
    return num;
}

/****************************************************
 *
 * void draw_plane
 *
 * generates a 6x6 rectangle centered on the origin
 * on the X-Y plane at Z=0. For perspective.
 *
 ***************************************************/
void draw_plane()
{
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glBegin(GL_QUADS);
  glColor3f(1.0, 0.0, 0.0);
  glVertex3f(-3.0, -3.0, 0.0);
  glColor3f(0.0, 1.0, 0.0);
  glVertex3f(3.0, -3.0, 0.0);
  glColor3f(0.0, 0.0, 1.0);
  glVertex3f(3.0, 3.0, 0.0);
  glColor3f(1.0, 1.0, 1.0);
  glVertex3f(-3.0, 3.0, 0.0);
  glEnd();
}

/****************************************************
 *
 * void draw_arm(GLUquadric, float length)
 *
 * draws a cylinder of diameter 0.2 units and of
 * height length.
 *
 ***************************************************/
void draw_arm(GLUquadricObj *qobj, float length)
{
  gluCylinder(qobj, 0.2, 0.2, length, 16, 5 * length / 2);
}

/****************************************************
 *
 * void draw_joint
 *
 * draws a sphere of radius 0.3 units centered at
 * the intersection of two arms. Represents a joint.
 *
 ***************************************************/
void draw_joint()
{
  glutSolidSphere(0.3, 5, 5);
}

/****************************************************
 *
 * void print_position
 *
 * gives the current angle or prismatic offset
 * of each joint. Will be amended to include 
 * generating Cartesian coordinates.
 *
 ***************************************************/
void print_position()
{
  int k;

  printf("===Joint space====\n");
  for (k = 0; k < i; k++)
    if (type[k]==r)
      printf("Joint[%d] is at %f\n", k, theta[k]);
    else if (type[k]==p)
      printf("Joint[%d] is at %f\n", k, d[k]);
  else
    printf("Joint[%d] is fixed\n", k);

  makeZero(i);
  makeIdentity(i);
  for (k = 0; k < i; k++)
    makeTMatrix(k);
  multiplyTMatrix(i);
  printEndPts();
}

/****************************************************
 *
 * void solvePuma(float x, float y, float z)
 *
 * Solves the inverse kinematics of the Puma 650.
 * Only solves for the first three joints since
 * the end-effector is irrelevant at this point
 *
 ***************************************************/
void solvePuma(float x, float y, float z)
{
  float K, theta23, temp;
  float temp1, temp2, temp3, temp4, temp5, temp6;

  z = z - d[0];

  theta[0] = (atan2(y,x) - atan2(d[2], sqrt(pow(x,2) + pow(y,2) - pow(d[2],2))));

  K = (pow(x,2) + pow(y,2) + pow(z,2) - pow(a[2],2) - pow(a[3],2) - pow(d[2],2) - pow(d[3],2))/(2*a[2]);

  temp = fabs(pow(a[3],2) + pow(d[3],2) - pow(K,2));

  if (temp < 0.0001)
    temp = 0;
  else
    temp = pow(a[3],2) + pow(d[3],2) - pow(K,2);

  theta[2] = atan2(a[3],d[3]) - atan2(K, sqrt(temp));

  temp1=(-a[3]-a[2]*cos(theta[2]))*z;
  temp2=(cos(theta[0])*x+sin(theta[0])*y);
  temp3=(d[3]-a[2]*sin(theta[2]));
  temp4= (a[2]*sin(theta[2])-d[3])*z;
  temp5=(a[3]+a[2]*cos(theta[2]));

  theta[0] = theta[0]*(180/pi);
  theta[2] = theta[2]*(180/pi);
  theta23 = (atan2(temp1-temp2*temp3,temp4+temp5*temp2))*(180/pi);

  theta[1] = theta23 - theta[2];
}

/****************************************************
 *
 * void solveMoto(float x, float y, float z)
 *
 * Solves the inverse kinematics of the Motoman L-3.
 * Only solves for the first three joints since
 * the end-effector is irrelevant at this point
 *
 ***************************************************/
void solveMoto(float x, float y, float z)
{
  float temp;

  z = z - d[0];

  theta[0] = atan2(y,x);

  temp = (pow(x,2)+pow(y,2)+pow(z,2)-pow(a[2],2)-pow(a[3],2))/(2*a[2]*a[3]);

  theta[2] = atan2(sqrt(1-pow(temp,2)),temp);

  theta[1] = -atan2(z,sqrt(pow(x,2)+pow(y,2))) - atan2(a[3]*sin(theta[2]),a[2]+a[3]*cos(theta[2]));

  theta[0] = theta[0]*(180/pi);
  theta[1] = theta[1]*(180/pi);
  theta[2] = theta[2]*(180/pi);
}

/****************************************************
 *
 * void solveStan(float x, float y, float z)
 *
 * Solves the inverse kinematics of the Stanford
 * Manipulator. Only solves for the first three joints
 * since the end-effector is irrelevant at this point
 *
 ***************************************************/
void solveStan(float x, float y, float z)
{
  float temp;

  z = z - d[0];

  theta[0] = atan2(y,x) - atan2(d[1],-sqrt(pow(x,2)+pow(y,2)-pow(d[1],2)));

  theta[1] = atan2(cos(theta[0])*x+sin(theta[0])*y,z);

  d[2] = sin(theta[1])*(cos(theta[0])*x+sin(theta[0])*y)+cos(theta[1])*z;

  theta[0] = theta[0]*(180/pi);
  theta[1] = theta[1]*(180/pi);
  theta[2] = theta[2]*(180/pi);
}

/****************************************************
 *
 * void solveArb(float x, float y, float z)
 *
 * Solves the inverse kinematics of an arbitrary
 * robot specified by DH parameters. Done by brute
 * force. Computationally expensive but does the job.
 *
 ***************************************************/
void solveArb(float x, float y, float z)
{
  int j;
  int sign;
  int max_grad;
  float k,l,m;
  float dist,min,mintheta;
  float tol,thetaTemp;
  float grad[3], max_grad_val;
  char c;
  int oddeven=0;

  for (j = 0; j < i; j++)
    {
      theta[j]=0; // set initial values to zero
      makeTMatrix(j);
    }

  for ( j = 0; j < i ; j++)
    {
      min = 100;
      for (k = 0; k < 360.0; k=k+0.1)
	{
	  if (oddeven==0)
	    {
	      oddeven=1;
	      theta[j]= -1.0 * (k+0.1) / 2.0;
	    }
	  else
	    {
	      oddeven=0;
	      theta[j]=k/2.0;
	    }


	  makeTMatrix(j);
	  makeZero(i);
	  makeIdentity(i);
	  multiplyTMatrix(i);

	  dist = sqrt(pow(TMatrix[i][0][3]-x,2) + pow(TMatrix[i][1][3]-y,2) + pow(TMatrix[i][2][3]-z,2));

	  if (dist < min)
	    {
	      min = dist;
	      mintheta=theta[j];
	    }
	}
      theta[j]=mintheta;
      makeTMatrix(j);
    }
}

/****************************************************
 *
 * void solveTrajectory(float x1, float x2, float y1,
 *                      float y2, float z1, float z2
 *                      float time, int via, bool last)
 *
 * Solve for the coefficients of the joint polynomials.
 * For via pts, assume continuous velocity and 
 * acceleration.
 *
 ***************************************************/
void solveTrajectory(float x1, float x2, float y1, float y2, float z1, float z2, float time)
{
  int j;

  a1[0] = a1[1] = a1[2] = 0;

  if (mtype == puma)
    {
      solvePuma(x1,y1,z1);
      display();
      for (j = 0; j < 3; j++)
	  a0[j] = theta[j];
      solvePuma(x2,y2,z2);
      for (j = 0; j < 3; j++)
	{
	  a2[j]=3*(theta[j]-a0[j])/pow(time,2);
	  a3[j]=-2*(theta[j]-a0[j])/pow(time,3);
	}
    }
  else if (mtype == moto)
    {
      solveMoto(x1,y1,z1);
      display();
      for (j = 0; j < 3; j++)
	  a0[j] = theta[j];
      solveMoto(x2,y2,z2);
      for (j = 0; j < 3; j++)
	{
	  a2[j]=3*(theta[j]-a0[j])/pow(time,2);
	  a3[j]=-2*(theta[j]-a0[j])/pow(time,3);
	}
    }
  else if (mtype == stan)
    {
      solveStan(x1,y1,z1);
      display();
      for (j = 0; j < 2; j++)
	  a0[j] = theta[j];

      a0[2]=d[2];
      solveStan(x2,y2,z2);
      for (j = 0; j < 2; j++)
	{
	  a2[j]=3*(theta[j]-a0[j])/pow(time,2);
	  a3[j]=-2*(theta[j]-a0[j])/pow(time,3);
	}

      a2[2]=3*(d[2]-a0[2])/pow(time,2);
      a3[2]=-2*(d[2]-a0[2])/pow(time,3);
    }
  else if (mtype == arb)
    {
      theta[0]=theta[1]=theta[2]=0;
      solveArb(x1,y1,z1);
      display();
      for (j = 0; j < 3; j++)
	  a0[j] = theta[j];
      theta[0]=theta[1]=theta[2]=0;
      solveArb(x2,y2,z2);
      for (j = 0; j < 3; j++)
	{
	  a2[j]=3*(theta[j]-a0[j])/pow(time,2);
	  a3[j]=-2*(theta[j]-a0[j])/pow(time,3);
	}
    }
}

/****************************************************
 *
 * void animateRobot(float time)
 *
 * animates the robot according to the polynomial
 *
 ***************************************************/
void animateRobot(float time)
{
  int j,k;
  char c;
  float t;

  for (t = 0; t < time; t=t+0.1)
    {
      for (j = 0; j < 3; j++)
	{
	  if ((mtype==stan)&&(j==2))
	    d[2]=a0[j] + a1[j]*t + a2[j]*pow(t,2) + a3[j]*pow(t,3);
	  else
	    theta[j] = a0[j] + a1[j]*t + a2[j]*pow(t,2) + a3[j]*pow(t,3);
	}
      display();
      for (j = 0;j < 1000 ; j++)
	; // do nothing
    }
}
/****************************************************
 *
 * void animateLinearRobot(float x1, float x2,
                           float y1, float y2,
                           float z1, float z2,
			   float time)
 *
 * animates the robot using linear motion
 *
 ***************************************************/
void animateLinearRobot(float x1, float x2, float y1, float y2, float z1, float z2, float time)
{
  int j;
  float t,curx,cury,curz;

  for (t = 0; t < time; t=t+0.1)
    {
      curx=x1+t*(x2-x1)/time;
      cury=y1+t*(y2-y1)/time;
      curz=z1+t*(z2-z1)/time;

      if (mtype==puma)
	solvePuma(curx,cury,curz);
      else if (mtype==moto)
	solveMoto(curx,cury,curz);
      else if (mtype==stan)
	solveStan(curx,cury,curz);
      else if (mtype==arb)
	solveArb(curx,cury,curz);

      display();
      for (j = 0;j < 1000 ; j++)
	; // do nothing
    }
}

/****************************************************
 *
 * void draw_end_effector
 *
 * generates a fork shaped end effector. Useful for
 * seeing rotation of last few joints.
 *
 ***************************************************/
void draw_end_effector(GLUquadricObj *qobj)
{
  glTranslatef(-0.25, 0.0, 0.0);
  glRotatef(90, 0.0, 1.0, 0.0);
  gluCylinder(qobj, 0.1, 0.1, 0.5, 4, 2);
  glRotatef(-90, 0.0, 1.0, 0.0);
  gluCylinder(qobj, 0.1, 0.1, 0.25, 4, 2);
  glTranslatef(0.5, 0.0, 0.0);
  gluCylinder(qobj, 0.1, 0.1, 0.25, 4, 2);
}

/****************************************************
 *
 * void init
 *
 * sets up the initial GL settings for lighting and
 * material. Was modified from the robot.c example
 * from the OpenGL Programming Guide.
 *
 ***************************************************/
void init(void) 
{
  GLfloat mat_specular[] = { 0.33, 0.33, 0.52, 1.0 };
  GLfloat mat_ambient[] = { 0.11, 0.06, 0.11, 1.0 };
  GLfloat mat_diffuse[] = { 0.43, 0.47, 0.54, 1.0 };
  GLfloat mat_shininess[] = { 10.0 };
  GLfloat model_ambient[] = {0.5, 0.5, 0.5, 1.0};

  GLfloat light_position[] = { -6.0, 1.0, 1.0, 0.0 };

  glClearColor (0.0, 0.0, 0.0, 0.0);
  glShadeModel (GL_SMOOTH);
  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

  glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular);
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, mat_ambient);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, mat_diffuse);
  glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess);
  glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
  glLightfv(GL_LIGHT0, GL_POSITION, light_position);
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, model_ambient);

  glEnable(GL_POLYGON_OFFSET_FILL);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_DEPTH_TEST);

  glPolygonOffset(1.0, 1.0);
}

/****************************************************
 *
 * void display
 *
 * draws the arms and joints using the global
 * variables for the joint angles and prismatic
 * offsets.
 *
 ***************************************************/
void display(void)
{
  int k;
  GLUquadricObj *qobj;

  glLoadIdentity();
  gluLookAt(X, Y, Z, A, B, C, 0.0, 0.0, 1.0);

  draw_plane();

  glColor3f(0.66, 0.66, 0.33);

  qobj = gluNewQuadric();

  glPushMatrix();

  for (k = 0; k < i; k++)
    {
      if (a[k] != 0)
	{
	  /* translate a along X */
	  glRotatef(90.0, 0.0, 1.0, 0.0);
	  glPushMatrix();
	  draw_arm(qobj, a[k]);
	  draw_joint(qobj);
	  glRotatef(-90.0, 0.0, 1.0, 0.0);

	  glTranslatef(a[k], 0.0, 0.0);
	  glPushMatrix();
	}

      /* rotate alpha around Z */
      glRotatef((GLfloat) alpha[k], 1.0, 0.0, 0.0);
      glPushMatrix();

      if (d[k] > 0)
	{
	  draw_arm(qobj, d[k]);
	  draw_joint(qobj);

	  /* translate d along Z */
	  glTranslatef(0.0, 0.0, d[k]);
	  glPushMatrix();
	}
      else
	d[k] = 0;

      /* rotate theta around Z */
      glRotatef((GLfloat) theta[k], 0.0, 0.0, 1.0);
      glPushMatrix();
    }

  draw_end_effector(qobj);

  glutSwapBuffers();
  glFlush();
}

/****************************************************
 *
 * void reshape
 *
 * redraws screen when window is resized. Taken
 * robot.c example from OpenGL Programming Guide.
 *
 ***************************************************/
void reshape (int w, int h)
{
   glViewport (0, 0, (GLsizei) w, (GLsizei) h); 
   glMatrixMode (GL_PROJECTION);
   glLoadIdentity ();
   gluPerspective(60.0, (GLfloat) w/(GLfloat) h, 2.0, 50.0);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
}

/****************************************************
 *
 * void keyboard
 *
 * Callback function for keyboard input while
 * window is active. The idea was borrowed from
 * the robot.c example from the OpenGL Programming
 * Guide but was extended to include up to 10 joints
 * which could be revolute as well as prismatic.
 *
 ***************************************************/
void keyboard (unsigned char key, int x, int y)
{
   switch (key) {
      case 'x':   /* X key modifies X viewpoint  */
	X=X+0.25;
         break;
      case 'X':
	X=X-0.25;
         break;
      case 'y':   /* Y key modifies Y viewpoint  */
	Y=Y+0.25;
         break;
      case 'Y':
	Y=Y-0.25;
         break;
      case 'z':   /* Z key modifies Z viewpoint  */
	Z=Z+0.25;
         break;
      case 'Z':
	Z=Z-0.25;
         break;
      case 'a':   /* A key modifies X target point  */
	A=A+0.25;
         break;
      case 'A':
	A=A-0.25;
         break;
      case 'b':   /* B key modifies Y target point  */
	B=B+0.25;
         break;
      case 'B':
	B=B-0.25;
         break;
      case 'c':   /* C key modifies Z target point  */
	C=C+0.25;
         break;
      case 'C':
	C=C-0.25;
         break;
      case '1':   /* 1 key modifies joint 0  */
	if (type[0]==r)
	  theta[0] = mod(theta[0] + 5.0);
	else if (type[0]==p)
	  d[0]=d[0]+0.05;
	else
	  ; // do nothing
         break;
      case '!':
	if (type[0]==r)
	  theta[0] = mod(theta[0] - 5.0);
	else if (type[0]==p)
	  d[0]=d[0]-0.05;
	else
	  ; // do nothing
         break;
      case '2':   /* 2 key modifies joint 1 */
	if (type[1]==r)
	  theta[1] = mod(theta[1] + 5.0);
	else if (type[1]==p)
	  d[1]=d[1]+0.05;
	else
	  ; // do nothing
         break;
      case '@':
	if (type[1]==r)
	  theta[1] = mod(theta[1] - 5.0);
	else if (type[1]==p)
	  d[1]=d[1]-0.05;
	else
	  ; // do nothing
         break;
      case '3':   /* 3 key modifies joint 2 */
	if (type[2]==r)
	  theta[2] = mod(theta[2] + 5.0);
	else if (type[2]==p)
	  d[2]=d[2]+0.05;
	else
	  ; // do nothing
         break;
      case '#':
	if (type[2]==r)
	  theta[2] = mod(theta[2] - 5.0);
	else if (type[2]==p)
	  d[2]=d[2]-0.05;
	else
	  ; // do nothing
         break;
      case '4':   /* 4 key modifies joint 3  */
	if (type[3]==r)
	  theta[3] = mod(theta[3] + 5.0);
	else if (type[3]==p)
	  d[3]=d[3]+0.05;
	else
	  ; // do nothing
         break;
      case '$':
	if (type[3]==r)
	  theta[3] = mod(theta[3] - 5.0);
	else if (type[3]==p)
	  d[3]=d[3]-0.05;
	else
	  ; // do nothing
         break;
      case '5':   /* 5 key modifies joint 4  */
	if (type[4]==r)
	  theta[4] = mod(theta[4] + 5.0);
	else if (type[4]==p)
	  d[4]=d[4]+0.05;
	else
	  ; // do nothing
         break;
      case '%':
	if (type[4]==r)
	  theta[4] = mod(theta[4] - 5.0);
	else if (type[4]==p)
	  d[4]=d[4]-0.05;
	else
	  ; // do nothing
         break;
      case '6':   /* 6 key modifies joint 5  */
	if (type[5]==r)
	  theta[5] = mod(theta[5] + 5.0);
	else if (type[5]==p)
	  d[5]=d[5]+0.05;
	else
	  ; // do nothing
         break;
      case '^':
	if (type[5]==r)
	  theta[5] = mod(theta[5] - 5.0);
	else if (type[5]==p)
	  d[5]=d[5]-0.05;
	else
	  ; // do nothing
         break;
      case '7':   /* 7 key modifies joint 6  */
	if (type[6]==r)
	  theta[6] = mod(theta[6] + 5.0);
	else if (type[6]==p)
	  d[6]=d[6]+0.05;
	else
	  ; // do nothing
         break;
      case '&':
	if (type[6]==r)
	  theta[6] = mod(theta[6] - 5.0);
	else if (type[6]==p)
	  d[6]=d[6]-0.05;
	else
	  ; // do nothing
         break;
      case '8':   /* 8 key modifies joint 7  */
	if (type[7]==r)
	  theta[7] = mod(theta[7] + 5.0);
	else if (type[7]==p)
	  d[7]=d[7]+0.05;
	else
	  ; // do nothing
         break;
      case '*':
	if (type[7]==r)
	  theta[7] = mod(theta[7] - 5.0);
	else if (type[7]==p)
	  d[7]=d[7]-0.05;
	else
	  ; // do nothing
         break;
      case '0':   /* 0 key modifies joint 9  */
	if (type[9]==r)
	  theta[9] = mod(theta[9] + 5.0);
	else if (type[9]==p)
	  d[9]=d[9]+0.05;
	else
	  ; // do nothing
         break;
      case ')':
	if (type[9]==r)
	  theta[9] = mod(theta[9] - 5.0);
	else if (type[9]==p)
	  d[9]=d[9]-0.05;
	else
	  ; // do nothing
         break;
      case '9':   /* 9 key modifies joint 8  */
	if (type[8]==r)
	  theta[8] = mod(theta[8] + 5.0);
	else if (type[8]==p)
	  d[8]=d[8]+0.05;
	else
	  ; // do nothing
         glutPostRedisplay();
         break;
      case '(':
	if (type[8]==r)
	  theta[8] = mod(theta[8] - 5.0);
	else if (type[8]==p)
	  d[8]=d[8]-0.05;
	else
	  ; // do nothing
         glutPostRedisplay();
         break;
      default:
         break;
   }
   glutPostRedisplay();
}

/****************************************************
 *
 * void mouse
 *
 * Callback function which handles mouse button
 * events. Pressing the left button allows the user
 * to enter new angles or offsets. The right button
 * causes the program to print out the current
 * values for the angles or offsets.
 *
 ***************************************************/
void mouse(int button, int state, int x, int y)
{

  if ((button == GLUT_LEFT_BUTTON) && (state == GLUT_DOWN))
    {
      listMenu();
    }
  else if ((button == GLUT_RIGHT_BUTTON) && (state == GLUT_DOWN))
    {
      selectRobot();
      glutPostRedisplay();
    }
}

/****************************************************
 *
 * void listMenu
 *
 * Displays the menu for forward and inverse
 * kinematics and motion.
 *
 ***************************************************/
void listMenu()
{
  int j,k,choice,via;
  char c;
  float x1, y1, z1;
  float x2, y2, z2;
  float viax[MAX_VIA],viay[MAX_VIA],viaz[MAX_VIA];
  float time;

  printf("Menu options:\n");
  printf("1) Print joint angles and Cartesian position\n");
  printf("2) Forward Kinematics\n");
  printf("3) Inverse Kinematics\n");
  printf("4) Cubic Polynomial Motion\n");
  printf("5) Linear Motion\n");
  scanf("%d", &choice);

  switch (choice) {

  case 1:
    print_position();
    break;

  case 2:
    printf("\nEnter new angles\n");

    for (k = 0; k < i; k++)
      {
	printf("Joint[%d]: ", k);
	if (type[k]==r)
	  scanf("%f", &theta[k]);
	else if (type[k]==p)
	  scanf("%f", &d[k]);
	else
	  printf("Fixed joint\n");
      }
    glutPostRedisplay();
    glFlush();
    print_position();
    break;

  case 3:
    printf("\nEnter X Y Z triple: ");
    scanf("%f %f %f", &x1, &y1, &z1);
    
    if (mtype == puma)
      solvePuma(x1,y1,z1);
    else if (mtype == moto)
      solveMoto(x1,y1,z1);
    else if (mtype == stan)
      solveStan(x1,y1,z1);
    else if (mtype == arb)
      solveArb(x1,y1,z1);

    display();
    print_position();
    glFlush();
    break;

  case 4:
    printf("Enter starting coordinates:");
    scanf("%f %f %f", &x1, &y1, &z1);
    printf("Number of via pts:");
    scanf("%d", &via);
    for (j = 0; j < via; j++)
      {
	printf("Enter via pt #%d coordinates:",j+1);
	scanf("%f %f %f", &viax[j], &viay[j], &viaz[j]);
      }
    printf("Enter ending coordinates:");
    scanf("%f %f %f", &x2, &y2, &z2);
    printf("Enter time between pts:");
    scanf("%f", &time);
    if (via == 0)
      {
	solveTrajectory(x1, x2, y1, y2, z1, z2, time);
	animateRobot(time);
      }
    else
      {
	solveTrajectory(x1,viax[0],y1,viay[0],z1,viaz[0],time);
	animateRobot(time);
	for (j = 1; j < via; j++)
	  {
	    solveTrajectory(viax[j-1],viax[j],viay[j-1],viay[j],viaz[j-1],viaz[j],time);
	    animateRobot(time);
	  }
	solveTrajectory(viax[via-1],x2,viay[via-1],y2,viaz[via-1],z2,time);
	animateRobot(time);
      }
	break;

      case 5:
      default:
	printf("Enter starting coordinates:");
	scanf("%f %f %f", &x1, &y1, &z1);
	printf("Enter ending coordinates:");
	scanf("%f %f %f", &x2, &y2, &z2);
	printf("Enter time between pts:");
	scanf("%f", &time);
	animateLinearRobot(x1,x2,y1,y2,z1,z2,time);
	break;
  }
}

/****************************************************
 *
 * void selectRobot
 *
 * Allows the user to enter arbitrary DH parameters
 * and initializes the GL callback functions.
 *
 ***************************************************/
void selectRobot()
{
  int j;
  int choice;
  i = 0;

  printf("Would you like to use:\n");
  printf("1) PUMA 560\n");
  printf("2) Motoman L-3\n");
  printf("3) Stanford Manipulator\n");
  printf("4) Arbitrary robot through DH parameters\n");
  scanf("%d", &choice);

  switch (choice)
    {
    case 1:
      loadPUMA();
      break;
    case 2:
      loadMoto();
      break;
    case 3:
      loadStan();
      break;
    case 4:
    default:
      mtype = arb;
      printf("Enter DH parameters:\n");
      printf("a[i] alpha[i] d[i] theta[i] (enter 999 to denote joint)\n");
      scanf("%f %f %f %f", &alpha[i], &a[i], &d[i], &theta[i]);
      while (a[i] != 999)
	{
	  if (d[i]==999)
	    {
	      type[i]=p;
	      d[i]=0;
	    }
	  else if (theta[i]==999)
	    {
	      type[i]=r;
	      theta[i]=0;
	    }
	  else
	    type[i]=f;

	  i++;
	  scanf("%f %f %f %f", &a[i], &alpha[i], &d[i], &theta[i]);
	}
      break;
    }

  for (j = 0; j < i; j++)
    makeTMatrix(j);

  multiplyTMatrix(i);
  //  display();
}


/****************************************************
 *
 * void main
 *
 * Calls the selection function and starts
 * GLU display.
 *
 ***************************************************/
int main(int argc, char** argv)
{
  int j;
  char c;
  i = 0;

  selectRobot();

  glutInit(&argc, argv);
  glutInitDisplayMode (GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGB);
  glutInitWindowSize (500, 500); 
  glutInitWindowPosition (100, 100);
  glutCreateWindow (argv[0]);
  init ();
  glutDisplayFunc(display); 
  glutReshapeFunc(reshape);
  glutKeyboardFunc(keyboard);
  glutMouseFunc(mouse);
  glutMainLoop();

  return 0;
}
