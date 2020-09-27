#!/bin/bash

OUTPUTFILE=$1

read -r -d '' statetmpl <<- EOM
AngryAssign_State = {
	["window"] = {
		["height"] = 500.000122070313,
		["top"] = 804.667053222656,
		["left"] = 549.332580566406,
		["width"] = 699.999877929688,
	},
	["locked"] = true,
	["display"] = {
		["y"] = 192.666748046875,
		["x"] = -101.997802734375,
		["point"] = "RIGHT",
		["scale"] = 1,
		["hidden"] = false,
	},
	["directionUp"] = false,
	["tree"] = {
		["groups"] = {},
		["scrollvalue"] = 0,
		["fullwidth"] = 665.999877929688,
		["selected"] = "SELECTED",
		["treewidth"] = 175,
		["treesizable"] = true,
	},
}
AngryAssign_Config = {
}
EOM

read -r -d '' pagetmpl <<- EOM
[PAGEID] = {
	["Updated"] = UPDATED,
	["Name"] = "NAME",
	["Id"] = PAGEID,
	["CategoryId"] = CATEGORYID,
	["Contents"] = "CONTENTS",
},
EOM

read -r -d '' grouptmpl <<- EOM
[ID] = {
  ["Id"] = ID,
  ["Name"] = "NAME",
},
EOM

a=($(find . -not -path '*/\.*' -type d | tail -n +2 | sed 's/\.\///'g))

echo "AngryAssign_Pages = {" > $OUTPUTFILE
for group in ${a[@]}; do
  groupid=$(echo "$RANDOM$RANDOM$RANDOM" | cut -c 1-10)
  agroupid+=($groupid)
  for file in $(find ./$group -type f); do
    pageid=$(echo "$RANDOM$RANDOM$RANDOM" | cut -c 1-10)
    apageid+=($pageid)
    updated=$(date +%s)
    contents=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' $file)
    categoryid=$groupid
    test=$(echo "$pagetmpl" | sed -e "s/PAGEID/$pageid/g" -e "s/NAME/$(basename $file|sed 's/\.txt//')/" -e "s/UPDATED/$updated/" -e "s/CATEGORYID/$categoryid/")
    page="${test/\CONTENTS/$contents}"
    echo "$page" >> $OUTPUTFILE
  done
done
echo "}" >> $OUTPUTFILE

echo "AngryAssign_Categories = {" >> $OUTPUTFILE
i=0
for group in ${a[@]}; do
  echo "$grouptmpl" | sed -e "s/ID/${agroupid[$i]}/g" -e "s/NAME/$group/" >> $OUTPUTFILE
  ((i++))
done
echo "}" >> $OUTPUTFILE

echo "$statetmpl" | sed -e "s/SELECTED/${apageid[0]}/" >> $OUTPUTFILE