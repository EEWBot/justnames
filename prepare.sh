#!/bin/bash

MOBY_COMMIT="4adc40ac40b935e27cd539a11928413ddc10eff7"
REPO="https://github.com/moby/moby/raw/"
NAMES_GENERATOR_URI="${REPO}${MOBY_COMMIT}/pkg/namesgenerator/names-generator.go"
LICENSE_URI="${REPO}${MOBY_COMMIT}/LICENSE"

NAMES_GENERATOR=$(curl -L "${NAMES_GENERATOR_URI}")

function names_left() {
	echo "$NAMES_GENERATOR" |
		sed -E 's_.*//.*__g' |						# Remove '//' comment lines
		tr -d '\n' |								# Remove all newlines
		sed -E 's_.*left = \[...\]string\{__g' |	# Remove what's before "left = [...]string{"
		sed -E 's_}.*__' |							# Remove what's after "}"
		sed 's_,_,\n_g' |							# Insert back newlines
		tr -d '\t'									# Remove \t
}


function names_right() {
	echo "$NAMES_GENERATOR" |
		sed -E 's_.*//.*__g' |						# Remove '//' comment lines
		tr -d '\n' |								# Remove all newlines
		sed -E 's_.*right = \[...\]string\{__g' |	# Remove what's before "right = [...]string{"
		sed -E 's_}.*__' |							# Remove what's after "}"
		sed 's_,_,\n_g' |							# Insert back newlines
		tr -d '\t'									# Remove \t
}

left_n="$(names_left | wc -l)"
right_n="$(names_right | wc -l)"

(
	curl -L "${LICENSE_URI}" | awk '{ print "// " $0 }'
	echo "/// Generated left variable from <${NAMES_GENERATOR_URI}>"
	echo "pub const LEFT: [&'static str; $left_n] = ["
	names_left | awk '{ print "    " $1 }';
	echo "];"
	echo "/// Generated right variable from <${NAMES_GENERATOR_URI}>"
	echo "pub const RIGHT: [&'static str; $right_n] = ["
	names_right | awk '{ print "    " $1 }';
	echo "];"
) > src/lib.rs

curl -L "${LICENSE_URI}" > LICENSE
