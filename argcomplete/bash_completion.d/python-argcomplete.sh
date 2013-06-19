# Copyright 2012-2013, Andrey Kislyuk and argcomplete contributors.
# Licensed under the Apache License. See https://github.com/kislyuk/argcomplete for more info.

_python_argcomplete_getalias () 
{ 
    local a;
    if alias $1 > /dev/null 2> /dev/null; then
        a=$(alias $1 2>&1);
        a=${a#alias $1=\'};
        a=${a%\'};
        echo $a;
    else
        echo $1;
    fi
}


_python_argcomplete_global() {
    local ARG1="$(_python_argcomplete_getalias "$1" | awk '{ print $1 ; }')"
    local ARGCOMPLETE=0
    if [[ "$ARG1" == python* ]] || [[ "$ARG1" == pypy* ]]; then
        if [[ -f "${COMP_WORDS[1]}" ]] && (head -c 1024 "${COMP_WORDS[1]}" | grep --quiet "PYTHON_ARGCOMPLETE_OK") >/dev/null 2>&1; then
            local ARGCOMPLETE=2
            set -- "${COMP_WORDS[1]}"
        fi
    elif (which "$ARG1" && head -c 1024 $(which "$ARG1") | grep --quiet "PYTHON_ARGCOMPLETE_OK") >/dev/null 2>&1; then
        local ARGCOMPLETE=1
    elif (which "$ARG1" && head -c 1024 $(which "$ARG1") | egrep --quiet "(EASY-INSTALL-SCRIPT|EASY-INSTALL-ENTRY-SCRIPT)" \
        && python-argcomplete-check-easy-install-script $(which "$ARG1")) >/dev/null 2>&1; then
        local ARGCOMPLETE=1
    fi

    if [[ $ARGCOMPLETE == 1 ]] || [[ $ARGCOMPLETE == 2 ]]; then
        local IFS=$(echo -e '\v')
        COMPREPLY=( $(_ARGCOMPLETE_IFS="$IFS" \
            COMP_LINE="$COMP_LINE" \
            COMP_POINT="$COMP_POINT" \
            COMP_WORDBREAKS="$COMP_WORDBREAKS" \
            _ARGCOMPLETE=$ARGCOMPLETE \
            "$ARG1" 8>&1 9>&2 1>/dev/null 2>&1) )
        if [[ $? != 0 ]]; then
            unset COMPREPLY
        fi
    fi
}
complete -o nospace -o default -D -F _python_argcomplete_global
