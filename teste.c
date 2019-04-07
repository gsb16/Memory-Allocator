#include <stdio.h>
#include "malloc.h"

int main () {
	iniciaAlocador();
	void *a,*b,*c,*d, *e;

	a=( void * ) alocaMem(100);
	imprimeMapa();
	b=( void * ) alocaMem(200);
	imprimeMapa();
	c=( void * ) alocaMem(300);
	imprimeMapa();
	d=( void * ) alocaMem(400);
	imprimeMapa();
	liberaMem(b);
	imprimeMapa();

	b=( void * ) alocaMem(80);
	imprimeMapa();

	liberaMem(c);
	imprimeMapa();
	e=( void * ) alocaMem(200);
	imprimeMapa();
	liberaMem(a);
	imprimeMapa();
	liberaMem(b);
	imprimeMapa();
	liberaMem(d);
	imprimeMapa();
	liberaMem(e);
	imprimeMapa();

	finalizaAlocador();
	return 0;
}
