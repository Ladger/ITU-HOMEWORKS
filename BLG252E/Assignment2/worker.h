// DO NOT MODIFY THIS FILE
#ifndef WORKER_HPP
#define WORKER_HPP

#include "unit.h"

class Worker : public Unit
{
private:
    static inline int m_num_head_workers{};

protected:
    static void increaseHeadWorkerCount();

    int m_experience;

public:
    Worker(std::string name, float cost_per_day, float base_return_per_day);

    float getReturnPerDay();
    int getExperience() const;
};

#endif // WORKER_HPP