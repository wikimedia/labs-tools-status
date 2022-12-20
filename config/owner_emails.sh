#!/bin/bash
#
# Email addresses of those responsible for some of the webpages.
# An email will be sent to them when their webpages are unreachable.

pam=  # Egg, bacon, sausage and $pam? No, thanks
WMES=alertas$pam@wikimedia.es,'platon''ides@gma''il.com'

declare -Ar EMAILS=(
	#
	#  Add '' strings to prevent spam: 'use''r@mym''ail.com'
	#
	['wikiba.se']='lydia.pi''ntscher@wikimedia.de'

	['wikilov.es']=$WMES
	['wikimedia.es']=$WMES
	['wiki.wikimedia.es']=$WMES
	['servidor.wikimedia.es']=$WMES
	['listas.wikimedia.es']=$WMES
	['wikilm.es']=$WMES
	['wikilovesearth.es']=$WMES
	['www.wikilm.es']=$WMES
	['www.wikilov.es']=$WMES
	['www.wikilovesearth.es']=$WMES
	['www.wikimedia.es']=$WMES
)
