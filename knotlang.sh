#!/usr/bin/env bash

file="$1"
jmp=0
returned=""

stack=()               # stack array
declare -A labels      # store labels
var_n=()               # variable names (array)
var_v=()               # variable values (array)

# --------------------
# Stack operations
# --------------------
push() { stack+=("$1"); }
pop() { unset 'stack[-1]'; }
swap() {
    a="${stack[-1]}"; pop
    b="${stack[-1]}"; pop
    push "$a"; push "$b"
}

# --------------------
# Variable operations
# --------------------
# get variable index
get_vi() {
    local name="$1"
    for i in "${!var_n[@]}"; do
        [[ "${var_n[i]}" == "$name" ]] && echo "$i" && return 0
    done
    echo -1
    return 1
}

# get variable value
get_v() {
    local idx
    idx=$(get_vi "$1")
    [[ "$idx" -ge 0 ]] && echo "${var_v[$idx]}" || echo ""
}

# set variable value from stack
set_v() {
    local name="$1"
    local value=""
    local idx
    idx=$(get_vi "$name")

    if [[ "$idx" -lt 0 ]]; then
        var_n+=("$name")
        var_v+=("")
        idx=$((${#var_n[@]} - 1))
    fi

    local a=$((${#stack[@]} - 1))
    while [[ $a -ge 0 && "${stack[a]}" != 0 ]]; do
        value="$value$(printf \\$(printf '%03o' "${stack[a]}"))"
        a=$((a - 1))
    done

    var_v[$idx]="$value"
}

# --------------------
# Arithmetic
# --------------------
add() {
    a="${stack[-1]}"; pop
    b="${stack[-1]}"; pop
    push $(( a + b ))
}
sub() {
    a="${stack[-1]}"; pop
    b="${stack[-1]}"; pop
    push $(( a - b ))
}
rand() {
    local seed
    local max
    if [[ "${#stack[@]}" -gt 0 ]]; then
        max="${stack[-1]}"
        pop
    else
        echo "Error: you need to push a max value in stack."
        push 0
        return
    fi

    if [[ "${#stack[@]}" -gt 0 ]]; then
        seed="${stack[-1]}"
        pop
    else
        seed=$(date +%s%N)
    fi

    local a=1664525
    local c=1013904223
    local m=4294967296

    local next=$(( (a * seed + c) % m ))
    next=$(( next % (max + 1) ))

    push $(( "$next" * -1 ))
}

# --------------------
# Conversion
# --------------------
tochar() {
    a="${stack[-1]}"; pop
    ch=$(printf "\\$(printf '%03o' "$a")")
    push "$ch"
}
toint() {
    a="${stack[-1]}"; pop
    ascii=$(printf "%d" "'$a")
    push "$ascii"
}

# --------------------
# Output
# --------------------
prints() {
    str=""
    id=$((${#stack[@]} - 1))
    while [[ "${stack[id]}" != 0 ]]; do
        tochar
        str="$str${stack[id]}"
        pop
        id=$(( id - 1 ))
    done
    echo "$str"
    pop
}

# --------------------
# Preprocess labels
# --------------------
lineno=0
while IFS= read -r line; do
    lineno=$((lineno + 1))
    if [[ "$line" =~ ^\:([a-zA-Z0-9_]+)$ ]]; then
        labels["${BASH_REMATCH[1]}"]=$lineno
    fi
done < "$file"

# --------------------
# Read all lines
# --------------------
mapfile -t lines < "$file"
lineno=0

# --------------------
# Main loop
# --------------------
while (( lineno < ${#lines[@]} )); do
    line="${lines[$lineno]}"
    lineno=$((lineno + 1))

    [[ "$jmp" -eq 1 ]] && { jmp=0; continue; }
    [[ "$line" == end ]] && break

    # push
    if [[ "$line" =~ ^push[[:space:]]+([0-9]+)$ ]]; then push "${BASH_REMATCH[1]}"; continue; fi

    # output
    [[ "$line" == list ]] && {
        if [[ "${#stack[@]}" -gt 0 ]]; then
            for (( v=$(( "${#stack[@]}" - 1 )); v > -1; v-- )); do
                echo -n "${stack[v]} "
            done
            echo ""
        else
            echo "<empty stack>"
        fi
        continue
    }
    [[ "$line" == prints ]] && { prints; continue; }
    [[ "$line" =~ ^echo[[:space:]]+(.+)$ ]] && { echo "${BASH_REMATCH[1]}"; continue; }

    # arithmetic
    [[ "$line" == add ]] && { add; continue; }
    [[ "$line" == sub ]] && { sub; continue; }

    # jump
    if [[ "$line" =~ ^jmp[[:space:]]+([a-zA-Z0-9_]+)$ ]]; then 
        target="${BASH_REMATCH[1]}"
        [[ -n "${labels[$target]}" ]] && lineno=$(( labels[$target] )) || { echo "Label '$target' not found"; exit 1; }
        continue
    fi

    # conditional jumps
    [[ "$line" =~ ^if=[[:space:]]*([0-9]+)$ ]] && { [[ "${stack[-1]}" != "${BASH_REMATCH[1]}" ]] && jmp=1; continue; }
    [[ "$line" =~ ^if\![[:space:]]*([0-9]+)$ ]] && { [[ "${stack[-1]}" == "${BASH_REMATCH[1]}" ]] && jmp=1; continue; }

    # read input
    [[ "$line" == read ]] && {
        read -p "" entry
        push 0
        for (( i=${#entry}-1; i>=0; i-- )); do
            push "${entry:i:1}"; toint
        done
        continue
    }

    # stack ops
    [[ "$line" == swap ]] && { swap; continue; }
    [[ "$line" == tochar ]] && { tochar; continue; }
    [[ "$line" == cls ]] && { clear; continue; }
    [[ "$line" == kill ]] && { stack=(); continue; }

    # variables ops
    [[ "$line" =~ ^set[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)$ ]] && {
        set_v "${BASH_REMATCH[1]}"
        continue
    }

    [[ "$line" =~ ^get[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)$ ]] && {
        val=$(get_v "${BASH_REMATCH[1]}")
        
        push 0
        for (( i=${#val}-1; i>=0; i-- )); do
            push "$(printf '%d' "'${val:i:1}")"
        done
        continue
    }

    # push string literal
    if [[ "$line" =~ ^pushs[[:space:]]+(.+)$ ]]; then
        str="${BASH_REMATCH[1]}"
        push 0
        for (( i=${#str}-1; i>=0; i-- )); do
            push "$(printf '%d' "'${str:i:1}")"
        done
    fi

    # misc
    if [[ "$line" =~ ^#[[:space:]]+(.+)$ ]]; then
        continue
    fi

    if [[ "$line" == rand ]]; then
        rand
    fi
done
