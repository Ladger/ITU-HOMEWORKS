
#include "factory.h"

using std::cout, std::endl;

Factory::Factory(float in_capital) : m_capital{in_capital}, m_is_bankrupt{Factory::isBankrupt()}
{}

void Factory::addUnit(const Worker& worker) {
	cout << worker.getName() << " is hired" << endl;
	m_workers.push_back(worker);
}

void Factory::addUnit(const Machine& machine) {
	cout << machine.getName() << " is bought" << endl;
	m_machines.push_back(machine);
}

bool Factory::isBankrupt() const {
	if (m_capital < 0) {
		return true;
	}
	else {
		return false;
	}
}

float Factory::getCapital() const {
	return m_capital;
}

int Factory::getWorkerCount() const {
	return m_workers.size();
}

int Factory::getMachineCount() const {
	return m_machines.size();
}

int Factory::getHeadWorkerCount() const {
	return m_head_workers.size();
}

void Factory::passOneDay() {
	
	float balance = 0;

	for (int i = 0; i < getWorkerCount(); i++) {
		balance += m_workers[i].getReturnPerDay();
	}

	for (int i = 0; i < getHeadWorkerCount(); i++) {
		balance += m_head_workers[i].getReturnPerDay();
	}

	for (int i = 0; i < getMachineCount(); i++) {
		balance += m_machines[i].getReturnPerDay();
	}

	m_capital += balance;
	cout << "[C: " << m_capital << ", W: " << getWorkerCount() << ", M: " << getMachineCount() << ", HW: " << getHeadWorkerCount() << "]" << endl;

	for (int i = 0; i < getWorkerCount();) {
		if (m_workers[i].getExperience() >= 10) {
			m_head_workers.push_back(m_workers[i]);
			m_workers.erase(m_workers.begin() + i);
			
		}
	}
}