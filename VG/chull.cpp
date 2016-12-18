/* chull.cpp
* 
* The second assignment code for the Computational Geometry Class, FEE CTU Prague
* 
* author: Petr Felkel and Vojtech Budnik, {felkepet|bubnivoj}@felk.cvut.cz
* 
*/

//#define SKELETON

#include "targa.h"
#include <math.h>
#include <string>
#include <vector>
#include <stack>
#include <algorithm> // sort
#include <iterator>  // back_inserter

#include <iostream>
#include <iomanip>  // for stream output precision 
#include <fstream>

#include <assert.h>

#include "predicates.h"


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
  void drawPoint( const float x, const float y, const int r, const int g, const int b)
  {
    const int POINT_SIZE = 5;

    if( x<xMin || y < yMin || x > xMax || y > yMax )
      return;

    int centerX = int((width-1) * (x-xMin) / (xMax - xMin));
    int centerY = int((height-1) * (y-yMin) / (yMax - yMin));
    for( int i=-POINT_SIZE; i< POINT_SIZE; i++)
      for( int j=-POINT_SIZE; j< POINT_SIZE; j++)
      {
        setPixel( centerX+i, centerY+j, r,g,b );
      }
      //setPixel( int(width * (x-xMin) / (xMax - xMin)), int(height * (y-yMin) / (yMax - yMin)), r,g,b);
  }
  //template  <class ForwardIterator>
  //void drawPoints( ForwardIterator first, ForwardIterator last )
  //{
  //  for( ForwardIterator i = first; i != last; i++)
  //    drawPoint( (*i).x, (*i).y,  0,255,0 ); 
  //}
  void drawLine(  float x1,  float y1,  float x2,  float y2, const int r, const int g, const int b )
  {  
    bresenhamLine( 
      (width-1)  * (x1-xMin) / (xMax - xMin),
      (height-1) * (y1-yMin) / (yMax - yMin),
      (width-1)  * (x2-xMin) / (xMax - xMin),
      (height-1) * (y2-yMin) / (yMax - yMin),
      r,g,b);        
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

template <class T>
struct Point
{
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
struct Orient2dNaive2
{
  OrientationType operator()(Point<T> a, Point<T> b, Point<T> c)
  {   
    T result =  (a.x - c.x)*(b.y-c.y) - (a.y - c.y)*(b.x-c.x);  //PIVOT c
    
    if(result > (T)0)
      return LEFT_TURN;
    else if (result < (T)0)
      return RIGHT_TURN;
    else 
      return STRAIGHT;
  }
};


template <typename T>
struct Orient2dNaiveShewchuk
{
  // Shewchuk uses the third point as pivot 
  OrientationType operator()(Point<T> a, Point<T> b, Point<T> c)
  {    	
    T result = orient2dfast( &a.x, &b.x, &c.x );  //PIVOT c

    if(result > 0.0)
      return LEFT_TURN;
    else if (result < 0.0)
      return RIGHT_TURN;
    else 
      return STRAIGHT;
  }
};

template <typename T>
struct Orient2dExact
{
  OrientationType operator()(Point<T> a, Point<T> b, Point<T> c)
  {    

    T result = orient2dexact( &a.x, &b.x, &c.x );  //PIVOT a

    if(result > 0.0)
      return LEFT_TURN;
    else if (result < 0.0)
      return RIGHT_TURN;
    else 
      return STRAIGHT;
  }
};

template <typename T>
struct Orient2dAdaptive
{
  OrientationType operator()(Point<T> a, Point<T> b, Point<T> c)
  {    

    T result = orient2d( &a.x, &b.x, &c.x );  //PIVOT c

    if(result > 0.0)
      return LEFT_TURN;
    else if (result < 0.0)
      return RIGHT_TURN;
    else 
      return STRAIGHT;
  }
};


// Returns true if r is on the extension of the ray starting in q in
// the direction q-p, i.e., if (q-p)*(r-q) >= 0, and false otherwise.
// Naive implementation, which is not precise with float / double types,
// but may deliver more precise results than Extended2dExact if the points are not exactly collinear.
template< class T>
struct Extended2dNaive
{
  bool operator()(Point<T> p, Point<T> q, Point<T> r)
  {   
    return ((q.x-p.x) * (r.x-q.x) >= (p.y-q.y) * (r.y-q.y));
  }
};

// Returns true if r is on the extension of the ray starting in q in
// the direction q-p, i.e., if (q-p)*(r-q) >= 0, and false otherwise.
// Exact implementation, works only if p, q, r are collinear.
template< class T>
struct Extended2dExact
{
  bool operator()(Point<T> p, Point<T> q, Point<T> r)
  {   
     assert(Orient2dAdaptive<T>()(p, q, r) == STRAIGHT);
     return ( p.x == q.x ) ?
       ( (p.y <= q.y) ? (q.y <= r.y) : (q.y >= r.y) ) :
       ( (p.x <= q.x) ? (q.x <= r.x) : (q.x >= r.x) );
  }
};





template<typename T, typename ORIENT, typename EXTENDED>
struct Kernel {
  typedef typename T		    FloatType;
  typedef typename ORIENT	  Orient;
  typedef typename EXTENDED	Extended;
};



// Reads a list of points from a file. Returns number of points read.
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
      Point<KERNEL::FloatType> p;
      while( inFile >> p )
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

template<class ForwardIterator>
int writePoints( std::string outputFileName, const ForwardIterator first, const ForwardIterator last )
{ 
  if(first == last)
    return -1;

  int returnValue = 0;
  std::ofstream outFile( outputFileName + ".txt" );

  if ( !outFile.is_open() )  {
    std::cerr <<  "Cannot open " << outputFileName << std::endl;
    returnValue = -1;
  } 
  else {
    for( ForwardIterator i = first; i != last; i++)
    {
      outFile << std::setprecision(18) << (*i).x << " " << (*i).y << std::endl;
    }
    outFile.close();
  }
  return returnValue;
}

template <class ForwardIterator>
void drawPolygon( const ForwardIterator first, const ForwardIterator last, Image & image )
{
  if(first == last)
    return;

  ForwardIterator ii = first;
  ForwardIterator i = first;
  for( i++; i != last; i++)
  {
    image.drawLine( (float)(*ii).x, (float)(*ii).y, (float)(*i).x, (float)(*i).y, 255,255,255 );
    ii = i;
  }
  image.drawLine( (float)(*ii).x, (float)(*ii).y, (float)(*first).x, (float)(*first).y, 255,255,128 );
}

template  <class ForwardIterator>
void drawPoints( const ForwardIterator first, const ForwardIterator last, Image & image, const int r = 0, const int g = 255, const int b = 0 )
{
 if(first == last)
    return;

 for( ForwardIterator i = first; i != last; i++)
    image.drawPoint( (float)(*i).x, (float)(*i).y,  r, g, b ); 
}

template  <class ForwardIterator>
void updateImageViewport( const ForwardIterator first, const ForwardIterator last, Image & image )
{ 
  const float BORDER = 0.05f;
  if(first == last)
    return;

  float xMin, yMin, xMax, yMax;
  xMin = xMax = (float)(*first).x;
  yMin = yMax = (float)(*first).y;

  ForwardIterator i = first;
  i++;
  for( ; i != last; i++)
  {
    xMin = std::min( xMin, (float)(*i).x );
    xMax = std::max( xMax, (float)(*i).x );
    yMin = std::min( yMin, (float)(*i).y );
    yMax = std::max( yMax, (float)(*i).y );    
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
    std::cout << *i << std::endl;
}


template <class KERNEL, class ForwardIterator, class OutputIterator>  
OutputIterator jarvisHull(const ForwardIterator first, const ForwardIterator last,
                          OutputIterator  result) 
{
  typedef typename KERNEL::FloatType FloatType;    
  typename KERNEL::Orient				orient; 
  typename KERNEL::Extended     extended;

  if ( first == last)
    return result; 
// ======== BEGIN OF SOLUTION - TASK 1-1 ======== //
  // Implement Jarvis' march (gift wrapping) algorithm 
  // store the CCW convex hull in result
// ========  END OF SOLUTION - TASK 1-1  ======== //
  ForwardIterator first_point = std::min_element(first, last);
  ForwardIterator p = first_point;
  ForwardIterator q;
  size_t n = last - first;
  Orient2dAdaptive<REAL> gts;
  //for (int i = 0; i < n; i++) {
  while(true){
	  *(result++) = *p;

	  q = p + 1;
	  if(q == last) {
		  q = first;
	  }

	  for (ForwardIterator r = first; r != last; ++r) {
		  OrientationType gt = gts(*p, *q, *r);
		  OrientationType d = orient(*p, *q, *r);
		  if (gt != d) {
			  std::cout << "Mismatch";
		  }
		  if (d == OrientationType::RIGHT_TURN) {
			  q = r;
		  }
		  else {
			  if (d == OrientationType::STRAIGHT && extended(*p, *q, *r)) {
				  q = r;
			  }
		  }
	  }
	  p = q;
	  if (first_point == q) {
		  break;
	  }
  }

  return result;
}

//// Implementation of Andrew's monotone chain 2D convex hull algorithm.
////http://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain#C.2B.2B
//// Asymptotic complexity: O(n log n).
//// Practical performance: 0.5-1.0 seconds for n=1000000 on a 1GHz machine.
//typedef double coord_t;         // coordinate type
//typedef double coord2_t;  // must be big enough to hold 2*max(|coordinate|)^2
// 
// Returns a list of points on the convex hull in counter-clockwise order.
template <class KERNEL, class ForwardIterator, class OutputIterator>  
OutputIterator grahamHull(const ForwardIterator first, const ForwardIterator last,
	OutputIterator  result)
{
	typedef typename KERNEL::FloatType FloatType;
	typename KERNEL::Orient				orient;

	if (first == last)
		return result;
	std::sort(first, last);

	std::vector<Point<FloatType>> hull(2 * (last - first));
  int k = 0;
  for (ForwardIterator iter = first; iter != last; ++iter) {
	  while (k >= 2 && orient(hull[k - 2], hull[k - 1], *iter) <= 0) {
		  k--;
	  }
	  hull[k++] = *iter;
  }

  int t = k + 1;
  for (ForwardIterator iter = last - 2; iter != first; --iter) {
	  while (k >= t && orient(hull[k - 2], hull[k - 1], *iter) <= 0) {
		  k--;
	  }
	  hull[k++] = *iter;
  }
  //Add first check
  while (k >= t && orient(hull[k - 2], hull[k - 1], *first) <= 0) {
	  k--;
  }
  hull[k++] = *first;
  //
  hull.resize(k - 1);
  
  std::copy(hull.begin(), hull.end(), result);

// ======== BEGIN OF SOLUTION - TASK 1-2 ======== //
  // Implement Graham scan algorithm 
  // store the CCW convex hull in result
// ========  END OF SOLUTION - TASK 1-2  ======== //


  return result;
}

template <class ForwardIterator>
void drawConvexHull(const ForwardIterator pointsFirst, const ForwardIterator pointsLast, const ForwardIterator hullFirst, const ForwardIterator hullLast, Image & image )
{
  drawPolygon( hullFirst, hullLast, image);

  drawPoints( pointsFirst, pointsLast, image,  0, 255, 0 );  // input points in green 

  if(hullFirst == hullLast)
    return;

  drawPoints( hullFirst, hullLast, image, 0, 0, 255  );      // hull points in blue
  ForwardIterator next = hullFirst; next++;
  drawPoints( hullFirst, next, image, 255, 0, 0  );     // first hull point in red
}


template <class KERNEL> 
void testCH( std::string dir, std::string filename, Image & image )
{
  // set the floating point unit 
  // just to have equal conditions on different HW
  if (sizeof(typename KERNEL::FloatType) == 4)
    setFPURoundingTo24Bits();
  else
    setFPURoundingTo53Bits();

  std::vector<Point<KERNEL::FloatType>> points;
  std::vector<Point<KERNEL::FloatType>> hull;

  readPoints<KERNEL>( filename, std::back_inserter(points) );
  updateImageViewport(points.begin(), points.end(), image);

  std::cout << "Input: "<< filename << std::endl;
  printPoints( points.begin(), points.end());


  // Jarvis Hull
  image.erase();
  jarvisHull<KERNEL>(points.begin(), points.end(), std::back_inserter(hull) );
  drawConvexHull( points.begin(), points.end(), hull.begin(), hull.end(), image);
  image.write((dir+"/"+filename+"-jarvis"+".tga").c_str());

  std::cout << "Output jarvis CH:" << std::endl;
  printPoints( hull.begin(), hull.end() );
  writePoints( dir+"/"+filename + "-jarvisHull", hull.begin(), hull.end() );

  // Graham Hull
  image.erase();
  hull.clear();
  grahamHull<KERNEL>(points.begin(), points.end(), std::back_inserter(hull) );
  drawConvexHull( points.begin(), points.end(), hull.begin(), hull.end(), image);
  image.write((dir+"/"+filename+"-graham"+".tga").c_str());

  std::cout << "Output graham CH:" << std::endl;
  printPoints( hull.begin(), hull.end() );
  writePoints( dir+"/"+filename + "-grahamHull", hull.begin(), hull.end() );

}

#ifdef SKELETON // @Task 2
// generate points in 0..1 square
template <class KERNEL, class OutputIterator>  
void pointsInSquare(int n, OutputIterator result)
{
  Point<KERNEL::FloatType> point;

  /* initialize random seed: */
  srand ((unsigned int)time(NULL));

  for( int i = 0; i < n; i++ )
  {
    point.x = (KERNEL::FloatType) rand() / (KERNEL::FloatType)RAND_MAX;
    point.y = (KERNEL::FloatType) rand() / (KERNEL::FloatType)RAND_MAX;
    *result++ = point;
  }

}

// generate points on 0..1 square border
template <class KERNEL, class OutputIterator>  
void pointsOnSquare(int n, OutputIterator result)
{
  Point<KERNEL::FloatType> point;

  /* initialize random seed: */
  srand ((unsigned int)time(NULL));

  for( int i = 0; i < n; i++ )
  {
    int side = rand() % 4;

    switch(side){
    case 0:
      point.x = (KERNEL::FloatType) -1.5;
      point.y = (KERNEL::FloatType) rand() / (KERNEL::FloatType)RAND_MAX;
      break;
    case 1:
      point.x = (KERNEL::FloatType)  1.5;
      point.y = (KERNEL::FloatType) rand() / (KERNEL::FloatType)RAND_MAX;
      break;
    case 2:
      point.x = (KERNEL::FloatType) rand() / (KERNEL::FloatType)RAND_MAX;
      point.y = (KERNEL::FloatType)  -1.5;
      break;
    case 3:
      point.x = (KERNEL::FloatType) rand() / (KERNEL::FloatType)RAND_MAX;
      point.y = (KERNEL::FloatType)  1.5;
      break;
    }

    *result++ = point;

  }

}

template <class TEST_KERNEL, class REFERENCE_KERNEL>  
void findDifferentResults(int num_points)
{
  const int MAX_COUNTER = 10;



  // set the floating point unit 
  // just to have equal conditions on different HW
  if (sizeof(typename TEST_KERNEL::FloatType) == 4)
    setFPURoundingTo24Bits();
  else
    setFPURoundingTo53Bits();



  int counter = 0; 
  do
  {
    std::vector<Point<REFERENCE_KERNEL::FloatType>> points;
    std::vector<Point<TEST_KERNEL::FloatType>> hullTest;
    std::vector<Point<REFERENCE_KERNEL::FloatType>> hullReference;

    //pointsInSquare<REFERENCE_KERNEL>( num_points, std::back_inserter(points) );
    pointsOnSquare<REFERENCE_KERNEL>( num_points, std::back_inserter(points) );

    jarvisHull<TEST_KERNEL>(points.begin(), points.end(), std::back_inserter(hullTest) );
    jarvisHull<REFERENCE_KERNEL>(points.begin(), points.end(), std::back_inserter(hullReference) );

    bool different = true;
    if( points.size() >= hullReference.size() )
      if( hullTest.size() == hullReference.size() )
        if(std::equal(hullReference.begin(), hullReference.end(), hullTest.begin() ))
          different = false;

    if(different) {
      ++counter;    
      writePoints("error-points" + std::to_string(counter), points.begin(), points.end() );
    }      

    //if(points.size() > 0)
    //  points.clear();

  } while(counter < MAX_COUNTER);

}

#endif

int main(void)
{
  // Shewchuk exact predicate arithmetic initialization - DO NOT FORGET!!!
  exactinit();

  // TEST DIFFERENT PRECISION on float and double
  Image image(200, 200);

  typedef Kernel<float,  Orient2dNaive2<float>,       Extended2dNaive<float>>		KernelFloatInexact2;
  typedef Kernel<double, Orient2dNaive2<double>,      Extended2dNaive<double>>	KernelDoubleInexact2;
  typedef Kernel<REAL,   Orient2dAdaptive<REAL>,      Extended2dExact<REAL>>		KernelDoubleAdaptiveShewchuk;
  typedef Kernel<REAL, Orient2dAdaptive<REAL>, Extended2dExact<REAL>>		KernelDoubleAdNaiveShewchuk;

  for( int i = 1; i <=7; i++ )
  { 
    //std::string inputFile = "points" + std::to_string(i);  // for VS2012 - correct std string
	  std::string inputFile = "points" + std::to_string(static_cast<long long>(i)); // for VS2010 - wrong std string
    testCH<KernelDoubleAdaptiveShewchuk>( "adaptive", inputFile, image );
    //testCH<KernelFloatInexact2>( "float", inputFile, image );
    testCH<KernelDoubleInexact2>( "double", inputFile, image );  // spadne task 5
	//testCH<KernelDoubleAdNaiveShewchuk>("AdNaive", inputFile, image);  // spadne task 5
  }

#ifdef SKELETON // @Task2
  findDifferentResults<KernelDoubleInexact2, KernelDoubleExactShewchuk>(1000);
  //findDifferentResults<KernelDoubleInexact2, KernelDoubleExactShewchuk>(1000);
  //findDifferentResults<KernelFloatInexact2, KernelDoubleExactShewchuk>(1000);
#endif

  return 0;

}
