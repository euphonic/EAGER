import re
from bs4 import BeautifulSoup
from itertools import groupby
from settings import EMAIL_PATTERN, PHONE_PATTERN, NOT_A_NAME_DICTIONARY_PATH

NOT_A_NAME_PATTERN = r"([0-9@!&]"
with open(NOT_A_NAME_DICTIONARY_PATH, "r") as not_a_name_words:
    for w in not_a_name_words.readlines():
        NOT_A_NAME_PATTERN += r"|\b{}\b".format(w.strip())
NOT_A_NAME_PATTERN += r")"

re_email = re.compile(EMAIL_PATTERN, re.IGNORECASE)
re_not_a_name = re.compile(NOT_A_NAME_PATTERN, re.IGNORECASE)
re_lower_case_word = re.compile(r"(\b[a-z][A-Z]*[a-z]*\b|^[^A-za-z]+)")
re_phone = re.compile(PHONE_PATTERN, re.IGNORECASE)


def get_context(html_ner, html_name_stats, names):
    """
    Resolves name records and extract their context based on NER frequencies and HTML path patterns matching
    :param html_ner: HTML document in str format with predefined ner markup
    :param html_name_stats: list of HTML patterns, their frequencies, and NER matching
    :param names: list names in the string[] format
    :return: dictionary of resolved features
    """
    soup = BeautifulSoup(html_ner, "html.parser")
    # thresholds = sorted([loc["ner_freq"] for loc in locators_freq if loc["ner_freq"] > 1], reverse=True)
    resolved_names, resolution_confidence = _resolve_names(soup, html_name_stats, max(len(names) * 0.2, 1))
    resolved_context = _resolve_context(soup)

    return {"resolved_names": resolved_names,
            "resolved_context": resolved_context,
            "resolution_score": resolution_confidence}


def _resolve_names(soup, locators_freq, ner_thresh):
    """
    Resolve HTML paths as names based on the NER frequency threshold
    :param locators_freq: HTML path patterns and their NER counters in the dict[] format
    :param ner_thresh: resolution threshold
    :return: list of resolved names and the confidence estimation
    """
    # propagate is_ner=true property to tags with same locators as is_name=true
    resolved_nodes = []
    not_a_name_cnt = 0
    is_single_word = True
    for locator in locators_freq:
        if locator["ner_freq"] >= ner_thresh:
            for tag in soup.findAll(path=locator["path"]):
                name = tag.string.strip()
                if not re_not_a_name.search(name) and not re_lower_case_word.search(name) and name:
                    resolved_nodes.append((name, tag))
                    if is_single_word:
                        is_single_word = name.count(" ") == 0
                else:
                    resolved_nodes.append(("_NOT_A_NAME_" + str(ner_thresh) + " " + name, tag))
                    not_a_name_cnt += 1

    resolved_names = []
    for node in resolved_nodes:
        name = node[0]
        tag = node[1]
        if not name.startswith("_NOT_A_NAME_"):
            if not is_single_word and name.count(" ") == 0:
                resolved_names.append("_NOT_A_NAME_" + str(ner_thresh) + " " + name)
                not_a_name_cnt += 1
            else:
                resolved_names.append(name)
                tag.attrs["is_name"] = True
                tag.attrs["names_below_cnt"] = 1
                while tag.parent.name != "html":
                    tag = tag.parent
                    if "names_below_cnt" in tag.attrs:
                        tag.attrs["names_below_cnt"] += 1
                    else:
                        tag.attrs["names_below_cnt"] = 1
        else:
            resolved_names.append(name)

    total_cnt = len(resolved_names)
    resolution_confidence = (1 - not_a_name_cnt / (total_cnt + .0)) if total_cnt > 0 else 0
    return resolved_names, resolution_confidence


def _resolve_context(soup):
    """
    Extract context relevant to each name
    :return: list of context objects
    """
    # take the max subtree relevant to each name
    resolved_context = []
    for tag in soup.findAll(is_name=True):
        context_node = tag
        while "names_below_cnt" in context_node.parent.attrs and context_node.parent.attrs["names_below_cnt"] == 1:
            context_node = context_node.parent
        name, emails, phones, residuals, formatted_context, context_schema = _format_context(context_node)
        if name:
            if len(emails) == 0:
                email = "_none"
            elif len(emails) > 1:
                email = "_ambiguous"
            else:
                email = emails[0]

            if len(phones) == 0:
                phone = "_none"
            elif len(phones) > 1:
                phone = "_ambiguous"
            else:
                phone = phones[0]

            if len(residuals) == 0:
                role = "_none"
            elif email == "_ambiguous" or phone =="_ambiguous":
                role = "_ambiguous"
            else:
                role = ";".join(residuals)

            resolved_context.append({"name": name,
                                     "role": role,
                                     "email": email,
                                     "phone": phone,
                                     "xml_context": formatted_context,
                                     "schema": context_schema})

    schema_groups = dict((key, len(list(group))/len(resolved_context)) for key, group in
                         groupby(sorted(resolved_context, key=lambda x: x["schema"]), key=lambda x: x["schema"]))
    resolved_context = [{**x, **{"cluster_score": schema_groups[x["schema"]]}} for x in resolved_context]

    return resolved_context


def _format_context(context_tag):
    """
    Reformatting the context of a named record
    :param context_tag: bs4 object of the context
    :return: list of extracted and formatted features
    """
    # remove all empty tags
    no_empty_tags = False
    while not no_empty_tags:
        removed = [empty_tag.extract() for empty_tag in
                   context_tag.findAll(lambda tag: not tag.contents or tag.string == " ")]
        if len(removed) == 0:
            no_empty_tags = True

    # unwrap all redundant tags
    no_unwrapped_tags = False
    while not no_unwrapped_tags:
        unwrapped = [unwrap_tag.unwrap()
                     for unwrap_tag in context_tag.findAll(
                lambda tag: "is_name" not in tag.attrs and len(list(tag.findChildren(recursive=False))) == 1)]
        if len(unwrapped) == 0:
            no_unwrapped_tags = True

    name = None
    emails = set()
    phones = []
    residuals = []

    # transform to formatted xml
    for tag in context_tag.findChildren(recursive=True):
        contents = tag.contents[0]
        if contents and isinstance(contents, str):
            contents = contents.strip()
            if contents != "":
                if "is_name" in tag.attrs:
                    tag.name = "name"
                    name = contents
                elif re_email.search(contents):
                    tag.name = "email"
                    emails.add(contents)
                elif re_phone.search(contents):
                    tag.name = "phone"
                    phones.append(contents)
                elif contents.lower() not in ["email"]:
                    tag.name = "tag"
                    residuals.append(contents)
            else:
                tag.unwrap()
        else:
            tag.unwrap()
        tag.attrs = {}

    first_order_children = list(context_tag.findChildren(recursive=False))
    if len(first_order_children) == 1 and first_order_children[0].name != "name":
        context_tag = first_order_children[0]

    context_tag.name = "person"
    context_tag.attrs = {}

    if not name and context_tag.string:
        name = context_tag.string.strip()
        context_tag = "<person><name>{}</name></person>".format(name)

    context_tag = str(context_tag)
    context_schema = re.sub(r"(?<=>)[^<>]+(?=<)", r"", context_tag)

    return name, list(emails), phones, residuals, context_tag, context_schema
