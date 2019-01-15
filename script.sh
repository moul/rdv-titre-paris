#!/bin/bash -e

# sites
# - 4eme = 29
# - 5eme = 45
# - 6eme = 48
# - 7eme = 46
# - 8eme = 37
# - 10eme = 40
# - 11eme = 47
# - 12eme = 24
# - 13eme = 7
# - 14eme = 10
# - 15eme = 3
# - 16eme = 26
# - 17eme = 38
# - 18eme = 1
# - 19eme = 25
# - 20eme = 30

SITES=(29   45  48  46  37  40  47  24  7   10  3   26  38  1   25  30)
MAIRIES=(4  5   6   7   8   10  11  12  13  14  15  16  17  18  19  20)
PARAMS=(214 538 782 554 390 437 776 263 287 321 211 262 400 212 213 288)


> output.txt
for (( i=0; i<=$(( ${#SITES[*]} -1 )); i++ )); do
    batchid=$(gshuf -i 100-200 -n1)
    param=${PARAMS[$i]}
    mairie=${MAIRIES[$i]}
    site=${SITES[$i]}
    cat <<EOF | sed "s/SITE/$site/" > post_data.tmp
callCount=1
page=/eAppointmentCNI-internet/element/jsp/appointment.jsp
httpSessionId=
scriptSessionId=DEFF2EBCC6759DBAF2F0B02B70608748684
c0-scriptName=AjaxSelectionFormFeeder
c0-methodName=getClosedDaysList
c0-id=0
c0-param0=boolean:false
c0-param1=string:site${site}
c0-param2=string:${param}
batchId=${batchid}
EOF
    echo "fetching: i=$i site=$site param=$param batchid=$batchid mairie=$mairie"
    #cat post_data.tmp
    curl -s 'https://rdv-titres.apps.paris.fr/eAppointmentCNI-internet/dwr/call/plaincall/AjaxSelectionFormFeeder.getClosedDaysList.dwr' -H 'Origin: https://rdv-titres.apps.paris.fr' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,fr;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36' -H 'Content-Type: text/plain' -H 'Accept: */*' -H 'Referer: https://rdv-titres.apps.paris.fr/eAppointmentCNI-internet/element/jsp/appointment.jsp' -H 'Cookie: JSESSIONID=46CDED71730206279751D656A5D05408' -H 'Connection: keep-alive' --data-binary @post_data.tmp --compressed | \
        grep --color=never 'dwr.engine._remoteHandleCallback' | \
        cat -e | \
        cut -d "[" -f2 | cut -d "]" -f1 | tr "," "\n" | \
        sed "s/\$/ ${mairie}eme/" | \
        tee -a output.txt
done

echo
echo "best:"
cat output.txt | sort | head -n 20
