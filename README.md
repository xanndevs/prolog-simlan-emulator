# SimLan Emulator  ![Prolog](https://img.shields.io/badge/Prolog-SWI--Prolog-%40f040?logo=swi-prolog) 
**A Register-Based Language Interpreter in Prolog**  
*A low-level emulator for SimLan (Simple Language) demonstrating register operations and program flow control.*



## Architecture  
The emulator features:  
- **32-register memory** (initialized to zeros)  
- **Program counter** tracking current line number  
- **Basic I/O** for program execution tracing  
- **Register operations**:  
  - `put` - Store immediate values  
  - `add` - Arithmetic operations  
  - `prn` - Print register values  
- **Flow control**:  
  - `jmpu` - Unconditional jump  
  - `jmpe` - Conditional jump (register equality check)  
  - `halt` - Program termination  

---

## Supported Commands  
| Command | Format | Description | 
|---------|--------|-------------|
| `put`   | `put X,Y` | Store value X in register Y |
| `add`   | `add X,Y` | Add registers X and Y, store result in Y |
| `prn`   | `prn X` | Print value of register X |
| `jmpe`  | `jmpe X,Y,Z` | Jump to line Z if register X == Y |
| `jmpu`  | `jmpu X` | Unconditional jump to line X |
| `halt`  | `halt` | Terminate program |

---

## Installation  
1. Install [SWI-Prolog](https://www.swi-prolog.org/download/stable)
2. Clone repository:  
   ```bash
   git clone https://github.com/xanndevs/prolog-simlan-emulator.git
   cd simlan-emulator
   ```

---

## Usage  
1. Create program file (e.g., `program.sim`)
2. Run emulator:  
   ```bash
   swipl .\main.prl 
   ```
3. Start the execution by typing:
   ```prolog
   os('program.txt')
   ``` 

---

## Example Program (`for` loop from 0 to 9) 
`program.txt`:  
```prolog
put 1,5     % Store 1 in register 5
put 0,1     % Store 0 in register 1
put 10,2    % Store 10 in register 2
jmpe 1,2,7  % Jump to line 7 if register1 == register2
prn 1       % Print register1
add 5,1     % Add registers5 + register1, store in register1
jmpu 3      % Jump back to line 3
prn 1       % Print register1 (unreachable)
halt
```

**Execution Output**:  
```
1 ?- os("program.txt").
ln.0 put 1,5            - Register5 is now 1
ln.1 put 0,1            - Register1 is now 0
ln.2 put 10,2           - Register2 is now 10
ln.3 jmpe 1,2,7         - Jump condition is not met, next line: 4
ln.4 prn 1              - Register1 is 0
ln.5 add 5,1            - Register5 (1) + Register1 (0) is 1
ln.6 jmpu 3             - Jumping unconditionally to the line 3
------------------------- jump-U SEPERATOR
ln.3 jmpe 1,2,7         - Jump condition is not met, next line: 4
... (loop continues)...
ln.7 prn 1              - Register1 is 10
ln.8 halt               - -END OF PROGRAM-
true.

2 ?-
```



## Contributing  
This implementation demonstrates core concepts for educational purposes. Feel free to clone or contribute to the project. I **will be accepting** pull requests, if there are any...

**Potential enhancements**:  
- [ ] Saving the program to the memory first, instead of reading the file over and over again
- [ ] Adding negative number support to the commands  
- [ ] Add error checking for invalid registers
- [ ] Support mathematical expressions in `put`  
...
