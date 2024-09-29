use super::*;
use sophia_api::graph::Graph;
use sophia_api::ns::{IriRef, Namespace};
use sophia_api::serializer::TripleSerializer;
use sophia_api::term::bnode_id::BnodeId;
use sophia_api::term::SimpleTerm;
use sophia_api::MownStr;
use sophia_turtle::serializer::turtle::TurtleSerializer;
use std::collections::hash_set::HashSet;
use std::fs::File;
use std::sync::OnceLock;

/// Transform a payload into an RDF dataset.
pub trait Transformer<'a> {
    fn to_rdf(&'a self) -> impl Graph;
    fn to_file(&'a self, path: PathBuf) -> Result<(), Box<dyn std::error::Error>> {
        let file = File::options()
            .read(false)
            .write(true)
            .append(false)
            .create(true)
            .open(path)?;

        let mut serializer = TurtleSerializer::new(file);
        let graph = self.to_rdf();
        serializer.serialize_graph(&graph)?;

        Ok(())
    }
}

/// Characteristic of a demon to RDF.
pub trait DemonCharacteristicTransformer<'a> {
    fn identifier_to_rdf(namespace: &'a Namespace<String>, id: &'a String) -> SimpleTerm<'a>;
}

pub struct BasicFusionRuleTransformer<'a> {
    pub rules: Vec<BasicFusionRule>,
    namespace: &'a Namespace<String>,

    race_namespace: &'a Namespace<String>,
    #[allow(dead_code)]
    demon_namespace: &'a Namespace<String>,

    with_race_1_term: SimpleTerm<'a>,
    with_race_2_term: SimpleTerm<'a>,
    fusion_race_result_term: SimpleTerm<'a>,
}

impl<'a> BasicFusionRuleTransformer<'a> {
    pub fn new(
        namespace: &'a Namespace<String>,
        demon_namespace: &'a Namespace<String>,
        race_namespace: &'a Namespace<String>,
        vocabulary_namespace: &'a Namespace<String>,
    ) -> Self {
        let with_race_1_iri = vocabulary_namespace.get("withRace1").unwrap();
        let with_race_1_term = SimpleTerm::Iri(with_race_1_iri.to_iriref());

        let with_race_2_iri = vocabulary_namespace.get("withRace2").unwrap();
        let with_race_2_term = SimpleTerm::Iri(with_race_2_iri.to_iriref());

        let fusion_race_result_iri = vocabulary_namespace.get("fusionRaceResult").unwrap();
        let fusion_race_result_term = SimpleTerm::Iri(fusion_race_result_iri.to_iriref());

        Self {
            rules: Vec::new(),
            namespace,

            race_namespace,
            demon_namespace,

            with_race_1_term,
            with_race_2_term,
            fusion_race_result_term,
        }
    }
}

impl<'a> Transformer<'a> for BasicFusionRuleTransformer<'a> {
    fn to_rdf(&'a self) -> impl Graph {
        let mut triples: Vec<[SimpleTerm; 3]> = Vec::new();
        for BasicFusionRule {
            result,
            demon1,
            demon2,
        } in self.rules.iter()
        {
            if result.contains("*") {
                continue;
            }

            let blank_node_id = format!("{}_{}", demon1, demon2);
            let blank_node_id: MownStr<'a> = MownStr::from(blank_node_id);
            let blank_node_id = BnodeId::new(blank_node_id).unwrap();
            let rule_blank_node = SimpleTerm::BlankNode(blank_node_id);

            let race_1_term = RaceTransformer::identifier_to_rdf(&self.race_namespace, demon1);
            let race_2_term = RaceTransformer::identifier_to_rdf(&self.race_namespace, demon2);
            let result_term = RaceTransformer::identifier_to_rdf(self.namespace, result);

            triples.push([
                rule_blank_node.clone(),
                self.with_race_1_term.clone(),
                race_1_term,
            ]);
            triples.push([
                rule_blank_node.clone(),
                self.with_race_2_term.clone(),
                race_2_term,
            ]);
            triples.push([
                rule_blank_node,
                self.fusion_race_result_term.clone(),
                result_term,
            ]);
        }
        triples
    }
}
/// Transform a [`Demon`] struct into a RDF named subgraph.
pub struct DemonTransformer<'a> {
    /// [`Demon`] collected
    pub demon: Vec<Demon>,
    namespace: &'a Namespace<String>,
    race_namespace: &'a Namespace<String>,

    /// RDF class of the demons.
    demon_term: SimpleTerm<'a>,
    /// RDF type predicate.
    a_term: SimpleTerm<'a>,
    /// RDF predicate to define a name.
    name_term: SimpleTerm<'a>,
    /// RDF predicate to define the race of the demon.
    race_term: SimpleTerm<'a>,
    /// RDF predicate to define the base level of a demon.
    lv_term: SimpleTerm<'a>,
}

impl<'a> DemonTransformer<'a> {
    pub fn new(
        namespace: &'a Namespace<String>,
        race_namespace: &'a Namespace<String>,
        vocabulary_namespace: &'a Namespace<String>,
    ) -> Self {
        let demon_iri = vocabulary_namespace.get("DemonSmt3").unwrap();
        let demon_term = SimpleTerm::Iri(demon_iri.to_iriref());

        let a_term_iri = IriRef::new(MownStr::from_str(
            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        ))
        .unwrap();
        let a_term = SimpleTerm::Iri(a_term_iri);

        let name_iri = IriRef::new(MownStr::from_str("https://schema.org/name")).unwrap();
        let name_term = SimpleTerm::Iri(name_iri);

        let race_iri = vocabulary_namespace.get("isOfRace").unwrap();
        let race_term = SimpleTerm::Iri(race_iri.to_iriref());

        let lv_iri = vocabulary_namespace.get("hasBasedLevel").unwrap();
        let lv_term = SimpleTerm::Iri(lv_iri.to_iriref());

        Self {
            demon: Vec::new(),
            namespace,
            demon_term,
            a_term,
            name_term,
            race_term,
            lv_term,
            race_namespace,
        }
    }
}

impl<'a> Transformer<'a> for DemonTransformer<'a> {
    fn to_rdf(&'a self) -> impl Graph {
        let mut triples: Vec<[SimpleTerm; 3]> = Vec::new();
        let string_term = STRING_TERM.get_or_init(|| {
            IriRef::new(MownStr::from_str("http://www.w3.org/2001/XMLSchema#string")).unwrap()
        });

        let interger_term = INTEGER_TERM.get_or_init(|| {
            IriRef::new(MownStr::from_str(
                "http://www.w3.org/2001/XMLSchema#integer",
            ))
            .unwrap()
        });

        for demon in self.demon.iter() {
            let instance_iri = self.namespace.get(&demon.iri).unwrap();
            let instance_term = SimpleTerm::Iri(instance_iri.to_iriref());

            let instance_name_term =
                SimpleTerm::LiteralDatatype(MownStr::from_str(&demon.name), string_term.clone());

            let instance_level_term =
                SimpleTerm::LiteralDatatype(MownStr::from_str(&demon.lv), interger_term.clone());

            let race_identifier: SimpleTerm<'a> =
                RaceTransformer::identifier_to_rdf(&self.race_namespace, &demon.race);

            triples.push([
                instance_term.clone(),
                self.a_term.clone(),
                self.demon_term.clone(),
            ]);

            triples.push([
                instance_term.clone(),
                self.name_term.clone(),
                instance_name_term,
            ]);

            triples.push([
                instance_term.clone(),
                self.race_term.clone(),
                race_identifier,
            ]);

            triples.push([
                instance_term.clone(),
                self.lv_term.clone(),
                instance_level_term,
            ]);
        }

        triples
    }
}

#[derive(Clone)]
/// Transform a race from a [`Demon`] struct into a unique RDF terms.
pub struct RaceTransformer<'a> {
    pub races: HashSet<String>,
    namespace: &'a Namespace<String>,

    /// RDF object to define a Race.
    race_term: SimpleTerm<'a>,
    /// RDF type predicate.
    a_term: SimpleTerm<'a>,
    /// RDF predicate to define a name.
    name_term: SimpleTerm<'a>,
}

impl<'a> RaceTransformer<'a> {
    pub fn new(
        namespace: &'a Namespace<String>,
        vocabulary_namespace: &'a Namespace<String>,
    ) -> Self {
        let race_iri = vocabulary_namespace.get("Race").unwrap();
        let race_term = SimpleTerm::Iri(race_iri.to_iriref());

        let a_term_iri = IriRef::new(MownStr::from_str(
            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        ))
        .unwrap();
        let a_term = SimpleTerm::Iri(a_term_iri);

        let name_iri = IriRef::new(MownStr::from_str("https://schema.org/name")).unwrap();
        let name_term = SimpleTerm::Iri(name_iri);

        Self {
            races: HashSet::new(),
            namespace,
            race_term,
            a_term,
            name_term,
        }
    }
}

impl<'a> DemonCharacteristicTransformer<'a> for RaceTransformer<'a> {
    fn identifier_to_rdf(namespace: &'a Namespace<String>, race: &'a String) -> SimpleTerm<'a> {
        let instance_iri = namespace.get(race).unwrap();
        SimpleTerm::Iri(instance_iri.to_iriref())
    }
}
impl<'a> Transformer<'a> for RaceTransformer<'a> {
    fn to_rdf(&'a self) -> impl Graph {
        let mut triples: Vec<[SimpleTerm; 3]> = Vec::new();
        let string_term = STRING_TERM.get_or_init(|| {
            IriRef::new(MownStr::from_str("http://www.w3.org/2001/XMLSchema#string")).unwrap()
        });

        for race in self.races.iter() {
            let instance_term = Self::identifier_to_rdf(self.namespace, race);
            let instance_name_term =
                SimpleTerm::LiteralDatatype(MownStr::from_str(&race), string_term.clone());

            triples.push([
                instance_term.clone(),
                self.a_term.clone(),
                self.race_term.clone(),
            ]);
            triples.push([instance_term, self.name_term.clone(), instance_name_term]);
        }
        triples
    }
}

static STRING_TERM: OnceLock<IriRef<MownStr<'static>>> = OnceLock::new();
static INTEGER_TERM: OnceLock<IriRef<MownStr<'static>>> = OnceLock::new();
