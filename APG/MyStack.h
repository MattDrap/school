#ifndef MYSTACK_LOIUZOI7D65R6TUDR67UD
#define MYSTACK_LOIUZOI7D65R6TUDR67UD

#include "context.h"
#include <vector>
using namespace std;

template<class T>
//faster implementation of classic stack
class MyStack{
public:
	//push on stack
	void push(T t){
		mat.push_back(t);
	}
	//remove top element from stack
	void pop(){
		mat.pop_back();
	}
	//return top element without removing
	T top(){
		return mat[mat.size() - 1];
	}
	//return size of stack
	int size(){
		return mat.size();
	}
private:
	vector<T> mat;
};

#endif