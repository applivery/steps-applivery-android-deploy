#!/bin/bash

THIS_SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function echoStatusFailed {
  envman add --key APPLIVERY_DEPLOY_STATUS --value "failed"
  echo
  echo 'APPLIVERY_DEPLOY_STATUS: "failed"'
  echo " --------------"
}


# IPA
if [ ! -f "${ipa_path}" ] ; then
  echo "# Error"
  echo "* No IPA found to deploy. Specified path was: ${ipa_path}"
  echoStatusFailed
  exit 1
fi

# App api_token
if [ -z "${api_token}" ] ; then
  echo "# Error"
  echo '* No App api_token provided as environment variable. Terminating...'
  echoStatusFailed
  exit 1
fi

echo
echo "========== Configs =========="
echo "* api_token: ${api_token}"
echo "* app_id: ${app_id}"
echo "* version_name: ${version_name}"
echo "* notes: ${notes}"
echo "* notify: ${notify}"
echo "* os: ${os}"
echo "* tags: ${tags}"
echo "* ipa_path: ${ipa_path}"
echo

###########################

curl_cmd="curl --fail"
curl_cmd="$curl_cmd -H \"Authorization: ${api_token}\""
curl_cmd="$curl_cmd -F \"app=${app_id}\""
curl_cmd="$curl_cmd -F \"versionName=${version_name}\""
curl_cmd="$curl_cmd -F \"notes=${notes}\""
curl_cmd="$curl_cmd -F \"notify=${notify}\""
curl_cmd="$curl_cmd -F \"os=${os}\""
curl_cmd="$curl_cmd -F \"tags=${tags}\""
curl_cmd="$curl_cmd -F \"package=@${ipa_path}\""
curl_cmd="$curl_cmd https://dashboard.applivery.com/api/builds"

echo
echo "=> Curl:"
echo '$' $curl_cmd
echo

json=$(eval $curl_cmd)
curl_res=$?

echo
echo " --- Result ---"
echo " * cURL command exit code: ${curl_res}"
echo " * response JSON: ${json}"
echo " --------------"
echo

if [ ${curl_res} -ne 0 ] ; then
  echo "# Error"
  echo '* cURL command exit code not zero!'
  echoStatusFailed
  exit 1
fi

# error handling
if [[ ${json} ]] ; then
  errors=`ruby "${THIS_SCRIPTDIR}/steps-utils-jsonval/parse_json.rb" \
  --json-string="${json}" \
  --prop=error`
  parse_res=$?
  if [ ${parse_res} -ne 0 ] ; then
     errors="Failed to parse the response JSON"
  fi
else
  errors="No valid JSON result from request."
fi

if [[ ${errors} ]]; then
  echo "# Error"
  echo "* ${errors}"
  echoStatusFailed
  exit 1
fi

# everything is OK

envman add --key "APPLIVERY_DEPLOY_STATUS" --value "success"


# final results
echo "# Success"
echo "* Deploy Result: **success**"

exit 0