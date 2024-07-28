
/*
Money, money, money
Must be funny
In the headworker spam world.
*/

#include "simulation.h"
#include <fstream>
#include <sstream>

using std::cout, std::endl, std::cin;

Simulation::Simulation(Factory& in_factory, int in_total_days, std::string in_workers_list_path, std::string in_machines_list_path)
    : m_factory{ &in_factory }, m_total_days{ in_total_days }
{
    srand(34);

    std::ifstream worker_market(in_workers_list_path);
    if (!worker_market.is_open()) {
        cout << "Worker Market failed to open." << endl;
    }

    std::string line;
    std::getline(worker_market, line);
    while (std::getline(worker_market, line)) {
        std::istringstream iss(line);
        std::string name;
        float cost_per_day, base_return_per_day;

        if (!(iss >> name >> cost_per_day >> base_return_per_day)) {
            continue;
        }

        m_labor_market.push_back(Worker(name, cost_per_day, base_return_per_day));
    }
    worker_market.close();
    
    std::ifstream machine_market(in_machines_list_path);
    if (!machine_market.is_open()) {
        cout << "Machine Market failed to open." << endl;
    }
    
    std::getline(machine_market, line);
    while (std::getline(machine_market, line)) {
        std::istringstream iss(line);
        std::string name;
        float price, cost_per_day, base_return_per_day, failure_probability, repair_cost;
        int repair_time;

        if (!(iss >> name >> price >> cost_per_day >> base_return_per_day >> failure_probability >> repair_time >> repair_cost)) {
            continue;
        }

        m_machines_market.push_back(Machine(name, price, cost_per_day, base_return_per_day, failure_probability, repair_time, repair_cost));
    }
    machine_market.close();
}

void Simulation::printWelcomeMessage() const
{
    cout << "Welcome to the Car Factory!" << endl;
    cout << "You have " << m_total_days << " days to make as much money as possible" << endl;
    cout << "You can add workers, machines, and fast forward days" << endl;

    cout << "Available commands:" << endl;
    cout << "    wX: adds X workers" << endl;
    cout << "    mX: adds X machines" << endl;
    cout << "    pX: passes X days" << endl;
    cout << "    q: exit the game properly" << endl;
}

Worker Simulation::hireRandomWorker() {
    int index = rand() % m_labor_market.size();
    Worker hiredWorker = m_labor_market[index];
    m_labor_market.erase(m_labor_market.begin() + index);
    
    return hiredWorker;
}

Machine Simulation::buyRandomMachine() {
    int index = rand() % m_machines_market.size();
    Machine boughtMachine = m_machines_market[index];
    m_machines_market.erase(m_machines_market.begin() + index);

    return boughtMachine;
}

void Simulation::run() {
    int days = 0;

    while (true) {
        if (!m_factory->isBankrupt()) {

            if (days == m_total_days) {
                cout << "Congrats! You have earned " << m_factory->getCapital() << " in 30 days" << endl;
                return;
            }

            std::string input;
            cin >> input;

            if (input == "q") {
                return;
            }

            std::string operation = input.substr(0, 1);
            std::string amountChar = input.substr(1);
            int amount{};

            for (char c : amountChar) {
                amount = amount * 10 + (c - '0');
            }

            if (operation == "w") {
                for (int i = 0; i < amount; i++) {
                    m_factory->addUnit(hireRandomWorker());
                }
            }
            else if (operation == "m") {
                for (int i = 0; i < amount; i++) {
                    Machine mac = buyRandomMachine();

                    if (m_factory->getCapital() >= mac.getPrice()) {
                        m_factory->addUnit(mac);
                    }
                    else {
                        m_machines_market.push_back(mac);
                        cout << "You do not have enough money." << endl;
                    }
                }
            }
            else if (operation == "p") {
                for (int i = 0; i < amount; i++) {
                    cout << "--- Day " << days + 1 << endl;
                    m_factory->passOneDay();
                    days++;
                }
            }
            else {
                cout << "Please enter correct input." << endl;
            }
        }
        else {
            cout << "You went bankrupt!" << endl;
            return;
        }
    }
}
