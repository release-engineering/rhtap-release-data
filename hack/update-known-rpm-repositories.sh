#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

cd "$(git rev-parse --show-toplevel)"

BASE_URL='https://access.redhat.com/security/data/meta/v1/repository-to-cpe.json'

# Update this variable for any additional repos that should be added to the list. This is a JSON
# formatted list, e.g.
#   export EXTRAS='[
#       "foo",
#       "bar",
#   ]'
# Having a comma on the last item is not necessarily valid JSON, but yq handles it well.
export EXTRAS='[
    "ubi-8-baseos-rpms",
    "ubi-8-baseos-debug-rpms",
    "ubi-8-baseos-source",
    "ubi-8-appstream-rpms",
    "ubi-8-appstream-debug-rpms",
    "ubi-8-appstream-source",
    "ubi-8-codeready-builder-rpms",
    "ubi-8-codeready-builder",
    "ubi-8-codeready-builder-debug-rpms",
    "ubi-8-codeready-builder-source",
    "ubi-9-baseos-rpms",
    "ubi-9-baseos-debug-rpms",
    "ubi-9-baseos-source",
    "ubi-9-appstream-rpms",
    "ubi-9-appstream-debug-rpms",
    "ubi-9-appstream-source",
    "ubi-9-codeready-builder-rpms",
    "ubi-9-codeready-builder",
    "ubi-9-codeready-builder-debug-rpms",
    "ubi-9-codeready-builder-source",
]'

export COMMENT='
This file is automatically generated by hack/update-repository-to-cpe.sh. Do not update it directly.
'

curl -L "${BASE_URL}" | \
    yq '.data |
        [to_entries[].key] as $repos |
        $repos + env(EXTRAS) | sort as $repos |
        {"rule_data": {"known_rpm_repositories": $repos}} |
        . head_comment=env(COMMENT)' > data/known_rpm_repositories.yml
