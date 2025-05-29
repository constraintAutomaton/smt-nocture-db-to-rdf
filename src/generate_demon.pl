:- use_module(library(serialization/json)).
:- use_module(library(pio)).
:- use_module(library(pairs)).
:- use_module(library(debug)).
:- use_module(library(lists)).
:- use_module('./util.pl').

generate_demons(Iri, Vocab_Iri, Race_Iri) :- 
    phrase_from_file(json_chars(Json), '../demon_data/demon-data.json'),
    open('../output/demon.ttl', write, Stream),
    demon_info(Json, Triples),
    license(Iri, Vocab_Iri, Race_Iri, Preliminary),
    maplist(write(Stream), Preliminary),
    write(Stream, '\n\n'),
    append(Triples, TriplesFlatten),
    maplist(write(Stream), TriplesFlatten),
    close(Stream).

demon_info(pairs(Data), Triples):- demon_info_(Data, [], Triples).

demon_info_([], Acc, Acc).
demon_info_([string(Name)-pairs([_, string("lvl")-number(Lv),string("race")-string(Race)|_])|Rest], Acc, Triples) :-
    demon_triple(Name, Lv, Race, Demon_Triples),
    demon_info_(Rest, [Demon_Triples|Acc], Triples).

demon_triple(Name, Lv, Race, Triples) :-
    replace_space(Name, NameCurated, "_"),
    append(["<", NameCurated, "> ", "a vocab:DemonSmt3 ;\n"], Declaration_Triple),
    append(["\t<https://schema.org/name> \"", Name, "\" ;\n"], Name_Triple),
    append(["\tvocab:isOfRace ", "race:", Race, " ;\n"], Race_Triple),
    number_chars(Lv, Lv_Char),
    append(["\tvocab:hasBasedLevel \"", Lv_Char,"\"^^xsd:integer .\n"], Lv_Triple),
    append([Declaration_Triple, Name_Triple, Race_Triple, Lv_Triple], Triples).

license(Iri, Vocab_Iri, Race_Iri, Preliminary) :-
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