#!/bin/bash

# Check for proper input arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <hash_file> <domain_admins_file>"
  exit 1
fi

hash_file="$1"
admins_file="$2"

# Read the domain admins into an array, converting everything to lowercase
declare -A domain_admins
while IFS= read -r admin; do
  # Convert the admin username to lowercase and store in the array
  admin_lower=$(echo "$admin" | tr '[:upper:]' '[:lower:]')
  domain_admins["$admin_lower"]=1
done < "$admins_file"

# Declare an associative array to store NT hashes and corresponding users
declare -A nt_hashes

# Read through the hash file and populate the nt_hashes array
while IFS=: read -r user id lm_hash nt_hash rest; do
  # Ensure nt_hash is not empty
  if [[ -z "$nt_hash" ]]; then
    echo "Skipping line with invalid hash: $user"
    continue
  fi

  # Handle usernames with domain (using a single backslash) and convert to lowercase
  user_name=$(echo "$user" | sed 's/^[^\\]*\\\(.*\)/\1/' | tr '[:upper:]' '[:lower:]' | xargs)
  
  # Add the user to the nt_hashes array under the corresponding NT hash
  nt_hashes["$nt_hash"]+="$user_name "
done < "$hash_file"

# Prepare the output file
output_file="output.txt"
> "$output_file" # Clear the output file if it already exists

# Loop through the NT hashes and print those that have more than one user sharing the same NT hash
for nt_hash in "${!nt_hashes[@]}"; do
  users="${nt_hashes[$nt_hash]}"
  
  # Only consider NT hashes shared by more than one user
  if [[ $(echo "$users" | wc -w) -gt 1 ]]; then
    # Write the delimiter line
    echo "-------" >> "$output_file"
    
    # Write each user and their NT hash, marking admins if necessary
    for user in $users; do
      # Check if the user is a domain admin (case-insensitive match)
      if [[ -n "${domain_admins[$user]}" ]]; then
        echo "$user:$nt_hash #Administrator account!" >> "$output_file"
      else
        echo "$user:$nt_hash" >> "$output_file"
      fi
    done
  fi
done

echo "Output written to $output_file"
