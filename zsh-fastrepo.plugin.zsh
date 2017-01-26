
# check curdir for a .hg or .git or whatever
# then check parent.... over and over until you find one
# or dont
is_repo() {
    local repo=".$1"
    local path="$2"

    if [[ "$path" == '/' ]]; then
        return 1
    fi

    [[ -d "$path/$repo" ]] && echo "$path/$repo" && return 0
    if [[ -L "$path" ]]; then
        [[ -d "$(/bin/readlink $path)/$repo" ]]
        is_repo "$1" "$(/bin/readlink $path)"
    fi
    is_repo "$1" "$(/bin/dirname $path)"
}

git_fast_rev() {
    local gitdir="$1"
    basename $(grep -H $(git show-ref HEAD | cut -f1 -d ' ') "$gitdir"/refs/heads/* | cut -f1 -d:)
}

hg_fast_rev() {
    local hgdir="$1"
    local b="$hgdir/bookmarks.current"
    [[ -e "$b" ]] && cat "$hgdir/bookmarks.current"
}

alias is_hg='is_repo hg'
alias is_git='is_repo git'

fastrepo_current_bookmark() {
    local branch_info=''
    local hg_dir="$(is_hg `pwd`)"
    [[ -n "$hg_dir" ]] && branch_info="$(hg_fast_rev "$hg_dir")"

    local git_dir=$(is_git `pwd`)
    [[ ! -n $hg_dir ]] && [[ -n $git_dir ]] && branch_info=$(git_fast_rev "$git_dir")
    echo $branch_info
}
