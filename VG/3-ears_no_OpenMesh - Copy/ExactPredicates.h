#pragma once

namespace ExactPredicates {

extern "C" {
	extern void   exactinit();
	extern void   setFPURoundingTo24Bits(void);
	extern void   setFPURoundingTo53Bits(void);
	extern void   setFPURoundingTo64Bits(void);
	extern double orient2d     (double *pa, double *pb, double *pc);
	extern double orient2dexact(double *pa, double *pb, double *pc);
	extern double orient3d     (double *pa, double *pb, double *pc, double *pd);
	extern double orient3dexact(double *pa, double *pb, double *pc, double *pd);
	extern double incircle     (double *pa, double *pb, double *pc, double *pd);
	extern double incircleexact(double *pa, double *pb, double *pc, double *pd);
	extern double insphere     (double *pa, double *pb, double *pc, double *pd, double *pe);
	extern double insphereexact(double *pa, double *pb, double *pc, double *pd, double *pe);
}

}; /* namespace ExactPredicates */
