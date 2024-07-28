#include "unit.h"

Unit::Unit(std::string in_name, float in_cost_per_day, float in_base_return_per_day) 
	: m_name{in_name}, m_cost_per_day{in_cost_per_day}, m_base_return_per_day{in_base_return_per_day}
{}

std::string Unit::getName() const { return m_name; };
float Unit::getCostPerDay() const { return m_cost_per_day; };
float Unit::getReturnPerDay() const { return m_base_return_per_day; };