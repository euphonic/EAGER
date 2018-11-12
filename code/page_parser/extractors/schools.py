import re
from settings import SCHOOL_NAME_PATTERN, SCHOOL_NAME_BLACKLIST, SCHOOL_NAME_EDGE_WORDS
from itertools import groupby
from difflib import SequenceMatcher

EDGE_PATTERN = "".join(["(?<!{0})(?<!{1})".format(word, word.upper()) for word in SCHOOL_NAME_EDGE_WORDS])
school_name_pattern = SCHOOL_NAME_PATTERN.replace("%EDGE_PATTERN%", EDGE_PATTERN)
re_school_name = re.compile(school_name_pattern)


def get_school_names(document):
    """
    Extracts school names and their frequencies based on the regex match
    :param document: text or HTML document in str format
    :return: dictionary of extracted features
    """
    school_names = re_school_name.findall(document)
    school_names_freq = dict((key, sum(1 for _ in group)) for key, group in groupby(sorted(
        filter(lambda x: x not in SCHOOL_NAME_BLACKLIST, school_names))))

    if school_names_freq:
        best_match = max(school_names_freq.items(), key=(lambda x: x[1]))
        school_name_best_match = best_match[0]
        school_name_max_freq = best_match[1]
    else:
        school_name_best_match = None
        school_name_max_freq = None

    return {"school_names": school_names_freq,
            "max_freq_school": {"school_name": school_name_best_match,
                                "freq": school_name_max_freq}}


def match_schools(input_schools, found_schools):
    scored_schools = []
    for input_school in input_schools:
        for found_school in found_schools:
            diff_score = SequenceMatcher(a=input_school.lower(), b=found_school.lower())
            scored_schools.append({"input_school": input_school, "found_school": found_school,
                                   "diff_score": diff_score.ratio()})

    if len(scored_schools) > 0:
        best_match = max(scored_schools, key=(lambda x: x["diff_score"]))
        resolved_school = best_match["input_school"]
        similarity_score = best_match["diff_score"]
    else:
        resolved_school = "_ambiguous"
        similarity_score = 0

    if len(input_schools) == 1:
        resolved_school = input_schools[0]
        similarity_score = 1

    return {"scored_schools": scored_schools,
            "resolved_school": resolved_school,
            "similarity_score": similarity_score}
