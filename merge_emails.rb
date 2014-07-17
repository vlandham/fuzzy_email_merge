#!/usr/bin/env ruby

require 'csv'
require 'fuzzy_match'
require 'ostruct'

email_filename = "emails.txt"
user_filename = "users.txt"

output_filename = "joined.txt"


def load_emails filename
  users = []
  CSV.foreach(filename, :headers => true, :col_sep => "\t") do |csv_obj|
    users << OpenStruct.new(csv_obj.to_hash)
  end
  fz = FuzzyMatch.new(users, :read => :name)
  fz
end

def get_users filename
  users = []
  CSV.foreach(filename, :headers => true, :col_sep => "\t") do |csv_obj|
    users << OpenStruct.new(csv_obj.to_hash)
  end
  users
end

@found = {}
@dup_count = 0
def get_match name, matcher
  match = matcher.find(name, {:must_match_at_least_one_word => true})

  if match
    if !@found.keys.include?(match)
      @found[match] = name
    else
      puts "ERROR - already used [#{match.name}] for [#{@found[match]}] not [#{name}]"
      @dup_count += 1
      match = nil
    end
  end
  match
end

matcher = load_emails email_filename
users = get_users user_filename

out = []
@missing_count = 0
@total_count = 0
@found_count = 0
users.each do |user|
  @total_count += 1
  match = get_match(user.name, matcher)
  if match
    out << [user.name, match.name, match.email]
    @found_count += 1
  else
    out << [user.name, 'none', 'none']
    @missing_count += 1
  end
end

puts "#{@dup_count} dups found"
puts "#{@missing_count} missing - #{(@missing_count.to_f / @total_count.to_f).round(2)}"
puts "#{@found_count} found - #{(@found_count.to_f / @total_count.to_f).round(2)}"
puts "#{@total_count} total"

CSV.open(output_filename, "wb") do |csv|
  csv << ["name", "match_name", "email"]
  out.each do |o|
    csv << o
  end
end



