//--- 2023-2024 Spring BLG 252E Object Oriented Programing Assignment 1 ---//
//--------------------------//
//---Name & Surname: Berk Özcan
//---Student Number: 150220107
//--------------------------//

//-------------Do Not Add New Libraries-------------//
//-------------All Libraries Needed Were Given-------------//
#include <iostream>
#include <stdio.h>
#include <string.h>

#include "pokemon.h"

using namespace std;

//-------------You Can Add Your Functions Down Below-------------//

pokemon::pokemon() {
	name = "Unknown";
	atkValue = 0;
	hpValue = 0;
}

pokemon::pokemon(string pokemonName, int pokemonAtk) {
	name = pokemonName;
	atkValue = pokemonAtk;
	hpValue = 100;
}

pokemon::pokemon(const pokemon& originalPokemon) : pokemon{ originalPokemon.name, originalPokemon.atkValue } {}

void pokedex::updatePokedex(pokemon newPokemon) {
	for (int i = 0; i < value; i++) {
		if (newPokemon.getName() == pokedexArray[i].getName()) {
			return;
		}
	}
	pokedexArray[value] = newPokemon;
	value++;
}

void pokedex::printPokedex() {
	for (pokemon poke : pokedexArray) {
		if (poke.getName() == "Unknown") {
			break;
		}
		cout << poke.getName() << endl;
	}
}

player::player() {
	name = "Unknown";
	pokemonNumber = 0;
	pokeballNumber = 0;
	badgeNumber = 0;
	playerPokemon = pokemon();
}

player::player(string playerName, pokemon startPokemon) {
	name = playerName;
	playerPokemon = startPokemon;
	pokemonNumber = 0;
	pokeballNumber = 0;
	badgeNumber = 0;
}

void player::battleWon() {
	badgeNumber++;
	pokeballNumber += 3;
}

void player::catchPokemon() {
	pokemonNumber++;
	pokeballNumber--;
}

enemy::enemy() {
	name = "Unknown";
	enemyPokemon = pokemon();
}

enemy::enemy(string enemyName, pokemon enemyStartPokemon) {
	name = enemyName;
	enemyPokemon = enemyStartPokemon;
}
