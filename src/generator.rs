use crate::domain::*;
use crate::transformer::*;
use csv;
use sophia_api::ns::Namespace;
use std::{
    fs::{self, File},
    io::{BufReader, Write},
    path::PathBuf,
};

pub(crate) fn generate_basic_fusion_rule(
    demon_rdf_namespace: &Namespace<String>,
    race_rdf_namespace: &Namespace<String>,
    vocabulary_rdf_namespace: &Namespace<String>,

    out_path: &PathBuf,
) -> Result<(), Box<dyn std::error::Error>> {
    let raw_file_basic_rule = PathBuf::from("./fusion_basic_rule.csv");

    let mut rule_transformer = BasicFusionRuleTransformer::new(
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

pub(crate) fn generate_demon_rdf(
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
