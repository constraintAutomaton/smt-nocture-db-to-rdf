# smt-nocture-db-to-rdf

A repository hosting an RDF dataset of demon information from [Shin Megami Tensei III: Nocturne](https://en.wikipedia.org/wiki/Shin_Megami_Tensei_III:_Nocturne).

## Building
`cargo build --release`

## Generating the dataset locally
To generate the dataset locally simpy run the following command
`cargo run --release -- -d "{URL of the desired demon dataset}/demon.ttl" -r "{URL of the desired race dataset}/race.ttl" -v "{URL of the desired vocabulary dataset}/vocabulary.ttl" -g "{URL of the desired game dataset}/vocabulary.ttl"`.

See the usage section for more info on the parameters.

### Usage
```
A Simple program to generate a Shin Megami Tensei III demon dataset

Usage: smt-nocture-db-to-rdf [OPTIONS]

Options:
      --raw-demon-file <RAW_DEMON_FILE>              Raw CSV file with the demon dataset
  -d, --demon-rdf-namespace <DEMON_RDF_NAMESPACE>    IRI namespace of the demon dataset
  -r, --race-rdf-namespace <RACE_RDF_NAMESPACE>      IRI namespace of the race dataset
  -v, --vocabulary-namespace <VOCABULARY_NAMESPACE>  IRI namespace of the vocabulary
  -g, --game-rdf-namespace <GAME_RDF_NAMESPACE>      IRI namespace of the game
      --path-vocabulary <PATH_VOCABULARY>            Path of the RDF vocabulary template file
      --path-game <PATH_GAME>                        Path of the RDF game template file
  -o, --out-path <OUT_PATH>                          Output folder of the datasets
  -h, --help                                         Print help
  -V, --version                                      Print version
```


## Queries to get the demon from the SQL database

### Get demon basic info

```sql
SELECT name, race, lv FROM demons;
```


```
cargo run --release -- -d "{URL of the desired demon dataset}/demon.ttl" -r "{URL of the desired race dataset}/race.ttl" -v "{URL of the desired vocabulary dataset}/vocabulary.ttl" -g "{URL of the desired game dataset}/vocabulary.ttl
```