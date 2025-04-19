:- use_module(library(lists)).

replace_template(Xs0, Xs1, Element):- 
    append([Front, "{}" ,Rest], Xs0),
    append([Front, Element ,Rest], Xs1).
