# parse.rb

require 'rubygems'
require 'nokogiri'
require 'date'
require 'securerandom'

#Ubuntu Instructions:
#  sudo apt-get install ruby
#  sudo apt-get install ruby-dev
#  sudo apt-get install make
#  sudo gem install nokogiri



#File.open("webpage.txt", "r") { |f|
#  f.each_line do |line|
#	allText += line
#    #puts line
#  end
#}


class Event
  @day
  @time
  @loc
  @teams

  def initialize(day, time, loc, teams)
    @day = day
    @time = time
    @loc = loc
    @teams = teams
  end

  def getDateTime()
    #return DateTime.parse(@day + " " + @time).to_s
    return DateTime.parse(@day + " " + @time).strftime("%Y%m%dT%H%M%S")
  end

  def getEndDateTime()
    dt = DateTime.parse(@day + " " + @time)
    dt = dt + Rational(1,24) #adds one hour
    return dt.strftime("%Y%m%dT%H%M%S")
  end

  def location()
    if @loc =~/asher levy/i then
      return "Asher Levy 185 First Avenue, New York, New York, 10009"
    elsif @loc =~/liberty school/i then
      return @loc #zog website doesnt have it
    elsif @loc =~/anna silver/i then
      return "Anna Silver 166 ESSEX STREET, New York, New York"
    else
      return @loc
    end
  end

  def getTimestamp

      return DateTime.now.strftime("%Y%m%dT%H%M%S")
  end

  def to_s
    #worked for date only:  d = Date.parse(@day + " " + @time).to_s
    d = getDateTime() #DateTime.parse(@day + " " + @time).to_s
    #return @day + " | " + @time + " | " + @loc + " | " + @teams
    return d + " | " + @time + " | " + @loc + " | " + @teams
  end

  def to_ical
    #see http://dev.af83.com/2008/03/04/publishing-icalendar-events-with-ruby-on-rails.html
    #http://tools.ietf.org/html/rfc5545
    #http://stackoverflow.com/questions/1823647/grouping-multiple-events-in-a-single-ics-file-icalendar-stream

    #DTSTAMP is when the stupid thing was created

    s = <<-ICAL
      BEGIN:VEVENT
      DTSTART;TZID=America/New_York:#{getDateTime()}
      DTEND;TZID=America/New_York:#{getEndDateTime()}
      DTSTAMP:#{getTimestamp()}
      SUMMARY: Volleyball
      DESCRIPTION: #{@teams + " at " + @loc}
      LOCATION: #{location()}
      UID: #{SecureRandom.uuid.gsub(/-/,"")}
      END:VEVENT
    ICAL
    return s.gsub(/^\s*/, "")
  end

end

teamEvents = Array.new

html_doc = Nokogiri::HTML(File.open("webpage.txt"))

tables =  html_doc.css('div.myschedule table');


tables.each { |table|

  trs = table.css('tr')
  trs.each { |tr|
    day = tr.css('td div#dayValue')
    if day.nil?
      next
    end
    time = tr.css('td div#startDateValue').text.strip
    loc = tr.css('td div#locationNameValue').text.strip
    teams = tr.css('td div#teamsValue').text.strip

    if not teams =~/balls to the wall/i then
      next
    end
   
    teamEvents.push(Event.new(day.text.strip, time, loc, teams ))

    #puts day.text.strip + " | " + time.text.strip + " | " + loc.text.strip + " | " + teams
  } 


}



def icalHeader()
  s = <<-ICAL
  BEGIN:VCALENDAR
  VERSION:2.0
  PRODID:-//bobbin v0.1//NONSGML iCal Writer//EN
  CALSCALE:GREGORIAN
  METHOD:PUBLISH
  ICAL

  return s.gsub(/^\s*/, "")

end

def icalFooter()
  s = <<-ICAL
  END:VCALENDAR
  ICAL
  return s.gsub(/^\s*/, "")
end




ical = icalHeader()

teamEvents.each { |e|

        #{e.to_ical}

  ical += e.to_ical
}

ical += icalFooter()

#add the stupid fucking \r bullshit
puts ical.gsub(/\n/,"\r\n")



