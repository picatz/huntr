require "command_lion"
require "nmapr"
require "shodan"
require "yaml"
require "colorize"
require "pry"
require "socket"
require "unirest"
require "resolv"
require "ipaddress"
require "whois-parser"
require "huntr/version"
require "huntr/target"

# The purpose of this libary is provide the tooling required
# to effectively perform reconnaissance on a given target.
#
# A *target* is simply an organization's IP address or domain name.
#
module Huntr

  # Re-usable code to provision different stages of the reconnaissance.
  module Utils
    def self.target_file
      data = {}
      data["domains"] = []
      data["ips"] = []
      data.to_yaml
    end

    def self.target_file?
      File.file?("target.yaml")
    end
  end

  trap("SIGINT") { exit 0 }

  CommandLion::App.run do
    if ENV["SHODAN_API_KEY"].nil?
      puts "No shodan API key detected. Will not be able to use shodan!"
    end
    name "Huntr".colorize(:yellow)
    version Huntr::VERSION
    description "Command-line reconnaissance toolkit."

    command :create do
      description "Create a new reconnaissance directory to store relevant information."
      type :string
      before do
        if argument.nil?
          puts "Must provide an argument!"
          exit 1
        end
        if File.directory?(argument)
          puts "Directory already exists!"
          exit 1
        end
      end
      action do
        Dir.mkdir(argument)
        Dir.chdir(argument)
        File.open("target.yaml", "w+") { |f| f.write Utils.target_file }
      end
      after do
        puts "Directory #{argument.colorize(:yellow)} has been created."
      end
    end

    command :targets do
      description "Add target domains and IP addresses to the target file."
      type :strings
      before do
        if arguments.empty?
          file = YAML.load(File.read("target.yaml"))
          puts "HUNTR TARGETS:"
          file["domains"].each do |domain|
            puts "Domain: #{domain}"
          end
          file["ips"].each do |ip|
            puts "IP: #{ip}"
          end
          exit
        end
        unless File.file?("target.yaml")
          puts "No target file found! Are you in a reconnaissance directory?"
          exit 1
        end
      end
      action do
        file = YAML.load(File.read("target.yaml"))
        arguments.each do |argument|
          if IPAddress.valid?(argument)
            file["ips"] << argument unless file["ips"].include?(argument)
            if names = Resolv.getnames(argument)
              names.each do |name|
                file["domains"] << name unless file["domains"].include?(name)
              end
            end
          elsif ip = IPSocket::getaddress(argument)
            file["domains"] << argument unless file["domains"].include?(argument)
            file["ips"] << ip unless file["ips"].include?(ip)
          end
          File.open("target.yaml", "w") { |f| f.write file.to_yaml }
        end
      end
    end

    command :delete do
      description "Delete a given reconnaissance directory."
      type :string
      before do
        if argument.nil?
          puts "Must provide an argument!"
          exit 1
        end
        unless File.directory?(argument)
          puts "That directroy doesn't exist, try again!"
          exit 1
        end
      end
      action do
        FileUtils.rm_rf(argument)
      end
    end
    
    command :shodan do
      description "Perform shodan query on a given domain or IP address."
      type :string
      before do
        if argument.nil?
          puts "Must provide an argument!"
          exit 1
        end
        unless File.file?("target.yaml")
          puts "No target file found! Are you in a reconnaissance directory?"
          exit 1
        end
      end
      action do
        api = Shodan::Shodan.new(ENV["SHODAN_API_KEY"])
        response = api.host(argument)
        file = YAML.load(File.read("target.yaml"))
        file["shodan"] = {} unless file["shodan"]
        file["shodan"][argument] = response
        File.open("target.yaml", "w") { |f| f.write file.to_yaml }
        puts response.to_yaml 
      end
    end

    command :nmap do
      description "Perform nmap scan on a given domain or IP address."
      type :string
      before do
        if argument.nil?
          puts "Must provide an argument!"
          exit 1
        end
        unless File.file?("target.yaml")
          puts "No target file found! Are you in a reconnaissance directory?"
          exit 1
        end
      end
      action do
        nmap = `nmap #{argument} -vvvv --reason -oN -`
        file = YAML.load(File.read("target.yaml"))
        file["nmap"] = {} unless file["nmap"]
        file["nmap"][argument] = nmap 
        File.open("target.yaml", "w") { |f| f.write file.to_yaml }
        puts nmap
      end
    end

    command :ipinfo do
      description "Get ipinfo.io information on a given domain or IP address."
      type :string
      before do
        if argument.nil?
          puts "Must provide an argument!"
          exit 1
        end
        unless File.file?("target.yaml")
          puts "No target file found! Are you in a reconnaissance directory?"
          exit 1
        end
      end
      action do
        data = Unirest.get('https://ipinfo.io/' + argument).body
        file = YAML.load(File.read("target.yaml"))
        file["ipinfo"] = {} unless file["ipinfo"]
        file["ipinfo"][argument] = data
        File.open("target.yaml", "w") { |f| f.write file.to_yaml }
        puts data.to_yaml
      end
    end

    command :whois do
      description "Perform nmap scan on a given domain or IP address."
      type :string
      before do
        if argument.nil?
          puts "Must provide an argument!"
          exit 1
        end
        unless File.file?("target.yaml")
          puts "No target file found! Are you in a reconnaissance directory?"
          exit 1
        end
      end
      action do
        data = Whois.whois(argument).to_s
        file = YAML.load(File.read("target.yaml"))
        file["whois"] = {} unless file["whois"]
        file["whois"][argument] = data
        File.open("target.yaml", "w") { |f| f.write file.to_yaml }
        puts data
      end
    end



  end
end
