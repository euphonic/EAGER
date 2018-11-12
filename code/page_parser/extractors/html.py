import re
import string
import htmlmin
from bs4 import BeautifulSoup, Comment
from collections import deque
from itertools import groupby


def get_html_features(html_document):
    """
    Cleans HTML document by removing comments, styles, scripts, and special characters.
    Extracts plain text and structure representation features.
    :param html_document: HTML document in str format
    :return: dictionary of extracted features
    """
    # remove special characters
    html_document = "".join(map(lambda x: x if x in string.printable else " ", html_document))

    minified_document = htmlmin.minify(html_document, remove_comments=True, remove_empty_space=True)
    soup = BeautifulSoup(minified_document, "html.parser")

    # generate plain text
    plain_text = soup.get_text()

    # copy "mailto" attributes to the content of new "email" tags
    for tag in soup.findAll("a", attrs={"href": re.compile("mailto:")}):
        email = soup.new_tag("email")
        email.string = tag["href"].replace("mailto:", "")
        tag.parent.append(email)

    # drop comments and no-content tags
    [comment.extract() for comment in soup.findAll(text=lambda text: isinstance(text, Comment))]
    [tag.extract() for tag in soup(["style", "script", "img", "link", "meta"])]

    # remove all empty tags
    no_empty_tags = False
    while not no_empty_tags:
        removed = [empty_tag.extract() for empty_tag in soup.findAll(lambda tag: not tag.contents)]
        if len(removed) == 0:
            no_empty_tags = True

    # generate clean html document
    html_clean = str(soup)
    html_clean = re.sub(r">\s*", "> ", html_clean)
    html_clean = re.sub(r"\s*<", " <", html_clean)

    # extract structure representation features
    stack = deque()
    html_tags = []
    body_node = soup.find("body")
    if body_node:
        # extract counters for html tags, tuples, and triplets
        stack.append(body_node)
        while len(stack) > 0:
            parent = stack.pop()
            if parent.name != "body":
                html_tags.append("_HTML_{0}".format(parent.name))
            children = parent.findChildren(recursive=False)
            for child in children:
                stack.append(child)
                html_tags.append("_HTML_{0}_{1}".format(parent.name, child.name))
                for grandchild in child.findChildren(recursive=False):
                    html_tags.append("_HTML_{0}_{1}_{2}".format(parent.name, child.name, grandchild.name))
    html_tags_freq = dict((key, sum(1 for _ in group)) for key, group in groupby(sorted(html_tags)))

    title_tag = soup.find("title")
    title = title_tag.string if title_tag else ""

    return {"html_clean": html_clean,
            "title": title,
            "page_text": plain_text,
            "html_stats": html_tags_freq}


def get_html_name_stats(html_clean, names):
    soup = BeautifulSoup(html_clean, "html.parser")
    for tag in soup.findAll(recursive=True):
        tag.attrs = {}
    leaf_nodes = []
    body_node = soup.find("body")
    if body_node:
        for tag in body_node.findAll(lambda t: len(t.findChildren(recursive=False)) == 0
                                     and t.string is not None and "@" not in t.string):
            path = tag.name
            current_node = tag
            while current_node.parent.name != "body":
                current_node = current_node.parent
                path = current_node.name + "/" + path

            is_ner = False
            for name in names:
                if name in tag.string:
                    is_ner = True

            tag.attrs["is_ner"] = is_ner
            tag.attrs["path"] = path

            leaf_nodes.append({"content": tag.string, "is_ner": is_ner, "path": path})

    grouped_locators = [(key, list(group)) for key, group in
                        groupby(sorted(leaf_nodes, key=lambda x: x["path"]),
                                key=lambda x: x["path"])]
    leaf_paths_freq = [
        {"ner_freq": sum(int(x["is_ner"]) for x in locator[1]), "freq": sum(1 for _ in locator[1]),
         "path": locator[0]} for locator in grouped_locators]

    leaf_paths_freq = sorted(leaf_paths_freq, key=lambda x: x["ner_freq"], reverse=True)

    return {"html_name_stats": leaf_paths_freq,
            "html_ner": str(soup)}
