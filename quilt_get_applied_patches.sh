#!/bin/bash 
SCRIPTPATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
. ${SCRIPTPATH}/config.sh

pdir=${1:-patches}

SHOW_FNAME_ONLY=${SHOW_FNAME_ONLY:-"0"}

pdir=$(readlink -f ${pdir})
if [ ! -e "${pdir}" ]; then
	echo "-E- patches folder does not exit !" >&2
	exit 1
fi

echo "Working with: ${pdir}"
echo

cd ${TREE}
for pp in $(grep "^[0-9]" ${pdir}/series)
do
	if [ "X${SHOW_FNAME_ONLY}" != "X0" ]; then
		echo "${pp}"
		continue
	fi
	subj=$(grep "Subject:" ${pdir}/${pp} 2>/dev/null)
	cid=
	if echo "${pp}" | grep -Eq '^[0-9]+-[a-zA-Z0-9]+.(diff|patch)'; then
		cid=$(echo ${pp} | sed -r -e 's/.*-(.*).(diff|patch)/\1/g')
	fi
	if [ "X${cid}" == "X" ]; then
		cid=$(grep "imported from commit" ${pdir}/${pp} | sed -e 's/.*commit //g' -e 's/).*//g')
	fi
	if [ "X${cid}" == "X" ]; then
		cid=$(grep "^commit " ${pdir}/${pp} | cut -d" " -f2)
	fi
	if [ "X${cid}" == "X" ]; then
		cid=$(grep "^From " ${pdir}/${pp} | cut -d" " -f2)
	fi
	if [ "X${cid}" == "X" ]; then
		echo "Failed to get commit ID of $pp (${subj}) !" >&2
		continue
		exit 1
	fi
	if !(git log -1 --oneline --no-decorate ${cid} 2>/dev/null); then
		echo "Failed to get info for: ${cid} (${subj})" >&2
		continue
		exit 1
	fi
#	echo "----------------------------------------------"
done
