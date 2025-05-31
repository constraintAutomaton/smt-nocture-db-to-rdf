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