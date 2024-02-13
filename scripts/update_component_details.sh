#!/bin/bash
# This command updates depedent component commit id's to components.json file

SCRIPT_DIR=$(dirname $0)
ROOT_PATH=$(realpath $SCRIPT_DIR/..)

# as of now, maintaining commit id's of develop branch
TARGET_BRANCH="develop"

# gitlab project id's
PROJECT_B_ID=""
PROJECT_C_ID=""
PROJECT_D_ID=""

# fetches commit id of target branch of corresponding repo
# updates commit id to components.json file
update_commit_id_and_message() {
  echo "Fetching $TARGET_BRANCH branch details of $1 repo"
  commitdetails=$(curl --header "PRIVATE-TOKEN: $3" --url "$PROJECT_URL/$2/repository/commits/$TARGET_BRANCH" 2>/dev/null)
  commitid=$(echo $commitdetails | jq -r '.id')
  commitmessage=$(echo $commitdetails | jq -r '.message')

  contents="$(jq ".deps.$1.commit_id = \"$commitid\"" $ROOT_PATH/config/components.json)"
  echo "$contents" > $ROOT_PATH/config/components.json

  contents="$(jq ".deps.$1.commit_message = \"$commitmessage\"" $ROOT_PATH/config/components.json)"
  echo "$contents" > $ROOT_PATH/config/components.json
}

PROJECT_A_version() {
  contents="$(jq ".frontend_client = \"$1\"" $ROOT_PATH/config/components.json)"
  echo "$contents" > $ROOT_PATH/config/components.json
}

PROJECT_A_version $1
update_commit_id_and_message PROJECT_B $PROJECT_B_ID $PROJECT_B_API_KEY
update_commit_id_and_message PROJECT_C $PROJECT_C_ID $PROJECT_C_API_KEY
update_commit_id_and_message protocol $PROJECT_D_ID $PROJECT_D_API_KEY

cat $ROOT_PATH/config/components.json
