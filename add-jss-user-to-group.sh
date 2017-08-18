#!/bin/bash

# Attach user to static group from CSV file

# Variables go here

apiuser="admin"
apipass="admin"
csvloc="/path/to/testdata.csv"

jssurl=$( /usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url )
tmpxmlloc="/var/tmp"

# Does the csv file exist?
[ ! -f $csvloc ] && { echo "$csvloc file not found"; exit 99; }

# Loop around CSV file. Reading record line by line.
# Have to do a test to make sure we get the last line. Missing newline characters cause that fault.
# I blame Excel for this.
while IFS=$'\r', read -r user group || [ -n "$user" ]
do
	# Remove the carriage return, if it exists. Again I blame Excel for this hack.
	username=$( echo $user | tr -d '\r' )
	groupname=$( echo $group | tr -d '\r' )

	# Does group xml file exist? It not, create!
	if [ ! -f "$tmpxmlloc/${groupname}.xml" ];
	then
cat <<EOF > "${tmpxmlloc}/${groupname}.xml"
<user_group>
  <name>$groupname</name>
  <is_smart>false</is_smart>
  <is_notify_on_change>false</is_notify_on_change>
  <users>
EOF
	fi

	# Append to xml file record
cat <<EOF >> "$tmpxmlloc/${groupname}.xml"
    <user>
      <username>$username</username>
    </user>
EOF

# And loop around until done.
done < "$csvloc"

# Find all the xml files, append the ending tags
find ${tmpxmlloc} -name '*.xml' | while IFS=$'\n' read file
do

	cat <<EOF >> "${file}"
  </users>
</user_group>
EOF

	# curl the file to the JSS API
	curl -X POST -k -u ${apiuser}:${apipass} ${jssurl}JSSResource/usergroups/id/0 -d @"${file}" -H "Content-Type:text/xml"

	# Delete the temp file
	rm "${file}"

done

# All done!
echo "Upload complete"