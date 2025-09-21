# KnotLang

KnotLang is a **stack-based programming language** inspired by Forth, designed for **portability on UNIX/OSX systems** with Bash installed. It is primarily focused on **education**, helping beginners understand stack operations, control flow, and simple program logic in a clear and interactive way.

---

## Features

- Stack-based operations (`<number>`, `pop`, `add`, `sub`, `swap`, `tochar`)
- Conditional jumps (`if=`, `if!`, `jmp`)
- Reading user input (`read`)
- Printing values (`print`) and ASCII strings (`prints`)
- Clear screen (`cls`)
- Easy-to-use syntax with labels for jumps

---

## Installation

1. **Download or clone the repository**:

```bash
git clone https://github.com/leonardopinezi/KnotLang.git
cd KnotLang
```

2. **Make the installer executable**:

```bash
chmod +x install.sh
```

3. **Run the installer**:

```bash
./install.sh
```

You will be prompted to enter the installation directory. Press **Enter** to use the default `/usr/local/bin`.

4. **Reload your shell**:

```bash
source ~/.bashrc
```

After this, you can run KnotLang from anywhere using the command:

```bash
knotlang path/to/your_program.knot
```

---

## Syntax Examples

### Push numbers to the stack

```
5
10
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
pushs "Hello, World!"
prints
end
```

Output:

```
Hello, World!
```

### Conditional jumps

```
:loop
1
print
if!=0
jmp loop
end
```

---

## Stack Operations

| Command | Description |
|---------|-------------|
| `<number>` | Push a number to the stack |
| `pop` | Remove the top value from the stack |
| `add` | Pop the top two numbers, add them, push the result |
| `sub` | Pop the top two numbers, subtract second from top, push the result |
| `swap` | Swap the top two values |
| `tochar` | Convert top number to ASCII character |
| `prints` | Convert stack values to string and print |

---

## Control Flow

| Command | Description |
|---------|-------------|
| `jmp <label>` | Jump to a label |
| `if=<value>` | Jump next line if top of stack is not equal to value |
| `if!=<value>` | Jump next line if top of stack is equal to value |
| `:label` | Define a label for jumps |

---

## Input/Output

| Command | Description |
|---------|-------------|
| `read` | Read user input and push it to the stack |
| `print` | Print the top value of the stack |
| `prints` | Print stack as ASCII characters |
| `cls` | Clear terminal screen |

---

## Example Program

```
pushs "Enter a number: "
prints
read
dup
pushs "You entered: "
prints
tochar
prints
end
```

---

## License

MIT License

