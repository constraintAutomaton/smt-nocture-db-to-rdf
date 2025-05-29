:- use_module(library(lists)).

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