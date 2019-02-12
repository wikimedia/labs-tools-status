#!/bin/bash
#
#  Copyright (C) 2016-2019, David Abián and contributors
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

declare -r -- LTSA_ROOT_PATH='..'
declare -r -- LTSA_CONFIG_PATH="${LTSA_ROOT_PATH}/config"

readarray -t -- CHAPTERS < "${LTSA_CONFIG_PATH}/chapters.txt"
readarray -t -- THEMATIC_ORGS < "${LTSA_CONFIG_PATH}/thematic_orgs.txt"
readarray -t -- USER_GROUPS < "${LTSA_CONFIG_PATH}/user_groups.txt"
readarray -t -- CONTESTS < "${LTSA_CONFIG_PATH}/contests.txt"
readarray -t -- MISC < "${LTSA_CONFIG_PATH}/misc.txt"

declare -r -- ALL_WEBPAGES=(
	$(echo ${CHAPTERS[*]})
	$(echo ${THEMATIC_ORGS[*]})
	$(echo ${USER_GROUPS[*]})
	$(echo ${CONTESTS[*]})
	$(echo ${MISC[*]})
)

source -- "${LTSA_CONFIG_PATH}/settings.sh"
source -- "${LTSA_CONFIG_PATH}/owner_emails.sh"

raise_warning() {
	echo "WARNING: $1" >&2
}

print_html_ok() {
	echo "<td class=\"status status-ok\"><div class=\"status-scrolling\">$1</div></td>"
	return 0
}

print_html_error() {
	content="$1"
	if [[ "x$content" == "x" ]]; then
		content="Unreachable"
	fi
	echo "<td class=\"status status-error\"><div class=\"status-scrolling\">$content</div></td>"
	return 1
}

print_html_table_start() {
	echo "<h2 id=\"$1\">$1</h2>"
	echo "<table>"
	echo "<tr>"
	echo -n "<th>webpage</th><th class=\"column_http\">HTTP&nbsp;details</th>"
	echo "<th class=\"column_https\">HTTPS&nbsp;details</th>"
	echo "</tr>"
}

print_html_table_end() {
	echo '</table>'
}

print_html_status() {
	declare -r LTSA_CURL_ERROR_CODE_ON_TIMEOUT=124
	status=$(timeout $((LTSA_CURL_TIMEOUT_SECONDS*4))s curl -s --head \
		--user-agent "$LTSA_CURL_USER_AGENT" \
		--referer "$LTSA_CURL_REFERER" \
		--location \
		--retry $LTSA_CURL_RETRIES \
		--max-time $LTSA_CURL_TIMEOUT_SECONDS \
		-- "$1")
	if [[ $? -eq ${LTSA_CURL_ERROR_CODE_ON_TIMEOUT} ]]; then
		status="Timeout (${LTSA_CURL_TIMEOUT_SECONDS}&nbsp;s)"
	else
		status=$(echo "$status" | \
			sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' | \
			sed ':a;N;$!ba;s/\n/<br>/g')
	fi
	echo "$status" | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null && \
		print_html_ok "$status" || print_html_error "$status"
}

print_html_item() {
	item=$1
	email_address=$2
	echo "<tr id=\"${item}\">"
	echo "<td class=\"item\"><a href=\"http://${item}\" target=\"_blank\">${item}</a></td>"
	print_html_status "http://${item}" || \
		if [[ "x$email_address" != "x" ]]; then
			echo "Subject: WARNING: $item is unreachable

				Hi,

				We've detected that http://${item} may be down right now. Please check out.

				Regards,
				your friendly Wikimedia status checker

				-- 
				https://tools.wmflabs.org/status/
				Checking the availability of Wikimedia-related webpages not hosted by the Wikimedia Foundation, Inc.
				" | \
				sed -e 's/^[ \t]*//' | \
				/usr/sbin/exim -odf -i "${email_address}"
		fi
	print_html_status "https://${item}"
	echo "</tr>"
}

is_webpage_in_list() {
	local page match="$1"
	shift
	for page; do
		[[ "$page" == "$match" ]] && return 0
	done
	return 1
}

main() {
	for webpage in "${!EMAILS[@]}"; do
		is_webpage_in_list "$webpage" "${ALL_WEBPAGES[@]}" || \
		raise_warning "$webpage will not be checked because it's not listed in any file in ${LTSA_CONFIG_PATH}/."
	done
	for webpage in $(for i in "${LTSA_CONFIG_PATH}"/*.txt; do
		cat "$i"; echo; done | sort | uniq -d)
	do
		raise_warning "$webpage is listed more than once in one or more files in ${LTSA_CONFIG_PATH}/."
	done
	echo '<!DOCTYPE html>'
	echo '<html>'
	echo '<head>'
	echo '<meta charset="UTF-8">'
	echo '<title>Availability of Wikimedia-related webpages</title>'
	echo '<link rel="stylesheet" type="text/css" href="./status.css">'
	echo '</head>'
	echo '<body>'
	echo '<div class="related-links">'
	echo '<a href="https://gerrit.wikimedia.org/r/#/admin/projects/labs/tools/status,branches">source&nbsp;code</a> - '
	echo '<a href="https://meta.wikimedia.org/wiki/User_talk:Abi%C3%A1n">contact</a> - '
	echo '<a href="https://tools.wmflabs.org/?list">more&nbsp;tools</a>'
	echo '</div>'
	echo '<h1>Availability of Wikimedia&nbsp;webpages not&nbsp;hosted' \
		'by&nbsp;the&nbsp;WMF</h1>'

	print_html_table_start "Wikimedia chapters"
	for item in ${CHAPTERS[*]}
	do print_html_item "$item" "${EMAILS[$item]}"
	done
	print_html_table_end

	print_html_table_start 'Wikimedia thematic organizations'
	for item in ${THEMATIC_ORGS[*]}
	do print_html_item "$item" "${EMAILS[$item]}"
	done
	print_html_table_end

	print_html_table_start 'Wikimedia user groups'
	for item in ${USER_GROUPS[*]}
	do print_html_item "$item" "${EMAILS[$item]}"
	done
	print_html_table_end

	print_html_table_start 'Wikimedia contests'
	for item in ${CONTESTS[*]}
	do print_html_item "$item" "${EMAILS[$item]}"
	done
	print_html_table_end

	print_html_table_start 'More'
	for item in ${MISC[*]}
	do print_html_item "$item" "${EMAILS[$item]}"
	done
	print_html_table_end

	echo '</body>'
	echo '</html>'
}

main "$@"
