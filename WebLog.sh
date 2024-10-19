#!/bin/bash

# Saúl Fernández García - 17 Octubre 2024 - saulfernandezgarcia.github.io

#---------------------------------------------
# Functions:

validate_params(){
	local file=$1
	local ip=$2
	
	# Verify if it is a valid filepath
	if ! test -f "$file"; then
		echo "Error: the file '$file' is not valid or does not exist."
		return 1
	fi
	
	# Verify if the IP address has a valid FORMAT (FORMAAAT!)
	# https://stackoverflow.com/questions/5284147/validating-ipv4-addresses-with-regexp
	if test -n "$ip"; then
		if [[ ! "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
			echo "Error: the ip '$ip' does not have a valid format."
			return 1
		fi
	fi
	
	return 0
}


# Case 1: one argument - file. 
# For each IP, count correct (200-299 status code) and incorrect (others) requests
check_correct_requests(){
	local file=$1

	# Verify parameters
	if ! validate_params "$file"; then
		exit 1
	fi
	
	# Maps
	# Each map contains, for each ip key, a classified-requests number value
	declare -A correctRequests
	declare -A incorrectRequests
	
	# Set to hold the IPs
	declare -A ipSet
	
	while read -r line; do
		# https://linuxize.com/post/bash-read/
		read auxIp statusCode <<< $(echo "$line" | awk '{print $1, $9}')
		
		# Add the ip to the set (make it "seen")
		ipSet["$auxIp"]=1
		
		# Classify requests
		if [[ $statusCode -ge 200 && $statusCode -lt 300 ]]; then
			correctRequests["$auxIp"]=$((correctRequests["$auxIp"]+1))
		else
			incorrectRequests["$auxIp"]=$((incorrectRequests["$auxIp"]+1))
		fi
	done < "$file"
	
	# Show results
	echo -e "\tRequest summary by IP"
	for ip in "${!ipSet[@]}"; do
		echo -e "IP: $ip\tCorrect: ${correctRequests[$ip]:-0}\tIncorrect: ${incorrectRequests[$ip]:-0}"
	done
}


# Case 2: two arguments - file, IP
# Find the requests with the IP, then display url, date, os, and browser
check_ip_request_info(){
	local file=$1
	local ip=$2
	
	# Verify parameters
	if ! validate_params "$file" "$ip"; then
		exit 1
	fi
	
	# Array to hold the filtered requests
	declare -a filteredRequests
	
	# Filter
	while read -r line; do
		# Line contains desired IP
		if [[ "$line" == *"$ip"* ]]; then
			url=$(echo "$line" | awk '{print $11}' | tr -d '"')
			date=$(echo "$line" | awk '{print $4}' | tr -d '[')
			
			userAgentSegment=$(echo "$line" | awk -F'"' '{print $(NF-1)}')
			# ^^^ awk separates fields between " and then obtains the last field

			userAgentLower=$(echo "$userAgentSegment" | tr '[:upper:]' '[:lower:]')
			# ^^^ Make lowercase to help with regex
			
			# Operating System
			if [[ "$userAgentLower" =~ (windows nt [0-9\\.]+) ]]; then
				os="Windows NT ${BASH_REMATCH[1]#windows nt }"
			elif [[ "$userAgentSegment" =~ (android [0-9_\\.]+) ]]; then
            	os="Android ${BASH_REMATCH[1]//_/\.}"	
            elif [[ "$userAgentLower" =~ (linux) ]]; then
				os="Linux"
			elif [[ "$userAgentLower" =~ (macintosh; intel mac os x [0-9_\\.]+) ]]; then
            	os="macOS ${BASH_REMATCH[1]//_/\.}"
			elif [[ "$userAgentLower" =~ (iphone; cpu iphone os [0-9_\\.]+) ]]; then
				os="iPhone OS ${BASH_REMATCH[1]//_\.}"
			elif [[ "$userAgentLower" =~ (ipad; cpu os [0-9_\\.]+) ]]; then
				os="iPad OS ${BASH_REMATCH[1]//_/\.}"
			else
				os="Unknown OS"
			fi
			
			# Browser
			# https://deviceatlas.com/blog/list-of-user-agent-strings
			if [[ "$userAgentLower" =~ chrome ]]; then
				browser="Chrome"
			elif [[ "$userAgentLower" =~ safari && ! "$userAgentLower" =~ chrome ]]; then
				browser="Safari"
			elif [[ "$userAgentLower" =~ firefox ]]; then
				browser="Firefox"
			elif [[ "$userAgentLower" =~ edg ]]; then
				browser="Edge"
			elif [[ "$userAgentLower" =~ samsungbrowser ]]; then
				browser="Samsung Browser"
			elif [[ "$userAgentLower" =~ wget ]]; then
				browser="Wget"
			fi
			
			result="$url $date $os $browser"
			filteredRequests+=("$result")
		fi
	done < "$file"
	
	# Show results
	echo -e "\tRequests for $ip"
	for request in "${filteredRequests[@]}"; do
		echo "$request"
	done
}

# Case 3: no arguments - offer the user with introducing both parameters, although case 1 and case 2 will be available regardless.
request_params(){
	read -p "Introduce the file path: " file
	read -p "Introduce the IP address (press 'enter' if you want to omit it): " ip
	
	if ! validate_params "$file" "$ip"; then
		exit 1
	fi
	
	if test -n "$ip"; then
		# Caso 2
		echo "Two parameters were passed."
		echo "------------------------------------------------------------------"
		check_ip_request_info "$file" "$ip"
	else
		# Caso 1
		echo "One parameter was passed."
		echo "------------------------------------------------------------------"
		check_correct_requests "$file"
	fi
}



#---------------------------------------------
# Main code:

if [[ "$#" -eq 1 ]]; then
	# Case 1
	check_correct_requests "$1"
elif [[ "$#" -eq 2 ]]; then
	# Case 2
	check_ip_request_info "$1" "$2"
elif [[ "$#" -eq 0 ]]; then
	# Case 3
	request_params
fi

