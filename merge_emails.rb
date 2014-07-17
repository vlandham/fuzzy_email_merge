#!/usr/bin/env ruby

require 'csv'
require 'fuzzy_match'
require 'ostruct'

email_filename = "emails.txt"
user_filename = "users.txt"



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
    users << csv_obj.to_hash
  end
  users
end

def get_match name, matcher
  match = matcher.find(name)
end

matcher = load_emails email_filename
users = get_users user_filename

out = []
users.each do |user|
  match = get_match(user["name"], matcher)
  if match
    out << [user['name'], match.name, match.email]
  else
    out << [user['name'], 'none', 'none']
  end

end

out.each do |o|
  puts o.join("\t")
end


