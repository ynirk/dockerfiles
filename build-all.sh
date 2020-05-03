#!/usr/bin/env bash
# Based on @jessfraz work
set -e
set -o pipefail

REPO_URL="${REPO_URL:-ynirk}"

build_and_push(){
	base=$1
	suite=$2
	build_dir=$3

	echo "Building ${REPO_URL}/${base}:${suite} for context ${build_dir}"
	docker build --rm --force-rm -t ${REPO_URL}/${base}:${suite} ${build_dir} || return 1

	# on successful build, push the image
	echo "                       ---                                   "
	echo "Successfully built ${base}:${suite} with context ${build_dir}"
	echo "                       ---                                   "

	# try push a few times because notary server sometimes returns 401 for
	# absolutely no reason
	n=0
	until [ $n -ge 5 ]; do
		docker push ${REPO_URL}/${base}:${suite} && break
		echo "Try #$n failed... sleeping for 15 seconds"
		n=$[$n+1]
		sleep 15
	done

	# also push the tag latest for "stable" tags
	if [[ "$suite" == "stable" ]]; then
		docker tag ${REPO_URL}/${base}:${suite} ${REPO_URL}/${base}:latest
		docker push --disable-content-trust=${DCT} ${REPO_URL}/${base}:latest
	fi
}

dofile() {
	f=$1
	image=${f%Dockerfile}
	base=${image%%\/*}
	build_dir=$(dirname "$f")
	suite=${build_dir##*\/}

	if [[ -z "$suite" ]] || [[ "$suite" == "$base" ]]; then
		suite=latest
	fi

	build_and_push "${base}" "${suite}" "${build_dir}" || echo "${base}:${suite}" >> "$ERRORS"
}

main(){
	# get the dockerfiles
	IFS=$'\n'
	mapfile -t files < <(find -L . -iname '*Dockerfile' | sed 's|./||' | sort)
	unset IFS

	# build all dockerfiles
	for f in "${files[@]}"; do
		dofile $f
	done

	if [[ ! -f "$ERRORS" ]]; then
		echo "No errors, hooray!"
	else
		echo "[ERROR] Some images did not build correctly, see below." >&2
		echo "These images failed: $(cat "$ERRORS")" >&2
		exit 1
	fi
}

main $@
