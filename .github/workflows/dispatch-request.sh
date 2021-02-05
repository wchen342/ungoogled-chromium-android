#!/usr/bin/env bash
set -eu -o pipefail

data='{'\
'  "ref":"master",'\
'  "inputs": {'\
'    "github_ref":"'"${GITHUB_REF}"'",'\
'    "github_sha":"'"${GITHUB_SHA}"'"'\
'  }'\
'}'

# Chromium build request
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${PAT_TOKEN}" \
  https://api.github.com/repos/"${REPO_USERNAME}"/"${REPO_NAME}"/actions/workflows/"${WORKFLOW_NAME}".yml/dispatches \
  -d "${data}"
