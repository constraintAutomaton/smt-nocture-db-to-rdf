:- use_module(library(serialization/json)).
:- use_module(library(pio)).
:- use_module(library(pairs)).
:- use_module(library(debug)).
:- use_module(library(lists)).
:- use_module('./util.pl').

generate_evolution_rules(Iri, VocabPrefix, DemonPrefix) :- 
    phrase_from_file(json_chars(Json), '../demon_data/evolutions.json'),
    open('../output/evolution_rules.ttl', write, Stream),
    evolution_info(Json, VocabPrefix, DemonPrefix, Triples),
    license(Iri, License),
    maplist(write(Stream), License),
    write(Stream, '\n\n'),
    append(Triples, TriplesFlatten),
    maplist(write(Stream), TriplesFlatten),
    close(Stream).

evolution_info(pairs([string(Name)-pairs([string("lvl")-number(Lv), string("result")-string(Result)])|Rest]), VocabPrefix, DemonPrefix, Triples) :-
    evolution_info_([string(Name)-pairs([string("lvl")-number(Lv), string("result")-string(Result)])|Rest], VocabPrefix, DemonPrefix, Triples).

evolution_info_([], _, _, []).

evolution_info_([string(Name)-pairs([string("lvl")-number(Lv), string("result")-string(Result)])|Rest], VocabPrefix, DemonPrefix, Triples):-
    evolution_info_(Rest, VocabPrefix, DemonPrefix, Triple2),
    iri_rule_declaration(Name, RuleIri),
    rule_declaration_triple(RuleIri, VocabPrefix, TripleDeclaration),
    level_evolution_triple(Lv, VocabPrefix, LvTriple),
    result_triple(Result, DemonPrefix, VocabPrefix, ResultTriple),
    append([[TripleDeclaration], [LvTriple], [ResultTriple]], TripleSet),
    append([Triple2, TripleSet], Triples).

iri_rule_declaration(Name, RuleIri):-
    (
        replace_space(Name, NameCurated, "_") ->
        true
    ;   NameCurated=Name
    ),
    append(["<", NameCurated, ">"], RuleIri).

rule_declaration_triple(RuleIri, VocabPrefix, Triple) :-
    append([RuleIri, " a ", "<", VocabPrefix, "EvolutionRule", ">;\n"], Triple).

level_evolution_triple(Lv, VocabPrefix,  Triple):-
    number_chars(Lv, LvChar),
    append(["\t","<", VocabPrefix, "evolutionLevel> ", LvChar, ";\n" ], Triple).

result_triple(Result, DemonPrefix, VocabPrefix, Triple) :-
    (
        replace_space(Result, ResultCurated, "_") ->
        true
    ;   ResultCurated=Result
    ),
    append(["<", DemonPrefix, ResultCurated, ">"], DemonTerm),
    append(["\t", "<", VocabPrefix, "demonResult> ", DemonTerm, ".\n" ], Triple).

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
    dct:title \"Shin Megami Tensei Evolution Rule Dataset\" ;\n\
    dct:license <http://opendatacommons.org/licenses/odbl/1.0/> ;\n\
    dct:rights <http://opendatacommons.org/licenses/dbcl/1.0/> ;\n\
    dct:creator \"Bryan-Elliott Tam\" ;\n\
    dct:created \"2025-05-05\"^^<http://www.w3.org/2001/XMLSchema#date> ;\n\
    dct:description \"This dataset is licensed under the ODbL; individual contents are under the DbCL.\" ."
, replace_template(Template, License, Iri)
.