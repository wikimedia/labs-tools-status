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

declare -r -- RANDOM_ID=$(date +%N)$(date +%N)
declare -r -- PUBLIC_HTML_PATH='../public_html'

./get_status.sh > "${PUBLIC_HTML_PATH}/status_0${RANDOM_ID}.html" && \
	cp "${PUBLIC_HTML_PATH}/status_0${RANDOM_ID}.html" "${PUBLIC_HTML_PATH}/index.html" && \
	rm "${PUBLIC_HTML_PATH}/status_0${RANDOM_ID}.html"
