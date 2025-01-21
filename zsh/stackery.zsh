alias stackery="nocorrect stackery"

alias          stackery-dev='_STACKERY_ENV=dev _STACKERY_CONFIG=~/.stackery.test.toml AWS_PROFILE=test stackery'
alias stackery-dev-localcli='_STACKERY_ENV=dev _STACKERY_CONFIG=~/.stackery.test.toml AWS_PROFILE=test ~/dev/stackery-cli/stackery'
alias         stackery-test='_STACKERY_ENV=apurva _STACKERY_CONFIG=~/.stackery.test.toml AWS_PROFILE=test stackery'
alias       stackery-apurva='_STACKERY_ENV=stg1 _STACKERY_CONFIG=~/.stackery.apurva.toml AWS_PROFILE=apurva stackery'
alias         stackery-stg1='_STACKERY_ENV=stg2 _STACKERY_CONFIG=~/.stackery.stg1.toml AWS_PROFILE=stg1 stackery'
alias    stackery-stg1-test='_STACKERY_ENV=stg1 _STACKERY_CONFIG=~/.stackery.stg1-test.toml AWS_PROFILE=stg1_test stackery'
alias         stackery-stg2='_STACKERY_ENV=stg1 _STACKERY_CONFIG=~/.stackery.stg2.toml AWS_PROFILE=stg2 stackery'
alias   stackery-stg2-tests='_STACKERY_ENV=stg2 _STACKERY_CONFIG=~/.stackery.stg2-tests.toml AWS_PROFILE=stg2_tests stackery' # For deploy tests
alias         stackery-prod='_STACKERY_ENV=stg1 _STACKERY_CONFIG=~/.stackery.prod.toml AWS_PROFILE=prod stackery'
alias    stackery-prod-test='_STACKERY_CONFIG=~/.stackery.prod-test.toml AWS_PROFILE=prod_test stackery'
alias  stackery-integration='_STACKERY_ENV=stg1 _STACKERY_CONFIG=~/.stackery.integration.toml AWS_PROFILE=integration stackery'
alias      stackery-matthew='_STACKERY_ENV=matthew STACKERY_USER_POOL_ID=us-west-2_0fsquJeEW STACKERY_USER_POOL_CLIENT_ID=4qvsnnbah504eb62dc8tl06u7p _STACKERY_CONFIG=~/.stackery.matthew-test.toml AWS_PROFILE=matthew_test stackery'

# Defaults for adasql
export ADASQL_SECRET=/development/stackery/Database/StackeryUser
export ADASQL_DATABASE=stackery

alias knex-local='AWS_PROFILE=apurva AWS_REGION=us-west-2 DB_ARN=arn:aws:rds:us-west-2:286372004415:cluster:stackery-260964759067125-db-1em9s67ernifh DB_ROOT_SECRET_ARN=arn:aws:secretsmanager:us-west-2:286372004415:secret:/development/stackery/Database/RootUser-urk1Nf knex'

# Variables needed for stackery-auth
export STACKERY_USER=apurva@stackery.io
export STACKERY_ENV_APURVA_AWS_ACCOUNT_ID=286372004415
export STACKERY_ENV_APURVA_PERSONAL_AWS_ACCOUNT_ID=652595090181
export STACKERY_ENV_TEST_AWS_ACCOUNT_ID=546975405407 # apurva-app - apurva+test
export STACKERY_ENV_TEST_SECOND_AWS_ACCOUNT_ID=674438015255 # apurva-app - apurva+test (2nd account)
# export STACKERY_ENV_TEST_DEMO_AWS_ACCOUNT_ID=668399881826
export STACKERY_ENV_TEST_NEWUSER1_AWS_ACCOUNT_ID=013069676273 # apurva-app - apurva+test+newuser1 // WAS TEST_2
export STACKERY_ENV_TEST_3_AWS_ACCOUNT_ID=743930498604 # apurva-app - apurva+test+3
export STACKERY_ENV_TEST_4_AWS_ACCOUNT_ID=737008526319 # apurva-app - apurva+test+4
export STACKERY_ENV_TEST_2_AWS_ACCOUNT_ID=928767774333 # apurva-app - apurva+test+2 // WAS TEST_5
export STACKERY_ENV_TEST_6_AWS_ACCOUNT_ID=245220578758 # apurva-app - apurva+test+6
export STACKERY_ENV_TEST_6_2_AWS_ACCOUNT_ID=177579719349 # apurva-app - apurva+test+6 (2nd account)
# export STACKERY_ENV_TEST_8_AWS_ACCOUNT_ID=955018955715
# export STACKERY_ENV_TEST_9_AWS_ACCOUNT_ID=281788060994 # apurva-app - use for testing throw-away accounts
export STACKERY_ENV_INTEGRATION_TEST_2_AWS_ACCOUNT_ID=664333367572
export STACKERY_ENV_INTEGRATION_TEST_3_AWS_ACCOUNT_ID=578406869357
export STACKERY_ENV_STG3_AWS_ACCOUNT_ID=987335807188
export STACKERY_ENV_TOOL_PROD_AWS_ACCOUNT_ID=651245977304
export STACKERY_ENV_PROD2_AWS_ACCOUNT_ID=127080087723
export STACKERY_ENV_PROD_TEST_AWS_ACCOUNT_ID=732223013839
# export STACKERY_ENV_PROD_TEST_5_AWS_ACCOUNT_ID=697660444500
export STACKERY_ENV_DEMOWARE_AWS_ACCOUNT_ID=766340742256
export STACKERY_ENV_STG1_TEST_AWS_ACCOUNT_ID=710722451622
export STACKERY_ENV_STG2_TESTS_AWS_ACCOUNT_ID=768826615389
export STACKERY_ENV_STG2_TEST_AWS_ACCOUNT_ID=768826615389 # Same as STG2_TESTS but this nameing convention is needed for cypress tests
# export STACKERY_ENV_DANIELLE_TEST_AWS_ACCOUNT_ID=108031521608
# export STACKERY_ENV_MATTHEW_TEST_AWS_ACCOUNT_ID=556177684213
export STACKERY_ENV_AUDIT_AWS_ACCOUNT_ID=768727794282
export STACKERY_CREDS_DEFAULT_ENVS=prod,stg1,stg2,apurva,test

# # Update GOPATH for Stackery CLI
export GOPATH="/Users/ajantrania/Documents/work/Stackery/codebase/cli"