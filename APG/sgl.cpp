//---------------------------------------------------------------------------
// sgl.cpp
// Empty implementation of the SGL (Simple Graphics Library)
// Date:  2011/11/1
// Author: Jaroslav Krivanek, Jiri Bittner CTU Prague
//---------------------------------------------------------------------------
#pragma once
#include "sgl.h"
#include "context.h"
#include <iostream>
using namespace std;

#define PI 3.14159265359f
#define nullptr 0

map<int, Context *> * m_map_of_context;
int m_context_index;
Context * actual_context;

/// Current error code.
static sglEErrorCode _libStatus = SGL_NO_ERROR;

static inline void setErrCode(sglEErrorCode c) 
{
  if(_libStatus==SGL_NO_ERROR)
    _libStatus = c;
}

//---------------------------------------------------------------------------
// sglGetError()
//---------------------------------------------------------------------------
sglEErrorCode sglGetError(void) 
{
  sglEErrorCode ret = _libStatus;
  _libStatus = SGL_NO_ERROR;
  return ret;
}

//---------------------------------------------------------------------------
// sglGetErrorString()
//---------------------------------------------------------------------------
const char* sglGetErrorString(sglEErrorCode error)
{
  static const char *errStrigTable[] = 
  {
      "Operation succeeded",
      "Invalid argument(s) to a call",
      "Invalid enumeration argument(s) to a call",
      "Invalid call",
      "Quota of internal resources exceeded",
      "Internal library error",
      "Matrix stack overflow",
      "Matrix stack underflow",
      "Insufficient memory to finish the requested operation"
  };

  if((int)error<(int)SGL_NO_ERROR || (int)error>(int)SGL_OUT_OF_MEMORY ) {
    return "Invalid value passed to sglGetErrorString()"; 
  }

  return errStrigTable[(int)error];
}

//---------------------------------------------------------------------------
// Initialization functions
//---------------------------------------------------------------------------

void sglInit(void) {
	m_map_of_context = new map<int, Context*>();
	actual_context = nullptr;
	m_context_index = 0;
}

void sglFinish(void) {
	for(unsigned int i = 0; i < m_map_of_context->size(); i++){
		sglDestroyContext(i);
	}
	delete m_map_of_context;
}

int sglCreateContext(int width, int height) {
	if(m_context_index == -1){
		setErrCode(SGL_OUT_OF_RESOURCES);
		return -1;
	}
	Context * context = new Context(width, height);
	m_map_of_context->insert(make_pair(m_context_index, context));
	return m_context_index++;
}

void sglDestroyContext(int id) {
	if(id == m_context_index){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	map<int, Context *>::iterator iter = m_map_of_context->find(id);
	if(iter == m_map_of_context->end()){
		setErrCode(SGL_INVALID_VALUE);
		return;
	}
	iter->second->~Context();
	m_map_of_context->erase(id);
}

void sglSetContext(int id) {
	if(m_map_of_context->find(id) == m_map_of_context->end()){
		setErrCode(SGL_INVALID_VALUE);
		return;
	}
	actual_context = m_map_of_context->at(id);
	m_context_index = id;
}

int sglGetContext(void) {
	if(actual_context == nullptr){
		setErrCode(SGL_INVALID_OPERATION);
		return -1;
	}
	return m_context_index;
}

float *sglGetColorBufferPointer(void) {
	if(actual_context == nullptr){
		return NULL;
	}
	return actual_context->getColorBuffer();
}
//---------------------------------------------------------------------------
// Drawing functions
//---------------------------------------------------------------------------

void sglClearColor (float r, float g, float b, float alpha) {
	Vector4 color(r,g,b);
	actual_context->setClearColor(color); 
}

void sglClear(unsigned what) {
	unsigned error = ~(SGL_COLOR_BUFFER_BIT | SGL_DEPTH_BUFFER_BIT);
	if((what & error) > 0){
		setErrCode(SGL_INVALID_VALUE);
		return;
	}
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
	}
	if(what & SGL_COLOR_BUFFER_BIT){
		float * buffer = actual_context->getColorBuffer();
		Vector4 color = actual_context->getClearColor();
		for(int i = 0; i < 3*actual_context->getWidth()*actual_context->getHeight() - 3; i+=3){
			buffer[i] = color.x;
			buffer[i+1] = color.y;
			buffer[i+2] = color.z;
		}
	}
	if(what & SGL_DEPTH_BUFFER_BIT){
		float * buffer = actual_context->getDepthBuffer();
		for(int i = 0; i < actual_context->getWidth()*actual_context->getHeight(); i++){

			buffer[i] = FLT_MAX;
		}
	}
}

void sglBegin(sglEElementType mode) {
	if (actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
	}
	if (mode > 8 && mode <= 0){
		setErrCode(SGL_INVALID_ENUM);
		return;
	}
	actual_context->begin(mode);
}

void sglEnd(void) {
	if (actual_context == nullptr || !actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
	}
	actual_context->end();
}

void sglVertex4f(float x, float y, float z, float w) {
	actual_context->drawVertex(Vector4(x, y, z, w));
}

void sglVertex3f(float x, float y, float z) {
	actual_context->drawVertex(Vector4(x, y, z));
}

void sglVertex2f(float x, float y) {
	actual_context->drawVertex(Vector4(x, y));
}

void sglCircle(float x, float y, float z, float radius) {
	//TODO - TO ASK do we require z coordinate?
	Vector4 center(x, y);
	Vector4 radiusV(radius,0,0,0);

	center = actual_context->transform(center);
	//radiusV = actual_context->transform(radiusV);
	Matrix m = actual_context->getResultMatrix();
	radius = radius * sqrt(m.data[0]*m.data[5] - m.data[1]*m.data[4]); //sqrt(radiusV.x*radiusV.x + radiusV.y*radiusV.y);

	actual_context->BressenCircle(center, radius);
}

void sglEllipse(float x, float y, float z, float a, float b) {
	int lineCnt = 40;//(a > b) ? a : b * 2 /2;
	Vector4 aT(a, 0, 0, 0);
	Vector4 bT(0, b, 0, 0);
	Vector4 zeroT(x, y);

	actual_context->getTransformationMatrix();
	aT = actual_context->transform(aT);
	bT = actual_context->transform(bT);
	zeroT = actual_context->transform(zeroT);

	for (int i = 0; i < lineCnt; i++)
	{
		float angle = i * 2.0f * PI / lineCnt;
		float prevAngle = angle - 2.0f * PI / lineCnt;

		float fromx = zeroT.x + cosf(prevAngle)*aT.x + sinf(prevAngle)*bT.x;
		float fromy = zeroT.y + cosf(prevAngle)*aT.y + sinf(prevAngle)*bT.y;
		float tox = zeroT.x + cosf(angle)*aT.x + sinf(angle)*bT.x;
		float toy = zeroT.y + cosf(angle)*aT.y + sinf(angle)*bT.y;

		/*Vector4 from(x + a*cosf(prevAngle), y + b*sinf(prevAngle));
		Vector4 to(x + a*cosf(angle), y + b*sinf(angle));

		from = actual_context->transform(from);
		to = actual_context->transform(to);*/

		Vector4 from(fromx, fromy,0,0);
		Vector4 to(tox, toy,0,0);
		actual_context->Bressen(from,to);
	}
}

void sglArc(float x, float y, float z, float radius, float from, float to) {
	int lineCnt = 20*(to-from)/PI;//(a > b) ? a : b * 2 /2;
	Vector4 center(x, y);
	Vector4 aT(radius, 0, 0, 0);
	Vector4 bT(0, radius, 0, 0);

	actual_context->getTransformationMatrix();
	center = actual_context->transform(center);
	aT = actual_context->transform(aT);
	bT = actual_context->transform(bT);

	for (int i = 1; i < lineCnt+1; i++)
	{
		float angle = from + i * (to-from) / lineCnt;
		float prevAngle = from + (i-1) * (to-from) / lineCnt;

		float fromx = center.x + cosf(prevAngle)*aT.x + sinf(prevAngle)*bT.x;
		float fromy = center.y + cosf(prevAngle)*aT.y + sinf(prevAngle)*bT.y;
		float tox = center.x + cosf(angle)*aT.x + sinf(angle)*bT.x;
		float toy = center.y + cosf(angle)*aT.y + sinf(angle)*bT.y;

		Vector4 from(fromx, fromy, 0, 0);
		Vector4 to(tox, toy, 0, 0);
		actual_context->Bressen(from, to);
	}
}

//---------------------------------------------------------------------------
// Transform functions
//---------------------------------------------------------------------------

void sglMatrixMode( sglEMatrixMode mode ) {
	unsigned error = ~(SGL_MODELVIEW | SGL_PROJECTION);
	if((mode & error) > 0){
		setErrCode(SGL_INVALID_ENUM);
		return;
	}
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	actual_context->setCurrentStack(mode);
}

void sglPushMatrix(void) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	//TODO Overflow
	MyStack<Matrix> * s = actual_context->getCurrentStack();
	Matrix mat = s->top();
	s->push(mat);
}

void sglPopMatrix(void) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	MyStack<Matrix> * s = actual_context->getCurrentStack();
	if(s->size() == 1){
		setErrCode(SGL_STACK_UNDERFLOW);
		return;
	}
	s->pop();
}

void sglLoadIdentity(void) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	MyStack<Matrix> * s = actual_context->getCurrentStack();
	s->pop();
	float fmat[16] = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
	Matrix mat(fmat);
	s->push(mat);
}

void sglLoadMatrix(const float *matrix) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	MyStack<Matrix> * s = actual_context->getCurrentStack();
	s->pop();
	Matrix mat(matrix);
	s->push(mat);
}

void sglMultMatrix(const float *matrix) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	MyStack<Matrix> * s = actual_context->getCurrentStack();
	Matrix m(matrix);
	Matrix c = s->top();
	s->pop();
	Matrix p = c*m;
	s->push(p);
}

void sglTranslate(float x, float y, float z) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	float translatem [16] = {1,0,0,0, 0,1,0,0, 0,0,1,0, x,y,z,1};
	sglMultMatrix(translatem);
}

void sglScale(float scalex, float scaley, float scalez) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	float scalem[16] = {scalex,0,0,0, 0,scaley,0,0, 0,0,scalez,0, 0,0,0,1};
	sglMultMatrix(scalem);
}

void sglRotate2D(float angle, float centerx, float centery) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	sglTranslate(centerx,centery, 0);
	float rotatem [16] = {cos(angle),sin(angle),0,0, -sin(angle),cos(angle),0,0, 0,0,1,0, 0,0,0,1};
	sglMultMatrix(rotatem);
	sglTranslate(-centerx, -centery, 0);
	//cout << "\n\n" << actual_context->getCurrentStack()->top();
	//stack<Matrix> *s = actual_context->getCurrentStack();
	//cout << "\n\n" << s->top();
}

void sglRotateY(float angle) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	float rotatem [16] = {cos(angle),0,sin(angle),0, 0,1,0,0, -sin(angle),0,cos(angle),0, 0,0,0,1};
	sglMultMatrix(rotatem);
}

void sglOrtho(float left, float right, float bottom, float top, float near, float far) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	if((left == right) || (bottom == top) || (near == far)){
		setErrCode(SGL_INVALID_VALUE);
		return;
	}
	float ortho [16] = {2/(right - left),0,0,0,		0,2/(top-bottom),0,0,
		0,0,-2/(far-near),0,	-(right+left)/(right-left),-(top+bottom)/(top-bottom),-(far+near)/(far-near),1};
	sglMultMatrix(ortho);
	//cout << "\n" << actual_context->getProjectionStack()->top();
}

void sglFrustum(float left, float right, float bottom, float top, float near, float far) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	sglOrtho(left, right, bottom, top, near, far);
	float frustrum[16] = {near,0,0,0, 0,near,0,0, 0,0,far+near,-1, 0,0,far*near,0};
	sglMultMatrix(frustrum);
}

void sglViewport(int x, int y, int width, int height) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	float view[16] = { width / 2.0, 0, 0, 0, 0, height / 2.0, 0, 0, x + width / 2.0, y + height / 2.0, 1, 0, width / 2.0, height / 2.0, 1, 0 };
	actual_context->setView(view);
}

//---------------------------------------------------------------------------
// Attribute functions
//---------------------------------------------------------------------------

void sglColor3f(float r, float g, float b) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	Vector4 color(r,g,b);
	actual_context->setActualColor(color);
}

void sglAreaMode(sglEAreaMode mode) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	unsigned error = ~(SGL_POINT | SGL_LINE | SGL_FILL);
	if((mode & error) > 0){
		setErrCode(SGL_INVALID_ENUM);
		return;
	}
	actual_context->setAreaMode(mode);
}

void sglPointSize(float size) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	if(size < 0){
		setErrCode(SGL_INVALID_VALUE);
		return;
	}
	actual_context->setPointSize(size);
}

void sglEnable(sglEEnableFlags cap) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	unsigned error = ~(SGL_DEPTH_TEST);
	if((cap & error) > 0){
		setErrCode(SGL_INVALID_ENUM);
		return;
	}
	unsigned int flags = actual_context->getFlags();
	flags |= cap;
	actual_context->setFlags(flags);
}

void sglDisable(sglEEnableFlags cap) {
	if(actual_context == nullptr || actual_context->IsBegin()){
		setErrCode(SGL_INVALID_OPERATION);
		return;
	}
	unsigned error = ~(SGL_DEPTH_TEST);
	if((cap & error) > 0){
		setErrCode(SGL_INVALID_ENUM);
		return;
	}
	unsigned int flags = actual_context->getFlags();
	flags = flags & ~cap;
	actual_context->setFlags(flags);
	
}

//---------------------------------------------------------------------------
// RayTracing oriented functions
//---------------------------------------------------------------------------

void sglBeginScene() {}

void sglEndScene() {}

void sglSphere(const float x,
			   const float y,
			   const float z,
			   const float radius) {}

void sglMaterial(const float r,
				 const float g,
				 const float b,
				 const float kd,
				 const float ks,
				 const float shine,
				 const float T,
				 const float ior) {}

void sglPointLight(const float x,
				   const float y,
				   const float z,
				   const float r,
				   const float g,
				   const float b) {}

void sglRayTraceScene() {}

void sglRasterizeScene() {}

void sglEnvironmentMap(const int width,
					   const int height,
					   float *texels)
{}

void sglEmissiveMaterial(
						 const float r,
						 const float g,
						 const float b,
						 const float c0,
						 const float c1,
						 const float c2
						 )
{}
