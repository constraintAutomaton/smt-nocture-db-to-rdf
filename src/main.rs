// smt-nocture-db-to-rdf: A generator of an RDF dataset of demon 
// information from the video game Shin Megami Tensei III: Nocturne
// Copyright (C) 2025 Bryan-Elliott Tam
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use clap::Parser;
use cli::CliArgs;
use generator::*;
use sophia_api::ns::Namespace;
use std::{
    io::Write,
    path::PathBuf,
};

mod cli;
mod transformer;
mod generator;
mod domain;

fn main() {
    let CliArgs {
        demon_rdf_namespace,
        race_rdf_namespace,
        out_path,
        vocabulary_namespace,
        game_rdf_namespace,
        path_vocabulary,
        path_game,
        license,
    } = CliArgs::parse();

    if license {
        println!("{}", LICENSE);
        return;
    }
    let demon_rdf_namespace = demon_rdf_namespace.unwrap_or("http://example.org/".to_string());
    let race_rdf_namespace = race_rdf_namespace.unwrap_or("http://example.org/".to_string());
    let vocabulary_namespace = vocabulary_namespace.unwrap_or("http://example.org/".to_string());
    let game_rdf_namespace = game_rdf_namespace.unwrap_or("http://example.org/".to_string());

    let demon_rdf_file_namespace = Namespace::new(demon_rdf_namespace).unwrap();
    let race_rdf_file_namespace = Namespace::new(race_rdf_namespace).unwrap();
    let vocabulary_rdf_namespace = Namespace::new(vocabulary_namespace.clone()).unwrap();

    let out_path = out_path.unwrap_or(PathBuf::from("./output/"));
    let path_vocabulary = path_vocabulary.unwrap_or(PathBuf::from("./vocabulary.ttl_template"));
    let path_game = path_game.unwrap_or(PathBuf::from("./game.ttl_template"));

    generate_demon_rdf(
        &demon_rdf_file_namespace,
        &race_rdf_file_namespace,
        &vocabulary_rdf_namespace,
        vocabulary_namespace,
        game_rdf_namespace,
        &out_path,
        &path_vocabulary,
        &path_game,
    )
    .unwrap();

    generate_basic_fusion_rule(
        &demon_rdf_file_namespace,
        &race_rdf_file_namespace,
        &vocabulary_rdf_namespace,
        &out_path,
    )
    .unwrap();
}

const LICENSE: &'static str = r#"
smt-nocture-db-to-rdf: A generator of an RDF dataset of demon 
information from the video game Shin Megami Tensei III: Nocturne
Copyright (C) 2025  Bryan-Elliott Tam

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
"#;
