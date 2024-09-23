use clap::{builder::Str, Parser};
use cli::CliArgs;
use csv;
use serde::Deserialize;
use sophia_api::ns::Namespace;
use std::{
    fs::{self, File},
    io::{BufReader, Write},
    path::PathBuf,
};
use transformer::*;

mod cli;
mod transformer;

fn main() {
    let CliArgs {
        demon_rdf_namespace,
        race_rdf_namespace,
        out_path,
        vocabulary_namespace,
        game_rdf_namespace,
        path_vocabulary,
        path_game,
        raw_demon_file,
    } = CliArgs::parse();

    let demon_rdf_namespace = demon_rdf_namespace.unwrap_or("http://example.org/".to_string());
    let race_rdf_namespace = race_rdf_namespace.unwrap_or("http://example.org/".to_string());
    let vocabulary_namespace = vocabulary_namespace.unwrap_or("http://example.org/".to_string());
    let game_rdf_namespace = game_rdf_namespace.unwrap_or("http://example.org/".to_string());

    let out_path = out_path.unwrap_or(PathBuf::from("./output/"));
    let path_vocabulary = path_vocabulary.unwrap_or(PathBuf::from("./vocabulary.ttl_template"));
    let path_game = path_game.unwrap_or(PathBuf::from("./game.ttl_template"));

    let raw_demon_file = raw_demon_file.unwrap_or(PathBuf::from("./demon_simple_info.csv"));

    generate_demon_rdf(
        demon_rdf_namespace,
        race_rdf_namespace,
        vocabulary_namespace,
        game_rdf_namespace,
        &out_path,
        &path_vocabulary,
        &path_game,
        &raw_demon_file,
    ).unwrap();
    
}

fn generate_demon_rdf(
    demon_rdf_namespace: String,
    race_rdf_namespace: String,
    vocabulary_namespace: String,
    game_rdf_namespace: String,

    out_path: &PathBuf,
    path_vocabulary: &PathBuf,
    path_game: &PathBuf,

    raw_demon_file: &PathBuf,
) -> Result<(), Box<dyn std::error::Error>> {
    let demon_rdf_file_namespace = Namespace::new(demon_rdf_namespace)?;
    let race_rdf_file_namespace = Namespace::new(race_rdf_namespace)?;

    let vocabulary_rdf_file_namespace = Namespace::new(vocabulary_namespace.clone())?;

    let mut race_transformer =
        RaceTransformer::new(&race_rdf_file_namespace, &vocabulary_rdf_file_namespace);
    let mut demon_transformer = DemonTransformer::new(
        &demon_rdf_file_namespace,
        &race_rdf_file_namespace,
        &vocabulary_rdf_file_namespace,
    );

    let out_folder = out_path;
    let race_output_file = out_folder.join("race.ttl");
    let demon_output_file = out_folder.join("demon.ttl");
    let vocabulary_output_file = out_folder.join("vocabulary.ttl");
    let game_output_file = out_folder.join("game.ttl");

    rdf_from_template(
        path_vocabulary,
        &vocabulary_output_file,
        vocabulary_namespace,
    )?;

    rdf_from_template(path_game, &game_output_file, game_rdf_namespace)?;

    let raw_file: File = File::open(raw_demon_file)?;
    let buf_reader = BufReader::new(raw_file);

    let mut rdr = csv::Reader::from_reader(buf_reader);

    for result in rdr.deserialize() {
        let demon_record: Demon = result?;

        demon_transformer.demon.push(demon_record.clone());
        race_transformer.races.insert(demon_record.race);
    }

    demon_transformer.to_file(demon_output_file)?;
    race_transformer.to_file(race_output_file)?;

    Ok(())
}

fn rdf_from_template(
    templace_path: &PathBuf,
    out_file: &PathBuf,
    namespace: String,
) -> Result<(), Box<dyn std::error::Error>> {
    let payload: String = fs::read_to_string(templace_path)?;
    let concrete_rdf = payload.replace("{}", &namespace);

    let mut file = File::options()
        .read(false)
        .write(true)
        .append(false)
        .create(true)
        .open(out_file)?;

    file.write(concrete_rdf.as_bytes())?;

    Ok(())
}

#[derive(Debug, Deserialize, Clone)]
struct Demon {
    pub name: String,
    pub race: String,
    pub lv: String,
}
