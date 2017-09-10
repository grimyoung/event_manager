require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  return zipcode.to_s.rjust(5,"0")[0..4] 
end

def legislator_by_zipcode(zipcode)
  return legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end
puts "EventManger Initialized"

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exist?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename, "w") do |file|
    file.puts form_letter
  end
end

def clean_telephone(telephone)
  telephone = telephone.to_s
  if telephone.length == 11 && telephone[0] == "1"
    telephone = telephone[0..-1]
  elsif telephone.length != 10
    telephone = nil
  end
end


template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislator_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id, form_letter)

end

