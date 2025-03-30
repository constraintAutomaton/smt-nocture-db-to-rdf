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

use std::path::PathBuf;

use clap::Parser;

/// A Simple program to generate a Shin Megami Tensei III demon dataset.
#[derive(Parser)]
#[command(version, about, long_about = None)]
pub struct CliArgs {
    /// IRI namespace of the demon dataset.
    #[arg(short, long)]
    pub demon_rdf_namespace: Option<String>,

    /// IRI namespace of the race dataset.
    #[arg(short, long)]
    pub race_rdf_namespace: Option<String>,

    /// IRI namespace of the vocabulary.
    #[arg(short, long)]
    pub vocabulary_namespace: Option<String>,

    /// IRI namespace of the game.
    #[arg(short, long)]
    pub game_rdf_namespace: Option<String>,

    /// Path of the RDF vocabulary template file.
    #[arg(long)]
    pub path_vocabulary: Option<PathBuf>,

    /// Path of the RDF game template file.
    #[arg(long)]
    pub path_game: Option<PathBuf>,

    /// Output folder of the datasets.
    #[arg(short, long)]
    pub out_path: Option<PathBuf>,

    #[arg(long)]
    /// Print the license
    pub license: bool,
}
