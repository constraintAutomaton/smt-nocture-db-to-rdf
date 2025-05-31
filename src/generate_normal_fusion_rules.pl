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

:- module(demon_generator, [generate_normal_fusion_rules/3]).

:- use_module(library(pio)).
:- use_module(library(lists)).
:- use_module(library(csv)).
:- use_module(library(dcgs)).
:- use_module('./util.pl').

/**
* generate normal fusion RDF dataset at `../output/normal_fusion_rules.ttl`
*/
generate_normal_fusion_rules(Iri, Vocab_Prefix, Race_Prefix) :- 
    phrase_from_file(parse_csv(Data), '../fusion_basic_rule.csv'),
    open('../output/normal_fusion_rules.ttl', write, Stream),
    fusion_rule_info(Data, Triples),
    preliminary(Iri, Vocab_Prefix, Race_Prefix, Preliminary),
    maplist(write(Stream), Preliminary),
    write(Stream, '\n\n'),
    append(Triples, TriplesFlatten),
    maplist(write(Stream), TriplesFlatten),
    close(Stream).

fusion_rule_info(frame(_, Rules), Triples) :-
    fusion_rule_info_(Rules, [], Triples).

fusion_rule_info_([], Acc, Acc).

fusion_rule_info_([[Result, Race1, Race2]| Rest], Acc, Triples) :-
    fusion_rule_triple(Result, Race1, Race2, Rule_Triples),
    fusion_rule_info_(Rest, [Rule_Triples|Acc], Triples).


fusion_rule_triple(Result, Race1, Race2, Triples):-
    append(["<", Race1, "_", Race2, "> "," a vocab:NormalFusionRule ;\n"], Rule_Definition),
    append(["\t vocab:withRace1 race:", Race1, " ;\n"], Rule_Input_1),
    append(["\t vocab:withRace2 race:", Race2, " ;\n"], Rule_Input_2),
    append(["\t vocab:fusionRaceResult race:", Result, " .\n"], Rule_Output),
    append([Rule_Definition, Rule_Input_1, Rule_Input_2, Rule_Output], Triples).

preliminary(Iri, Vocab_Iri, Race_Iri, Preliminary) :-
    Template = "# This data  is made available under the Open Database License: http://opendatacommons.org/licenses/odbl/1.0/.\n\
# Any rights in individual contents of the database are licensed under the Database Contents License: http://opendatacommons.org/licenses/dbcl/1.0/\n\
\n\
@base <{}> .\n\
\n\
@prefix dct: <http://purl.org/dc/terms/> .\n\
@prefix void: <http://rdfs.org/ns/void#> .\n\
@prefix vocab: <{}> .\n\
@prefix race: <{}> .\n\
\n\
<>\n\
    a void:Dataset ;\n\
    dct:title \"Shin Megami Tensei Demon Dataset\" ;\n\
    dct:license <http://opendatacommons.org/licenses/odbl/1.0/> ;\n\
    dct:rights <http://opendatacommons.org/licenses/dbcl/1.0/> ;\n\
    dct:creator \"Bryan-Elliott Tam\" ;\n\
    dct:created \"2025-05-29\"^^<http://www.w3.org/2001/XMLSchema#date> ;\n\
    dct:description \"This dataset is licensed under the ODbL; individual contents are under the DbCL.\" .",
    replace_template(Template, P0, Iri),
    replace_template(P0, P1, Vocab_Iri),
    replace_template(P1, Preliminary, Race_Iri).