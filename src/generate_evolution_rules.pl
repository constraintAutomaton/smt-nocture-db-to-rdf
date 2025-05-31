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

:- module(demon_generator, [generate_evolution_rules/3]).

:- use_module(library(serialization/json)).
:- use_module(library(pio)).
:- use_module(library(pairs)).
:- use_module(library(lists)).
:- use_module('./util.pl').

/**
* generate an evolution rule RDF dataset at `../output/evolution_rules.ttl`
*/
generate_evolution_rules(Iri, Vocab_Prefix, Demon_Prefix) :- 
    phrase_from_file(json_chars(Json), '../demon_data/evolutions.json'),
    open('../output/evolution_rules.ttl', write, Stream),
    evolution_info(Json, Triples),
    preliminary(Iri, Vocab_Prefix, Demon_Prefix, Preliminary),
    maplist(write(Stream), Preliminary),
    write(Stream, '\n\n'),
    append(Triples, TriplesFlatten),
    maplist(write(Stream), TriplesFlatten),
    close(Stream).

evolution_info(pairs(Data), Triples) :-
    evolution_info_(Data, [], Triples).

evolution_info_([], Acc, Acc).

evolution_info_([string(Name)-pairs([string("lvl")-number(Lv), string("result")-string(Result)])|Rest], Acc, Triples):-
    evolution_triples(Name, Lv, Result, Evolution_Triples),
    evolution_info_(Rest, [Evolution_Triples|Acc], Triples).

evolution_triples(Name, Lv, Result, Triples) :-
    replace_space(Name, Name_Curated, "_"),
    replace_space(Result, Result_Curated, "_"),
    append(["<",Name_Curated,">" , " a ", "vocab:EvolutionRule", " ;\n"], Declaration_Triple),
    number_chars(Lv, LvChar),
    append(["\t","vocab:evolutionLevel ", LvChar, ";\n" ], Lv_Triple),
    append(["\tvocab:demonResult demon:", Result_Curated, " .\n" ], Result_Triple),
    append([Declaration_Triple, Lv_Triple, Result_Triple], Triples).

preliminary(Iri, Vocab_Prefix, Demon_Prefix, Preliminary) :-
    Template = "# This data  is made available under the Open Database License: http://opendatacommons.org/licenses/odbl/1.0/.\n\
# Any rights in individual contents of the database are licensed under the Database Contents License: http://opendatacommons.org/licenses/dbcl/1.0/\n\
\n\
@base <{}> .\n\
\n\
@prefix dct: <http://purl.org/dc/terms/> .\n\
@prefix void: <http://rdfs.org/ns/void#> .\n\
@prefix vocab: <{}> .\n\
@prefix demon: <{}> .\n\
\n\
<>\n\
    a void:Dataset ;\n\
    dct:title \"Shin Megami Tensei Evolution Rule Dataset\" ;\n\
    dct:license <http://opendatacommons.org/licenses/odbl/1.0/> ;\n\
    dct:rights <http://opendatacommons.org/licenses/dbcl/1.0/> ;\n\
    dct:creator \"Bryan-Elliott Tam\" ;\n\
    dct:created \"2025-05-05\"^^<http://www.w3.org/2001/XMLSchema#date> ;\n\
    dct:description \"This dataset is licensed under the ODbL; individual contents are under the DbCL.\" .",
    replace_template(Template, P0, Iri),
    replace_template(P0, P1, Vocab_Prefix),
    replace_template(P1, Preliminary, Demon_Prefix).