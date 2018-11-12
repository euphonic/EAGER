import re
from settings import EMAIL_PATTERN
from itertools import groupby

re_email = re.compile(EMAIL_PATTERN, re.IGNORECASE)


def get_emails(document):
    """
    Extracts emails and their frequencies based on the regex match
    :param document: text or HTML document in str format
    :return: dictionary of extracted features
    """
    emails = re_email.findall(document)
    email_parts = list(map(lambda x: x.split("@"), emails))
    user_names = list(map(lambda x: x[0], email_parts))
    domains = list(map(lambda x: x[1], email_parts))

    emails_freq = dict((key, sum(1 for _ in group)) for key, group in groupby(sorted(emails)))
    user_names_freq = dict((key, sum(1 for _ in group)) for key, group in groupby(sorted(user_names)))
    domains_freq = dict((key, sum(1 for _ in group)) for key, group in groupby(sorted(domains)))

    return {"emails": emails_freq,
            "user_names": user_names_freq,
            "domains": domains_freq}
