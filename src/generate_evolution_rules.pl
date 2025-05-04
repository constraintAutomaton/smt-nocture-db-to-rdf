:- use_module(library(serialization/json)).
:- use_module(library(pio)).
:- use_module(library(pairs)).
:- use_module(library(debug)).
:- use_module(library(lists)).
:- use_module('./util.pl').

generate_evolution_rules(Json) :- 
    phrase_from_file(json_chars(Json) , '../demon_data/evolutions.json').

evolution_info(pairs([string(Name)-pairs([string("lvl")-number(Lv), string("result")-string(Result),])|Rest]))