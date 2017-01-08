/* main.cpp
* 
* The third assignment code for the Computational Geometry Class, FEE CTU Prague
* 
* Variant with OpenMesh, http:// www.openmesh.org
*
* author: Vojtech Bubnik and Petr Felkel {bubnivoj|felkepet}@felk.cvut.cz
* 
*/

#include "targa.h"
#include <math.h>
#include <string>
#include <vector>
#include <set>
#include <limits.h>
#include <queue>
#include <unordered_set>

#include <iostream>
#include <iomanip>  // for stream output precision 
#include <fstream>
#include <list>

#include <assert.h>

#include "ExactPredicates.h"
#include "PolyMesh.h"

using namespace OpenMesh;


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
  void drawPoint( const VectorT<T, 2> &p, const int r, const int g, const int b, const int pointRadius = 5)
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
  void drawLine(const VectorT<T, 2> &p1, const VectorT<T, 2> &p2, const int r, const int g, const int b )
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
std::istream & operator>>( std::istream& in, VectorT<T, 2> & p)
{
  T x,y;
  in >> x >> y;
  if( in )
    p = VectorT<T, 2>(x,y);
  return in;
}

// stream output for 2d point in debugging format
template< class T>
std::ostream& operator<<( std::ostream& out, const VectorT<T, 2>& p) {
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
  OrientationType operator()(VectorT<T, 2> a, VectorT<T, 2> b, VectorT<T, 2> c)
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


template <typename T>
struct Orient2dExact
{
  OrientationType operator()(VectorT<T, 2> a, VectorT<T, 2> b, VectorT<T, 2> c)
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


// Returns true if r is on the extension of the ray starting in q in
// the direction q-p, i.e., if (q-p)*(r-q) >= 0, and false otherwise.
// Naive implementation, which is not precise with float / double types,
// but may deliver more precise results than Extended2dExact if the points are not exactly collinear.
template< class T>
struct Extended2dNaive
{
  bool operator()(VectorT<T, 2> p, VectorT<T, 2> q, VectorT<T, 2> r)
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
  bool operator()(VectorT<T, 2> p, VectorT<T, 2> q, VectorT<T, 2> r)
  {   
     assert(Orient2dAdaptive<T>()(p, q, r) == STRAIGHT);
     return ( p.x == q.x ) ?
       ( (p.y <= q.y) ? (q.y <= r.y) : (q.y >= r.y) ) :
       ( (p.x <= q.x) ? (q.x <= r.x) : (q.x >= r.x) );
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
  InsideOutsideType operator()(VectorT<T, 2> a, VectorT<T, 2> b, VectorT<T, 2> c, VectorT<T, 2> d)
  {   
	  VectorT<T, 2> ad = a - d;
	  VectorT<T, 2> bd = b - d;
	  VectorT<T, 2> cd = c - d;
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
  InsideOutsideType operator()(VectorT<T, 2> a, VectorT<T, 2> b, VectorT<T, 2> c, VectorT<T, 2> d)
  {   
	 T det = ExactPredicates::incircle(&a[0], &b[0], &c[0], &d[0]);
	 return (det > 0) ? INOUT_INSIDE : ((det < 0) ? INOUT_OUTSIDE : INOUT_BOUNDARY);
  }
};

template<typename T, typename ORIENT, typename EXTENDED, typename INCIRCLE>
struct Kernel {
  typedef T											FloatType;
  typedef PolyMesh_ArrayKernelT<PolyMeshTraits<T> >	MeshType;
  typedef ORIENT									Orient;
  typedef EXTENDED									Extended;
  typedef INCIRCLE									InCircle;
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
      VectorT<typename KERNEL::FloatType, 2> p;
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

template<class MESH>
void drawMesh( const MESH &mesh, Image & image )
{
	// Draw inner edges.
    for (auto it = mesh.halfedges_begin(); it != mesh.halfedges_end(); ++ it)
	if (! mesh.is_boundary(*it))
		image.drawLine(mesh.point(mesh.from_vertex_handle(*it)), mesh.point(mesh.to_vertex_handle(*it)), 255, 0, 0);

	// Draw boundary edges.
    for (auto it = mesh.halfedges_begin(); it != mesh.halfedges_end(); ++ it)
	if (mesh.is_boundary(*it))
		image.drawLine(mesh.point(mesh.from_vertex_handle(*it)), mesh.point(mesh.to_vertex_handle(*it)), 255, 255, 255);

	// Draw vertices.
	const int pointRadius = 2;
    for (auto it = mesh.vertices_begin(); it != mesh.vertices_end(); ++ it)
		image.drawPoint(mesh.point(*it), 0, 0, 255, pointRadius);

	// Draw first point.
	image.drawPoint(mesh.point(mesh.vertex_handle(0)), 255, 0, 0, pointRadius);
	image.drawPoint(mesh.point(mesh.vertex_handle(1)), 0, 255, 0, pointRadius);
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
// ======== BEGIN OF SOLUTION - TASK 1-1 ======== //
template<typename POINT, typename ORIENT>
class PolygonEar
{
};
// ========  END OF SOLUTION - TASK 1-1  ======== //



/** The ear cutting procedure
 *  @param[in]   points    - Input, simple polygon
 *  @param[out]  triangles - Indices of triangle vertices - three consecutive vertices form a triangle
 */
// ======== BEGIN OF SOLUTION - TASK 2-1 ======== //
/*struct KeyHasher
{
	std::size_t operator()(const VertexHandle& k) const
	{
		return (std::hash<int>()(k.idx()));
	}
};

template<typename KERNEL>
bool TriangulateFaceByEarCutting2(
	typename KERNEL::MeshType				&mesh,
	typename KERNEL::MeshType::FaceHandle	 fh)
{
	typename KERNEL::Orient Orient;
	
	//PREPARE ALL Ears "edges"
	std::list<HalfedgeHandle> q;
	std::unordered_set<VertexHandle, KeyHasher> qv;

	HalfedgeHandle orig(mesh.halfedge_handle(fh));
	HalfedgeHandle he = orig;
	HalfedgeHandle he1(mesh.next_halfedge_handle(he));
	HalfedgeHandle he2(mesh.next_halfedge_handle(he1));
	do {
		VertexHandle Vert = mesh.to_vertex_handle(he);
		VertexHandle Vert1 = mesh.to_vertex_handle(he1);
		VertexHandle Vert2 = mesh.to_vertex_handle(he2);

		OrientationType pred = Orient(mesh.point(Vert), mesh.point(Vert1), mesh.point(Vert2));

		if (pred == LEFT_TURN) {
			if (isEar<KERNEL>(Vert, Vert1, Vert2, mesh, he2)) {
				q.push_back(he);
				qv.insert(Vert1);
			}
		}

		he = mesh.next_halfedge_handle(he);
		he1 = mesh.next_halfedge_handle(he);
		he2 = mesh.next_halfedge_handle(he1);
	} while (he != orig);

	uint edges = mesh.valence(fh);

	//PICK UP Ears and cut them one by one
	while (edges > 3 && !q.empty()) {

		he = q.front();
		q.pop_front();
		HalfedgeHandle he1(mesh.next_halfedge_handle(he));
		HalfedgeHandle he2(mesh.next_halfedge_handle(he1));

		VertexHandle Vert0 = mesh.to_vertex_handle(mesh.prev_halfedge_handle(he));
		VertexHandle Vert = mesh.to_vertex_handle(he);
		VertexHandle Vert1 = mesh.to_vertex_handle(he1);
		VertexHandle Vert2 = mesh.to_vertex_handle(he2);
		VertexHandle Vert3 = mesh.to_vertex_handle(mesh.next_halfedge_handle(he2));

		OrientationType pred = Orient(mesh.point(Vert), mesh.point(Vert1), mesh.point(Vert2));
		if (pred == LEFT_TURN) {
			if (isEar<KERNEL>(Vert, Vert1, Vert2, mesh, he2)) {
				mesh.insert_edge(he2, he1);
				edges--;
				//Adjacent vertices test

				if (qv.find(Vert0) != qv.end()) { //FOUND
					auto it = qv.find(Vert0);
					qv.erase(it);
					for (auto mit = q.begin(); mit != q.end(); ++mit) {
						HalfedgeHandle temphe = mesh.next_halfedge_handle(*mit);
						VertexHandle tempv = mesh.to_vertex_handle(temphe);
						if (tempv == Vert0) {
							q.erase(mit);
							break;
						}
					}
				}
				OrientationType pred = Orient(mesh.point(Vert0), mesh.point(Vert), mesh.point(Vert1));
				if (pred == LEFT_TURN) {
					if (isEar<KERNEL>(Vert0, Vert, Vert1, mesh, he1)) {
						q.push_back(mesh.prev_halfedge_handle(he));
						qv.insert(Vert0);
					}
				}
				if (qv.find(Vert2) != qv.end()) {
					auto it = qv.find(Vert2);
					qv.erase(it);
					for (auto mit = q.begin(); mit != q.end(); ++mit) {
						HalfedgeHandle temphe = mesh.next_halfedge_handle(*mit);
						VertexHandle tempv = mesh.to_vertex_handle(temphe);
						if (tempv == Vert2) {
							q.erase(mit);
							break;
						}
					}
				}
				pred = Orient(mesh.point(Vert1), mesh.point(Vert2), mesh.point(Vert3));
				if (pred == LEFT_TURN) {
					if (isEar<KERNEL>(Vert1, Vert2, Vert3, mesh, mesh.next_halfedge_handle(he2))) {
						q.push_back(he1);
						qv.insert(Vert2);
					}
				}
			}
		}
	}
	// Implement the ear cutting procedure
	return true;
};*/
template<typename KERNEL>
bool TriangulateFaceByEarCutting(
	typename KERNEL::MeshType				&mesh, 
	typename KERNEL::MeshType::FaceHandle	 fh)
{
	typename KERNEL::Orient Orient;
	
	HalfedgeHandle he(mesh.halfedge_handle(fh));
	he = mesh.next_halfedge_handle(he);
	HalfedgeHandle he1(mesh.next_halfedge_handle(he));
	HalfedgeHandle he2(mesh.next_halfedge_handle(he1));

	uint edges = mesh.valence(fh);

	while (edges > 3) {

		VertexHandle Vert = mesh.to_vertex_handle(he);
		VertexHandle Vert1 = mesh.to_vertex_handle(he1);
		VertexHandle Vert2 = mesh.to_vertex_handle(he2);

		OrientationType pred = Orient(mesh.point(Vert), mesh.point(Vert1), mesh.point(Vert2));

		if (pred == LEFT_TURN) {
			if (isEar<KERNEL>(Vert, Vert1, Vert2, mesh, he2)) {

				mesh.insert_edge(he2, he1);
				edges--;
			}
		}
		he = mesh.next_halfedge_handle(he);
		he1 = mesh.next_halfedge_handle(he);
		he2 = mesh.next_halfedge_handle(he1);
	}
  // Implement the ear cutting procedure
	return true;
};
template<typename KERNEL>
bool isEar(VertexHandle vertPrev, VertexHandle curVert,VertexHandle vertNext, typename KERNEL::MeshType &mesh, HalfedgeHandle walk){
	typename KERNEL::Orient orient;
	
	HalfedgeHandle ph = walk;
	ph = mesh.next_halfedge_handle(ph);
	VertexHandle p = mesh.to_vertex_handle(ph);
	
	while (p != vertPrev) {
		if (orient(mesh.point(p), mesh.point(curVert), mesh.point(vertNext)) == LEFT_TURN &&
			orient(mesh.point(p), mesh.point(vertNext), mesh.point(vertPrev)) == LEFT_TURN &&
			orient(mesh.point(p), mesh.point(vertPrev), mesh.point(curVert)) == LEFT_TURN) {
			return false;
		}
		ph = mesh.next_halfedge_handle(ph);
		p = mesh.to_vertex_handle(ph);
	}
	return true;
};


// ========  END OF SOLUTION - TASK 2-1  ======== //


/** Perform diagonal flipping. 
 *  Replace illegal halfedge hh by a flipped diagonal while updating all edge, face and vertex handles.
 *  @param[in,out]   mesh  - Current triangulation
 *  @param[out]      hh    - Handle of a halfedge to be flipped
 */template<typename MeshType>
void FlipDiagonal(MeshType &mesh, typename MeshType::HalfedgeHandle hh)
{ 
  // Get the useful handles
	typename MeshType::HalfedgeHandle hhOpposite	= mesh.opposite_halfedge_handle(hh);  
	typename MeshType::HalfedgeHandle hhPrev			= mesh.prev_halfedge_handle(hh);      
	typename MeshType::HalfedgeHandle hhNext			= mesh.next_halfedge_handle(hh);
	typename MeshType::HalfedgeHandle hhOppositePrev	= mesh.prev_halfedge_handle(hhOpposite);
	typename MeshType::HalfedgeHandle hhOppositeNext	= mesh.next_halfedge_handle(hhOpposite);
	typename MeshType::FaceHandle     fhLeft			= mesh.face_handle(hh);
	typename MeshType::FaceHandle     fhRight			= mesh.face_handle(hhOpposite);
	typename MeshType::VertexHandle   vhStart			= mesh.to_vertex_handle(hhOpposite);
	typename MeshType::VertexHandle   vhEnd				= mesh.to_vertex_handle(hh);

	// Remove the old diagonal.  
  //    - reconnect prev and next handles of previous and next halfedges
	mesh.set_next_halfedge_handle(hhPrev, hhOppositeNext);  
	mesh.set_prev_halfedge_handle(hhOppositeNext, hhPrev);
	mesh.set_next_halfedge_handle(hhOppositePrev, hhNext);
	mesh.set_prev_halfedge_handle(hhNext, hhOppositePrev);
  //    - set halfedges pointed by former start and end vertex to surviving edges
	mesh.set_halfedge_handle(vhStart, hhOppositeNext);
	mesh.set_halfedge_handle(vhEnd,   hhNext);

	// Reinsert the diagonal.
  //    - set pairs of prev-next pointers
	mesh.set_next_halfedge_handle(hhNext, hh);
	mesh.set_prev_halfedge_handle(hh, hhNext);
	mesh.set_next_halfedge_handle(hhOpposite, hhPrev);
	mesh.set_prev_halfedge_handle(hhPrev, hhOpposite);
	mesh.set_next_halfedge_handle(hh, hhOppositePrev);
	mesh.set_prev_halfedge_handle(hhOppositePrev, hh);
	mesh.set_next_halfedge_handle(hhOppositeNext, hhOpposite);
	mesh.set_prev_halfedge_handle(hhOpposite, hhOppositeNext);
	//    - adjust the vertices.
	mesh.set_vertex_handle  (hh,		 mesh.to_vertex_handle(hhOppositeNext));
	mesh.set_vertex_handle  (hhOpposite, mesh.to_vertex_handle(hhNext));

  // Adjust faces.
  //    - left from halfedge hh
	for (typename MeshType::HalfedgeHandle hhNext = mesh.next_halfedge_handle(hh); hhNext != hh; hhNext = mesh.next_halfedge_handle(hhNext))
		mesh.set_face_handle(hhNext, fhLeft);
  //    - left from halfedge twin to hh
	mesh.set_face_handle(hhOpposite, fhRight);
	for (typename MeshType::HalfedgeHandle hhNext = mesh.next_halfedge_handle(hhOpposite); hhNext != hhOpposite; hhNext = mesh.next_halfedge_handle(hhNext))
		mesh.set_face_handle(hhNext, fhRight);
  //    - one edge from each face
	mesh.set_halfedge_handle(fhLeft,  hh);
	mesh.set_halfedge_handle(fhRight, hhOpposite);
	// Maintain a rule on outgoing halfedges from vertices: If vertex resides on an open boundary, the outgoing halfedge shall have no face assigned.
	// mesh.adjust_outgoing_halfedge(vhStart);
	// mesh.adjust_outgoing_halfedge(vhEnd);
}

// Expects the mesh to be triangular.
template<typename KERNEL>
bool MakeDelaunayByDiagonalFlipping(typename KERNEL::MeshType &mesh)
{
	typedef typename KERNEL::MeshType	MeshType;
	typename KERNEL::InCircle inCircle;

	std::queue<HalfedgeHandle> q;
	for (MeshType::FaceIter f_it = mesh.faces_begin(); f_it != mesh.faces_end(); ++f_it) {
		HalfedgeHandle he = mesh.halfedge_handle(f_it);
		q.push(he);
	}
	while (!q.empty())
	{
		//Get First edge of face
		HalfedgeHandle diagonal = q.front();		
		q.pop();
		
		VertexHandle Facevertices[3];
		int iter = 0;

		// Get all vertices of given face 
		HalfedgeHandle next = diagonal;
		do {
			Facevertices[iter] = mesh.from_vertex_handle(next);
			next = mesh.next_halfedge_handle(next);
			iter++;
		} while (diagonal != next);

		//OPPOSITE
		HalfedgeHandle mirdiagonal = mesh.opposite_halfedge_handle(diagonal);
		HalfedgeHandle nextmir = mirdiagonal;
		
		//RATHER TEST ALL 3 Possibilities
		do {
			VertexHandle testvertex = mesh.from_vertex_handle(nextmir);
			InsideOutsideType pred = inCircle(mesh.point(Facevertices[0]), mesh.point(Facevertices[1]), mesh.point(Facevertices[2]), mesh.point(testvertex));
			if (pred == InsideOutsideType::INOUT_INSIDE) {
				FlipDiagonal(mesh, diagonal);
				
				HalfedgeHandle iprev = mesh.next_halfedge_handle(diagonal);
				HalfedgeHandle inext = mesh.prev_halfedge_handle(diagonal);

				HalfedgeHandle imirprev = mesh.next_halfedge_handle(mirdiagonal);
				HalfedgeHandle imirnext = mesh.prev_halfedge_handle(mirdiagonal);

				//Because is_boundary is only on one side of half edge - test both sides
				if (!mesh.is_boundary(mesh.opposite_halfedge_handle(inext)) &&
					!mesh.is_boundary(inext)) {
					q.push(inext);
				}
				if (!mesh.is_boundary(mesh.opposite_halfedge_handle(iprev)) &&
					!mesh.is_boundary(iprev)) {
					q.push(iprev);
				}

				if (!mesh.is_boundary(mesh.opposite_halfedge_handle(imirnext)) &&
					!mesh.is_boundary(imirnext)) {
					q.push(imirnext);
				}
				if (!mesh.is_boundary(mesh.opposite_halfedge_handle(imirprev)) &&
					!mesh.is_boundary(imirprev)) {
					q.push(imirprev);
				}
				break;
			}
			nextmir = mesh.next_halfedge_handle(nextmir);
		} while (mirdiagonal != nextmir);
	}
	// Now flip the new diagonals iteratively to satisfy Delaunay criteria.
	return true;
}

template <class KERNEL> 
void testCDT( std::string dir, std::string filename, Image & image )
{
  // set the floating point unit 
  // just to have equal conditions on different HW
  if (sizeof(typename KERNEL::FloatType) == 4)
    ExactPredicates::setFPURoundingTo24Bits();
  else
    ExactPredicates::setFPURoundingTo53Bits();

  typedef VectorT<typename KERNEL::FloatType, 2> VecType;
  std::vector<VecType> points;
  readPoints<KERNEL>( filename, std::back_inserter(points) );
  updateImageViewport(points.begin(), points.end(), image);

  std::cout << "Input: "<< filename << std::endl;
  printPoints( points.begin(), points.end());

  // Initialize mesh structure with a single face representing the input simple polygon.
  typename KERNEL::MeshType	mesh;
  typename std::vector<typename KERNEL::MeshType::VertexHandle> vertices;
  for (auto it = points.begin(); it != points.end(); ++ it)
	  vertices.push_back(mesh.add_vertex(*it));
  typename KERNEL::MeshType::FaceHandle	fh = mesh.add_face(vertices);

  image.erase();
  drawMesh(mesh, image);
  image.write((dir+"/"+filename+"-input"+".tga").c_str());

  TriangulateFaceByEarCutting<KERNEL>(mesh, fh);

  image.erase();
  drawMesh(mesh, image);
  image.write((dir+"/"+filename+"-CT"+".tga").c_str());

  MakeDelaunayByDiagonalFlipping<KERNEL>(mesh);

  image.erase();
  drawMesh(mesh, image);
  image.write((dir+"/"+filename+"-CDT"+".tga").c_str());
}

#ifdef GENERATE_POLYGONS
#endif // GENERATE_POLYGONS

int main()
{
  // Shewchuk exact predicate arithmetic initialization - DO NOT FORGET!!!
  ExactPredicates::exactinit();


  // TEST DIFFERENT PRECISION on float and double
  Image image(800, 800);

  typedef Kernel<float,  Orient2dNaive<float>,   Extended2dNaive<float>,	InCircleNaive<float>>	  KernelFloatInexact2;
  typedef Kernel<double, Orient2dNaive<double>,  Extended2dNaive<double>,	InCircleNaive<double>>	KernelDoubleInexact2;
  typedef Kernel<double, Orient2dExact<double>,  Extended2dExact<double>,	InCircleExact<double>>	KernelDoubleAdaptiveShewchuk;

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
