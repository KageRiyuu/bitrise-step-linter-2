# Outdated Libs Stats

This step will create report about versions of used libraries.


## Required Params and Sample Values

You need to pass these param, all are required:

### Secure Params:

- GIT_ACCESS_TOKEN:                                 You can create in your bitbucket account settings.

### Normal Params;
- GIT_BASE_URL:                                     https://gitpub.mydomain.com
- GIT_PROJECT:                                      My-MOBILE
- GIT_REPO:                                         app-ios
- TEAM_LEAD_GIT_NAME:                               kage.ryu
- BRANCH_CONDITION:                                 [feature/*|bugfix/*|refactor/*]  (Regular Expression)

## Outputs
- AUTO_LINT_PR:                                     https://gitpub.rakuten-it.com/projects/RMS-MOBILE/repos/rms-ios/pull-requests/478

## How to use this Step

Add this in your bitrise.yml file and replace proper variables:

```
- git::https://github.com/EC-Mobile/bitrise-step-linter.git@main:
    title: PR Creator
    inputs:
    - GIT_BASE_URL: https://gitpub.rakuten-it.com
    - GIT_ACCESS_TOKEN: <Variable>
    - GIT_PROJECT: <Project>
    - GIT_REPO: <Repo>
    - TEAM_LEAD_GIT_NAME: <Variable>
    - BRANCH_CONDITION: <Variable>
```