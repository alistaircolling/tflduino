#ifndef TubeLine_H
#define TubeLine_H

#include "WProgram.h"

class TubeLine { 
public:
	
	TubeLine();
	~TubeLine();
	String name;
	String id;
	String status; //0 is fine, 1 is minor delays, 2 is sever delays, 3 is not working / closed
	long color;
private:
	String _name;	
};

#endif