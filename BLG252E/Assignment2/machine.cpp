
#include "machine.h"

Machine::Machine(std::string in_name, float in_price, float in_cost_per_day, float in_base_return_per_day, float in_failure_probability, int in_repair_time, float in_repair_cost)
	: Unit{in_name, in_cost_per_day, in_base_return_per_day}, m_price{in_price}, m_failure_probability{in_failure_probability}, m_repair_time{in_repair_time}, m_repair_cost{in_repair_cost}, m_days_until_repair{in_repair_time}
{}

float Machine::getReturnPerDay() {
	if (m_days_until_repair < m_repair_time) {
		m_days_until_repair++;
		return 0;
	}
	else {
		if ((rand() / RAND_MAX) < m_failure_probability) {
			m_days_until_repair = 0;
			return -m_repair_cost;
		}
		else {
			return Unit::getReturnPerDay() - getCostPerDay();
		}
	}
}

float Machine::getPrice() const {
	return m_price;
}