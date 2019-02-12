#!/bin/bash
#
# Email addresses of those responsible for some of the webpages.
# An email will be sent to them when their webpages are unreachable.

declare -Ar EMAILS=(
	#
	#  Add '' strings to prevent spam: 'use''r@mym''ail.com'
	#
	['blog.wikimedia.es']='platon''ides@gma''il.com'
	['wikiba.se']='dav''idab''ian@wikim''edia.es'
	['wikilov.es']='platon''ides@gma''il.com'
	['wikimedia.es']='platon''ides@gma''il.com'
	['www.wikiba.se']='dav''idab''ian@wikim''edia.es'
	['www.wikilov.es']='platon''ides@gma''il.com'
	['www.wikimedia.es']='platon''ides@gma''il.com'
)
