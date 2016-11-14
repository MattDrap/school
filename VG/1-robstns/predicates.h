// For single precision ( which will save some memory and reduce paging ),
//   define the symbol SINGLE by using the -DSINGLE compiler switch or by
//   writing "#define SINGLE" below.
//
// For double precision ( which will allow you to refine meshes to a smaller
//   edge length), leave SINGLE undefined.

// #define SINGLE

#ifdef SINGLE
  #define REAL float
#else
  #define REAL double
#endif 	// not defined SINGLE



//predicates.cpp - lines 1405 - 1637
/*****************************************************************************/
/*                                                                           */
/*  orient2dfast()   Approximate 2D orientation test.  Nonrobust.            */
/*  orient2dexact()   Exact 2D orientation test.  Robust.                    */
/*  orient2dslow()   Another exact 2D orientation test.  Robust.             */
/*  orient2d()   Adaptive exact 2D orientation test.  Robust.                */
/*                                                                           */
/*               Return a positive value if the points pa, pb, and pc occur  */
/*               in counterclockwise order; a negative value if they occur   */
/*               in clockwise order; and zero if they are collinear.  The    */
/*               result is also a rough approximation of twice the signed    */
/*               area of the triangle defined by the three points.           */
/*                                                                           */
/*  Only the first and last routine should be used; the middle two are for   */
/*  timings.                                                                 */
/*                                                                           */
/*  The last three use exact arithmetic to ensure a correct answer.  The     */
/*  result returned is the determinant of a matrix.  In orient2d() only,     */
/*  this determinant is computed adaptively, in the sense that exact         */
/*  arithmetic is used only to the degree it is needed to ensure that the    */
/*  returned value has the correct sign.  Hence, orient2d() is usually quite */
/*  fast, but will run more slowly when the input points are collinear or    */
/*  nearly so.                                                               */
/*                                                                           */
/*****************************************************************************/

extern REAL exactinit();
extern void setFPURoundingTo24Bits();
extern void setFPURoundingTo53Bits();
extern void setFPURoundingTo64Bits();
extern REAL orient2dfast(REAL *pa, REAL *pb, REAL *pc);
extern REAL orient2dexact(REAL *pa, REAL *pb, REAL *pc);
extern REAL orient2dslow(REAL *pa, REAL *pb, REAL *pc);
extern REAL orient2dadapt(REAL *pa, REAL *pb, REAL *pc, REAL detsum);
extern REAL orient2d(REAL *pa, REAL *pb, REAL *pc);
