use std::path::PathBuf;

use clap::Parser;

/// A Simple program to generate a Shin Megami Tensei III demon dataset.
#[derive(Parser)]
#[command(version, about, long_about = None)]
pub struct CliArgs {
    /// Raw CSV file with the demon dataset.
    #[arg(long)]
    pub raw_demon_file: Option<PathBuf>,

    /// Raw CSV file with the basic fusion dataset.
    #[arg(long)]
    pub raw_basic_fusion_file: Option<PathBuf>,

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

    /// IRI namespace of the basic rules.
    #[arg(short, long)]
    pub basic_rules_rdf_namespace: Option<String>,

    /// Path of the RDF vocabulary template file.
    #[arg(long)]
    pub path_vocabulary: Option<PathBuf>,

    /// Path of the RDF game template file.
    #[arg(long)]
    pub path_game: Option<PathBuf>,

    /// Output folder of the datasets.
    #[arg(short, long)]
    pub out_path: Option<PathBuf>,
}
