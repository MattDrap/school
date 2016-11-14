/* robustness.cpp
 * 
 * The first assignment code for the Computational Geometry Class, FEE CTU Prague
 * 
 * author: Petr Felkel and Vojtech Budnik, {felkepet|bubnivoj}@felk.cvut.cz
 * 
 */

// Notes to IEEE float in Czech>
// http://www.h-schmidt.net/FloatConverter/IEEE754.html
// Presnost cisla float je 23+1 bitu (skryta jednicka)
// Ve vzorci pro orientaci se pocitaji rozdily
//    float_orient(p,q,r) = sign((qx-px)*(ry-py)-(qy-py)*(rx-px));
// Proto se musi oba operandy (24 a 0.5) prevest na stejny exponent
//   0.5   je e = 0111 1110 ( -1~126)  mantisa (1).000 0000 0000 0000 0000 0000 --- 23 nul 
// u=2^-19 je e = 0110 1100 (-19~108)  mantisa (1).000 0000 0000 0000 0000 0000 --- 23 nul 
// 0.5 + u je e = 0111 1110 ( -1~126)  mantisa (1).000 0000 0000 0000 0010 0000 -- u posun o 18 cifer doprava

// Pred odectenim 24-(0.5+u) musim zarovnat mantisy s cislem 24, tj posun o 4+1 bit
// posununute 0.5 + u je e = 1000 0011 ( +4~131)  mantisa (0).000 0100 0000 0000 0000 0001 -- nenormalizivana mantisa posun 0 5 bitu doprava
// 24      je e = 1000 0011 ( +4~131)  mantisa (1).100 0000 0000 0000 0010 0000 
// 12      je e = 1000 0011 ( +3~130)  mantisa (1).100 0000 0000 0000 0100 0000 
// pri posunu 0.5+u doprava o 5 bitu ztratíme 5 LSB bitu - to u 24 jeste k chybì nevede
                
// Problém nastává pøi násobení (které je nutné pro výpoèet orientace), mùže totiž
// nastat situace, že násobením mantis obou èísel dostaneme denormalizovanou
// mantisu ve tvaru 1x.xxxxx (x znaèí 0 nebo 1). Abychom tuto mantisu
// normalizovali, je nutné navýšit hodnotu exponentu o jedna a mantisu posunout o
// jednu pozici doprava, tedy 1.xxxx, èímž ztratíme LSB bit, tedy dohromady jsme
// ztratili 6 bitových pozic, což v pøípadì souètu 0.5+u znamená, že jsme vlastnì
// žádnou inkrementaci o epsilon neprovedli a orientace je stejná pro obì hodnoty
// 0.5+u a 0.5 .
// První chyba pro u = 2^(-19)
/** orientation predicate in flolating point arithmetic ("hand made")
  * @param a,b,c three points, positive if points form a left turn 
  * @param eps   optional epsilon for comparison of results - implicitly 0
  */
#include "targa.h"
#include <math.h>
#include <string>
#include <assert.h>

#include "predicates.h"


/** RGB image */
struct Image {
    uint16_t width;  // number of columns
    uint16_t height; // number of rows
    int size;
    int sizeInBytes;
    uint8_t * pixels;

    Image(const uint16_t _width = 500, const uint16_t _height = 500) : width(_width), height(_height)
    {	
        size = width * height;
        sizeInBytes = 3* size;
        pixels = new uint8_t[sizeInBytes];
    }
    ~Image() 
    {
        if(pixels) 
            delete(pixels);
    }
    // image with [0,0] in the lower left corner
    // x ... column
    // y ... row
    void setPixel(int x, int y,int r, int g, int b)
    {
        int pos = 3* ((height-y-1) * width + x);
        pixels[pos]   = b;
        pixels[pos+1] = g;
        pixels[pos+2] = r;
    }
    void erase()
    {
        uint8_t * pixelsPtr = pixels;
        for( int i=0; i<sizeInBytes; i++)
            *pixelsPtr++ = 0;
    }
    void write(const char * file)
    {
        const uint8_t pixelDepth = 24;
        tga_write_bgr(file, pixels, height, width, pixelDepth);
    }
};

// test: Write 24bit targa file 500x500 with three points in row 150
int testImage(void)
{    
    Image image;
    image.erase();
    image.setPixel(150,150, 128, 128, 128);
    image.setPixel(160,150, 255, 0, 0);
    image.setPixel(170,150, 255,255,255);
    image.write("output.tga");
    return 0;
}

template <class T>
struct Point
{
    T x;
    T y; 
    Point( T xx, T yy ) : x(xx), y(yy) {};
    //Point() : x((T)0.0), y((T)0.0){};

    template<typename T2>
    Point<T2> convert() const { return Point<T2>((T2)x, (T2)y); }

    Point<T>operator+(const Point<T> & p)
    {
        return( Point<T>(this->x + p.x, this->y + p.y));
    }
};

typedef Point<float>  Pointf;
typedef Point<double> Pointd;

template <class T>
struct PointTriple
{
    Point<T> a,b,c;

    PointTriple(const Point<T> &aa, const Point<T> &ab, const Point<T> &ac) : a(aa), b(ab), c(ac) {}

    template<typename T2>
    PointTriple<T2> convert() const { 
        return PointTriple<T2>(a.convert<T2>(), b.convert<T2>(), c.convert<T2>());
    }
};

typedef PointTriple<float>  PointTriplef;
typedef PointTriple<double> PointTripled;

enum OrientationType
{
    ORIENTATION_UNDEF  = INT_MAX,
    RIGHT_TURN	= -1,
    STRAIGHT	= 0,
    LEFT_TURN	= 1
};

template <typename T>
struct Orient2dNaive2
{
    OrientationType operator()(Point<T> a, Point<T> b, Point<T> c)
    {   
      // ======== BEGIN OF SOLUTION - TASK 1-1 ======== //
        // Implement the naive version of the operator as 2x2 determinant ()()-()()
		T result = ( (a.x - c.x)*(b.y - c.y) - (a.y - c.y)*(b.x - c.x) );
      // ========  END OF SOLUTION - TASK 1-1  ======== //
        if(result > (T)0)
            return LEFT_TURN;
        else if (result < (T)0)
            return RIGHT_TURN;
        else 
            return STRAIGHT;
    }
};

template <typename T>
struct Orient2dNaive3
{
    OrientationType operator()(Point<T> a, Point<T> b, Point<T> c)
    {   
      // ======== BEGIN OF SOLUTION - TASK 2-1 ======== //
        // Implement the naive version of the operator as 3x3 deteminant
        T result =  (T) (a.x*b.y + b.x*c.y + c.x*a.y - a.x*c.y - b.x*a.y - c.x*b.y);
      // ========  END OF SOLUTION - TASK 2-1  ======== //
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

enum PivotType {
    PIVOT_A, 
    PIVOT_B, 
    PIVOT_C
};

template <typename KERNEL, const PivotType PIVOT>
void test(int _deltaExponent, Image & image, const PointTriple<double> & testPoints )
{
    typedef typename KERNEL::FloatType	FloatType;
    typename KERNEL::Orient				orient; 


    Point<FloatType> p0 = testPoints.a.convert<FloatType>();
    Point<FloatType> q  = testPoints.b.convert<FloatType>();
    Point<FloatType> r  = testPoints.c.convert<FloatType>();


    FloatType delta = pow(FloatType(2.0),_deltaExponent);


    for(int j=0; j<image.height; j++)     // Y 
        for(int i=0; i<image.width; i++)  // X
        {
            
            Point<FloatType> p( p0.x + (FloatType)i*delta, p0.y + (FloatType)j*delta );

            OrientationType orientation = ORIENTATION_UNDEF;
            switch (PIVOT) {
            case PIVOT_C: orientation = orient(p,q,r); break;  // Shewchuk uses the third point C as pivot
            case PIVOT_A: orientation = orient(q,r,p); break;
            case PIVOT_B: orientation = orient(r,p,q); break;
            }
 
            switch(orientation)
            {
            case LEFT_TURN:
                image.setPixel(i,j, 255, 0, 0); //RED
                break;
            case STRAIGHT:
                image.setPixel(i,j, 255, 255, 0); //YELLOW
                break;
            case RIGHT_TURN:
                image.setPixel(i,j, 0, 0, 255); //BLUE
                break;
            default:
                assert(false);
                break;
            }
        }
}

template <class KERNEL, const PivotType PIVOT>
void testExponents( int from, int to, Image & image,  PointTriple<double> &testPoints, int testPointsIndex,  const char * prefix )
{
    if (sizeof(typename KERNEL::FloatType) == 4)
        setFPURoundingTo24Bits();
    else
        setFPURoundingTo53Bits();

    for(int _deltaExponent=from; _deltaExponent < to; _deltaExponent++) 
    {
        image.erase();

        test<KERNEL, PIVOT>( _deltaExponent, image, testPoints);
        
        std::string s = std::to_string(testPointsIndex) + " " +prefix + std::to_string(_deltaExponent) + ".tga";		
        image.write(s.c_str());
    }
}

template<typename T, typename ORIENT>
struct Kernel {
    typedef typename T		FloatType;
    typedef typename ORIENT	Orient;
};

int main(void)
{
    // Shewchuk exact predicate arithmetic initialization - DO NOT FORGET!!!
    exactinit();

    // set the values of points for testing in procedure test on lines 227 to 252 
    const int size = 4;
    const PointTriple<double> testTriples[size] =
    {
        PointTriple<double>( // pointset 0	-  variant (a) on slide 40
            Point<double>(  0.5,  0.5),
            Point<double>( 12.0, 12.0),
            Point<double>( 24.0, 24.0)    
        ),	 
        PointTriple<double>( // pointset 1	-  variant (b) on slide 40
            Point<double>(  0.50000000000002531, 0.5000000000000171),
            Point<double>( 17.300000000000001,  17.300000000000001), 
            Point<double>( 24.00000000000005,   24.0000000000000517765)   
        ),		
        PointTriple<double>( // pointset 2   -  variant (c) on slide 40	
            Point<double>(  0.5,  0.5), 
            Point<double>(  8.8000000000000007, 8.8000000000000007), 
            Point<double>( 12.1, 12.1) 
         ),		
        PointTriple<double>( // pointset 3	
            Point<double>(  0.5,  0.5),
            Point<double>( 12.0, 12.0),
            Point<double>( 24.000001, 24.000001)    
        ),	
    };
    


    // TEST DIFFERENT PRECISION on float and double
    Image image(256, 256);

    typedef Kernel<float,  Orient2dNaive2<float>>		KernelFloatInexact2;
    typedef Kernel<float,  Orient2dNaive3<float>>		KernelFloatInexact3;
    typedef Kernel<double, Orient2dNaive2<double>>		KernelDoubleInexact2;
    typedef Kernel<double, Orient2dNaive3<double>>		KernelDoubleInexact3;
    typedef Kernel<REAL,   Orient2dNaiveShewchuk<REAL>>	KernelDoubleNaiveShewchuk;
    typedef Kernel<REAL,   Orient2dExact<REAL>>			KernelDoubleExactShewchuk;
    typedef Kernel<REAL,   Orient2dAdaptive<REAL>>		KernelDoubleAdaptiveShewchuk;




    for( int i= 0; i < size; i++)
    {
        //PointTriple<double> pf= testTriples[1].convert<double>();
        PointTriple<double> pointTriple = testTriples[i];

        // standard floating point naive predicates (float and double) computed via pivots
        // ======== BEGIN OF SOLUTION - TASK 1-2 ======== //
        // use parameter PIVOT_{ABC} for selection of pivot line subtracted in 2x2 determinant
        // Program the predicates and uncomment the lines below
        testExponents<KernelFloatInexact2,  PIVOT_A>( -25, -17, image,  pointTriple, i, "float_pivotA_exp=" ); 
        testExponents<KernelFloatInexact2,  PIVOT_B>( -25, -17, image,  pointTriple, i, "float_pivotB_exp=" ); 
        testExponents<KernelFloatInexact2,  PIVOT_C>( -25, -17, image,  pointTriple, i, "float_pivotC_exp=" ); 
        testExponents<KernelDoubleInexact2, PIVOT_A>( -55, -46, image,  pointTriple, i, "double_pivotA_exp=" );
        testExponents<KernelDoubleInexact2, PIVOT_B>( -55, -46, image,  pointTriple, i, "double_pivotB_exp=" );
        testExponents<KernelDoubleInexact2, PIVOT_C>( -55, -46, image,  pointTriple, i, "double_pivotC_exp=" );
        // ========  END OF SOLUTION - TASK 1-2  ======== //

        // standard floating point naive predicates (float and double) computed as a complete 3x3 determinant
        // use parameter PIVOT_{ABC} similarly as above - it represents the order of input points
        // ======== BEGIN OF SOLUTION - TASK 2-2 ======== //
		testExponents<KernelFloatInexact3, PIVOT_A>(-25, -17, image, pointTriple, i, "float3_pivotA_exp=");
		testExponents<KernelFloatInexact3, PIVOT_B>(-25, -17, image, pointTriple, i, "float3_pivotB_exp=");
		testExponents<KernelFloatInexact3, PIVOT_C>(-25, -17, image, pointTriple, i, "float3_pivotC_exp=");
		testExponents<KernelDoubleInexact3, PIVOT_A>(-55, -46, image, pointTriple, i, "double3_pivotA_exp=");
		testExponents<KernelDoubleInexact3, PIVOT_B>(-55, -46, image, pointTriple, i, "double3_pivotB_exp=");
		testExponents<KernelDoubleInexact3, PIVOT_C>(-55, -46, image, pointTriple, i, "double3_pivotC_exp=");

        // ========  END OF SOLUTION - TASK 2-2  ======== //

        // Shewchuk naive predicates for REAL (REAL defined in predicates.h as double)
        testExponents<KernelDoubleNaiveShewchuk, PIVOT_A>( -55, -46, image,  pointTriple, i, "double_naiveShew_pivotA_exp=" );
        testExponents<KernelDoubleNaiveShewchuk, PIVOT_B>( -55, -46, image,  pointTriple, i, "double_naiveShew_pivotB_exp=" );
        testExponents<KernelDoubleNaiveShewchuk, PIVOT_C>( -55, -46, image,  pointTriple, i, "double_naiveShew_pivotC_exp=" );

        // Shewchuk robust float predicates for REAL (REAL defined in predicates.h as double)
        testExponents<KernelDoubleExactShewchuk,    PIVOT_A>(-59, -46, image,  pointTriple, i, "double_exactShew_pivotA_exp=" );
        testExponents<KernelDoubleExactShewchuk,    PIVOT_B>(-59, -46, image,  pointTriple, i, "double_exactShew_pivotB_exp=" );
        testExponents<KernelDoubleExactShewchuk,    PIVOT_C>(-59, -46, image,  pointTriple, i, "double_exactShew_pivotC_exp=" );
        testExponents<KernelDoubleAdaptiveShewchuk, PIVOT_A>(-59, -46, image,  pointTriple, i, "double_adaptiveShew_pivotA_exp" );
        testExponents<KernelDoubleAdaptiveShewchuk, PIVOT_B>(-59, -46, image,  pointTriple, i, "double_adaptiveShew_pivotB_exp=" );
        testExponents<KernelDoubleAdaptiveShewchuk, PIVOT_C>(-59, -46, image,  pointTriple, i, "double_adaptiveShew_pivotC_exp=" );
    }
    return 0;

}
