:- use_module(library(serialization/json)).
:- use_module(library(pio)).
:- use_module(library(pairs)).
:- use_module(library(debug)).
:- use_module(library(lists)).
:- use_module('./util.pl').

generate_race_file(Iri, IriVocab) :- 
    fusion_chart(Json),
    get_races(Json, Json_race_list),
    json_race_list_to_list(Json_race_list, RaceList),
    open('../output/race.ttl', write, Stream),
    license(Iri, License),
    maplist(write(Stream), License),
    maplist(race_triples(IriVocab), RaceList, TripleRaceList),
    append(TripleRaceList, TripleRaceListFlatten),
    write(Stream, '\n\n'),
    maplist(write(Stream), TripleRaceListFlatten),
    close(Stream).

get_races(pairs([string("races")-RaceList|_]), RaceList).
get_races(pairs([string(_)-_|X]), RaceList):- get_races_(X, RaceList).

get_races(pairs([string(_)-_|X]), RaceList):- get_races_(X, RaceList).
get_races_([string("races")-RaceList|_], RaceList).

get_races_([], _) :- false.


json_race_list_to_list(list([string(Race)| Rest]), RaceList) :- json_race_list_to_list(Rest, RaceList0), append([Race], RaceList0 ,RaceList).

json_race_list_to_list([string(Race)| Rest], RaceList) :- json_race_list_to_list(Rest, RaceList0), append([Race], RaceList0 ,RaceList).

json_race_list_to_list([string(Race)], [Race]).

race_triples(IriVocab, Race, Triples) :- 
    append(["<", Race, ">"], S),
    A = "a",
    append(["<", IriVocab, "Race", ">"], RaceRdfType),
    Schema = "<https://schema.org/name>",
    append([S," ", A, " ", RaceRdfType, ";\n", "\t", Schema, " ", "\"",Race, "\"", ".\n"], Triples).

license(Iri, License) :-
Template = "# This data  is made available under the Open Database License: http://opendatacommons.org/licenses/odbl/1.0/.\n\
# Any rights in individual contents of the database are licensed under the Database Contents License: http://opendatacommons.org/licenses/dbcl/1.0/\n\
\n\
@base <{}> .\n\
\n\
@prefix dct: <http://purl.org/dc/terms/> .\n\
@prefix void: <http://rdfs.org/ns/void#> .\n\
\n\
<>\n\
    a void:Dataset ;\n\
    dct:title \"Shin Megami Tensei Race Dataset\" ;\n\
    dct:license <http://opendatacommons.org/licenses/odbl/1.0/> ;\n\
    dct:rights <http://opendatacommons.org/licenses/dbcl/1.0/> ;\n\
    dct:creator \"Bryan-Elliott Tam\" ;\n\
    dct:created \"2025-04-19\"^^<http://www.w3.org/2001/XMLSchema#date> ;\n\
    dct:description \"This dataset is licensed under the ODbL; individual contents are under the DbCL.\" .",
replace_template(Template, License, Iri).
