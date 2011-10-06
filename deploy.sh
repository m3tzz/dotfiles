#!/usr/bin/env bash
set -e

OLDDIR=~/.old_dotfiles
WD=$(pwd)
dotfiles=(bashrc vimrc gitconfig hgrc)

function regular_file {
    [[ -e $1 ]] || return 1
    [[ $(stat -c %F $1) = "regular file" ]]
    return $?
}

function deployed_file {
    [[ -h ~/.$1 && $(readlink ~/.$1) = $WD/$1 ]]
    return $?
}

function apply {
    [[ -z $OLDDIR ]] && return 1

    if [[ -d $OLDDIR ]]; then
        echo "Dotfiles already deployed!"
        return 1
    else
        mkdir $OLDDIR
    fi

    for file in ${dotfiles[*]}; do
        echo -n "Deploying $file..."
        if regular_file ~/.$file; then
            mv ~/.$file $OLDDIR/$file
            ln -s $WD/$file ~/.$file
            echo "done"
        else
            echo "skipped"
        fi
    done
}

function revert {
    [[ -z $OLDDIR ]] && return 1

    if [[ ! -d $OLDDIR ]]; then
        echo "Can't revert to old dotfiles!"
        return 1
    fi

    for file in ${dotfiles[*]}; do
        echo -n "Reverting $file..."
        if deployed_file $file; then
            rm ~/.$file
            [[ -f "$OLDDIR/$file" ]] && mv $OLDDIR/$file ~/.$file
            echo "done"
        else
            echo "skipped"
        fi
    done

    [[ -z $(ls -A $OLDDIR) ]] && rmdir $OLDDIR
}

function usage {
    echo "$0 <action>"
    echo ""
    echo -e "\tapply\tapply dotfiles"
    echo -e "\trevert\trevert to old dotfiles"
    echo ""
}

case $1 in
    apply) apply;;
    revert) revert;;
    *) usage;;
esac

