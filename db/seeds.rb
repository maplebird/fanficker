# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Story.create(
    title: "Test Story",
    thread_url: "https://forums.spacebattles.com/threads/test-story.1234",
    author: "Don Julio",
    chapter_count: 5
)

Story.create(thread_url: "https://forums.spacebattles.com/threads/test-story.2345")