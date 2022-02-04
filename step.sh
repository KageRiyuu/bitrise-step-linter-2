function createPR() {
    echo "Creating PR on Bitbucket Repo: ${GIT_BASE_URL} -> ${GIT_PROJECT} -> ${GIT_REPO} with details: "
    echo "- Title: ${PR_TITLE}"
    echo "- Description: ${PR_DESCRIPTION}"
    echo "- Source Branch: ${BRANCH_FROM}"
    echo "- Target Branch: ${BRANCH_TO}"
    echo "- Reviewer: ${TEAM_LEAD_GIT_NAME}"

    echo "Calling bitbucket create PR API..."
    response=$(curl --location --request POST "${GIT_BASE_URL}/rest/api/1.0/projects/${GIT_PROJECT}/repos/${GIT_REPO}/pull-requests" \
    --header "Authorization: Bearer ${GIT_ACCESS_TOKEN}" \
    --header 'Content-Type: application/json' \
    --data-raw "{
        \"title\": \"${PR_TITLE}\",
        \"description\": \"${PR_DESCRIPTION}\",
        \"state\": \"OPEN\",
        \"open\": true,
        \"closed\": false,
        \"fromRef\": {
            \"id\": \"${BRANCH_FROM}\",
            \"repository\": {
                \"slug\": \"${GIT_REPO}\",
                \"name\": null,
                \"project\": {
                    \"key\": \"${GIT_PROJECT}\"
                }
            }
        },
        \"toRef\": {
            \"id\": \"${BRANCH_TO}\",
            \"repository\": {
                \"slug\": \"${GIT_REPO}\",
                \"name\": null,
                \"project\": {
                    \"key\": \"${GIT_PROJECT}\"
                }
            }
        },
        \"locked\": false,
        \"reviewers\": [
            {
                \"user\": {
                    \"name\": \"${TEAM_LEAD_GIT_NAME}\"
                }
            }
        ]
    }")
    echo "------------------------ ------------------------------"
    echo "$response"
    echo "PR creation complete...."

    PATTERN="$GIT_BASE_URL/projects/$GIT_PROJECT/repos/$GIT_REPO/pull-requests/[0-9]*"
    AUTO_LINT_PR=($(echo "$response" | grep -Eo -1 "$PATTERN"))
    echo "$AUTO_LINT_PR"
}

# ----------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------
# Test Values
# export BRANCH_CONDITION=".*"
# export TEAM_LEAD_GIT_NAME="bilal.a.ahmad"
# export GIT_BASE_URL="https://gitpub.rakuten-it.com"
# export GIT_PROJECT="RMS-MOBILE"
# export GIT_REPO="rms-ios"
# export GIT_ACCESS_TOKEN=""

echo "Preparing Branch..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch is: ${CURRENT_BRANCH}"

if ! [[ ${CURRENT_BRANCH} =~ ${BRANCH_CONDITION} ]]; then
    echo "This branch does not match condtion: $BRANCH_CONDITION"
    exit 0
fi

if [[ "$CURRENT_BRANCH" == *"autolint"* ]]; then
    echo "This is an auto lint branch..."
    exit 0
fi

FIX_BRANCH="${CURRENT_BRANCH}-autolint"
echo "Fix branch is: ${FIX_BRANCH}"

git branch -D $FIX_BRANCH
git push origin --delete $FIX_BRANCH

SWIFT_LINT="./Pods/SwiftLint/swiftlint"
if which "${SWIFT_LINT}" >/dev/null; then
    echo "Linting..."
    echo "--------------------------------------------"
    git checkout -b $FIX_BRANCH
    "${SWIFT_LINT}" --fix
    echo "--------------------------------------------"
else
   echo "warning: SwiftLint not integrated..."
fi

git diff-index --quiet HEAD -- || {
    echo "Found changes after lint !"
    git commit -a -m "Applied fixable lint issues using Swift Lint." # -a is to commit only modified and deleted files
    git push --set-upstream origin $FIX_BRANCH

    echo "Creating PR..."
    echo "--------------------------------------------"
    PR_TITLE="[Merge With Care] Auto lint of ${CURRENT_BRANCH}"
    PR_DESCRIPTION="Applied auto lint to the branch: ${CURRENT_BRANCH}"
    BRANCH_FROM="${FIX_BRANCH}"
    BRANCH_TO="${CURRENT_BRANCH}"
    
    createPR
    echo "--------------------------------------------"
    envman add --key AUTO_LINT_PR --value "$AUTO_LINT_PR"
}

git reset --hard
git checkout $CURRENT_BRANCH