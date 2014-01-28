# /usr/bin/env ruby
# Lars Sommer - lars.j.sommer@gmail.com
#
# Notes: This is an algorithm aimed at smoothing out some of the rough edges 
# associated with arena MMR. For more information, view the README file. 
#

require 'httparty'
require 'json'
require 'rubygems'

# Options: us, eu, kr, tw, and china. China has different DNS format.
region = "us"

if region == "china"
    $host = "www.battlenet.com.cn"
else
    $host  = "http://#{region}.battle.net"
end

class Character
    def initialize(name, realm)
        @name      = name
        @realm     = realm
    end

    def name
        return @name
    end

    def realm 
        return @realm
    end

    attr_accessor :url
    attr_accessor :source_data
    attr_accessor :pretty_data
    attr_accessor :parsed_data
    attr_accessor :iLevel
    attr_accessor :pvpPower
    attr_accessor :pvpResil
    attr_accessor :rating_2s
    attr_accessor :rating_3s
    attr_accessor :rating_5s
end

class Team
    def initialize(*members)
        @members = members
    end

    def members
        return @members
    end

    attr_accessor :rating
end

dealy        = Character.new("Dealy", "Nerzhul")
defdef       = Character.new("Defdef", "Nerzhul")
defghanistan = Character.new("Defghanistan", "Nerzhul")
larsadin     = Character.new("Larsadin", "Nerzhul")
notfrost     = Character.new("Notfrost", "Nerzhul")
shoshirent   = Character.new("Shoshirent", "Nerzhul")

pally_rogue   = Team.new(larsadin, shoshirent)
lock_war_mage = Team.new(dealy, defghanistan, notfrost)

characters   = [dealy, defdef, defghanistan, larsadin, notfrost, shoshirent]

# Battle.net is backed by the HTTParty gem, making get requests pretty easy
# Break up URL into URI format
def generate_urls(character)
    name          = character.name
    realm         = character.realm
    host          = $host
    path          = "/api/wow/character/#{realm}/#{name}"
    query         = "?fields=items,pvp,stats"
    character.url = "#{host}#{path}#{query}"
end

# Submit request, return source data
def query_api(character)
    character.source_data = HTTParty.get(character.url)
end

# Clean up / parse JSON
def parse_response(character)
    character.pretty_data = []
    character.parsed_data = []
    # Keeping this around for when I want to look at the source JSON with my eyeballs
    character.pretty_data = JSON.pretty_generate(character.source_data)
    # Annoyingly, parsing the data with JSON.parse obliterates the pretty formatting
    character.parsed_data = JSON.parse(character.pretty_data)
end

# Select out the data that we want 
def populate_stats(character)
    # There is a typo in the API for the 5's bracket(d)
    # Commenting out the current rating API call, I am discarding real rankings for the moment
    #character.rating_2s = character.source_data["pvp"]["brackets"]["ARENA_BRACKET_2v2"]["rating"].to_s
    #character.rating_3s = character.source_data["pvp"]["brackets"]["ARENA_BRACKET_3v3"]["rating"].to_s
    #character.rating_5s = character.source_data["pvp"]["brackets"]["ARENA_BRACKED_5v5"]["rating"].to_s
    character.iLevel    = character.source_data["items"]["averageItemLevelEquipped"].to_s
    character.pvpPower  = character.source_data["stats"]["pvpPower"].to_s
    character.pvpResil  = character.source_data["stats"]["pvpResilience"].to_s
    gear                = character.iLevel.to_i
    power               = character.pvpPower.to_i
    resil               = character.pvpResil.to_i
    character.rating_2s = gear + (power *2) + resil
end

# Wrapper
def stage(character)
    generate_urls(character)
    query_api(character)
    parse_response(character)
    populate_stats(character)
end

# This sort of monkey-coding isn't recommended but I need a quick way to access the last
# element in a hash. Plus it's just really useful.
class Hash
    def last_value
        values.last
    end
end

def hash_v_avg(hash)
    average = hash.inject(0) {|total, (k, v)| total + v} /hash.size
    return average
end

def team_rating_calc(team)
    # For the sake of demonstration I am only using 2s data, modify this for 3s or 5s
    ratings = Hash.new
    team.members.each do |char|
        ratings[char.name] = char.rating_2s
    end

    sorted         = Hash[ratings.sort_by {|char, rating| rating}.reverse]
    highest_rating = sorted.values[0].to_i
    lowest_rating  = sorted.last_value.to_i
    average        = hash_v_avg(ratings)
    elevator       = (lowest_rating /2)

    if highest_rating - lowest_rating > elevator
        team.rating = average.to_i + elevator.to_i
    else 
        team.rating = average
    end

    puts team.rating
end

characters.each do |char|
    stage(char)
end

team_rating_calc(pally_rogue)
team_rating_calc(lock_war_mage)









