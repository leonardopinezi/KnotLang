# KnotLang

KnotLang is a **stack-based programming language** inspired by Forth, designed for **portability on UNIX/OSX systems** with Bash installed. It is primarily focused on **education**, helping beginners understand stack operations, control flow, and simple program logic in a clear and interactive way.

---

## Features

* Stack-based operations (`push <number>`, `pop`, `add`, `sub`, `swap`, `tochar`, `toint`)
* Conditional jumps (`if=`, `if!`, `jmp`)
* Reading user input (`read`)
* Printing values (`print`) and ASCII strings (`prints`)
* Clear screen (`cls`)
* Random number generation (`rand`)
* Easy-to-use syntax with labels for jumps

---

## Installation

1. **Download or clone the repository**:

```bash
git clone https://github.com/leonardopinezi/KnotLang.git
cd KnotLang
```

2. **Make the interpreter executable**:

```bash
chmod +x knotlang.sh
chmod +x install.sh
```

3. **Install the interpreter**:

```bash
bash install.sh
```

4. **Run a KnotLang program**:

```bash
knotlang path/to/your_program.knot
```

---

## Syntax Examples

### Push numbers to the stack

```
push 5
push 10
add
print
end
```

Output:

```
15
```

### Push a string and print it

```
pushs Hello, World!
prints
end
```

Output:

```
Hello, World!
```

### Generate a random number between 0 and 10

```
push 10
rand
print
end
```

Output (example):

```
7
```

---

## Stack Operations

| Command         | Description                                                        |
| --------------- | ------------------------------------------------------------------ |
| `push <number>` | Push a number to the stack                                         |
| `pop`           | Remove the top value from the stack                                |
| `add`           | Pop the top two numbers, add them, push the result                 |
| `sub`           | Pop the top two numbers, subtract second from top, push the result |
| `swap`          | Swap the top two values                                            |
| `tochar`        | Convert top number to ASCII character                              |
| `toint`         | Convert top character to its ASCII number                          |
| `prints`        | Convert stack values to string and print                           |
| `kill`          | Clear the entire stack                                             |
| `rand`          | Get the last stack number, and push a random number based on it    |

---

## Control Flow

| Command       | Description                                          |
| ------------- | ---------------------------------------------------- |
| `jmp <label>` | Jump to a label                                      |
| `if= <value>`  | Skip next line if top of stack is not equal to value |
| `if!= <value>` | Skip next line if top of stack is equal to value     |
| `:label`      | Define a label for jumps                             |

---

## Input/Output

| Command       | Description                              |
| ------------- | ---------------------------------------- |
| `read`        | Read user input and push it to the stack |
| `prints`      | Print stack as ASCII characters          |
| `echo <text>` | Print text literally                     |
| `cls`         | Clear terminal screen                    |

---

## Example: Number Guessing Game

```
echo Welcome to Number Guessing Game!
push 10
rand
set numero_secreto

:loop
echo Guess a number between 0 and 10:
read
set palpite

get palpite
get numero_secreto
sub
push 0
if=
jmp! wrong

echo Congrats! You guessed it!
jmp end_game

:wrong
echo Try again!
jmp loop

:end_game
echo Game over!
end
```
