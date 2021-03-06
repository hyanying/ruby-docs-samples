#!/bin/bash

for required_variable in                       \
	GOOGLE_CLOUD_PROJECT                   \
	GOOGLE_APPLICATION_CREDENTIALS         \
	GOOGLE_CLOUD_STORAGE_BUCKET            \
	ALTERNATE_GOOGLE_CLOUD_STORAGE_BUCKET  \
; do
	if [[ -z "${!required_variable}" ]]; then
		echo "Must set $required_variable"
		exit 1
	fi
done

script_directory="$(dirname "`realpath $0`")"
repo_directory="$(dirname $script_directory)"
status_return=0 # everything passed

# Print out Ruby version
ruby --version

while read product
do
	# Run Tets
	export TEST_DIR=$product
	echo "[$product]"
	pushd "$repo_directory/$product/"
	bundle install && bundle exec rspec --format documentation

	 # Check status of bundle exec rspec
	if [ $? != 0 ]; then
		status_return=1
	fi
	popd
done < <(find * -type d -name 'spec' -path "*/*" -not -path "*vendor/*" -exec dirname {} \;)

exit $status_return
