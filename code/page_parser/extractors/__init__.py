from extractors.html import get_html_features, get_html_name_stats
from extractors.schools import get_school_names, match_schools
from extractors.emails import get_emails
from extractors.names import get_names
from extractors.context import get_context

import nltk
nltk.download("punkt")


def extract_all(page_html, input_schools):
    html_features = get_html_features(page_html)
    title_school_name = get_school_names(html_features["title"])
    if title_school_name:
        school_in_title = title_school_name["max_freq_school"]["school_name"]
    else:
        school_in_title = None
    schools_data = get_school_names(html_features["html_clean"])
    emails_data = get_emails(html_features["html_clean"])
    names_data = get_names(html_features["html_clean"])
    html_ner = get_html_name_stats(html_features["html_clean"], list(map(lambda x: x["name"], names_data["names"])))
    context = get_context(html_ner["html_ner"], html_ner["html_name_stats"], names_data["names"])
    resolved_schools = match_schools(input_schools, schools_data["school_names"])

    features = {"html_stats": html_features["html_stats"],
                "html_name_stats": html_ner["html_name_stats"],
                "html_clean": html_features["html_clean"],
                "page_text": html_features["page_text"],
                "html_ner": html_ner["html_ner"],
                "school_in_title": school_in_title,
                "school_names": schools_data["school_names"],
                "max_freq_school": schools_data["max_freq_school"],
                "emails": emails_data["emails"],
                "user_names": emails_data["user_names"],
                "domains": emails_data["domains"],
                "names": names_data["names"],
                "resolved_names": context["resolved_names"],
                "resolved_context": context["resolved_context"],
                "resolution_score": context["resolution_score"],
                "resolved_schools": resolved_schools}

    return features
