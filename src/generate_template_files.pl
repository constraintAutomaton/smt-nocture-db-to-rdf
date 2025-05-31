/**
smt-nocture-db-to-rdf: A generator of an RDF dataset of demon 
information from the video game Shin Megami Tensei III: Nocturne
Copyright (C) 2025  Bryan-Elliott Tam
*/

:- module(demon_generator, [generate_vocabulary_file/1, generate_game_file/1]).

:- use_module(library(pio)).
:- use_module(library(lists)).
:- use_module(library(clpz)).
:- use_module(library(dcgs)).
:- use_module('./util.pl').

/**
* generate an vocabulary RDF dataset at `../output/vocabulary.ttl`
*/
generate_vocabulary_file(Iri) :- generate_file_with_iri('../vocabulary.ttl_template', Iri,  '../output/vocabulary.ttl').

/**
* generate a game RDF dataset at `../output/game.ttl`
*/
generate_game_file(Iri) :- generate_file_with_iri('../game.ttl_template', Iri,  '../output/game.ttl').

generate_file_with_iri(File, Iri, Out) :- 
    phrase_from_file(file_to_list(X1) , File),
    replace_template(X1, X, Iri),
    open(Out, write, Stream),
    maplist(write(Stream), X),
    close(Stream).

file_to_list(X) --> file_to_list_(X).
file_to_list_([X0|X]) --> [X0], file_to_list_(X) .

file_to_list_(['']) --> "".