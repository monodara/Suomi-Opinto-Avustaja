FEATURE_MAP = {
    "Case": {
        "Nom": "Nominatiivi (Nominative)",
        "Gen": "Genetiivi (Genitive)",
        "Par": "Partitiivi (Partitive)",
        "Acc": "Akkusatiivi (Accusative)",
        "Ess": "Essiivi (Essive)",
        "Tra": "Translatiivi (Translative)",
        "Ina": "Inessiivi (Inessive)",
        "Ela": "Elatiivi (Elative)",
        "Ill": "Illatiivi (Illative)",
        "Ade": "Adessiivi (Adessive)",
        "Abl": "Ablatiivi (Ablative)",
        "All": "Allatiivi (Allative)",
        "Com": "Komitatiivi (Comitative)",
        "Ins": "Instruktiivi (Instrumental)",
    },
    "Degree": {
        "Pos": "Perusaste (Positive)",
        "Cmp": "Komparatiivi (Comparative)",
        "Sup": "Superlatiivi (Superlative)",
    },
    "Number": {
        "Sing": "Yksikkö (Singular)",
        "Plur": "Monikko (Plural)",
    },
    "Derivation": {
        "Llinen": "Adjective derivation",
        "inen": "Adjective suffix",
        "ma": "Verb->Noun derivation",
        "ja": "Agent derivation",
        "o": "Noun suffix",
    },
    "Person": {
        "1": "Ensimmäinen persoona (1st person)",
        "2": "Toinen persoona (2nd person)",
        "3": "Kolmas persoona (3rd person)",
    },
    "Tense": {
        "Pres": "Preesens (Present)",
        "Past": "Imperfekti (Past)",
        "Fut": "Futuuri (Future)",
    },
    "Mood": {
        "Ind": "Indikatiivi (Indicative)",
        "Cnd": "Konditionaali (Conditional)",
        "Imp": "Imperatiivi (Imperative)",
        "Pot": "Potentiaali (Potential)",
        "Opt": "Optatiiv (Optative)",
    },
    "Voice": {
        "Act": "Aktivi (Active)",
        "Pass": "Passiivi (Passive)",
    },
    "Polarity": {
        "Pos": "Positiivinen (Positive)",
        "Neg": "Negatiivinen (Negative)"
    }
}

def parse_feats(feats_string: str) -> list[str]:
    parsed_features = []
    if not feats_string:
        return parsed_features

    features = feats_string.split('|')

    for feature in features:
        parts = feature.split('=')
        if len(parts) == 2:
            feature_type = parts[0]
            feature_value = parts[1]

            if feature_type in FEATURE_MAP and \
               feature_value in FEATURE_MAP[feature_type]:
                parsed_features.append(f"{feature_type}: {FEATURE_MAP[feature_type][feature_value]}")
            else:
                # Fallback to original if not found in map
                parsed_features.append(f"{feature_type}: {feature_value}")
        else:
            parsed_features.append(feature) # Fallback for malformed features
    return parsed_features
