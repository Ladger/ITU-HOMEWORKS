
#include "headworker.h"
#include <iostream>

using std::cout, std::endl;

HeadWorker::HeadWorker(Worker& worker) 
	: Worker{worker.getName(), worker.getCostPerDay(), worker.Unit::getReturnPerDay()}
{
	cout << getName() << " is promoted" << endl;
}

float HeadWorker::getReturnPerDay() {
	float returnPerDay = (Unit::getReturnPerDay() + m_experience * 5) - getCostPerDay();
	m_experience++;
	return returnPerDay;
}