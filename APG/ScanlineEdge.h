#ifndef SCANLINE_EDGE
#define SCANLINE_EDGE
#include <vector>

struct ScanlineEdge{
	int ymin;
	int ymax;
	float x;
	float step_m;
	ScanlineEdge(){
	}
	ScanlineEdge(float x1, float y1, float x2, float y2){
		if(y1 < y2){
			ymin = y1;
			ymax = y2 - 1;
		}else{
			ymin = y2;
			ymax = y1 - 1;
		}
		if(x2-x1 != 0){
			float m = (y2 - y1)/(x2 - x1); 
			int b = -m*x1 + y1;
			x = (ymin-b)/m;
			step_m = 1/m;
		}else{
			if(ymin == (int)y1){
				x = x1;
			}else{
				x = x2;
			}
			step_m = 0;
		}
	}
	void update(){
		ymin += 1;
		x += step_m;
	}
	bool operator<(const ScanlineEdge& e) const
	{
		if(ymin == e.ymin){
			return x < e.x;
		}
		return ymin < e.ymin;
	}
};

void ShakeSort(ScanlineEdge * vec, int size) {
	for (int i = 0; i < size/2; i++) {
        bool swapped = false;
        for (int j = i; j < size - i - 1; j++) { //tam
            if (vec[j+1] < vec[j]) {
				ScanlineEdge tmp = vec[j];
                vec[j] = vec[j+1];
                vec[j+1] = tmp;
                swapped = true;
            }
        }
        for (int j = size - 2 - i; j > i; j--) { //a zpatky
            if (vec[j] < vec[j-1]) {
				ScanlineEdge tmp = vec[j];
                vec[j] = vec[j-1];
                vec[j-1] = tmp;
                swapped = true;
            }
        }
        if(!swapped) break; //zarazka (pokud nebylo prohozeno, je serazeno)
    }
}

void ShakeSort(std::vector<ScanlineEdge *> &vec) {
    int size = vec.size();
	for (int i = 0; i < size/2; i++) {
        bool swapped = false;
        for (int j = i; j < size - i - 1; j++) { //tam
            if (*vec[j+1] < *vec[j]) {
				ScanlineEdge *tmp = vec[j];
                vec[j] = vec[j+1];
                vec[j+1] = tmp;
                swapped = true;
            }
        }
        for (int j = size - 2 - i; j > i; j--) { //a zpatky
            if (*vec[j] < *vec[j-1]) {
				ScanlineEdge *tmp = vec[j];
                vec[j] = vec[j-1];
                vec[j-1] = tmp;
                swapped = true;
            }
        }
        if(!swapped) break; //zarazka (pokud nebylo prohozeno, je serazeno)
    }
}
#endif