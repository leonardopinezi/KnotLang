#!/usr/bin/env bash
file="$1"
jmp=0

stack=()
declare -A labels

push() {
    stack+=("$1")
}

pop() {
    unset 'stack[-1]'
}

add() {
    a="${stack[-1]}"
    pop
    b="${stack[-1]}"
    pop
    push $(( a + b ))
}

sub() {
    a="${stack[-1]}"
    pop
    b="${stack[-1]}"
    pop
    push $(( a - b ))
}

swap() {
    a="${stack[-1]}"
    pop
    b="${stack[-1]}"
    pop
    push "$a"
    push "$b"
}

tochar() {
    a="${stack[-1]}"
    pop
    ch=$(printf "\\$(printf '%03o' "$a")")
    push "$ch"
}

prints() {
    str=""
    id=$((${#stack[@]} - 1))
    while [[ "${stack[id]}" -ne 0 ]]; do
        tochar
        str="$str${stack[id]}"
        pop
        id=$(( id - 1))
    done
    echo -n "$str"
    echo -n 
}

lineno=0
while IFS= read -r line; do
    lineno=$((lineno + 1))
    if [[ "$line" =~ ^\:([a-zA-Z0-9_]+)$ ]]; then
        label="${BASH_REMATCH[1]}"
        labels["$label"]=$lineno
    fi
done < "$file"



lines=()
mapfile -t lines < "$file"
lineno=0

while (( lineno < ${#lines[@]} )); do
    line="${lines[$lineno]}"
    lineno=$((lineno + 1))

    if [[ "$jmp" -eq 1 ]]; then
        jmp=0
        continue
    fi

    if [[ "$line" == end ]]; then
        break
    elif [[ "$line" =~ ^[0-9]+$ ]]; then
        push "$line"
    elif [[ "$line" == print ]]; then
        last_index=$((${#stack[@]} - 1))
        echo "${stack[$last_index]}"
    elif [[ "$line" == prints ]]; then
        prints
    elif [[ "$line" == add ]]; then
        add
    elif [[ "$line" == sub ]]; then
        sub
    elif [[ "$line" =~ ^jmp[[:space:]]+([a-zA-Z0-9_]+)$ ]]; then 
        target="${BASH_REMATCH[1]}"
        if [[ -n "${labels[$target]}" ]]; then
            lineno=$(( labels[$target] ))
        else
            echo "Error: label '$target' not found" >&2
            exit 1
        fi
    elif [[ "$line" =~ ^if=[[:space:]]*([0-9]+)$ ]]; then
        val="${BASH_REMATCH[1]}"
        last_index=$((${#stack[@]} - 1))
        top="${stack[$last_index]}"

        if [[ "$top" != "$val" ]]; then
            jmp=1
        fi
    elif [[ "$line" =~ ^if\![[:space:]]*([0-9]+)$ ]]; then
        val="${BASH_REMATCH[1]}"
        last_index=$((${#stack[@]} - 1))
        top="${stack[$last_index]}"

        if [[ "$top" == "$val" ]]; then
            jmp=1
        fi
    elif [[ "$line" == read ]]; then
        entry=""
        read -p ">" entry
        push entry
    elif [[ "$line" == swap ]]; then
        swap
    elif [[ "$line" == tochar ]]; then
        tochar
    elif [[ "$line" == cls ]]; then
        clear
    elif [[ "$line" =~ ^pushs[[:space:]]+(.+)$ ]]; then
        push 0
        push 11
        push 13
        str="${BASH_REMATCH[1]}"
        for (( i=${#str}-1; i>=0; i-- )); do
            char="${str:$i:1}"
            ascii=$(printf '%d' "'$char")
            push "$ascii"
        done;
    fi
done