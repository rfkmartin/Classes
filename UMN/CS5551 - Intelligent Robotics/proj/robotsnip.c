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

  theta[0] = (atan2(y,x) - atan2(d[2], \
								 sqrt(pow(x,2) + pow(y,2) - pow(d[2],2))));

  K = (pow(x,2) + pow(y,2) + pow(z,2) - pow(a[2],2) - \
	   pow(a[3],2) - pow(d[2],2) - pow(d[3],2))/(2*a[2]);

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
