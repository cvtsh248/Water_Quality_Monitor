#include <iostream>
#include <cmath>

using namespace std;

//calculate relationship between X and Y, use least square method

int main(){
	float m;
	float c;
	float x_mean = 0;
	float y_mean = 0;
	float data_x[5] = {0,0,0,0,0};
	float data_y[5] = {0,0,0,0,0};
	for (int n = 0; n < 5; n++) { //data in
		float x;
		float y;
		cout << "Enter X value: " ;
		cin >> x;
		cout << "\n";
		cout << "Enter Y value: ";
		cin >> y;
		data_x[n] = x;
		data_y[n] = y;
		cout << "\n";
	}
	float sigma_a = 0;
	float sigma_b = 0;
	for (int n = 0; n < 5; n++){ //mean
		x_mean += data_x[n];
		y_mean += data_y[n];
	}
	x_mean /= 5;
	y_mean /= 5;
	for (int n = 0; n < 5; n++){ //least square
		sigma_a += ((data_x[n] - x_mean)*(data_y[n] - y_mean));
		sigma_b += pow((data_x[n] - x_mean),2.0);
	}
	m = sigma_a/sigma_b;
	c = y_mean - m*x_mean;
	cout << "Gradient: " << m << "\n" <<  "Constant: " << c << "\n";
	cout << "y = " << m << "x + " << c << "\n";
	return 0;
}
