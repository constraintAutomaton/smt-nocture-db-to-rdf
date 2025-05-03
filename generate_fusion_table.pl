:- use_module(library(pio)).
:- use_module(library(debug)).
:- use_module(library(lists)).
:- use_module(library(csv)).
:- use_module(library(dcgs)).
:- use_module('./util.pl').

generate_basic_rules(Iri, IriRace, IriVocab) :- 
    open('./fusion_basic_rule.csv', read, StreamCsv),
    once(phrase_from_stream(parse_csv(Data), StreamCsv)),
    open('./output/basic_rules.ttl', write, Stream),
    fusion_rule_triples(Data, IriRace, IriVocab, Triples),
    license(Iri, License),
    maplist(write(Stream), License),
    write(Stream, '\n\n'),
    append(Triples, TriplesFlatten),
    maplist(write(Stream), TriplesFlatten),
    close(Stream).

fusion_rule_triples_([], _, _, []).

fusion_rule_triples_([[Result, Race1, Race2]| Rest], IriRace, IriVocab, Triples) :-
    fusion_rule_triples_(Rest, IriRace, IriVocab, Triples2),
    blank_node_rule_declaration(Race1, Race2, BlankNode),
    with_race_1_triple(Race1, BlankNode, IriVocab, IriRace, Race1Triple),
    with_race_2_triple(Race2, BlankNode, IriVocab, IriRace, Race2Triple),
    with_race_R_triple(Result, BlankNode, IriVocab, IriRace, RaceRTriple),
    append([[Race1Triple], [Race2Triple], [RaceRTriple]], TripleSet),
    append([Triples2, TripleSet], Triples).

fusion_rule_triples(frame(_, Rules), IriRace, IriVocab, Triples) :-
    fusion_rule_triples_(Rules, IriRace, IriVocab, Triples).

blank_node_rule_declaration(Race1, Race2, BlankNode):-
    append(["_:",Race1, "_", Race2 ], BlankNode).

with_race_triple(Race, BlankNode, IriVocab, IriRace, WithRaceX, Triple) :-
    append(["<", IriVocab, WithRaceX, ">"], WithRaceTerm),
    append(["<", IriRace, Race, ">"], RaceTerm),
    append([BlankNode, " ", WithRaceTerm, " ",RaceTerm, ".", "\n" ], Triple).

with_race_1_triple(Race, BlankNode, IriVocab, IriRace, Triple) :-
    with_race_triple(Race, BlankNode, IriVocab, IriRace,"withRace1", Triple).

with_race_2_triple(Race, BlankNode, IriVocab, IriRace, Triple) :-
    with_race_triple(Race, BlankNode, IriVocab, IriRace,"withRace2", Triple).

with_race_R_triple(Race, BlankNode, IriVocab, IriRace, Triple) :-
    with_race_triple(Race, BlankNode, IriVocab, IriRace,"fusionRaceResult", Triple).

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
    dct:title \"Shin Megami Tensei Basic Rule Dataset\" ;\n\
    dct:license <http://opendatacommons.org/licenses/odbl/1.0/> ;\n\
    dct:rights <http://opendatacommons.org/licenses/dbcl/1.0/> ;\n\
    dct:creator \"Bryan-Elliott Tam\" ;\n\
    dct:created \"2025-05-03\"^^<http://www.w3.org/2001/XMLSchema#date> ;\n\
    dct:description \"This dataset is licensed under the ODbL; individual contents are under the DbCL.\" .",
replace_template(Template, License, Iri).