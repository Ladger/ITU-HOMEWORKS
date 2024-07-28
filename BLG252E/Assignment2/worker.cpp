#include "worker.h"

#include <iostream>

Worker::Worker(std::string in_name, float in_cost_per_day, float in_base_return_per_day)
	: Unit{ in_name, in_cost_per_day, in_base_return_per_day }, m_experience{}
{}

void Worker::increaseHeadWorkerCount() {
	m_num_head_workers++;
}

float Worker::getReturnPerDay() {

	float returnPerDay = (Unit::getReturnPerDay() + m_experience * 2 + m_num_head_workers * 3) - getCostPerDay();
	m_experience++;
	return returnPerDay;
}

int Worker::getExperience() const {
	return m_experience;
}