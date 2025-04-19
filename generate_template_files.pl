:- use_module(library(pio)).
:- use_module(library(lists)).
:- use_module(library(clpz)).
:- use_module(library(debug)).
:- use_module(library(dcgs)).

generate_file_with_iri(File, Iri, Out) :- 
    phrase_from_file(file_to_list(X1) , File),
    replace_template(X1, X, Iri),
    open(Out, write, Stream),
    maplist(write(Stream), X),
    close(Stream).

generate_vocabulary_file(Iri) :- generate_file_with_iri('./vocabulary.ttl_template', Iri,  './output/vocabulary.ttl').
generate_game_file(Iri) :- generate_file_with_iri('./game.ttl_template', Iri,  './output/game.ttl').

replace_template(Xs0, Xs1, Element):- 
    append([Front, "{}" ,Rest], Xs0),
    append([Front, Element ,Rest], Xs1).

file_to_list(X) --> file_to_list_(X).
file_to_list_([X0|X]) --> [X0], file_to_list_(X) .

file_to_list_(['']) --> "".