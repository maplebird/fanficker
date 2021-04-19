# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

test_story = Story.create(
  title: 'Test Story',
  thread_url: 'https://forums.spacebattles.com/threads/test-story.1234',
  author: 'Don Julio',
  chapter_count: 5,
  download_complete: true
)

Chapter.create(
  story_id: test_story.id,
  title: 'I Liked Looking at Fonts as a Kid.',
  threadmark: 1,
  body: 'A quick brown fox jumps over the lazy dog'
)

Chapter.create(
  story_id: test_story.id,
  title: 'Lorem Ipsum',
  threadmark: 1,
  body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
)

Story.create(
  thread_url: 'https://forums.spacebattles.com/threads/empress-in-azeroth-drowtales-warcraft-crossover.905910/',
  refresh_story: true
)
