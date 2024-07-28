// DO NOT MODIFY THIS FILE
#include <iostream>
#include <string>
#include <cstdlib> // std::srand

#include "factory.h"
#include "simulation.h"

using namespace std;

int main(int argc, char** argv)
{
    string labor_market_file;
    string machines_market_file;

    if (argc == 1)
    {
        labor_market_file = "./data/labor_market.txt";
        machines_market_file = "./data/machines_market.txt";
    }
    else if (argc == 3)
    {
        labor_market_file = argv[1];
        machines_market_file = argv[2];
    }
    else
    {
        cout << "Usage: " << argv[0] << " [labor_market_file] [machines_market_file]" << endl;
        return 1;
    }

    // Set the initial capital and total days
    const float capital = 100.0f;
    const int total_days = 30;

    // For reproducibility, set the seed to a fixed value
    srand(34);

    // Create factory and simulation objects
    Factory factory(capital);

    Simulation simulation(factory, total_days, labor_market_file, machines_market_file);

    // Run the simulation
    simulation.printWelcomeMessage();
    simulation.run();

    return 0;
}