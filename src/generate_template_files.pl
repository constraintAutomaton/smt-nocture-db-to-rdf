:- use_module(library(pio)).
:- use_module(library(lists)).
:- use_module(library(clpz)).
:- use_module(library(debug)).
:- use_module(library(dcgs)).
:- use_module('./util.pl').

% We can do it in a streaming matter, but the files are small so it does not really matter, but the code is kindof ugly
generate_file_with_iri(File, Iri, Out) :- 
    phrase_from_file(file_to_list(X1) , File),
    replace_template(X1, X, Iri),
    open(Out, write, Stream),
    maplist(write(Stream), X),
    close(Stream).

generate_vocabulary_file(Iri) :- generate_file_with_iri('../vocabulary.ttl_template', Iri,  '../output/vocabulary.ttl').
generate_game_file(Iri) :- generate_file_with_iri('../game.ttl_template', Iri,  '../output/game.ttl').


file_to_list(X) --> file_to_list_(X).
file_to_list_([X0|X]) --> [X0], file_to_list_(X) .

file_to_list_(['']) --> "".