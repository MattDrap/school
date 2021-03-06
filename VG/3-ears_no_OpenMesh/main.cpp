/* main.cpp
* 
* The third assignment code for the Computational Geometry Class, FEE CTU Prague
*
* Variant without OpenMesh
*
* author: Vojtech Bubnik and Petr Felkel {bubnivoj|felkepet}@felk.cvut.cz
* 
*/

//#define SKELETON
//#define GENERATE_POLYGONS

#include "targa.h"
#include <math.h>
#include <string>
#include <vector>
#include <set>
#include <unordered_map>
#include <iterator>
#include <limits.h>
#include <algorithm>

#include <iostream>
#include <iomanip>  // for stream output precision 
#include <fstream>

#include <assert.h>

#include "ExactPredicates.h"

template <class T>
struct Point
{
  typedef T	FloatType;
  T x;
  T y; 
  Point( T xx, T yy ) : x(xx), y(yy) {};
  Point() : x((T)0.0), y((T)0.0){};

  template<typename T2>
  Point<T2> convert() const { return Point<T2>((T2)x, (T2)y); }

  bool operator< ( const Point<T>& p) const { return x < p.x || (x==p.x && y < p.y); };
  bool operator== (const Point<T>& p) const { return (x==p.x && y==p.y ); }     
  bool operator!= (const Point<T>& p) const { return (x!=p.x || y!=p.y ); }

  Point<T>operator+(const Point<T> & p)
  {
    return( Point<T>(this->x + p.x, this->y + p.y));
  }

  T&		operator[](const int i)       { assert(i == 0 || i == 1); return (i == 0) ? x : y; }
  const T	operator[](const int i) const { assert(i == 0 || i == 1); return (i == 0) ? x : y; }
};

/** RGB image */
struct Image {
  uint16_t width;  // number of columns
  uint16_t height; // number of rows
  int size;
  int sizeInBytes;
  uint8_t * pixels;

  float xMin, xMax, yMin, yMax; // viewPort

  Image(const uint16_t _width = 500, const uint16_t _height = 500) : width(_width), height(_height)
  {	
    size = width * height;
    sizeInBytes = 3* size;
    pixels = new uint8_t[sizeInBytes];
    xMin = yMin = -2.0f;
    xMax = yMax = 2.0f;
  }
  ~Image() 
  {
    if(pixels) 
      delete(pixels);
  }
  // image with [0,0] in the lower left corner
  // x ... column
  // y ... row
  void setPixel(const int x, const int y, const int r, const int g, const int b)
  {
    if( x<0 || y < 0 || x >= width || y >= height )
      return;

    int pos = 3* ((height-y-1) * width + x);
    pixels[pos]   = b;
    pixels[pos+1] = g;
    pixels[pos+2] = r;
  }
  void drawPoint( const float x, const float y, const int r, const int g, const int b, const int pointRadius = 5)
  {
    if( x<xMin || y < yMin || x > xMax || y > yMax )
      return;

    int centerX = int((width-1) * (x-xMin) / (xMax - xMin));
    int centerY = int((height-1) * (y-yMin) / (yMax - yMin));
    for( int i=-pointRadius; i< pointRadius; i++)
      for( int j=-pointRadius; j< pointRadius; j++)
      {
        setPixel( centerX+i, centerY+j, r,g,b );
      }
      //setPixel( int(width * (x-xMin) / (xMax - xMin)), int(height * (y-yMin) / (yMax - yMin)), r,g,b);
  }
  template<typename T>
  void drawPoint( const Point<T> &p, const int r, const int g, const int b, const int pointRadius = 5)
  {
	  drawPoint((float)p[0], (float)p[1], r, g, b, pointRadius);
  }
  void drawLine(  float x1,  float y1,  float x2,  float y2, const int r, const int g, const int b )
  {  
    bresenhamLine( 
      (width-1)  * (x1-xMin) / (xMax - xMin),
      (height-1) * (y1-yMin) / (yMax - yMin),
      (width-1)  * (x2-xMin) / (xMax - xMin),
      (height-1) * (y2-yMin) / (yMax - yMin),
      r,g,b);        
  }
  template<typename T>
  void drawLine(const Point<T> &p1, const Point<T> &p2, const int r, const int g, const int b )
  {  
	  drawLine((float)p1[0], (float)p1[1], (float)p2[0], p2[1], r, g, b);
  }
  void bresenhamLine(  float x1,  float y1,  float x2,  float y2, const int r, const int g, const int b )
  {      
    // Bresenham's line algorithm
    // from http://rosettacode.org/wiki/Bitmap/Bresenham%27s_line_algorithm#C.2B.2B
    const bool steep = (fabs(y2 - y1) > fabs(x2 - x1));
    if(steep)
    {
      std::swap(x1, y1);
      std::swap(x2, y2);
    }

    if(x1 > x2)
    {
      std::swap(x1, x2);
      std::swap(y1, y2);
    }

    const float dx = x2 - x1;
    const float dy = fabs(y2 - y1);

    float error = dx / 2.0f;
    const int ystep = (y1 < y2) ? 1 : -1;
    int y = (int)y1;

    const int maxX = (int)x2;

    for(int x=(int)x1; x<maxX; x++)
    {
      if(steep)
      {
        setPixel(y,x, r,g,b);
      }
      else
      {
        setPixel(x,y, r,g,b);
      }

      error -= dy;
      if(error < 0)
      {
        y += ystep;
        error += dx;
      }
    }
  }
  void setViewPort(float _xMin, float _xMax, float _yMin, float _yMax ) 
  {
    xMin = _xMin;
    xMax = _xMax;
    yMin = _yMin;
    yMax = _yMax;
  }
  void erase()
  {
    uint8_t * pixelsPtr = pixels;
    for( int i=0; i<sizeInBytes; i++)
      *pixelsPtr++ = 0;
  }
  void write(const std::string fileName)
  {
    const uint8_t pixelDepth = 24;
    tga_write_bgr(fileName.c_str(), pixels,  width, height, pixelDepth);
  }
};

// stream input, white space seaparated
template< class T>
std::istream & operator>>( std::istream& in, Point<T> & p)
{
  T x,y;
  in >> x >> y;
  if( in )
    p = Point<T>(x,y);
  return in;
}

// stream output for 2d point in debugging format
template< class T>
std::ostream& operator<<( std::ostream& out, const Point<T>& p) {
  out << "Point( " << std::setprecision(18) << p.x << ", " 
    << std::setprecision(18) << p.y << ')';
  return out;
} 

enum OrientationType
{
  ORIENTATION_UNDEF  = INT_MAX,
  RIGHT_TURN	= -1,
  STRAIGHT	= 0,
  LEFT_TURN	= 1
};

// The naive version of the operator as 2x2 determinant ()()-()()
template <typename T>
struct Orient2dNaive
{
  OrientationType operator()(Point<T> a, Point<T> b, Point<T> c)
  {   
    T result =  (a[0] - c[0])*(b[1]-c[1]) - (a[1] - c[1])*(b[0]-c[0]);  //PIVOT c
    
    if(result > (T)0)
      return LEFT_TURN;
    else if (result < (T)0)
      return RIGHT_TURN;
    else 
      return STRAIGHT;
  }
};

/// test, if point d is in the circumcircle to points a,b,c
template <typename T>
struct Orient2dExact
{
  OrientationType operator()(Point<T> a, Point<T> b, Point<T> c)
  {    

	T result = ExactPredicates::orient2dexact( &a[0], &b[0], &c[0] );  //PIVOT a

    if(result > 0.0)
      return LEFT_TURN;
    else if (result < 0.0)
      return RIGHT_TURN;
    else 
      return STRAIGHT;
  }
};

enum InsideOutsideType
{
  INOUT_UNDEF		= INT_MAX,
  INOUT_INSIDE		= -1,
  INOUT_BOUNDARY	= 0,
  INOUT_OUTSIDE		= 1
};

/// test, if point d is in the circumcircle to points a,b,c
template< class T>
struct InCircleNaive
{
  InsideOutsideType operator()(Point<T> a, Point<T> b, Point<T> c, Point<T> d)
  {   
	  Point<T> ad(a.x - d.x, a.y - d.y);
	  Point<T> bd(b.x - d.x, b.y - d.y);
	  Point<T> cd(c.x - d.x, c.y - d.y);
      T abdet = ad[0] * bd[1] - bd[0] * ad[1];
	  T bcdet = bd[0] * cd[1] - cd[0] * bd[1];
	  T cadet = cd[0] * ad[1] - ad[0] * cd[1];
	  T alift = ad[0] * ad[0] + ad[1] * ad[1];
	  T blift = bd[0] * bd[0] + bd[1] * bd[1];
	  T clift = cd[0] * cd[0] + cd[1] * cd[1];
	  T det = alift * bcdet + blift * cadet + clift * abdet;
	  return (det > 0) ? INOUT_INSIDE : ((det < 0) ? INOUT_OUTSIDE : INOUT_BOUNDARY);
  }
};

/// test, if point d is in the circumcircle to points a,b,c
template< class T>
struct InCircleExact
{
  InsideOutsideType operator()(Point<T> a, Point<T> b, Point<T> c, Point<T> d)
  {   
	 T det = ExactPredicates::incircle(&a[0], &b[0], &c[0], &d[0]);
	 return (det > 0) ? INOUT_INSIDE : ((det < 0) ? INOUT_OUTSIDE : INOUT_BOUNDARY);
  }
};

template<typename T, typename ORIENT, typename INCIRCLE>
struct Kernel {
  typedef T											FloatType;
  typedef Point<T>									PointType;
  typedef ORIENT									Orient;
  typedef INCIRCLE									InCircle;
};

/// Read a list of points from a file. Returns number of points read.
template <class OutputIterator>
int read_points( const char* filename, OutputIterator points) {
  std::ifstream in( filename, std::ios::binary);
  if ( ! in) {
    std::cerr << "Error: cannot open file `" << filename <<
      "' for reading." << std::endl;
    return 0;
  }
  return read_points( in, points);
} 

/// Reads a list of points of given point type KERNEL::PointType from a file. Returns number of points read.
template <class KERNEL, class OutputIterator> 
int readPoints( std::string inputFileName, OutputIterator points )
{
  int returnValue;
  int n = 0;

  std::ifstream inFile( inputFileName + ".txt" );

  if ( !inFile.is_open() ) 
  {
    std::cerr <<  "Cannot open " << inputFileName << std::endl;
    returnValue = -1;
  } else {
    if( !inFile.eof() )
    {
      typename KERNEL::PointType p;
      while( inFile >> p[0] && inFile >> p[1] )
      {
        *points++ = p;
        n++;
      }
    }
    returnValue = n;
  }

  inFile.close();

  return returnValue;
}

// Write opoints to file
template<class ForwardIterator>
int writePoints( std::string outputFileName, const ForwardIterator first, const ForwardIterator last )
{ 
  if(first == last)
    return -1;

  int returnValue = 0;
  std::ofstream outFile( outputFileName + ".txt" );

  if ( !outFile.is_open() )  {
    std::cerr <<  "Cannot open " << outFile << std::endl;
    returnValue = -1;
  } 
  else {
    for( ForwardIterator i = first; i != last; i++)
    {
      outFile << std::setprecision(18) << (*i)[0] << " " << (*i)[1] << std::endl;
    }
    outFile.close();
  }
  return returnValue;
}

/** Draw mesh into an image 
 *
 */
template<class POINT>
void drawMesh(const std::vector<POINT> &points, std::vector<int> &triangles, Image & image)
{
	// Draw inner edges.
    for (size_t i = 0; i < triangles.size(); i += 3) {
		image.drawLine(points[triangles[i    ]], points[triangles[i + 1]], 255, 0, 0);
		image.drawLine(points[triangles[i + 1]], points[triangles[i + 2]], 255, 0, 0);
		image.drawLine(points[triangles[i + 2]], points[triangles[i    ]], 255, 0, 0);
	}

	// Draw boundary edges.
	for (size_t i = 0; i < points.size(); ++ i) {
		int j = (i + 1 == points.size()) ? 0 : i + 1;
		image.drawLine(points[i], points[j], 255, 255, 255);
	}

	// Draw vertices.
	const int pointRadius = 2;
	for (size_t i = 0; i < points.size(); ++ i)
		image.drawPoint(points[i], 0, 0, 255, pointRadius);

	// Draw first point.
	image.drawPoint(points[0], 255, 0, 0, pointRadius);
	image.drawPoint(points[1], 0, 255, 0, pointRadius);
}

template  <class ForwardIterator>
void updateImageViewport( const ForwardIterator first, const ForwardIterator last, Image & image )
{ 
  const float BORDER = 0.05f;
  if(first == last)
    return;

  float xMin, yMin, xMax, yMax;
  xMin = xMax = (float)(*first)[0];
  yMin = yMax = (float)(*first)[1];

  ForwardIterator i = first;
  i++;
  for( ; i != last; i++)
  {
    xMin = std::min( xMin, (float)(*i)[0] );
    xMax = std::max( xMax, (float)(*i)[0] );
    yMin = std::min( yMin, (float)(*i)[1] );
    yMax = std::max( yMax, (float)(*i)[1] );    
  }
  xMin -= (xMax-xMin) * BORDER;
  xMax += (xMax-xMin) * BORDER;
  yMin -= (yMax-yMin) * BORDER;
  yMax += (yMax-yMin) * BORDER;
  image.setViewPort( xMin, xMax, yMin, yMax );
}


template  <class ForwardIterator>
void printPoints( const ForwardIterator first, const ForwardIterator last )
{
	for( ForwardIterator i = first; i != last; i++)
		std::cout << "Point( " << std::setprecision(18) << (*i)[0] << ", " << std::setprecision(18) << (*i)[1] << ')' << std::endl;
}

//****************************************************************************************
template<typename POINT, typename ORIENT>
class PolygonEar
// ======== BEGIN OF SOLUTION - TASK 1-1 ======== //
{
};
// ========  END OF SOLUTION - TASK 1-1  ======== //

/** The ear cutting procedure
 *  @param[in]   points    - Input, simple polygon
 *  @param[out]  triangles - Indices of triangle vertices - three consecutive vertices form a triangle
 */template<typename KERNEL>
bool TriangulateFaceByEarCutting(
	const std::vector<typename KERNEL::PointType> &points,
	std::vector<int> &faces)
	// ======== BEGIN OF SOLUTION - TASK 2-1 ======== //
{
	std::vector<typename KERNEL::PointType> my_points = points;
	std::vector<int> point_ind;
	for (int i = 0; i < my_points.size(); i++) {
		point_ind.push_back(i);
	}
	TriangulateRecurssion<KERNEL>(my_points, faces, point_ind, 0);
	
	// Implement the ear cutting procedure
	return false;
};
template<typename KERNEL>
void TriangulateRecurssion(std::vector<typename KERNEL::PointType> points,
	std::vector<int> &faces, std::vector<int> indices, int index) {
	typedef KERNEL::PointType point;
	typename KERNEL::Orient orient;
	if (points.size() == 3) {
		faces.push_back(indices[0]);
		faces.push_back(indices[1]);
		faces.push_back(indices[2]);
		return;
	}
	int ind1 = (index - 1 + points.size()) % points.size();
	int ind2 = (index + 1 + points.size()) % points.size();

	if (isEar<KERNEL>(points, index)) {
		points.erase(points.begin() + index);
		faces.push_back(indices[ind1]);
		faces.push_back(indices[index]);
		faces.push_back(indices[ind2]);
		indices.erase(indices.begin() + index);

		TriangulateRecurssion<KERNEL>(points, faces, indices, 0);
		return;
	}
	//Create Bisector and find first intersection
	point predir(0.5 * (points[ind1].x + points[ind2].x), 0.5 * (points[ind1].y + points[ind2].y));
	point origin = points[index];
	point dir((predir.x - origin.x), (predir.y - origin.y));
	KERNEL::FloatType norm = sqrt(dir.x * dir.x + dir.y * dir.y);
	dir.x = (dir.x / norm);
	dir.y = (dir.y / norm);
	int k1 = -1, k2 = -1;
	KERNEL::FloatType mint2;
	point v3(-dir.y, dir.x);
	KERNEL::FloatType mint = 100000;
	KERNEL::FloatType maxt = -100000;
	bool convex = orient(points[ind1], points[index], points[ind2]) == OrientationType::LEFT_TURN;
	for (int e1 = 0; e1 < points.size(); e1++) {
		int e2 = (e1 + 1 + points.size()) % points.size();
		if (e1 != index && e2 != index) {
			point v1(origin.x - points[e1].x, origin.y - points[e1].y);
			point v2(points[e2].x - points[e1].x, points[e2].y - points[e1].y);

			KERNEL::FloatType pret = v2.x*v1.y - v2.y*v1.x;
			KERNEL::FloatType pret2 = v1.x * v3.x + v1.y * v3.y;
			KERNEL::FloatType pret1 = v2.x * v3.x + v2.y * v3.y;
			KERNEL::FloatType t1 = pret / pret1;

			KERNEL::FloatType t2 = pret2 / pret1;

			if (convex) {
				if (t1 < mint && t1 > 0 && t2 >= 0 && t2 <= 1) {
					mint = t1;
					k1 = e1;
					k2 = e2;
					mint2 = t2;
				}
			}
			else {
				if (t1 > maxt && t1 < 0 && t2 >= 0 && t2 <= 1) {
					maxt = t1;
					k1 = e1;
					k2 = e2;
					mint2 = t2;
				}
			}
		}
	}
	//Failure test
	if (k1 == -1) {
		return;
	}
	//Add possible cuts
	std::vector<int> possibles;
	point y(points[k1].x + mint2 * (points[k2].x - points[k1].x), points[k1].y + mint2 * (points[k2].y - points[k1].y));
	for (int j = 0; j < points.size(); j++) {
		if (j != k1 && j != index) {
			OrientationType test1 = orient(y, points[index], points[j]);
			OrientationType test2 = orient(points[index], points[k1], points[j]);
			OrientationType test3 = orient(points[k1], y, points[j]);
			if (test1 == OrientationType::LEFT_TURN &&
				test2 == OrientationType::LEFT_TURN &&
				test3 == OrientationType::LEFT_TURN) {
				if(j != ind1 && j != ind2) {
					possibles.push_back(j);
				}
			}
		}
		if (j != k2 && j != index) {
			OrientationType test1 = orient(points[index], y, points[j]);
			OrientationType test2 = orient(y, points[k2], points[j]);
			OrientationType test3 = orient(points[k2], points[index], points[j]);
			if (test1 == OrientationType::LEFT_TURN &&
				test2 == OrientationType::LEFT_TURN &&
				test3 == OrientationType::LEFT_TURN) {
				if (j != ind1 && j != ind2) {
					possibles.push_back(j);
				}
			}
		}
	}
	if (k1 != ind1 && k1 != ind2) {
		possibles.push_back(k1);
	}
	if (k2 != ind1 && k2 != ind2) {
		possibles.push_back(k2);
	}
	//Find polygon diagonal cut
	int best = 0;
	for (int j = 0; j < possibles.size(); j++) {
		point origin = points[index];
		point dir( (points[possibles[j]].x - origin.x), ( points[possibles[j]].y - origin.y ) );
		point v3(-dir.y, dir.x);
		bool is_in = true;
		for (int e1 = 0; e1 < points.size(); e1++) {
			int e2 = (e1 + 1) % points.size();
			if (e1 != index && e2 != index) {
				point v1(origin.x - points[e1].x, origin.y - points[e1].y);
				point v2(points[e2].x - points[e1].x, points[e2].y - points[e1].y);

				KERNEL::FloatType pret = v2.x*v1.y - v2.y*v1.x;
				KERNEL::FloatType pret2 = v1.x * v3.x + v1.y * v3.y;
				KERNEL::FloatType pret1 = v2.x * v3.x + v2.y * v3.y;
				KERNEL::FloatType t1 = pret / pret1;
				KERNEL::FloatType t2 = pret2 / pret1;
				if (t1 < 1 && t1 > 0 && t2 >= 0 && t2 <= 1) {
					is_in = false;
					break;
				}
			}
		}
		if (is_in) {
			best = possibles[j];
		}
	}
	//Take points, split them and recursion
	int start = best < index ? best : index;
	int end = best < index ? index : best;
	int var = start;
	std::vector<typename KERNEL::PointType> inner_points1;
	std::vector<int> inner_indices1;
	while (var != end) {
		inner_points1.push_back(points[var]);
		inner_indices1.push_back(indices[var]);
		var = (var + 1) % points.size();
	}
	inner_indices1.push_back(indices[var]);
	inner_points1.push_back(points[var]);

	var = end;
	std::vector<typename KERNEL::PointType> inner_points2;
	std::vector<int> inner_indices2;
	while (var != start) {
		inner_points2.push_back(points[var]);
		inner_indices2.push_back(indices[var]);
		var = (var + 1) % points.size();
	}
	inner_indices2.push_back(indices[var]);
	inner_points2.push_back(points[var]);

	TriangulateRecurssion<KERNEL>(inner_points1, faces, inner_indices1, rand() % (inner_points1.size() - 1));
	TriangulateRecurssion<KERNEL>(inner_points2, faces, inner_indices2, rand() % (inner_points2.size() - 1));
};
template<typename KERNEL>
bool isEar(std::vector<typename KERNEL::PointType> &points, int ind) {
	typename KERNEL::Orient orient;
	int ind1 = (ind - 1 + points.size()) % points.size();
	int ind2 = (ind + 1 + points.size()) % points.size();

	OrientationType d = orient(points[ind1], points[ind], points[ind2]);

	if (d == LEFT_TURN) {
		bool not_in = true;
		for (int j = 0; j < points.size(); j++) {
			if (j != ind1 && j != ind2 && j != ind) {
				OrientationType test1 = orient(points[ind1], points[ind], points[j]);
				OrientationType test2 = orient(points[ind], points[ind2], points[j]);
				OrientationType test3 = orient(points[ind2], points[ind1], points[j]);
				if (test1 == OrientationType::LEFT_TURN &&
					test2 == OrientationType::LEFT_TURN &&
					test3 == OrientationType::LEFT_TURN) {
					return false;
				}
			}
		}
		return true;
	}
	return false;
};

template<typename KERNEL>
bool TriangulateFaceByEarCutting2(
	const std::vector<typename KERNEL::PointType> &points,
	std::vector<int> &faces)
	// ======== BEGIN OF SOLUTION - TASK 2-1 ======== //
{
	typename KERNEL::Orient orient;
	std::vector<typename KERNEL::PointType> my_points = points;
	std::vector<int> point_ind;
	for (int i = 0; i < my_points.size(); i++) {
		point_ind.push_back(i);
	}
	while (my_points.size() > 3) {
		for (int i = 0; i < my_points.size(); i++) {
			int ind = i;
			int ind1 = (ind - 1 + my_points.size()) % my_points.size();
			int ind2 = (ind + 1 + my_points.size()) % my_points.size();
			
			OrientationType d = orient(my_points[ind1], my_points[ind], my_points[ind2]);

			if (d == LEFT_TURN) {
				bool is_in = false;
				for (int j = 0; j < my_points.size(); j++) {
					if (j != ind1 && j != ind2 && j != ind) {
						OrientationType test1 = orient(my_points[ind1], my_points[ind], my_points[j]);
						OrientationType test2 = orient(my_points[ind], my_points[ind2], my_points[j]);
						OrientationType test3 = orient(my_points[ind2], my_points[ind1], my_points[j]);
						if (test1 == OrientationType::LEFT_TURN &&
							test2 == OrientationType::LEFT_TURN &&
							test3 == OrientationType::LEFT_TURN) {
							is_in = true;
							break;
						}
					}
				}
				if(is_in == false){
					my_points.erase(my_points.begin() + ind);
					faces.push_back(point_ind[ind1]);
					faces.push_back(point_ind[ind]);
					faces.push_back(point_ind[ind2]);
					point_ind.erase(point_ind.begin() + ind);
					break;
				}
			}
		}
	}
	faces.push_back(point_ind[0]);
	faces.push_back(point_ind[1]);
	faces.push_back(point_ind[2]);
	// Implement the ear cutting procedure
	return false;
};
// ========  END OF SOLUTION - TASK 2-1  ======== //


/// Edge cosnsists of two point indices - ordered for usage as a key in hash map
struct Edge
{
	Edge(int v1, int v2) : vertex1(v1), vertex2(v2) { assert(v1 != v2); if (v1 > v2) std::swap(vertex1, vertex2); }
	bool operator<(const Edge &e2) const { return vertex1 < e2.vertex1 || (vertex1 == e2.vertex1 && vertex2 < e2.vertex2); }
	bool operator==(const Edge &e2) const { return vertex1 == e2.vertex1 && vertex2 == e2.vertex2; }
	int vertex1;
	int vertex2;
};

// hash map of edges
namespace std {
	template <>
	struct hash<Edge>
	{
		std::size_t operator()(const Edge& k) const {
			return k.vertex1 * 3571 + k.vertex2;
		}
	};
}

typedef std::unordered_map<Edge, std::pair<int, int> > EdgeMap;


/** Add edge to EdgeMap
 *  Create edge, if it does not exist and store face as its first face
 *  or add its second face to the existing edge
 */
void AddEdge(EdgeMap &edges, const Edge &edge, int face)
{
	auto it = edges.find(edge);
	if (it == edges.end())
		edges.insert(std::make_pair(edge, std::pair<int, int>(face, -1)));
	else {
		assert(it->first.vertex1 == edge.vertex1);
		assert(it->first.vertex2 == edge.vertex2);
		assert(it->second.first != -1);
		assert(it->second.second == -1);
		it->second.second = face;
	}
}

/** Remove edge from EdgeMap 
 *  Erase it, or make the face its first face
 */
void RemoveEdge(EdgeMap &edges, const Edge &edge, int face)
{
	assert(face != -1);
	auto it = edges.find(edge);
	assert(it != edges.end());
	assert(it->first.vertex1 == edge.vertex1);
	assert(it->first.vertex2 == edge.vertex2);
	if (it->second.second == -1) {
		assert(it->second.first == face);
		edges.erase(it);
	} else {
		if (it->second.first == face)
			std::swap(it->second.first, it->second.second);
		assert(it->second.first != -1);
		assert(it->second.second == face);
		it->second.second = -1;
	}
}

bool IsBoundaryEdge(const EdgeMap &edges, const Edge &edge)
{
	auto it = edges.find(edge);
	assert(it != edges.end());
	assert(it->second.first != it->second.second);
	assert(it->second.first != -1 || it->second.second != -1);
	return it->second.first == -1 || it->second.second == -1;
}


/** Take a mesh triangulation and convert it to dealaunay triangulation
 *  @param[in]       points    - Input, simple polygon
 *  @param[in, out]  triangles - Indices of triangle vertices - three consecutive vertices form a triangle. 
 */
template<typename KERNEL>
bool MakeDelaunayByDiagonalFlipping(
	const std::vector<typename KERNEL::PointType> &points,
	std::vector<int> &triangles)
{

// ======== BEGIN OF SOLUTION - TASK 2-2 ======== //
  // implement this code
  return false;
// ========  END OF SOLUTION - TASK 2-2  ======== //

}

/// test the EarCutting (CT) and Delaunay triangulations (CDT)
template <class KERNEL> 
void testCDT( std::string dir, std::string filename, Image & image )
{
  // set the floating point unit 
  // just to have equal conditions on different HW
  if (sizeof(typename KERNEL::FloatType) == 4)
    ExactPredicates::setFPURoundingTo24Bits();
  else
    ExactPredicates::setFPURoundingTo53Bits();

  typedef typename KERNEL::PointType VecType;
  std::vector<VecType> points;
  readPoints<KERNEL>( filename, std::back_inserter(points) );
  updateImageViewport(points.begin(), points.end(), image);

  std::cout << "Input: "<< filename << std::endl;
  printPoints( points.begin(), points.end());

  // Initialize mesh structure with a single face representing the input simple polygon.
  std::vector<int> triangles;

  image.erase();
  drawMesh(points, triangles, image);
  image.write((dir+"/"+filename+"-input"+".tga").c_str());


  TriangulateFaceByEarCutting<KERNEL>(points, triangles);

  image.erase();
  drawMesh(points, triangles, image);
  image.write((dir+"/"+filename+"-CT"+".tga").c_str());

  MakeDelaunayByDiagonalFlipping<KERNEL>(points, triangles);

  image.erase();
  drawMesh(points, triangles, image);
  image.write((dir+"/"+filename+"-CDT"+".tga").c_str());
}

#ifdef GENERATE_POLYGONS
#endif  /* GENERATE_POLYGONS */

int main()
{
  // Shewchuk exact predicate arithmetic initialization - DO NOT FORGET!!!
  ExactPredicates::exactinit();

#ifdef GENERATE_POLYGONS
#endif /* GENERATE_POLYGONS */

  // TEST DIFFERENT PRECISION on float and double
  Image image(800, 800);

  typedef Kernel<float,  Orient2dNaive<float>,   InCircleNaive<float>>	KernelFloatInexact2;
  typedef Kernel<double, Orient2dNaive<double>,  InCircleNaive<double>>	KernelDoubleInexact2;
  typedef Kernel<double, Orient2dExact<double>,  InCircleExact<double>>	KernelDoubleAdaptiveShewchuk;

  for( int i = 1; i <=5; i++ )
  { 
    //std::string inputFile = "points" + std::to_string(i);  // for VS2012 - correct std string
	  std::string inputFile = "simple_polygon_" + std::to_string(static_cast<long long>(i)); // for VS2010 - wrong std string
    testCDT<KernelDoubleAdaptiveShewchuk>( "adaptive", inputFile, image );
    testCDT<KernelFloatInexact2>( "float", inputFile, image );
    testCDT<KernelFloatInexact2>( "double", inputFile, image );
  }

  return 0;
}
