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
  dns_raw = dns_raw.filter { |x| x[0] != "#" }
  dns_raw = dns_raw.filter { |x| x.length > 1 }
  split_words = []

  dns_raw.map { |rec|
    tmp = rec.split(", ").map { |x| x.strip }
    split_words.push(tmp)
  }

  type_of_rec = split_words.map { |word| word[0] }.uniq

  records = {}

  # Creating Records
  # Like :type => { :name => :value, :name => value }
  type_of_rec.map { |type|
    value_pair = {}

    split_words.filter { |word|
      if word[0] == type
        value_pair[:"#{word[1]}"] = "#{word[2]}"
      end
    }

    records[:"#{type}"] = value_pair
  }
  records
end

def resolve(dns_records, lookup_chain, domain)
  domain_keys = dns_records.keys
  typeKey = {}
  domain_keys.map { |domain_key|
    typeKey = dns_records[:"#{domain_key}"].select { |key, hash| key.to_s == domain }

    # If domain found then break map
    if typeKey.empty? == false
      break typeKey
    end
  }
  # Domain Not found
  if (typeKey.empty? == true)
    lookup_chain = ["Error: record not found for #{domain}"]
  else
    if lookup_chain.last != domain
      lookup_chain.push(domain)
    end
    if typeKey[:"#{domain}"][0].count("a-zA-Z") > 0 #Check if its a IP Address or Alias
      resolve(dns_records, lookup_chain, typeKey[:"#{domain}"])
    else
      lookup_chain.push(typeKey[:"#{domain}"])
      lookup_chain
    end
  end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
