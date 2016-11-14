#ifndef VECTOR4
#define VECTOR4
#include <iostream>
#include <cmath>
using namespace std;
//Vector 4D
struct Vector4{
public:
	float x,y,z,w;
	Vector4() {}
	Vector4(float x,float y,float z) : x(x),y(y),z(z),w(1.0f) {}
	Vector4(float x,float y,float z, float w) : x(x),y(y),z(z),w(w){}
	Vector4(float x,float y) : x(x),y(y),z(0.0f),w(1.0f){}

	inline Vector4 operator+=(const Vector4 &u)
	{
		x+=u.x; y+=u.y; z+=u.z;
		return *this;
	}

	inline Vector4 operator-=(const Vector4 &u)
	{
		x -= u.x; y -= u.y; z -= u.z;
		return *this;
	}

	friend ostream& operator<<(ostream& os, const Vector4& m);
};

ostream& operator<<(ostream& os, const Vector4& m) {
	os << m.x << " " << m.y << " " << m.z << " " << m.w << "\n\n";
	return os;
}

//Vector operations
inline Vector4 operator*(const Vector4& u,const Vector4 &v) 
{ 
  return Vector4(u.x*v.x,u.y*v.y,u.z*v.z); 
}

inline Vector4 operator*(const float s, const Vector4& u)
{ 
  return Vector4(s*u.x,s*u.y,s*u.z); 
}

inline Vector4 operator*(const Vector4& u, const float s)
{ 
  return Vector4(s*u.x,s*u.y,s*u.z);
}

inline Vector4 operator/(const Vector4& u, const float s)
{ 
  return Vector4(u.x/s,u.y/s,u.z/s);
}

inline Vector4 operator+(const float s, const Vector4& u)
{ 
  return Vector4(s+u.x,s+u.y,s+u.z); 
}

inline Vector4 operator+(const Vector4& u, const float s)
{ 
  return Vector4(s+u.x,s+u.y,s+u.z);
}

inline Vector4 operator+(const Vector4& u, const Vector4& v)
{ 
  return Vector4(u.x+v.x,u.y+v.y,u.z+v.z); 
}

inline Vector4 operator-(const Vector4& u, const Vector4& v)
{ 
  return Vector4(u.x-v.x,u.y-v.y,u.z-v.z); 
}

inline Vector4 operator-(const Vector4& u)
{ 
  return Vector4(-u.x,-u.y,-u.z); 
}

inline float dot(const Vector4& u,const Vector4& v)
{
  return u.x*v.x + u.y*v.y + u.z*v.z;
}

inline Vector4 cross(const Vector4& u, const Vector4& v)
{
  return Vector4(u.y*v.z - u.z*v.y,
              u.z*v.x - u.x*v.z,
              u.x*v.y - u.y*v.x);
}

inline float length(const Vector4& u)
{
	return std::sqrt(dot(u,u));
}
inline Vector4 normalize(const Vector4& u)
{
  return (1.0f/length(u))*u;
}
#endif VECTOR4