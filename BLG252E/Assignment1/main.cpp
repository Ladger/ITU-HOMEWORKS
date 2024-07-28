
//-------------Do Not Add New Libraries-------------//
//-------------All Libraries Needed Were Given-------------//
#include <iostream> 
#include <stdio.h>
#include <string.h>
#include <fstream>

#include "pokemon.h"

using namespace std;

//-------------Do Not Change These Global Variables-------------//
int NAME_COUNTER = 0;   //Use this to keep track of the enemy names
int POK_COUNTER = 0;    //Use this to keep track of the pokemon names
int PLAYER_POKEMON_ATTACK = 20; //You don't have to use this variable but its here if you need it
int ENEMY_POKEMON_ATTACK = 10;  //You don't have to use this variable but its here if you need it
//--------------------------------------------------------------//

//---If Necessary Add Your Global Variables Here---// 
int CURRENT_ENEMY = 0;
int CURRENT_POKEMON = 0;
//-------------------------------------------------//

//-------------Do Not Change These Function Definitions-------------//
string* readEnemyNames(const char*);
string* readPokemonNames(const char*);
player characterCreate(string, int);
void mainMenu();
void fightEnemy(player*, string*, string*);
void catchPokemon(player*, string*);
//------------------------------------------------------------------//

int main(int argc, char* argv[]) {
    system("clear");

    ////---Creating Enemy and Pokemon Name Arrays---//
    string* enemyNames = readEnemyNames(argv[1]);
    string* pokemonNames = readPokemonNames(argv[2]);

    string playerName;
    int pokemonChoice;

    cout << "Welcome to the Pokemon Game! \n" << endl;
    cout << "Please enter your name: ";
    cin >> playerName;
    cout << "Please choose one of these pokemons as your pokemon: \n1- Bulbasaur \n2- Charmender \n3- Squirtle \nChoice: ";
    cin >> pokemonChoice;

    //---Character Creation--//
    player newPlayer = characterCreate(playerName, pokemonChoice);
    int menuChoice;

    while (true) {
        mainMenu();
        cin >> menuChoice;

        switch (menuChoice) {
        case 1:
            fightEnemy(&newPlayer, enemyNames, pokemonNames);
            break;
        case 2:
            catchPokemon(&newPlayer, pokemonNames);
            break;
        case 3:
            cout << newPlayer.showPokemonNumber() << endl;
            break;
        case 4:
            cout << newPlayer.showPokeballNumber() << endl;
            break;
        case 5:
            cout << newPlayer.showBadgeNumber() << endl;
            break;
        case 6:
            cout << endl;
            cout << "------- Pokedex -------" << endl;
            newPlayer.playerPokedex.printPokedex();
            break;
        case 7:
            //---Deletes Dynamic Arrays From Memory and Exits---//
            delete[] enemyNames;
            delete[] pokemonNames;
            return EXIT_SUCCESS;
            break;

        default:
            cout << "Please enter a valid number!!!" << endl;
            break;
        }
    }
    return EXIT_FAILURE;

}
//-----------------------------------------------------//

//-------------Code This Function-------------//
string* readEnemyNames(const char* argv) {
    ifstream enemyNamesFile(argv);

    enemyNamesFile >> NAME_COUNTER;
    string* enemyNames = new string[NAME_COUNTER];

    for (int i = 0; i < NAME_COUNTER; i++)
    {
        enemyNamesFile >> enemyNames[i];
    }

    enemyNamesFile.close();
    return enemyNames;
};
//-----------------------------------------------------//

//-------------Code This Function-------------//
string* readPokemonNames(const char* argv) {
    ifstream pokemonNamesFile(argv);

    pokemonNamesFile >> POK_COUNTER;
    string* pokemonNames = new string[POK_COUNTER];

    for (int i = 0; i < POK_COUNTER; i++)
    {
        pokemonNamesFile >> pokemonNames[i];
    }

    pokemonNamesFile.close();
    return pokemonNames;
};
//-----------------------------------------------------//

//-------------Code This Function-------------//
player characterCreate(string playerName, int pokemonChoice) {
    player* newPlayerPtr;
    pokemon* newPokemonPtr;

    switch (pokemonChoice)
    {
    case 1:
        newPokemonPtr = new pokemon("Bulbasaur", PLAYER_POKEMON_ATTACK);
        newPlayerPtr = new player(playerName, *newPokemonPtr);
        break;
    case 2:
        newPokemonPtr = new pokemon("Charmender", PLAYER_POKEMON_ATTACK);
        newPlayerPtr = new player(playerName, *newPokemonPtr);
        break;
    case 3:
        newPokemonPtr = new pokemon("Squirtle", PLAYER_POKEMON_ATTACK);
        newPlayerPtr = new player(playerName, *newPokemonPtr);
        break;
    default:
        cout << "Incorrect pokemon choice." << endl;
        return player();
    }

    player newPlayer = *newPlayerPtr;

    delete newPlayerPtr;
    delete newPokemonPtr;
    return newPlayer;
};
//--------------------------------------------//

//-------------Do Not Change This Function-------------//
void mainMenu() {
    cout << endl;
    cout << "-------- Menu --------" << endl;
    cout << "1. Fight for a badge" << endl;
    cout << "2. Catch a Pokemon" << endl;
    cout << "3. Number of Pokemons" << endl;
    cout << "4. Number of Pokeballs " << endl;
    cout << "5. Number of Badges" << endl;
    cout << "6. Pokedex" << endl;
    cout << "7. Exit" << endl;
    cout << endl;
    cout << "Choice: ";
};
//-----------------------------------------------------//

//-------------Code This Function-------------//
void fightEnemy(player* newPlayer, string* enemyNames, string* pokemonNames) {
    pokemon* enemyPokemon = new pokemon(pokemonNames[CURRENT_POKEMON], ENEMY_POKEMON_ATTACK);
    enemy* newEnemy = new enemy(enemyNames[CURRENT_ENEMY], *enemyPokemon);
    newPlayer->playerPokedex.updatePokedex(*enemyPokemon);

    CURRENT_POKEMON++;
    if (CURRENT_POKEMON >= pokemonNames->length()) {
        CURRENT_POKEMON = 0;
    }

    CURRENT_ENEMY++;
    if (CURRENT_ENEMY >= enemyNames->length()) {
        CURRENT_ENEMY = 0;
    }

    bool isFirstRound = true;
    while ((newPlayer->getPokemonHp() > 0) && (newEnemy->getPokemonHp() > 0)) {
        int menuChoice;
        if (isFirstRound) {
            cout << "You encounter with " << newEnemy->getName() << " and his/hers pokemon " << newEnemy->getPokemon().getName() << endl;
            cout << newEnemy->getPokemon().getName() << " Health : 100 Attack : 10\n1 - Fight\n2 - Runaway\nChoice : ";
            isFirstRound = false;
        }
        else {
            cout << "Your Pokemons Healt: " << newPlayer->getPokemonHp() << endl;
            cout << newEnemy->getName() << " Pokemons Healt : " << newEnemy->getPokemonHp() <<"\n1 - Fight\n2 - Runaway\nChoice: ";
        }
        cin >> menuChoice;

        switch (menuChoice)
        {
        case 1:
            newEnemy->takePokemonDamage(PLAYER_POKEMON_ATTACK);
            newPlayer->takePokemonDamage(ENEMY_POKEMON_ATTACK);
            break;
        case 2:
            newPlayer->setPokemonHpDefault();
            delete newEnemy;
            delete enemyPokemon;
            return;
        default:
            cout << "Invalid choice." << endl;
            break;
        }
    }

    // I know this logic is dumb, because we are giving damage at the same loop even if player hits first
    // However calico checking that way so :/
    if (newEnemy->getPokemonHp() <= 0) {
        cout << "Your Pokemons Healt: " << newPlayer->getPokemonHp() << endl;
        cout << newEnemy->getName() << " Pokemons Healt : " << newEnemy->getPokemonHp() << "\nYou Won!" << endl;
    }
    else if (newPlayer->getPokemonHp() <= 0) {
        cout << "Your Pokemons Healt: " << newPlayer->getPokemonHp() << endl;
        cout << newEnemy->getName() << " Pokemons Healt : " << newEnemy->getPokemonHp() << "\nYou Lost!" << endl;
    }

    newPlayer->battleWon();

    delete newEnemy;
    delete enemyPokemon;
    return;
};
//--------------------------------------------//

//-------------Code This Function-------------//
void catchPokemon(player* newPlayer, string* pokemonNames) {
    if (newPlayer->showPokeballNumber() <= 0) {
        cout << "You do not have any pokeballs!" << endl;
    }
    else {
        pokemon* newPokemon = new pokemon(pokemonNames[CURRENT_POKEMON], ENEMY_POKEMON_ATTACK);
        newPlayer->playerPokedex.updatePokedex(*newPokemon);

        CURRENT_POKEMON++;
        if (CURRENT_POKEMON >= pokemonNames->length()) {
            CURRENT_POKEMON = 0;
        }

        int menuChoice;
        cout << "You encounter with " << newPokemon->getName() << " Health: 100 Attack: 10\n1- Catch\n2- Runaway\nChoice: ";
        cin >> menuChoice;

        switch (menuChoice)
        {
        case 1:
            cout << "You catch " << newPokemon->getName() << endl;
            newPlayer->catchPokemon();
            break;
        case 2:
            break;
        default:
            cout << "Invalid choice." << endl;
            break;
        }

        delete newPokemon;
        return;
    }
};
//--------------------------------------------//