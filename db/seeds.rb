titles = [
  'The Great Gatsby',
  'To Kill a Mockingbird',
  '1984',
  'Pride and Prejudice',
  'The Catcher in the Rye',
]

# Create books in the database
titles.each { |title| Book.create(title: title) }

puts 'Seed data has been successfully added.'