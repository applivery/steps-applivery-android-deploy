#!/bin/bash

echo "=> Starting Applivery Android Deploy"

THIS_SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function echoStatusFailed {
  envman add --key APPLIVERY_DEPLOY_STATUS --value "failed"
  echo
  echo 'APPLIVERY_DEPLOY_STATUS: "failed"'
  echo " --------------"
}

############# VALIDATIONS ##############

# IPA
if [ ! -f "${apk_path}" ] ; then
  echo "# Error"
  echo "* No APK found to deploy. Specified path was: ${apk_path}"
  echoStatusFailed
  exit 1
fi

# APPLIVERY API TOKEN
if [ -z "${APPLIVERY_API_TOKEN}" ] ; then
  echo "# Error"
  echo '* No App APPLIVERY_API_TOKEN provided as environment variable. Terminating...'
  echoStatusFailed
  exit 1
fi

# APPLIVER APP ID
if [ -z "${APPLIVERY_APP_ID}" ] ; then
  echo "# Error"
  echo '* No App APPLIVERY_APP_ID provided as environment variable. Terminating...'
  echoStatusFailed
  exit 1
fi

############# DEFINITIONS ##############

api_token="${APPLIVERY_API_TOKEN}"
app_id="${APPLIVERY_APP_ID}"

echo
echo "========== CONFIGS =========="
echo "* api_token: ********"
echo "* app_id: ${app_id}"
echo "* version_name: ${version_name}"
echo "* notes: ${notes}"
echo "* notify: ${notify}"
echo "* os: ${os}"
echo "* tags: ${tags}"
echo "* apk_path: ${apk_path}"
echo

###########################

curl_cmd="curl --fail"
curl_cmd="$curl_cmd -H \"Authorization: ${api_token}\""
curl_cmd="$curl_cmd -F \"app=${app_id}\""
curl_cmd="$curl_cmd -F \"versionName=${version_name}\""
curl_cmd="$curl_cmd -F \"notes=${notes}\""
curl_cmd="$curl_cmd -F \"notify=${notify}\""
curl_cmd="$curl_cmd -F \"os=android\""
curl_cmd="$curl_cmd -F \"tags=${tags}\""
curl_cmd="$curl_cmd -F \"package=@${apk_path}\""
curl_cmd="$curl_cmd https://dashboard.applivery.com/api/builds"

echo
echo "=> Curl:"
echo '$' $curl_cmd
echo

json=$(eval $curl_cmd)
curl_res=$?

echo
echo "========== RESULT =========="
echo " * cURL command exit code: ${curl_res}"
echo " * JSON response: ${json}"
echo "============================"
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
echo "* Deploy Result: Success"

exit 0