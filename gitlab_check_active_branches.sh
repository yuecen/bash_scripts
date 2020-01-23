#!/bin/bash

api_site=https://gitlab.com/api/v4
token=<YOUR_PERSONAL_TOKEN>


list_groups() {
    curl --header "Private-Token: $token" -s "$api_site"/groups |
        jq --raw-output -c '.[]'
}

list_projects() {
    curl --header "Private-Token: $token" -s "$api_site"/groups/"$1"/projects |
        jq --raw-output -c '.[] | {id,name}'
}

find_current_active_branches() {
    # You can alter select query to filter results you want.
    curl --header "Private-Token: $token" -s "$api_site"/projects/"$1"/repository/branches |
        jq --raw-output -c '.[] |
            select(.name != "master") |
            select(.name != "development") |
            {name,merged}'
}

list_groups | while read -r group; do
    group_id=$(echo "$group" | jq --raw-output -c '.id')
    group_name=$(echo "$group" | jq --raw-output -c '.name')
    list_projects "$group_id" | while read -r project; do
        project_id=$(echo "$project" | jq --raw-output -c '.id')
        project_name=$(echo "$project" | jq --raw-output -c '.name')
        find_current_active_branches "$project_id" | while read -r branch; do
            branch_name=$(echo "$branch" | jq --raw-output -c '.name')
            merged=$(echo "$branch" | jq --raw-output -c '.merged')
            echo "$group_name > $project_name > $branch_name $([[ $merged =~ true ]] && echo "(merged)")"
        done
    done
done

