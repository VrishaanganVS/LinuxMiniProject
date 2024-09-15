#!/bin/bash

# Navigate to the src directory
cd src

# Ensure there are no malicious files
if [ -d "maliciousFiles" ]; then
  echo "Failed to generate secret. The directory 'maliciousFiles' contains some malicious files... it must be removed before."
  exit 1
fi

# Check if the .secret file exists in secretDir
if [ ! -f "secretDir/.secret" ]; then
  echo "Failed to generate secret. The directory 'secretDir' must contain a file '.secret' in which the secret will be stored."
  exit 1
fi

# Check if the .secret file has the correct permissions
OCTAL_PERMISSIONS=$(stat -c "%a" secretDir/.secret)
if [ "$OCTAL_PERMISSIONS" != "600" ]; then
  echo "Failed to generate secret. The file 'secretDir/.secret' must have read and write permission only."
  exit 1
fi

# Check for broken symbolic link
if [ -L 'important.link' ] && [ ! -e 'important.link' ]; then
  echo "Failed to generate secret. Secret can not be generated when a broken file link exists. Please fix it..."
  exit 1
fi

# Generate the secret by hashing the content of CONTENT_TO_HASH
cat ./CONTENT_TO_HASH | xargs | md5sum | awk '{print $1}' > secretDir/.secret

# Ensure the secret is 32 characters long
secret=$(cat secretDir/.secret)
if [ ${#secret} -eq 32 ]; then
    # Copy the secret into the SOLUTION file
    echo $secret > ../SOLUTION
    echo "Done! Your secret was stored in secretDir/.secret and copied to SOLUTION."
else
    echo "Failed: The generated secret is not 32 characters long."
    exit 1
fi
