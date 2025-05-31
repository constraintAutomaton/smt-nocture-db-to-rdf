:- module(util, [replace_space/3, replace_template/3, fusion_chart/1]).

:- use_module(library(lists)).
:- use_module(library(pio)).
:- use_module(library(serialization/json)).

replace_template(Xs0, Xs1, Element):- 
    append([Front, "{}" ,Rest], Xs0),
    append([Front, Element ,Rest], Xs1).

replace_space(Xs0, Xs2, Element):- 
    (
        append([Front, " " ,Rest], Xs0) ->
            append([Front, Element ,Rest], Xs1),
            replace_space(Xs1, Xs2, Element)
        ;   Xs0=Xs2
    ).

fusion_chart(Json) :- phrase_from_file(json_chars(Json) , '../demon_data/fusion-chart.json').