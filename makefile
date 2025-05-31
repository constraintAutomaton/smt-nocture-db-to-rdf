DOMAIN_NAME="https://constraintautomaton.github.io/smt-nocture-db-to-rdf"
DEMON_FILE="demon.ttl"
VOCABULARY_FILE="vocabulary.ttl"
RACE_FILE="race.ttl"
EVOLUTION_RULE_FILE="evolution_rules.ttl"
NORMAL_FUSION_RULE_FILE="normal_fusion_rules.ttl"
GAME_FILE="game.ttl"

.PHONY: all clean

all:
	make -j6 \
		./output/demon.ttl \
		./output/evolution_rules.ttl \
		./output/normal_fusion_rules.ttl \
		./output/race.ttl \
		./output/vocabulary.ttl \
		./output/game.ttl

clean:
	rm -f \
	./output/demon.ttl \
	./output/evolution_rules.ttl \
	./output/normal_fusion_rules.ttl \
	./output/race.ttl \
	./output/vocabulary.ttl \
	./output/game.ttl


./output/demon.ttl: ./src/generate_demons.pl
	(cd ./src && scryer-prolog generate_demons.pl -g "\
		Iri=\"$(DOMAIN_NAME)/$(DEMON_FILE)\", \
		Vocab_Iri=\"$(DOMAIN_NAME)/$(VOCABULARY_FILE)\", \
		Race_Iri=\"$(DOMAIN_NAME)/$(RACE_FILE)\", \
		once(catch(generate_demons(Iri, Vocab_Iri, Race_Iri), _, halt)), \
		halt.")

./output/evolution_rules.ttl: ./src/generate_evolution_rules.pl
	(cd ./src && scryer-prolog generate_evolution_rules.pl -g "\
		Iri=\"$(DOMAIN_NAME)/$(EVOLUTION_RULE_FILE)\", \
		Vocab_Iri=\"$(DOMAIN_NAME)/$(VOCABULARY_FILE)\", \
		Demon_Iri=\"$(DOMAIN_NAME)/$(DEMON_FILE)\", \
		once(catch(generate_evolution_rules(Iri, Vocab_Iri, Demon_Iri), _, halt)), \
		halt.")

./output/normal_fusion_rules.ttl: ./src/generate_normal_fusion_rules.pl
	(cd ./src && scryer-prolog generate_normal_fusion_rules.pl -g "\
		Iri=\"$(DOMAIN_NAME)/$(NORMAL_FUSION_RULE_FILE)\", \
		Vocab_Iri=\"$(DOMAIN_NAME)/$(VOCABULARY_FILE)\", \
		Race_Iri=\"$(DOMAIN_NAME)/$(RACE_FILE)\", \
		once(catch(generate_normal_fusion_rules(Iri, Vocab_Iri, Race_Iri), _, halt)), \
		halt.")

./output/race.ttl: ./src/generate_race.pl
	(cd ./src && scryer-prolog generate_race.pl -g "\
		Iri=\"$(DOMAIN_NAME)/$(RACE_FILE)\", \
		Vocab_Iri=\"$(DOMAIN_NAME)/$(VOCABULARY_FILE)\", \
		once(catch(generate_races(Iri, Vocab_Iri), _, halt)), \
		halt.")

./output/vocabulary.ttl: ./src/generate_template_files.pl
	(cd ./src && scryer-prolog generate_template_files.pl -g "\
		Iri=\"$(DOMAIN_NAME)/$(VOCABULARY_FILE)\", \
		once(catch(generate_vocabulary_file(Iri), _, halt)), \
		halt.")

./output/game.ttl: ./src/generate_template_files.pl
	(cd ./src && scryer-prolog generate_template_files.pl -g "\
		Iri=\"$(DOMAIN_NAME)/$(GAME_FILE)\", \
		once(catch(generate_game_file(Iri), _, halt)), \
		halt.")