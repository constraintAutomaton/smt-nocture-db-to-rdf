use clap::Parser;
use cli::CliArgs;
use csv;
use serde::Deserialize;
use sophia_api::ns::Namespace;
use std::collections::hash_set::HashSet;
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
        basic_rules_rdf_namespace,
    } = CliArgs::parse();

    let demon_rdf_namespace = demon_rdf_namespace.unwrap_or("http://example.org/".to_string());
    let race_rdf_namespace = race_rdf_namespace.unwrap_or("http://example.org/".to_string());
    let vocabulary_namespace = vocabulary_namespace.unwrap_or("http://example.org/".to_string());
    let game_rdf_namespace = game_rdf_namespace.unwrap_or("http://example.org/".to_string());
    let basic_rules_rdf_namespace =
        basic_rules_rdf_namespace.unwrap_or("http://example.org/".to_string());

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
        basic_rules_rdf_namespace,
        &out_path,
    )
    .unwrap();
}

fn generate_basic_fusion_rule(
    demon_rdf_namespace: &Namespace<String>,
    race_rdf_namespace: &Namespace<String>,
    vocabulary_rdf_namespace: &Namespace<String>,

    basic_rules_rdf_namespace: String,

    out_path: &PathBuf,
) -> Result<(), Box<dyn std::error::Error>> {
    let raw_file_basic_rule = PathBuf::from("./fusion_basic_rule.csv");
    let basic_rule_rdf_file_namespace = Namespace::new(basic_rules_rdf_namespace)?;

    let mut rule_transformer = BasicFusionRuleTransformer::new(
        &basic_rule_rdf_file_namespace,
        demon_rdf_namespace,
        race_rdf_namespace,
        vocabulary_rdf_namespace,
    );

    let basic_rules_output_file = out_path.join("basic_rules.ttl");

    let raw_file: File = File::open(raw_file_basic_rule)?;
    let buf_reader = BufReader::new(raw_file);

    let mut rdr = csv::Reader::from_reader(buf_reader);

    for result in rdr.deserialize() {
        let fusion_rule_record: BasicFusionRule = result?;
        rule_transformer.rules.push(fusion_rule_record);
    }

    rule_transformer.to_file(basic_rules_output_file)?;

    Ok(())
}

fn generate_demon_rdf(
    demon_rdf_namespace: &Namespace<String>,
    race_rdf_namespace: &Namespace<String>,
    vocabulary_rdf_namespace: &Namespace<String>,
    vocabulary_namespace: String,
    game_rdf_namespace: String,

    out_path: &PathBuf,
    path_vocabulary: &PathBuf,
    path_game: &PathBuf,
) -> Result<(), Box<dyn std::error::Error>> {
    let raw_demon_file: PathBuf = PathBuf::from("./demon_simple_info.csv");
    let special_fusion_demon_sets = parse_special_fusion_sets()?;
    let mut race_transformer = RaceTransformer::new(race_rdf_namespace, &vocabulary_rdf_namespace);
    let mut demon_transformer = DemonTransformer::new(
        demon_rdf_namespace,
        race_rdf_namespace,
        &vocabulary_rdf_namespace,
        &special_fusion_demon_sets,
    );

    let race_output_file = out_path.join("race.ttl");
    let demon_output_file = out_path.join("demon.ttl");
    let vocabulary_output_file = out_path.join("vocabulary.ttl");
    let game_output_file = out_path.join("game.ttl");

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
        let mut demon_record: Demon = result?;
        // replace space to _ to create an IRI
        demon_record.iri = demon_record.name.replace(" ", "_");

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

fn parse_special_fusion_sets() -> Result<SpecialFusionDemonSets, Box<dyn std::error::Error>> {
    let path = fs::read_to_string("./special_fusion.json")?;
    let output: SpecialFusionDemonSets = serde_json::from_str(&path)?;
    Ok(output)
}

#[derive(Debug, Deserialize, Clone)]
struct Demon {
    pub name: String,
    pub race: String,
    pub lv: String,
    #[serde(skip)]
    pub iri: String,
}

#[derive(Debug, Deserialize, Clone)]
struct BasicFusionRule {
    pub result: String,
    pub demon1: String,
    pub demon2: String,
}

#[derive(Debug, Deserialize)]
struct SpecialFusionDemonSets {
    pub evolve_caught: HashSet<String>,
    pub special_fusion: HashSet<String>,
    pub death_stone: HashSet<String>,
    pub exception: HashSet<String>,
}
