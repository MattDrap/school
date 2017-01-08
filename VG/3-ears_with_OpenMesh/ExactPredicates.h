#pragma once

#include <OpenMesh/Core/Mesh/PolyMesh_ArrayKernelT.hh>

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

inline double orient2d(const OpenMesh::Vec2d &pa, const OpenMesh::Vec2d &pb, const OpenMesh::Vec2d &pc)
{ 
	return orient2dexact(
		const_cast<double*>(&pa[0]), 
		const_cast<double*>(&pb[0]), 
		const_cast<double*>(&pc[0]));
}

inline double  orient2d(const OpenMesh::Vec2f &pa, const OpenMesh::Vec2f &pb, const OpenMesh::Vec2f &pc)
{ 
	return orient2d(
		OpenMesh::Vec2d(pa[0], pa[1]),
		OpenMesh::Vec2d(pb[0], pb[1]),
		OpenMesh::Vec2d(pc[0], pc[1]));
}

inline double incircle(const OpenMesh::Vec2d &pa, const OpenMesh::Vec2d &pb, const OpenMesh::Vec2d &pc, const OpenMesh::Vec2d &pd)
{ 
	return incircleexact(
		const_cast<double*>(&pa[0]),
		const_cast<double*>(&pb[0]),
		const_cast<double*>(&pc[0]),
		const_cast<double*>(&pd[0]));
}

inline double incircle(const OpenMesh::Vec2f &pa, const OpenMesh::Vec2f &pb, const OpenMesh::Vec2f &pc, const OpenMesh::Vec2f &pd)
{ 
	return incircle(
		OpenMesh::Vec2d(pa[0], pa[1]),
		OpenMesh::Vec2d(pb[0], pb[1]),
		OpenMesh::Vec2d(pc[0], pc[1]),
		OpenMesh::Vec2d(pd[0], pd[1]));
}

}; /* namespace ExactPredicates */
