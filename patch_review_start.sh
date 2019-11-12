#!/bin/bash -ex

curr_branch=$(git branch | grep "^* " | awk '{print $2}')
echo "${curr_branch}" > .orig_branch

base_branch="master"
if [ "X${curr_branch}" != "X" ]; then
	if (git branch | grep -qw "master.${curr_branch}"); then
		base_branch="master.${curr_branch}"
	fi
fi

/bin/rm -rf toreview
git format-patch ${base_branch} -o toreview
git co ${base_branch} -B reviewbranch

/bin/rm -rf toreview_work
mkdir toreview_work

/bin/rm -rf .data
mkdir .data
cat > .data/patchreview.prj << EOF
0
1
1
vimdiff
toreview
toreview_work
true
true
true
EOF

patchreview
