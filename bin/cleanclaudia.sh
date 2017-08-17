#!/bin/sh

usage() {
        echo `basename $0`: ERROR: $* 1>&2
        echo usage: `basename $0` [base_package_name]  [aws_profile_name] '  - Cleanup claudia roles  removing roles, and policies' 1>&2
        exit 1
}

if [ -z "$2" ]; then
  usage
  exit 1
else
export AWS_DEFAULT_REGION="us-east-1"
export AWS_DEFAULT_PROFILE=$2
fi


echo "Running profile: $AWS_DEFAULT_PROFILE"

#Initialization of variables
roleName="${1}-executor"
awsFunction=$1

echo $roleName
echo $awsFunction

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

