#pragma once

#include <OpenMesh/Core/Mesh/PolyMesh_ArrayKernelT.hh>

// Traits for a 2D planar structure.
// OpenMesh requires all the below listed types to be defined, but the actual memory
// will be allocated on request. Only the points are allocated by default.
template<typename T>
struct PolyMeshTraits
{
	/// The default coordinate type is OpenMesh::Vec3f.
	typedef OpenMesh::VectorT<T,2>  Point;

	/// The default normal type is OpenMesh::Vec3f.
	typedef OpenMesh::VectorT<T,3>  Normal;

	/// The default 1D texture coordinate type is float.
	typedef float					TexCoord1D;
	/// The default 2D texture coordinate type is OpenMesh::Vec2f.
	typedef OpenMesh::Vec2f			TexCoord2D;
	/// The default 3D texture coordinate type is OpenMesh::Vec3f.
	typedef OpenMesh::Vec3f			TexCoord3D;

	/// The default texture index type
	typedef int						TextureIndex;

	/// The default color type is OpenMesh::Vec3uc.
	typedef OpenMesh::Vec3uc		Color;

	VertexTraits    {};
	HalfedgeTraits  {};
	EdgeTraits      {};
	FaceTraits      {};

	VertexAttributes(OpenMesh::Attributes::Status);
	HalfedgeAttributes(OpenMesh::Attributes::PrevHalfedge | OpenMesh::Attributes::Status);
	EdgeAttributes(OpenMesh::Attributes::Status);
	FaceAttributes(OpenMesh::Attributes::Status);
};
