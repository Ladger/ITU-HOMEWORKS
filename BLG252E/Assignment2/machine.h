// DO NOT MODIFY THIS FILE
#ifndef MACHINE_HPP
#define MACHINE_HPP

#include "unit.h"

class Machine : public Unit
{
private:
    float m_failure_probability;
    int m_repair_time;
    float m_price;
    float m_repair_cost;

    int m_days_until_repair;

public:
    Machine(std::string name, float price, float cost_per_day, float base_return_per_day, float failure_probability, int repair_time, float repair_cost);
    float getReturnPerDay();
    float getPrice() const;
};

#endif // MACHINE_HPP