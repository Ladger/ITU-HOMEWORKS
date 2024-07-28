// DO NOT MODIFY THIS FILE
#ifndef UNIT_HPP
#define UNIT_HPP

#include <string>

// Base class
class Unit
{
private:
    std::string m_name;
    float m_cost_per_day;
    float m_base_return_per_day;

public:
    Unit(std::string name, float cost_per_day, float base_return_per_day);

    std::string getName() const;
    float getCostPerDay() const;
    float getReturnPerDay() const;
};

#endif // UNIT_HPP