use serde::Deserialize;
use std::collections::hash_set::HashSet;


#[derive(Debug, Deserialize, Clone)]
pub(super) struct Demon {
    pub name: String,
    pub race: String,
    pub lv: String,
    #[serde(skip)]
    pub iri: String,
}

#[derive(Debug, Deserialize, Clone)]
pub(super) struct BasicFusionRule {
    pub result: String,
    pub demon1: String,
    pub demon2: String,
}

#[derive(Debug, Deserialize)]
pub (super) struct SpecialFusionDemonSets {
    pub evolve_caught: HashSet<String>,
    pub special_fusion: HashSet<String>,
    pub death_stone: HashSet<String>,
    pub exception: HashSet<String>,
}
