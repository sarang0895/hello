

class ApacheLogAnalyzer

	def initialize
		
		@total_hits_by_ip = {}
		@total_hits_per_url = {}
		@secret_hits_by_ip = {}
		@error_count = 0
	end
	def analyze(file_name)
		# Regex to match a single octet of an IPv4 address
		octet = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/
		# Since an IPv4 address is made of four octets we will string them together
		# to match a full IPv4 address
		ip_regex = /^#{octet}\.#{octet}\.#{octet}\.#{octet}/
		# Regex to match an alphanumeric url ending with .html
		url_regex = /[a-zA-Z0-9]+.html/
		
		File.readlines(file_name).each do |line|
			ip = line.scan(ip_regex).first
			url = line.scan(url_regex)
			
			secret = url.include? 'secret'
			error = line.include? '404'
		
			count_hits(ip, url, secret, error)
		end
		
		print_hits
	end
	
	def count_hits(ip, url, secret, error)
		@total_hits_by_ip[ip] = @total_hits_by_ip[ip].to_i +  1;
		@total_hits_per_url[url] = @total_hits_per_url[url].to_i +  1;

		if secret
			@secret_hits_by_ip[ip] = @secret_hits_by_ip[ip].to_i + 1;
		end
		
		if error
			@error_count = @error_count.to_i + 1
		end
	end

	def print_hits
		print_string = 'IP: %s, Total Hits: %s, Secret Hits: %s'
		
		@total_hits_by_ip.sort.each do |ip, total_hits|
		  secret_hits = @secret_hits_by_ip[ip]
		  puts sprintf(print_string, ip, total_hits, secret_hits)
		end
	
		url_print_string = 'URL: %s, Number of Hits: %s'
		
		@total_hits_per_url.sort.each do |url, url_hits|
		  puts sprintf(url_print_string, url, url_hits)
		end
		
		puts sprintf('Total Errors: %s', @error_count)
	end	
end

def main
	if ARGV.empty?
		puts "Invalid arguments"
		exit(1)
	end
	ARGV.each do |file_name|
		log_analyzer = ApacheLogAnalyzer.new
		log_analyzer.analyze(file_name)
	end
end
if __FILE__ == $PROGRAM_NAME
	main
end