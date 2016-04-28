# Includes and helpers
require 'csv'
require 'sunlight/congress'
require 'erb'
Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

#File structure validations
if File.exist?('../event_attendees.csv')
  puts "EventManager Initialized!"
else
  puts 'You need to have a file for me to analyze'
end
template_letter = File.read('../form_letter.erb')
erb_template = ERB.new(template_letter)

#Helper Methods
def validate_zipcode(zipcode)
  zipcode.to_s.rjust(5,'0')[0..4]
end

def sanitize_phone(phone)
  phone.to_s.rjust(10,'0')[0..9]
end

def register_date(date)
  DateTime.strptime(date, "%m/%d/%Y %H:%M")
end

def legislators(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)

end

def save_letter(id, form_letter)
  Dir.mkdir('../output') unless Dir.exist?('../output')
  filename = "../output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

#Program Start
contents = CSV.open('../event_attendees.csv', headers: true, header_converters: :symbol)
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = validate_zipcode(row[:zipcode])
  legis = legislators(row[:zipcode])
  form_letter = erb_template.result(binding)
  save_letter(id, form_letter)
  #Stitisctics Info
  phone = sanitize_phone(row[:homephone])
  puts "Participant #{name}'s Phone NR is: #{phone}'"
  date = register_date(row[:regdate])
  puts "registered on #{date.wday} at: #{date.hour}"
end

