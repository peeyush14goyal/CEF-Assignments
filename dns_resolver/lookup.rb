def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  # Removing comments and empty lines
  dns_raw = dns_raw.filter { |x| x[0] != "#" }.filter { |x| x.length > 1 }
  split_words = []

  split_words = dns_raw.map { |rec|
    rec.split(", ").map { |x| x.strip }
  }

  records = {}

  split_words.map { |x|
    records[x[1].to_sym] = { :type => "#{x[0]}", :target => "#{x[2]}" }
  }
  records
end

def resolve(dns_records, lookup_chain, domain)
  record = dns_records[domain.to_sym]
  if (!record)
    lookup_chain.clear()
    lookup_chain << "Error: Record not found for " + domain
  elsif record[:type] == "CNAME"
    lookup_chain.push(record[:target])
    resolve(dns_records, lookup_chain, record[:target])
  elsif record[:type] == "A"
    lookup_chain.push(record[:target])
    return lookup_chain
    return
  else
    lookup_chain.clear()
    lookup_chain << "Invalid record type for " + domain
  end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
