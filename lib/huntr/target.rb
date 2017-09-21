module Huntr
  class Target
    def initialize(target)
      @target = target
    end
    
    def given
      @target
    end

    def resolve_to_ip(target = @target)
      IPSocket::getaddress(target)
    end

    def ip
      @ip || @ip = resolve_to_ip 
    end

    def resolve_to_domains(ip = self.ip)
      Resolv.getnames(ip)
    end

    def domains
      @domains || @domains = resolve_to_domains
      return @domains unless block_given?
      @domains.each { |domain| yield domain }
    end

    Struct.new("IPInfo", :ip, :hostname, :city, :region, :country, :gps, :org, :postal )
    
    def ipinfo
      return @ipinfo unless @ipinfo.nil?
      data = Unirest.get('https://ipinfo.io/' + self.ip).body
      data.each { |k,v| v.nil? || v.empty? ? data[k] = nil : data[k] = v  }
      @ip_info = Struct::IPInfo.new
      missing_info = nil
      @ip_info.ip       = data["ip"]       || missing_info
      @ip_info.hostname = data["hostname"] || missing_info
      @ip_info.city     = data["city"]     || missing_info
      @ip_info.region   = data["region"]   || missing_info
      @ip_info.country  = data["country"]  || missing_info
      @ip_info.gps      = data["loc"]      || missing_info
      @ip_info.org      = data["org"]      || missing_info
      @ip_info.postal   = data["postal"]   || missing_info
			@ip_info
    end

    def whois(domain = self.domains.first, recheck: false)
      return @whois unless @whois.nil? or recheck
      @whois = Thread.new do 
        @whois = Whois.whois(domain).parser
      end
    end

    def nmap(recheck: false)
      return @nmap unless @nmap.nil? or recheck
      @nmap = Thread.new do
        @nmap = `nmap #{self.ip} -vvvv --reason -oX -`
      end
    end

    def shodan(host = self.ip)
      # not yet implemented 
    end

  end
end
