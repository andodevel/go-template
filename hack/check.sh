#!/usr/bin/env bash

readonly reset=$(tput sgr0)
readonly red=$(tput setaf 1)
readonly green=$(tput setaf 2)
readonly yellow=$(tput setaf 3)

exit_code=0
check_scope=$1
if [[ "${check_scope}" = "all" ]]; then
    echo "all"
    files=($(git ls-files | grep "\.go" | grep -v -e "^third_party" -e "^vendor"))
else
    files=($(git diff --cached --name-only --diff-filter ACM | grep "\.go" | grep -v -e "^third_party" -e "^vendor"))
fi

echo -e "${green}1. Formatting using goimports"
if [[ "${#files[@]}" -ne 0 ]]; then
    goimports -w ${files[@]}
fi
if [[ $? -eq 0 ]]; then
  echo -e "${yellow}Done!"
fi 

echo -e "${green}2. Linting using golint"
for file in "${files[@]}"; do
    out=$(golint ${file})
    if [[ -n "${out}" ]]; then
        echo "${red}${out}"
        exit_code=1
    fi
done

if [[ ${exit_code} -ne 0 ]]; then
    echo "${red}Fix errors before commit!"
else
    echo "${yellow}Perfekt!"
fi
echo "${reset}"

exit ${exit_code}
