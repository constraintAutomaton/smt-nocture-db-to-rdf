/**
smt-nocture-db-to-rdf: A generator of an RDF dataset of demon 
information from the video game Shin Megami Tensei III: Nocturne
Copyright (C) 2025  Bryan-Elliott Tam

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

:- module(demon_generator, [generate_races/2]).

:- use_module(library(serialization/json)).
:- use_module(library(pio)).
:- use_module(library(pairs)).
:- use_module(library(debug)).
:- use_module(library(lists)).
:- use_module('./util.pl').

/**
* generate a race RDF dataset at `../output/race.ttl`
*/
generate_races(Iri, Vocab_Prefix) :- 
    fusion_chart(Json),
    get_races(Json, Json_race_list),
    json_race_list_to_list(Json_race_list, RaceList),
    open('../output/race.ttl', write, Stream),
    preliminary(Iri, Vocab_Prefix, Preliminary),
    maplist(write(Stream), Preliminary),
    maplist(race_triples, RaceList, TripleRaceList),
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

race_triples(Race, Triples) :- 
    append(["<", Race, "> ", "a vocab:Race ;\n"], Race_Declaration),
    append(["\t <https://schema.org/name> \"", Race, "\" .\n" ], Race_Name),
    append([Race_Declaration, Race_Name], Triples).

preliminary(Iri, Vocab_Iri, Preliminary) :-
    Template = "# This data  is made available under the Open Database License: http://opendatacommons.org/licenses/odbl/1.0/.\n\
# Any rights in individual contents of the database are licensed under the Database Contents License: http://opendatacommons.org/licenses/dbcl/1.0/\n\
\n\
@base <{}> .\n\
\n\
@prefix dct: <http://purl.org/dc/terms/> .\n\
@prefix void: <http://rdfs.org/ns/void#> .\n\
@prefix vocab: <{}> .\n\
\n\
<>\n\
    a void:Dataset ;\n\
    dct:title \"Shin Megami Tensei Race Dataset\" ;\n\
    dct:license <http://opendatacommons.org/licenses/odbl/1.0/> ;\n\
    dct:rights <http://opendatacommons.org/licenses/dbcl/1.0/> ;\n\
    dct:creator \"Bryan-Elliott Tam\" ;\n\
    dct:created \"2025-04-19\"^^<http://www.w3.org/2001/XMLSchema#date> ;\n\
    dct:description \"This dataset is licensed under the ODbL; individual contents are under the DbCL.\" .",
    replace_template(Template, P0, Iri),
    replace_template(P0, Preliminary, Vocab_Iri).
