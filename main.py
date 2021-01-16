#!/usr/bin/env python

from requests import get
from feedparser import parse
from pprint import pprint
from bs4 import BeautifulSoup

all_chapter_metadata = []
all_chapters = []


def get_html(url):
    reader_mode_url = "{}/reader".format(url)
    content = get(reader_mode_url).content.decode('utf-8')
    return content


def get_post(soup, post):
    post_filter = {
        "data-lb-id": post
    }
    message = soup.findAll("div", post_filter)

    if message:
        print("Parsing post ", post)
        message = message[0].findAll("div", {"class": "bbWrapper"})[0]
        message = str(message)
        return message
    return 'none'


def get_soup(url):
    html = get_html(url)
    soup = BeautifulSoup(html, 'html.parser')
    return soup


def get_message(soup, chapter, retries=0):
    if retries < 2:
        message = get_post(soup, chapter['post'])

        if message != 'none':
            return message
        else:
            retries += 1
            soup = get_soup(chapter['link'])
            get_message(soup, chapter, retries)
    else:
        return 'skip'


def save_file(filename, output):
    out = filename
    f = open(out, 'w')
    f.write(output)
    f.close()


# Parse threadmarks RSS to grab some metadata about every chapter
# Chapter threadmarks are in reverse order with latest entries first, so we want to flip this when saving to a file
def get_chapter_metadata(rss):
    entries = rss.entries
    entries.reverse()
    for entry in entries:
        post = entry.link.split('/')[-1]
        chapter = {
            'title': entry.title,
            'description': entry.description,
            'link': entry.link,
            'post': post
        }
        all_chapter_metadata.append(chapter)


def build_html_base(head, title, author):
    fic_header_html = """
<h1>{title}</h1>
<h2>By: {author}</h2>
""".format(title=title, author=author)

    base = str(head) + fic_header_html
    return base


def build_chapter_html(chapter):
    chapter_html = """
<hr>
<br>
<h2>{name}</h2>
<h4>{description}</h4>
<br><br>
{content}
<br><br>
""".format(name=chapter['title'], description=chapter['description'], content=chapter['message'])
    return chapter_html


def main():
    thread_url = input("Enter URL to the story you wish to download: ").rstrip('/')
    rss_url = "{}/threadmarks.rss".format(thread_url)
    filename = thread_url.split('/')[-1].split('.')[0] + '.html'
    print(filename)
    print(thread_url)

    print("Downloading Threadmarks RSS at {}".format(rss_url))
    rss = parse(rss_url)
    threadmarks = rss.entries

    if len(threadmarks) < 1:
        raise Exception("NoThreadmarksError: No threadmarks found for given thread. Cannot download.")
    print("Found {} chapters in story".format(len(threadmarks)))

    print("Parsing RSS for chapter metadata.")
    get_chapter_metadata(rss)
    soup = get_soup(all_chapter_metadata[0]['link'])

    html_base = build_html_base(head=soup.head, title=rss.feed.title, author=rss.entries[-1].author)
    html_body = ""

    for chapter in all_chapter_metadata:
        print('Downloading story content for chapter titled "{}"'.format(chapter['title']))
        message = get_message(soup, chapter)
        if message != 'skip':
            chapter['message'] = message
            all_chapters.append(chapter)

    for chapter in all_chapters:
        html_body += build_chapter_html(chapter)

    output = html_base + html_body
    save_file(filename, output)


if __name__ == "__main__":
    main()