from nltk.tokenize import word_tokenize
from nltk.tag.stanford import StanfordNERTagger
from settings import STANFORD_LNG_MODEL_PATH, STANFORD_NER_PATH
from itertools import groupby

stanford_ner_tagger = StanfordNERTagger(STANFORD_LNG_MODEL_PATH, STANFORD_NER_PATH)


def get_names(document):
    """
    Extracts person names and their frequencies based on Stanford NER.
    :param document: text or HTML document in str format
    :return: dictionary of extracted features
    """
    tokens = word_tokenize(document)
    ner = stanford_ner_tagger.tag(tokens)
    persons = []
    person = ""
    for entity in ner:
        if entity[1] == "PERSON":
            person += entity[0] + " "
        elif person != "":
            if len(person.strip()) > 2:
                persons.append(person.strip())
            person = ""

    if len(person.strip()) > 2:
        persons.append(person.strip())

    names_freq = sorted([{"name": key, "count": sum(1 for _ in group)} for key, group in groupby(sorted(persons))],
                        key=lambda x: x["name"])

    return {"names": names_freq}
