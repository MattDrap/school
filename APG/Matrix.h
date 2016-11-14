#ifndef MATRIX
#define MATRIX
#include "Vector4.h"
#include <cstring>
#include <cfloat>
using namespace std;
//Matrix
class Matrix{
public:
	float data[16];
	Matrix(){}
	inline Matrix(const float * datarix){
		load(datarix);
	}
	inline Matrix( const Matrix& other ){
		std::memcpy(data, other.data, 16 * sizeof(float));
	}
	inline void load(const float * datarix){
		std::memcpy(data, datarix, 16 * sizeof(float));
	}
	inline float const& operator[](int index) const
	{
		return data[index];
	} 

	friend ostream& operator<<(ostream& os, const Matrix& m);
};

ostream& operator<<(ostream& os, const Matrix& m) {
	for (int y = 0; y<4; y++)
	{
		for (int x = 0; x<4; x++)
			os << (float)m.data[x*4+y] << " ";
		os << "\n";
	}
	os << "\n";
	return os;
}

inline Matrix operator*(const Matrix& u,const Matrix &v) 
{ 
	float product [16];
	float * uf = (float*)u.data;
	float * uv = (float*)v.data;
	product[0] = uf[0] * uv[0] + uf[4] * uv[1] + uf[8] * uv[2] + uf[12] * uv[3];
	product[1] = uf[1] * uv[0] + uf[5] * uv[1] + uf[9] * uv[2] + uf[13] * uv[3];
	product[2] = uf[2] * uv[0] + uf[6] * uv[1] + uf[10] * uv[2] + uf[14] * uv[3];
	product[3] = uf[3] * uv[0] + uf[7] * uv[1] + uf[11] * uv[2] + uf[15] * uv[3];

	product[4] = uf[0] * uv[4] + uf[4] * uv[5] + uf[8] * uv[6] + uf[12] * uv[7];
	product[5] = uf[1] * uv[4] + uf[5] * uv[5] + uf[9] * uv[6] + uf[13] * uv[7];
	product[6] = uf[2] * uv[4] + uf[6] * uv[5] + uf[10] * uv[6] + uf[14] * uv[7];
	product[7] = uf[3] * uv[4] + uf[7] * uv[5] + uf[11] * uv[6] + uf[15] * uv[7];

	product[8] = uf[0] * uv[8] + uf[4] * uv[9] + uf[8] * uv[10] + uf[12] * uv[11];
	product[9] = uf[1] * uv[8] + uf[5] * uv[9] + uf[9] * uv[10] + uf[13] * uv[11];
	product[10] = uf[2] * uv[8] + uf[6] * uv[9] + uf[10] * uv[10] + uf[14] * uv[11];
	product[11] = uf[3] * uv[8] + uf[7] * uv[9] + uf[11] * uv[10] + uf[15] * uv[11];

	product[12] = uf[0] * uv[12] + uf[4] * uv[13] + uf[8] * uv[14] + uf[12] * uv[15];
	product[13] = uf[1] * uv[12] + uf[5] * uv[13] + uf[9] * uv[14] + uf[13] * uv[15];
	product[14] = uf[2] * uv[12] + uf[6] * uv[13] + uf[10] * uv[14] + uf[14] * uv[15];
	product[15] = uf[3] * uv[12] + uf[7] * uv[13] + uf[11] * uv[14] + uf[15] * uv[15];

	Matrix m;
	m.load(product);
	return m;
}

inline Vector4 operator*(const Matrix& u, const Vector4 &v)
{
	Vector4 product(0,0,0,0);
	//Matrix vector multiplication optimization - trust me i'm nearly engineer
	float * uf = (float*)u.data;
	product.x = uf[0] * v.x + uf[4] * v.y + uf[8] * v.z + uf[12] * v.w;
	product.y = uf[1] * v.x + uf[5] * v.y + uf[9] * v.z + uf[13] * v.w;
	product.z = uf[2] * v.x + uf[6] * v.y + uf[10] * v.z + uf[14] * v.w;
	product.w = uf[3] * v.x + uf[7] * v.y + uf[11] * v.z + uf[15] * v.w;

	return product;
}
#endif