/**
smt-nocture-db-to-rdf: A generator of an RDF dataset of demon 
information from the video game Shin Megami Tensei III: Nocturne
Copyright (C) 2025  Bryan-Elliott Tam
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
generate_evolution_rules(Iri, VocabPrefix, DemonPrefix) :- 
    phrase_from_file(json_chars(Json), '../demon_data/evolutions.json'),
    open('../output/evolution_rules.ttl', write, Stream),
    evolution_info(Json, Triples),
    preliminary(Iri, VocabPrefix, DemonPrefix, Preliminary),
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
    replace_space(Name, NameCurated, "_"),
    append(["<",NameCurated,">" , " a ", "vocab:EvolutionRule", " ;\n"], Declaration_Triple),
    number_chars(Lv, LvChar),
    append(["\t","vocab:evolutionLevel ", LvChar, ";\n" ], Lv_Triple),
    append(["\t vocab:demonResult demon:", Result, " .\n" ], Result_Triple),
    append([Declaration_Triple, Lv_Triple, Result_Triple], Triples).

preliminary(Iri, VocabPrefix, DemonPrefix, Preliminary) :-
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
    replace_template(P0, P1, VocabPrefix),
    replace_template(P1, Preliminary, DemonPrefix).