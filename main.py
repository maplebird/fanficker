#!/usr/bin/env python

from requests import get
from pprint import pprint
from bs4 import BeautifulSoup
from urllib import request

all_chapter_data = []


def get_html(url):
    response = get(url)
    html = response.content.decode('utf-8')
    return html


def get_post_text(url):
    soup = get_soup(url)
    body = soup.findAll("div", {"class": "bbWrapper"})

    if len(body) > 0:
        return str(body[0])
    return 'Could not download chapter text'


def get_soup(url):
    html = get_html(url)
    soup = BeautifulSoup(html, 'html.parser')
    return soup


def save_file(filename, output):
    out = filename
    f = open(out, 'w')
    f.write(output)
    f.close()


def build_html_base(url, metadata):
    soup = get_soup(url)
    head = str(soup.head)
    title = metadata['title']
    author = metadata['author']

    fic_header_html = """
<h1>{title}</h1>
<h2>By: {author}</h2>
""".format(title=title, author=author)

    base = head + fic_header_html
    return base


def build_chapter_html(chapter):
    chapter_html = """
<hr>
<br>
<h2>{name}</h2>
<br><br>
{body}
<br><br>
""".format(name=chapter['title'], body=chapter['body'])
    return chapter_html


def build_filename(url):
    parsed = request.urlparse(url)
    # Splitting this into multiple lines for readability
    thread_name = parsed.path.rstrip('/').split('/')[-1]    # Remove slashes from path
    thread_name = thread_name.split('.')[0]                 # Remove numeric thread ID
    return thread_name + '.html'


# Generate base forum URL from full link
def get_base_url(url):
    parsed = request.urlparse(url)
    base_url = parsed.scheme + '://' + parsed.netloc
    return base_url


def get_story_metadata(threadmarks_url):
    soup = get_soup(threadmarks_url)
    base_url = get_base_url(threadmarks_url)
    metadata = {}

    metadata['title'] = soup.findAll("h1", {"class": "threadmarkListingHeader-name"})[0].get_text()

    description_soup = soup.findAll("article", {"class": "threadmarkListingHeader-extraInfoChild message-body"})[0]
    metadata['description'] = description_soup.findAll("div", {"class": "bbWrapper"})[0].get_text()

    author = soup.findAll("a", {"class": "username"})[0]
    metadata['author'] = author.get_text()
    metadata['author_profile'] = base_url + str(author.get("href"))

    return metadata


def parse_threadmarks(threadmarks_url):
    base_url = get_base_url(threadmarks_url)
    soup = get_soup(threadmarks_url)

    # This is the closest HTML structure to the threadmark link that I can search for without pulling in extra elements
    soup = soup.findAll("div", {"class": "structItem-title threadmark_depth0"})

    for chapter in soup:
        chapter_metadata = {}
        link = chapter.findAll("a")[0]  # Surprisingly this is way faster than calling .a method on chapter soup
        path = link.get("data-preview-url")   # Opens preview URL so there's less stuff to load
        chapter_metadata['title'] = link.get_text()

        print(chapter_metadata['title'])

        chapter_metadata['url'] = base_url + path
        all_chapter_data.append(chapter_metadata)


def main():
    # thread_url = input("Enter URL to the story you wish to download: ").rstrip('/')
    thread_url = "https://forums.spacebattles.com/threads/empress-in-azeroth-drowtales-warcraft-crossover.905910"
    thread_url = "https://forums.spacebattles.com/threads/the-last-angel.244209"

    filename = build_filename(thread_url)
    print(filename)

    threadmarks_url = thread_url + '/threadmarks'
    parse_threadmarks(threadmarks_url)

    story_metadata = get_story_metadata(threadmarks_url)

    html_base = build_html_base(thread_url, story_metadata)
    html_body = ""

    for chapter in all_chapter_data:
        print('Downloading story content for chapter titled "{}"'.format(chapter['title']))
        chapter['body'] = get_post_text(chapter['url'])

    for chapter in all_chapter_data:
        html_body += build_chapter_html(chapter)

    output = html_base + html_body
    save_file(filename, output)


if __name__ == "__main__":
    main()