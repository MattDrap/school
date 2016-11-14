#ifndef CONTEXT
#define CONTEXT
#include <iostream>
#include "MyStack.h"
#include "Matrix.h"
#include <map>
#include <cmath>
#include <cstring>
#include <cfloat>
#include <vector>
#include <algorithm>
#include "ScanlineEdge.h"

using namespace std;

//Class for encapsulating buffers, stack, colors and objects
class Context{
	MyStack<Matrix> * model_view;
	MyStack<Matrix> * projection;
	//pointer for current stack
	MyStack<Matrix> * current_stack;
	Matrix viewMatrix;
	Matrix resultMatrix;
	float *color_buffer;
	float *depth_buffer;
	unsigned int flags;
	Vector4 clear_color;
	float actual_color[3];
	float point_size;
	unsigned int width;
	unsigned int height;
	
	//DRAWING
	
	//if drawing has begun
	bool begin_draw;
	//last element type
	sglEElementType line_mode;
	//first and last vertex for connecting
	Vector4 firstV, lastV;
	//toggle if last vertex is in buffer already
	bool lastVB;
	//count number of vertices
	int vertex_counter;
	//if projection, modelview or viewport has changed and need to recalculate
	bool matrixChange;
	//type of fill
	sglEAreaMode area_mode;
	//vertex buffer
	vector<Vector4> vertex_buffer;

public :

	void begin(sglEElementType mode){
		line_mode = mode;
		begin_draw = true;
		vertex_counter = 0;
		vertex_buffer.clear();
		getTransformationMatrix();
	}
	void end(){
		if (line_mode == SGL_LINE_LOOP){
			Bressen(firstV, lastV);
		}
		if (line_mode == SGL_POLYGON && area_mode == SGL_FILL){
			fillPolygon();
		}
		vertex_buffer.clear();
		vertex_counter = 0;
		begin_draw = false;
		lastVB = false;
	}
	void BressenCircle(Vector4 pos, float radius)
	{
		int x0 = pos.x;
		int y0 = pos.y;
		int f = 1 - radius;
		int ddF_x = 0;
		int ddF_y = -2 * radius;
		int x = 0;
		int y = radius;

		fillPixel(x0, y0 + radius);
		fillPixel(x0, y0 - radius);
		fillPixel(x0 + radius, y0);
		fillPixel(x0 - radius, y0);

		while (x < y)
		{
			if (f >= 0)
			{
				y--;
				ddF_y += 2;
				f += ddF_y;
			}
			x++;
			ddF_x += 2;
			f += ddF_x + 1;

			fillPixel(x0 + x, y0 + y);
			fillPixel(x0 - x, y0 + y);
			fillPixel(x0 + x, y0 - y);
			fillPixel(x0 - x, y0 - y);
			fillPixel(x0 + y, y0 + x);
			fillPixel(x0 - y, y0 + x);
			fillPixel(x0 + y, y0 - x);
			fillPixel(x0 - y, y0 - x);
		}
	}

	// Bresenham's line algorithm
	void Bressen(Vector4 v1, Vector4 v2)
	{
		int x1 = v1.x;
		int y1 = v1.y;
		int x2 = v2.x;
		int y2 = v2.y;
		const bool steep = (abs(y2 - y1) > abs(x2 - x1));
		float *pixels = color_buffer;
		int xp=0, yp=0;
		if (steep)
		{
			std::swap(x1, y1);
			std::swap(x2, y2);
		}

		if (x1 > x2)
		{
			std::swap(x1, x2);
			std::swap(y1, y2);
		}

		if (steep)
		{
			pixels += x1 * width * 3 + y1 * 3;
			xp = width*3; yp = 3;
		}
		else
		{
			pixels += y1 * width * 3 + x1 * 3;
			xp = 3; yp = width*3;
		}

		const float dx = x2 - x1;
		const float dy = abs(y2 - y1);

		float error = dx / 2.0f;
		const int ystep = (y1 < y2) ? 1 : -1;

		const int maxX = (int)x2;

		float *pixelMax = color_buffer + width*height*3;
		for (int x = (int)x1; x <= maxX; x++)
		{
			//if (pixels<pixelMax && pixels>color_buffer)
				memcpy(pixels, actual_color, sizeof(float) *3);

			error -= dy;
			if (error < 0)
			{
				pixels += yp*ystep;
				error += dx;
			}
			pixels += xp;
		}
	}

	//return transformated vetor through modelview projection and view
	inline Vector4 transform(Vector4 vector){
		vector = resultMatrix*vector;
		//normalise?
		return vector;
	}
	inline void getTransformationMatrix(){
		if (matrixChange)
		{
			resultMatrix = viewMatrix * projection->top() * model_view->top();
			matrixChange = false;
		}
	}
	inline Matrix& getResultMatrix(){
		getTransformationMatrix();
		return resultMatrix;
	}
	inline void drawLineLoop(Vector4 vector){
		if (!lastVB){
			lastVB = true;
			lastV = vector;
			firstV = vector;
		}
		else {
			Bressen(lastV, vector);
			lastV = vector;
		}
	}
	inline void fillPolygon(){
		//scanline
		int vbuffer_size = vertex_buffer.size();
		ScanlineEdge * edges = new ScanlineEdge[vbuffer_size];
		int scanline_y_min = INT_MAX;
		int scanline_y_max = INT_MIN;
		vector<ScanlineEdge *> active_list;
		for(int j = 0; j < vbuffer_size - 1; j++){
			if(abs(vertex_buffer[j].y - vertex_buffer[j+1].y) < 0.0001)
				continue;

			ScanlineEdge s(vertex_buffer[j].x, vertex_buffer[j].y, vertex_buffer[j+1].x, vertex_buffer[j+1].y);
			if(s.ymin < scanline_y_min){
				scanline_y_min = s.ymin;
			}
			if(s.ymax > scanline_y_max){
				scanline_y_max = s.ymax;
			}
			edges[j] = s;
		}
		ScanlineEdge s(vertex_buffer[vbuffer_size - 1].x, vertex_buffer[vbuffer_size - 1].y, vertex_buffer[0].x, vertex_buffer[0].y);
		if(s.ymin < scanline_y_min){
			scanline_y_min = s.ymin;
		}
		if(s.ymax > scanline_y_max){
			scanline_y_max = s.ymax;
		}
		edges[vbuffer_size - 1] = s;
		ShakeSort(edges, vbuffer_size);

		int lastI;
		for(int i = 0; i < vbuffer_size; i++){
			if(edges[i].ymin == scanline_y_min ){
				active_list.push_back(&edges[i]);
				lastI = i;
			}
			else{
				break;
			}
		}
		for(int i = scanline_y_min; i <= scanline_y_max; i++){
			for(int j = lastI + 1; j < vbuffer_size; j++){
				if(i == edges[j].ymin){
					active_list.push_back(&edges[j]);
					lastI = j;
				}
				else{
					break;
				}
			}
			for(int j = 0; j < active_list.size() - 1; j+=2){
				for(int k = ceil(active_list[j]->x); k <= floor(active_list[j+1]->x); k++){
					fillPixel(k, i);
				}
			}
			for(vector<ScanlineEdge *>::iterator iter = active_list.begin(); iter != active_list.end();){
				(*iter)->update();
				if((*iter)->ymin - 1 == (*iter)->ymax){
					iter = active_list.erase(iter);
				}else{
					iter++;
				}
			}
			ShakeSort(active_list);
		}
		delete [] edges;
		active_list.clear();
	}
	//central method drawing objects
	void drawVertex(Vector4 vector){
		//transform
		vector = resultMatrix*vector;
		//normalise?
		//clipping?
		switch (line_mode){
		case SGL_POINTS:
			if (point_size == 1)
			{
				fillPixel(vector.x, vector.y);
				break;
			}
			for (int x = 0; x < point_size; x++)
				for (int y = 0; y < point_size; y++)
					fillPixel(vector.x - point_size / 2 + x, 
							  vector.y - point_size / 2 + y);
			break;
		case SGL_LINES:
			if (!lastVB){
				lastVB = true;
				lastV = vector;
			}
			else {
				lastVB = false;
				Bressen(lastV,vector);
			}
			break;
		case SGL_LINE_STRIP:
			if (!lastVB){
				lastVB = true;
				lastV = vector;
			}
			else {
				Bressen(lastV, vector);
				lastV = vector;
				//lastVB = false;
			}
			break;
		case SGL_LINE_LOOP:
			drawLineLoop(vector);
			break;
		case SGL_TRIANGLES:
			if(vertex_counter == 3){
				lastVB = false;
				vertex_counter = 0;
				Bressen(firstV, lastV);
			}
			drawLineLoop(vector);
			++vertex_counter;
			break;
		case SGL_POLYGON:
			if(area_mode == SGL_LINE){
				line_mode = SGL_LINE_LOOP;
				drawLineLoop(vector);
			}else if(area_mode == SGL_FILL){
				vertex_buffer.push_back(vector);
			}
			break;
		}
	}

	inline Context(const int width,const int height):width(width), height(height),flags(0),begin_draw(false),point_size(1),lastVB(false){
		color_buffer = new float[3 * width * height];
		depth_buffer = new float[width * height];
		model_view = new MyStack<Matrix>();
		projection = new MyStack<Matrix>();
		float mat [16] = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
		Matrix m(mat);
		clear_color.x = 0;
		clear_color.y = 0;
		clear_color.z = 0;
		actual_color[0] = 0;
		actual_color[1] = 0;
		actual_color[2] = 0;
		current_stack = projection;
		model_view->push(m);
		projection->push(m);
		getTransformationMatrix();
		viewMatrix = m;
		vertex_counter = 0;
		matrixChange = false;
	}
	inline ~Context(){
		delete [] color_buffer;
		delete [] depth_buffer;
		delete model_view;
		delete projection;
	}
	inline void setView(float* mat){
		Matrix m(mat);
		viewMatrix = m;
		matrixChange = true;
	}
	inline int getPixel(int x, int y){
		if (x<0 || y<0 || x>width || y>height)
			return -1;
		return y * width * 3 + x * 3;
	}
	inline void fillPixel(int x, int y){
		unsigned int id = y * width * 3 + x * 3;
		//if (id < width*height*3)
			memcpy(color_buffer + id,actual_color,sizeof(float)*3);
	}
	inline void fillPixel(float* id){
		if (id < color_buffer+width*height*3)
			memcpy(id, actual_color, sizeof(float) *3);
	}
	inline float * getColorBuffer(){
		return color_buffer;
	}
	inline Vector4 getClearColor(){
		return clear_color;
	}
	inline void setClearColor(Vector4 color){
		clear_color = color;
	}
	inline int getWidth(){
		return width;
	}
	inline int getHeight(){
		return height;
	}
	inline float * getDepthBuffer(){
		return depth_buffer;
	}
	inline bool IsBegin(){
		return begin_draw;
	}
	inline void setCurrentStack(unsigned matrixmode){
		if(matrixmode == 0){
			current_stack = model_view;
		}else{
			current_stack = projection;
		}
	}
	inline MyStack<Matrix> * getModelViewStack(){
		return model_view;
	}
	inline MyStack<Matrix> * getProjectionStack(){
		return projection;
	}
	inline MyStack<Matrix> * getCurrentStack(){
		matrixChange = true;
		return current_stack;
	}
	inline unsigned int getFlags(){
		return flags;
	}
	inline void setFlags(unsigned int aflags){
		flags = aflags;
	}
	inline void setActualColor(Vector4 color){
		actual_color[0] = color.x;
		actual_color[1] = color.y;
		actual_color[2] = color.z;
	}
	inline void setPointSize(float point_size){
		this->point_size = point_size;
	}
	inline void setAreaMode(sglEAreaMode mode){
		this->area_mode = mode;
	}
};

//Contexts 
extern map<int, Context*> * m_map_of_context;
//index to actual context
extern int m_context_index;

//Kdyby náhodou, na pøíštì
//no už se na ty upvectory tìšim, faktžejo
class Camera
{
public:
  const int    frameWidth;
  const int    frameHeight;
  const Vector4  position;
  const Vector4 direction;
  const Vector4 up;
  const Vector4 right;
  
  Camera(const int     frameWidth,
         const int     frameHeight,
         const Vector4&  position,
         const Vector4& direction,
         const Vector4& up) 
  : frameWidth(frameWidth),frameHeight(frameHeight),
    position(position), direction(normalize(direction)), up(normalize(up)) {}
      
};
#endif