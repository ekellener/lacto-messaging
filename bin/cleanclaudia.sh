#!/bin/sh

# Disable and require env variables.
usage() {
        echo `basename $0`: ERROR: $* 1>&2
        echo usage: `basename $0`  [application_name] '  - Cleanup claudia roles  removing roles, and policies' 1>&2
        exit 1
}



# Need application stem name
if [ -z "$1" ]; then
  usage
  exit 1
fi

echo "${NODE_ENV:?Need to set NODE_ENV before proceeding}"
echo "${AWS_DEFAULT_PROFILE:?Need to set AWS_DEFAULT_PROFILE before proceeding}"
echo "${AWS_DEFAULT_REGION:?Need to set AWS_DEFAULT_REGION before proceeding}"


echo "Running"
echo "Profile: $AWS_DEFAULT_PROFILE"
echo "Region: $AWS_DEFAULT_REGION"
echo "Node Env: $NODE_ENV"

#Initialization of variables
roleName="${1}-executor"
awsFunction=$1

echo "Role: $roleName"
echo "Function: $awsFunction"

#Clean up Claudia
echo "***  Attempting to delete existing roles,policies, and aliases..(may see errors)."

roles=$(aws iam list-roles --query 'Roles[?RoleName==`'$roleName'`].RoleName' --output text)
for role in $roles; do
  echo deleting policies for role $role
  policies=$(aws iam list-role-policies --role-name=$role --query PolicyNames --output text)
  for policy in $policies; do
    echo deleting policy $policy for role $role
    aws iam delete-role-policy --policy-name $policy --role-name $role
  done
  echo deleting role $role
  aws iam delete-role --role-name $role
done

functions=$(aws lambda list-functions --query 'Functions[?FunctionName==`'$awsFunction'`].FunctionName' --output text)
for fn in $functions; do
  echo deleting function $functions
  aws lambda delete-function --function-name $functions
done


echo "All done..."

