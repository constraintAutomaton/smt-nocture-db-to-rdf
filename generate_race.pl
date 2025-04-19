:- use_module(library(serialization/json)).
:- use_module(library(pio)).
:- use_module(library(pairs)).
:- use_module(library(debug)).
:- use_module(library(lists)).

generate(X, RaceList) :- 
    phrase_from_file(json_chars(X) , './demon_data/fusion-chart.json'),
    get_races(X, Json_race_list),
    json_race_list_to_list(Json_race_list, RaceList) .

get_races(pairs([string("races")-RaceList|_]), RaceList).
get_races(pairs([string(_)-_|X]), RaceList):- get_races(X, RaceList).
get_races([], _) :- false.


json_race_list_to_list(list([string(Race)| Rest]), RaceList) :- json_race_list_to_list(Rest, RaceList0), append([Race], RaceList0 ,RaceList).

json_race_list_to_list([string(Race)| Rest], RaceList) :- json_race_list_to_list(Rest, RaceList0), append([Race], RaceList0 ,RaceList).

json_race_list_to_list([string(Race)], [Race]).
json_race_list_to_list([], []).
