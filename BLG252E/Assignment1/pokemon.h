//--- 2023-2024 Spring BLG 252E Object Oriented Programing Assignment 1 ---//
//--------------------------//
//---Name & Surname: Berk Özcan
//---Student Number: 150220107
//--------------------------//

#ifndef _H
#define _H

//-------------Do Not Add New Libraries-------------//
//-------------All Libraries Needed Were Given-------------//
#include <iostream>
#include <stdio.h>
#include <string.h>

using namespace std;

//-------------Do Not Add Any New Class(es)-------------//

class pokemon {
    //-------------Do Not Change Given Variables-------------//
    //-------------You Can Add New Variables If Neccessary-------------//
private:
    string name;
    int hpValue;
    int atkValue;
public:
    pokemon();
    pokemon(string, int);
    pokemon(const pokemon&);

    string getName() { return name; }
    int getHpVal() { return hpValue; }
    int getAtkVal() { return atkValue; }
    void takeDamage(int damage) {
        hpValue -= damage;
    }
    void setHpDefault() {
        hpValue = 100;
    }
};

class pokedex {
    //-------------Do Not Change Given Variables-------------//
    //-------------You Can Add New Variables If Neccessary-------------//
private:
    pokemon pokedexArray[100];
    int value;
public:
    pokedex() { value = 0; }
    void updatePokedex(pokemon);
    void printPokedex();
};

class player {
private:
    //-------------Do Not Change Given Variables-------------//
    //-------------You Can Add New Variables If Neccessary-------------//
    string name;
    int pokemonNumber;
    int pokeballNumber;
    int badgeNumber;
    pokemon playerPokemon;
public:
    pokedex playerPokedex;
    player();
    player(string, pokemon);

    string getName() { return name; }
    int showPokemonNumber() { return pokemonNumber; }
    int showPokeballNumber() { return pokeballNumber; }
    int showBadgeNumber() { return badgeNumber; }
    int getPokemonHp() { return playerPokemon.getHpVal(); }
    pokemon getPokemon() { return playerPokemon; }
    void battleWon();
    void catchPokemon();
    void takePokemonDamage(int damage) {
        playerPokemon.takeDamage(damage);
    }
    void setPokemonHpDefault() {
        playerPokemon.setHpDefault();
    }
    
};

class enemy {
    //-------------Do Not Change Given Variables-------------//
    //-------------You Can Add New Variables If Neccessary-------------//
private:
    string name;
    pokemon enemyPokemon;
public:
    enemy();
    enemy(string, pokemon);

    pokemon getPokemon() { return enemyPokemon; }
    string getName() { return name; }
    int getPokemonHp() { return enemyPokemon.getHpVal(); }
    void takePokemonDamage(int damage) {
        enemyPokemon.takeDamage(damage);
    }
};

#endif