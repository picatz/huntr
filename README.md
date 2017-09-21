# Huntr

A simple reconnaissance command-line application with built in support for whois, ipinfo, nmap, and shodan.

## Installation

    $ gem install huntr

## Look, a wild Geff appeared!

![demo](https://github.com/picatz/huntr/blob/master/demo.gif)
###### Ran on a simulated network using pre-found responses.

## Usage

To get started, create a new reconnaissance directory. This is where all the information gathered during the reconnaissance will be aggregated into a `target.yaml` file which will store all the information about our target including information such as domains, ip addresses and open ports.

```
huntr create example_dir_name
```

You can now change in the the `example_dir_name` directory where a `target.yaml` will exist, basically empty. Then you probably to add some target IP/DOMAIN information:

```
huntr targets 8.8.8.8
```

Inside of the `target.yaml` file you should now see:

```yaml
---
domains:
- google-public-dns-a.google.com
ips:
- 8.8.8.8
```

As you can see, it has already figured out the `google-public-dns-a.google.com` from the `8.8.8.8` IP address. If we were to do the reverse, providing a domain, then it would also resolve the IP address of the domain for us -- if possible:

```
huntr targets google-public-dns-b.google.com
```

Inside of the `target.yaml` file you should now see:

```
---
domains:
- google-public-dns-a.google.com
- google-public-dns-b.google.com
ips:
- 8.8.8.8
- 8.8.4.4
```

You can mix and match the `targets` arguments with as many IPs and Domains as you'd like. But, once you start to figure those out, you probably want to learn more about them. There's some online web services with APIs and even some command-line tools Huntr can interface with. Let's go over those.

##### IpInfo

The [ipinfo](https://ipinfo.io/) services provides a free API ( with limited requets per day ). You can utilize and save this information with the `ipinfo` command-line flag.

```
huntr ipinfo 8.8.8.8
``` 

##### Nmap

To perform an nmap scan a target, the `nmap` command-line flag is there for you.

```
huntr nmap 8.8.8.8
```

##### Shodan

The Shodan API is available if you have the `SHODAN_API_KEY` enviroment variable set with your [shodan](https://www.shodan.io/) API key. 

```
huntr shodan 8.8.8.8
```

##### Whois

To query the whois information for a given target, you have the `whois` command-line flag.

```
huntr whois google.com
```

### Development

This project was built for my Ethical Hacking Reconnaissance Lab project. I didn't want to write a paper, so I wrote a command-line tool.

#### Nmap

To use the NMAP integration you will need to download and install nmap.

```
brew install nmap
```

#### Shodan API

To use the SHODAN integration you will need to sign-up and set your API key into the `SHODAN_API_KEY` enviroment variable of your shell either temporarily or permentently:

```
SHODAN_API_KEY=key...
```
