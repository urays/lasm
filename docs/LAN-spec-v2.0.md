# 🌞 Hello! LAN

> Version: 2.0
> Last Updated: 2026-01-20

## Table of Contents
- [Introduction](#introduction)
- [Lexical Structure](#lexical-structure)
- [Language Syntax](#language-syntax)
- [Pseudo-Operations](#pseudo-operations)
- [Constants and Expressions](#constants-and-expressions)
- [Program Structure](#program-structure)
- [Examples](#examples)
- [Appendix: Potato Processor Overview](#appendix-potato-processor-overview)

## Introduction

### What is LAN?

VLIW Assembly Notation (LAN) is a symbolic assembly language designed for Very Long Instruction Word (VLIW) architectures. It operates at the **symbolic assembly level**—an abstraction where programmers write actual ISA instruction mnemonics while using symbolic variables and optionally omitting low-level resource binding details such as register allocation, functional unit assignment, and instruction parallelism.

LAN is the input language for the LASM (VLIW Assembly Scheduling Machine) framework, an extensible competitive scheduling framework that supports multi-strategy compilation. The framework respects all user-provided specifications while automatically handling omitted details. It transforms LAN code through stratified assembly structures (SAS) that maintain mixed scheduling states, enabling sophisticated optimizations while preserving user-specified constraints.

### Design Philosophy

1. **Symbolic Assembly Abstraction**: Write ISA instructions with symbolic operands, delegating resource binding to the framework when desired
2. **Selective Specification**: Explicitly control parallelism, functional units, and registers where needed, omit where convenient
3. **Simplicity**: Concise pseudo-operation set (`@`-prefixed directives) for program structure
4. **Modularity**: Multi-file support with function imports and separate compilation
5. **Optimization-Friendly**: Designed to integrate with advanced scheduling strategies (LAEMS, FBBF, etc.)

### Key Features

- **Implicit Variable Declaration**: Variables are implicitly declared on first use, remaining symbolic until register allocation
- **Optional Resource Specification**: Users may specify instruction bundling (`|`), functional units (`.UNIT`), physical registers (`@asg`), or delegate these to LASM
- **Conditional Execution**: First-class support for predicated instructions
- **Rich Constant System**: Integer, floating-point, character, and expression constants with IEEE754 compliance
- **Label Annotations**: Loop iteration bounds for advanced optimizations


## Lexical Structure

### Comments

LAN supports two comment styles:

```c
// C-style single-line comment
mov 0, x     // End-of-line comment

; Assembly-style comment
sub 1, k, k  ;count1=n
```

Both comment styles terminate at the end of the line.

### Identifiers

Identifiers for variables, labels, and functions follow these rules:

**Syntax**: `^[a-zA-Z_][a-zA-Z0-9_]*`

```c
// Valid identifiers
counter
loop_start
_LOOP_M
ar_a
v_alpha
```

**Note**: LAN identifiers are **case-sensitive**. However, machine-defined register names are case-insensitive (e.g., `r0` = `R0`, `ar8` = `AR8`).

### Reserved Symbols

- **Pseudo-operations**: All symbols prefixed with `@` (e.g., `@func`, `@ret`, `@sect`)
- **Parallelism operator**: `|`
- **Conditional execution**: `[`, `]`, `!`
- **Memory dereference**: `*`
- **Functional unit separator**: `.`

### Whitespace

Whitespace (spaces, tabs, newlines) separates tokens and is otherwise ignored. Newlines typically terminate statements, but the language is not strictly line-oriented.

## Language Syntax

### Instruction Format

The general format of a LAN instruction:

```
[condition] MNEMONIC [.UNIT] operand1, operand2, ..., destination
```

Components:
- **Condition** (optional): `[reg]` or `[!reg]` for conditional execution
- **Mnemonic**: ISA-defined instruction name (case-insensitive)
- **Functional Unit** (optional): `.UNIT` suffix specifying execution unit
- **Operands**: Registers, variables, immediates, memory addresses
- **Destination**: Target register or variable

### Conditional Execution

Instructions can execute conditionally based on register values:

```c
// Positive condition: execute if register is non-zero
[k]  br _LOOP_K         // Branch if k != 0
[c]  sub 1, c, c        // Decrement if c != 0

// Negative condition: execute if register is zero
[!r0] mov 1, r1         // Move if r0 == 0
[!k]  br END            // Branch if k == 0
```

The condition register must be a scalar register (not a vector register).

### Functional Unit Specification

Explicitly assign instructions to functional units:

```c
// Syntax: INSTRUCTION.UNIT operands...

add .C1  r0, r1, r2     // Execute on C1 unit
add .C2  r3, r4, r5     // Execute on C2 unit
```

When omitted, LASM automatically assigns functional units during scheduling.

### Parallel Execution

The `|` operator indicates instructions that should be bundled in the same VLIW instruction word:

```c
// Sequential execution (two VLIW words)
vload *ar0++[16], b_1:b_0
vmul b_0, a_N, t0

// Parallel execution (one VLIW word)
  vload *ar0++[16], b_1:b_0
| vmul  b_0, a_N, t0
```

The framework verifies resource conflicts and dependencies. When parallelism is not specified, LASM determines optimal bundling.

### Memory Addressing

Memory operands use pointer dereference syntax:

```c
*address_register[offset_expression]
```

Common addressing modes:

| Mode | Syntax | Description | Example |
|------|--------|-------------|---------|
| Direct | `*ar` | No modification | `load *ar0, r1` |
| Post-increment | `*ar++[N]` | Access, then ar += N | `load *ar0++[1], r1` |
| Pre-offset (non-modifying) | `*+ar[N]` | Access at ar+N, ar unchanged | `load *+ar0[16], r2` |
| Post-decrement | `*ar--[N]` | Access, then ar -= N | `stor r1, *ar1--[8]` |

The offset `[N]` can be an immediate constant or an offset register:

```c
load *aA++[1], ta       // Increment by 1
vload *ar_b++[16], b_1:b_0  // Increment by 16
vload *ar++[or_0], v_1:v_0  // Increment by offset register
```

### Register Pairs

Some instructions operate on register pairs for wider data:

```c
// Syntax: high_register:low_register
vload *ar_b++[16], b_1:b_0     // Load into pair b_1:b_0
vstor c_1:c_0, *ar_c++[16]     // Store from pair c_1:c_0
```

Register pairs must follow the machine's pairing rules (typically consecutive registers).

### Variables vs. Physical Registers

LAN allows mixing symbolic variables and physical register names:

```c
// Symbolic variables (allocated by framework)
mov M, i                // 'i' is a variable
add 1, counter, counter // 'counter' is a variable

// Physical registers (explicit binding)
mov M, r0               // r0 is a physical scalar register
mov addrA, ar0          // ar0 is a physical address register

// Mixed usage
add r0, counter, result // Mix physical and symbolic
```

Physical registers are specified by machine description files. For Potato:
- Scalar: `r0`-`r63` (or `R0`-`R63`)
- Address: `ar0`-`ar15` (or `AR0`-`AR15`)
- Offset: `or0`-`or15` (or `OR0`-`OR15`)
- Vector: `vr0`-`vr63` (or `VR0`-`VR63`)

### Labels

Labels mark program locations and optionally specify loop iteration bounds:

```c
// Syntax
label_name:
label_name: min_iteration[, max_iteration]

// Identifier pattern
// label_name: ^[a-zA-Z_][a-zA-Z0-9_]*
// min_iteration: Minimum number of loop iterations (must be > 0)
// max_iteration: Maximum number of loop iterations

// Examples
_LOOP_M:                      // General label (no loop info)
_LOOP_K: 64, 64               // Fixed 64 iterations
_LOOP_N: 512, 512             // Fixed 512 iterations
inner_loop: 10, 100           // 10-100 iterations
LOOP_BASE: 1, 17              // Short loop path
SGEMM_LOOP: 3, 384            // Matrix operation loop
END:                          // Label for readability (no code follows)
```

**Important Notes**:

1. **Iteration Semantics**: `min_iteration` and `max_iteration` are the **actual number of iterations of the loop body**, independent of the initial value of the loop counter. They describe how many times the loop body will execute, not the counter's value.

2. **Loop Recognition**: LASM automatically recognizes loop structures in the program (for all loop types) and will not allow cross-loops. Loops must be properly nested.

3. **Optimization Hints**: Iteration bounds are hints for LASM's optimization strategies including software pipelining, modulo scheduling (LAEMS), and cross-boundary scheduling (FBBF). They are not runtime constraints.

**Loop Parsing Example**:

LASM parses loop structures from branch patterns:

```c
// Source code:                   // Parsed structure:
i_am_loop_1:                      i_am_loop_1 {
    ...                               ...
i_am_loop_2: 10000, 200000            i_am_loop_2 {
    ...                                   ...
    sub r_9, r_0, r_0                     ...
    [r_0] br i_am_loop_2              }
    add R13, R12, R13                 ...
    sub R13, R9, r_0
    [r_0] br i_am_loop_1          }
    ...                               ...
i_am_loop_3: 20000                i_am_loop_3 {
    ...                               ...
    [r_1] br i_am_loop_3          }
```

In this example:
- `i_am_loop_1` is the outer loop
- `i_am_loop_2` is a nested inner loop with bounds [10000, 200000]
- `i_am_loop_3` is a separate loop after the outer loop completes
- LASM recognizes the loop structure from conditional branch patterns

## Pseudo-Operations

Pseudo-operations are directives prefixed with `@` that define program structure, data, and control flow. They do not generate machine instructions directly.

### Storage and Data Types

#### @bN - Bit Storage

Define symbols with N-bit storage (1 ≤ N ≤ 64):

```c
// Syntax
@bN symbol_name, symbol_value

// Parameters:
// - N: Integer in range [1, 64], specifying the number of bits for storage
// - symbol_name: Identifier following pattern ^[a-zA-Z_][a-zA-Z0-9_]*
// - symbol_value: Can be constants, strings, expressions, or symbolic constants

// Examples
@b64 N, 24576           // 64-bit integer constant
@b32 threshold, 0x100   // 32-bit value
@b16 flags, 0b1011      // 16-bit binary value
@b8  byte_val, 255      // 8-bit value
@b36 addr, 0x210000000  // 36-bit address constant
@b4  nibble, 0xF        // 4-bit value
```

**Detailed Behavior**:

1. **Value Processing**:
   - Values are first expanded to 64 bits
   - Then truncated to N bits (keeping lower N bits)
   - Stored right-aligned with zero-padding for unspecified high-order bits

2. **Truncation Rules**:
   - If value < 2^N, it's stored as-is
   - If value ≥ 2^N, lower N bits are kept and LASM issues a warning
   - Example: `@b4 x, 0xFF` → x = 0xF (warning issued)

3. **String Processing**:
   - Strings are processed character by character from the beginning
   - Each character is concatenated into the result
   - Example: `@b32 x, "abc"` → 'a','b','c' concatenated → 0x616263

4. **Floating-Point Conversion**:
   - Floating-point constants are converted to IEEE754 double precision
   - Then treated as 64-bit integers for truncation
   - Example: `@b64 x, 1.5` → 0x3FF8000000000000

5. **Constants are NOT Sign-Extensible**:
   - LASM reserves exactly N bits for storage
   - No automatic sign extension occurs
   - Negative decimals are stored as two's complement

**Usage in Segments**:
```c
@sect ".data", array, @b8, 1, 2, 3     // Initialize byte array
@usect ".bss", buffer, @b32, 128       // Reserve 128 32-bit elements
```

#### @bh, @bf, @bd - Floating-Point Storage

IEEE754 floating-point constants with specific precisions:

```c
// @bh - Half precision (16-bit: 1 sign, 5 exponent, 10 mantissa)
// Syntax: @bh symbol_name, symbol_value
@bh half_val, 1.5       // 0x3E00
@bh a, 1.2              // 0x3CCD
@sect ".data", x, @bh, 1.5, -2.0

// @bf - Single precision (32-bit: 1 sign, 8 exponent, 23 mantissa)
// Syntax: @bf symbol_name, symbol_value
@bf float_val, 3.14159  // 0x40490FDA
@bf f132, -1.0          // 0xBF800000
@bf f1, 1.0             // 0x3F800000
@sect ".data", arr, @bf, 1.0, 2.0, 3.0

// @bd - Double precision (64-bit: 1 sign, 11 exponent, 52 mantissa)
// Syntax: @bd symbol_name, symbol_value
@bd double_val, 2.718281828    // 0x4005BF0A8B145769
@bd x, 1.2                     // 0x3FF3333333333333
@bd y, -1e-2                   // 0xBF847AE147AE147B
@bd d164, 1.0                  // 0x3FF0000000000000
```

**Parameters**:
- **symbol_name**: Identifier following pattern \^[a-zA-Z_][a-zA-Z0-9_]*
- **symbol_value**: Floating-point constant in decimal or scientific notation

**Precision Preservation**:

When referencing floating-point symbolic constants, LASM uses the **original value** to minimize precision loss:

```c
@bf x, 1.2              // x = 1.2 (stored as 32-bit float 0x3F99999A)
@bd y, x                // Equivalent to @bd y, 1.2 (uses original 1.2)
                        // NOT @bd y, 0x3F99999A (machine representation)

@bh a, 1.2              // a = 0x3CCD (16-bit)
@b7 z, a                // Equivalent to @b7 z, 1.2
                        // NOT @b7 z, 0x3CCD
```

This ensures that successive type conversions don't accumulate rounding errors.

**Packed Constants**:

Multiple floating-point values can be packed into wider storage:

```c
@bf f132, -1.0
@b64 f132_f132, (f132<<32) + f132    // Pack two -1.0f into 64-bit
// Result: 0xBF800000BF800000

@bf f1, 1.0
@b64 f1_f1, (f1<<32) + f1            // Pack two 1.0f into 64-bit
// Result: 0x3F8000003F800000
```

**Direct Usage**:

```c
mov 0xBF800000BF800000, alpha    // Two -1.0f values packed
mov 0x3F8000003F800000, beta     // Two 1.0f values packed
```

### Segment Management

#### @sect - Initialized Segment

Define or continue an initialized segment with optional data:

```c
// Syntax
@sect "section_name"
@sect "section_name", symbol_name, T, val1[, val2, ...]

// Parameters:
// - section_name: String literal for segment name
// - symbol_name: Identifier for first address of the data
// - T: Storage type (@bN, @bh, @bf, @bd)
// - val1, val2, ...: Can be constants, strings, expressions, or symbolic constants

// Examples
@sect ".text"                                // Start code segment
@sect ".text.1"                              // Code segment with suffix
@sect "custom"                               // Custom segment name
@sect ".data"                                // Start data segment
@sect ".data", arr, @b32, 1, 3, 5, -3, 4    // Initialize array with 5 elements
@sect ".rodata", x, @b8, 0x2, -2, 255, 'A'  // Byte array: 0x02, 0xfe, 0xff, 0x61
@sect ".data", a2, @bf, 1.2, 1.4, -1.5, 1e-2 // Float array with 4 elements
```

**Segment Switching Behavior**:

After `@sect` completes, a **new segment starts** if the segment name is different from the current one. The specified segment remains active for subsequent code/data until another segment directive.

```c
@sect ".data", x, @b64, 13, 14    // Enter .data segment
// Still in .data segment
@sect ".text"                      // End .data, start .text
@func foo {                        // foo is placed in .text
    @ret
}
```

**Common Segment Names**:
- `.text`, `.text.1`, `.text.s` - Executable code (suffixes for modular organization)
- `.data` - Initialized read-write data
- `.rodata` - Initialized read-only data (constants)
- `.bss` - Uninitialized data (use @usect instead)
- Custom names: `"custom"`, `"xdmeifj"`, etc.

**Segment Naming**:
Segments can have suffixes for organizational purposes. For example, `.text`, `.text.1`, and `.text.main` are all valid code segment names.

#### @usect - Uninitialized Segment

Reserve space in an uninitialized segment (typically BSS):

```c
// Syntax
@usect "section_name", symbol_name, T, count

// Parameters:
// - section_name: String literal for segment name (usually ".bss")
// - symbol_name: Identifier pointing to the first byte of reserved space
// - T: Storage type (@bN, @bh, @bf, @bd) specifying element size
// - count: Number of data elements to reserve
// - Reserved space size (bytes) = sizeof(T) * count
// - Starting position can be set via @align (default: 1-byte alignment, 0-byte offset)

// Examples
@usect ".bss", buffer, @b32, 128         // Reserve 128 32-bit elements (512 bytes)
@usect ".bss", workspace, @b64, 256      // Reserve 256 64-bit elements (2048 bytes)

@align 8
@usect ".data", x, @bd, 10               // 10 double-precision elements, 8-byte aligned

@align 8, 1
@usect ".bss", y, @b32, 128              // 8-byte aligned with 1-byte offset

@usect ".bss", Arr, @b10, 128            // 128 elements, 2 bytes each (10 bits → 2 bytes)
// Arr.cnt = 128 (element count)
// Arr.gra = 2 (bytes per element)
```

**Critical Segment Switching Behavior**:

`@usect` has **automatic revert** behavior that differs from `@sect`:

- After `@usect` completes, LASM **automatically reverts** to the previous segment
- After `@sect` completes, a **new segment starts** (if the name differs)

```c
@sect ".data", x, @b64, 13, 14         // In .data segment
@usect ".bss", sym, @bh, 32            // Temporarily switch to .bss, then revert to .data
// Automatically returned to .data segment here
@sect ".text"                           // Explicitly end .data, start .text
@func __start {                         // __start is placed in .text
    @ret
}
```

**Alignment Control**:

Use `@align` before `@usect` to control memory layout:

```c
@align 16                              // Request 16-byte alignment
@usect ".bss", aligned_buffer, @b64, 64

@align 4, 2                            // 4-byte alignment with 2-byte offset
@usect ".bss", offset_buffer, @b32, 32
```

**Symbolic Properties**:

Reserved space symbols have `.cnt` and `.gra` properties:

```c
@usect ".bss", buffer, @b32, 256
// buffer.cnt = 256 (element count)
// buffer.gra = 4 (bytes per element: 32 bits = 4 bytes)

@b16 x, buffer.gra, buffer.cnt
// x values: 0x0004, 0x0100
```

### Function Definitions

#### @func - Function Declaration

Define a regular function:

```c
// Syntax
@func function_name [arg1[, arg2, ...]] {
    // Function body
    @ret [return_values...]
}

// Function name pattern: ^[a-zA-Z_][a-zA-Z0-9_]*
// Arguments and return values can be any number (including zero)

// Examples
@func _sample_code addrA, addrB, addrC, M, N, K {
    mov addrA, aA
    mov addrB, aB
    // ... function body ...
    @ret
}

@func add a, b {
    add a, b, result
    @ret result
}

@func sgemv_0_kernel addrA, addrX, addrY, M, N {
    // Matrix-vector multiplication implementation
    @ret
}

@func sgemm_kernel addrA, addrB, addrC, M, K, N {
    // Matrix-matrix multiplication implementation
    @ret
}
```

**Function Name Rules**:

1. **Identifier Pattern**: `^[a-zA-Z_][a-zA-Z0-9_]*`
   - Must start with letter or underscore
   - Can contain letters, digits, and underscores

2. **Scope**: Function names declared by `@func` are **GLOBAL** within the file

3. **Uniqueness Requirements**:
   - User must ensure function names are **UNIQUE within a file**
   - If a function is referenced by another file (via `@import`), names must be **unique across BOTH files**
   - LASM reports an error if function name conflicts are detected

4. **Case Sensitivity**: Function names are case-sensitive
   - `MyFunc` and `myfunc` are different functions

**Parameter Passing**:

Parameters are passed by convention. The calling convention (register usage, stack layout) depends on the target architecture. LASM handles the details based on the machine description.

**Return Values**:

Functions can return zero or more values using `@ret`. The calling convention determines how return values are passed back to the caller.

#### @main - Entry Function

Define the program entry point:

```c
// Syntax
@main function_name {
    // Entry point code
    @ret
}

// Function name pattern: ^[a-zA-Z_][a-zA-Z0-9_]*
// NO parameters allowed

// Examples
@main __start {
    mov 42, r0
    @call add, 10, 20, = result
    @ret
}

@main testing_axpby {
    @b36 addrX, 0x210000000
    @b36 addrY, 0x210060000
    @icall config_cvccr, 3
    @icall _axpby_kernel, addrX, addrY, N, alpha, beta, = r1, r2
    @icall test_stop
    @ret
}
```

**Critical Rules**:

1. **Uniqueness**: Only **ONE** `@main` is allowed per project
   - If multiple `@main` definitions exist, LASM reports an error
   - Each project should have exactly zero or one `@main`

2. **No Parameters**: `@main` does **NOT** allow parameters to be passed in
   - Entry function receives no arguments
   - Use global data or constants for initialization values

3. **Optimization Scope**:
   - **If `@main` exists**: LASM only optimizes regular functions that have an ancestor relationship in the entry function (reachable from `@main`)
     - Functions not called (directly or indirectly) from `@main` are ignored
     - This enables dead code elimination

   - **If `@main` does NOT exist**: LASM optimizes **ALL** regular functions and exports them in topological call order
     - All functions are considered library functions
     - Suitable for building reusable function libraries

**Use Cases**:

- **Standalone Programs**: Define `@main` as the entry point
- **Library Modules**: Omit `@main` to export all functions
- **Test Harnesses**: Use `@main` to call specific test functions

**Return Values**:

`@main` typically uses `@ret` without arguments. If return values are provided, they are handled by the runtime environment (e.g., exit code).

#### @ret - Function Return

Return from a function:

```c
// Syntax
@ret [val1[, val2, ...]]

// Return value types: constants, symbolic constants, physical registers, variables

// Examples
@ret                        // No return value
@ret 42                     // Return constant
@ret result                 // Return variable
@ret r0, r1                 // Return multiple values (physical registers)
@ret r10                    // Return from get_core_id
@ret ID, CoreNum            // Return multiple named values
@ret sum, product, count    // Return three values
```

**Three Usage Cases**:

1. **@ret without return value**:
   - Executes jump instruction directly at function end
   - Used for void functions or procedures
   ```c
   @func initialize {
       mov 0, counter
       @ret                 // No return value
   }
   ```

2. **@ret with return values**:
   - Passes return values according to calling convention
   - Then executes jump instruction to return to caller
   ```c
   @func compute a, b {
       add a, b, sum
       mul a, b, product
       @ret sum, product   // Return two values
   }
   ```

3. **@ret not provided**:
   - If function body has no `@ret`, LASM reports an error
   - Called function MUST have at least one `@ret` statement (unless it never returns)
   ```c
   @func broken {
       mov 0, x
       // ERROR: Missing @ret
   }
   ```

**Multiple Return Statements**:

Functions can have multiple `@ret` statements for different code paths:

```c
@func conditional_return flag {
    [flag] br TRUE_PATH

FALSE_PATH:
    mov 0, result
    @ret result

TRUE_PATH:
    mov 1, result
    @ret result
}
```

**Return Value Types**:

Return values can be:
- **Constants**: `@ret 0`, `@ret 42`
- **Symbolic constants**: `@ret SIZE`, `@ret MAX_COUNT`
- **Physical registers**: `@ret r0, r1, ar0`
- **Variables**: `@ret sum, product, counter`

The calling convention determines how these are passed back to the caller.

### Function Calls

#### @call - Regular Function Call

Call a function (potentially generating actual call instruction):

```c
// Syntax
@call function_name[, arg1, arg2, ...][, = ret1, ret2, ...]

// Parameters:
// - function_name: Function defined by @func or imported via @import
// - arg1, arg2, ...: Argument values (constants, variables, registers)
// - ret1, ret2, ...: Variables to receive return values (after =)

// Examples
@call initialize                              // No arguments, no returns
@call compute, x, y                           // Two arguments, no returns
@call divide, a, b, = quotient, remainder     // Two args, two returns
@call add, 10, 20, = result                   // Constant args, one return
@call print_value, value                      // Single argument
```

**Behavior**:

1. **Call Mechanism**:
   - Generates actual function call instructions
   - May involve saving return address, jumping to function, and restoring context
   - Calling convention handled by LASM based on architecture

2. **Argument Passing**:
   - Arguments are passed according to the target architecture's calling convention
   - May use registers, stack, or combination
   - LASM automatically handles the details

3. **Return Value Capture**:
   - Use `= var1, var2, ...` syntax to capture return values
   - Return values are assigned to specified variables
   - Number of return variables must match function's `@ret` signature

4. **vs. @icall**:
   - `@call` always generates a call sequence
   - May be more suitable for large functions or recursive calls
   - See `@icall` for inlining hints

#### @icall - Inline Call Hint

Call with inlining hint (may trigger function inlining):

```c
// Syntax
@icall function_name[, arg1, arg2, ...][, = ret1, ret2, ...]

// Parameters:
// - function_name: Function defined by @func or imported via @import
// - arg1, arg2, ...: Argument values (constants, variables, registers)
// - ret1, ret2, ...: Variables to receive return values (after =)

// Examples
@icall fast_helper, input, = output           // Potential inline expansion
@icall config_cvccr, 3                        // Configuration call
@icall config_scr, 3                          // Another config call
@icall _axpby_kernel, addrX, addrY, N, alpha, beta, = r1, r2
@icall test_output, addrY, N*8                // Expression as argument
@icall test_stop                              // No arguments
@icall get_core_state, = ID, CoreNum          // Multiple return values
@icall clk_open, r11                          // Physical register argument
@icall leaf_function                          // Simple call candidate
```

**Inlining Decision**:

`@icall` is a **hint** to LASM that this function is a good candidate for inlining. LASM makes the final decision based on:

1. **Cost Heuristics**:
   - Function size (instruction count)
   - Call frequency and context
   - Code size vs. performance trade-off

2. **Register Pressure**:
   - Available registers in the caller
   - Register usage in the callee
   - Potential for register spilling

3. **Function Characteristics**:
   - Leaf functions (no further calls) are preferred
   - Small, frequently called functions
   - Functions with constant arguments

**Conditions for Inlining**:

- Function must be **inlineable** (no recursive calls, finite size)
- Register pressure must be **acceptable** (no excessive spilling)
- Inlining must provide **performance benefit** or reduce code size

**vs. @call**:

| Feature | @call | @icall |
|---------|-------|--------|
| Call overhead | Always present | May be eliminated |
| Code size | Smaller (one call site) | Larger (duplicated code) |
| Performance | Call/return overhead | No call overhead if inlined |
| Register pressure | Lower | May be higher |
| Use case | Large functions, recursion | Small, hot functions |

**Example with @bar**:

Use `@bar` to prevent unwanted inlining across optimization boundaries:

```c
@icall setup_function
@bar                          // Optimization barrier
@icall critical_function      // Prevent inlining across barrier
@bar
```

### Import and Export

#### @import - Import Functions

Import functions from another LAN file for cross-file references:

```c
// Syntax
@import "filename", func1[, func2, ...]

// Parameters:
// - filename: Relative file path (string literal)
// - func1, func2, ...: Function names to import (must exist in target file)

// Examples
@import "../lib/utils.lan", helper_func
@import "./math.lan", add, multiply, divide
@import "../lib/csl.lan", test_output, test_stop, config_cvccr, config_scr
@import "./kernels/axpby.lan", _axpby_kernel
@import "vector_ops.lan", vector_add, vector_mul, vector_sub
```

**Behavior**:

1. **File Path Resolution**:
   - Path is **relative to the current file**
   - Supports Unix-style paths: `../`, `./`, subdirectories
   - Examples:
     - `"math.lan"` - Same directory
     - `"./lib/utils.lan"` - Subdirectory
     - `"../common/helper.lan"` - Parent directory

2. **Function Availability**:
   - Imported functions become **callable** in the current file
   - Can be used with `@call` or `@icall`
   - Functions must be defined with `@func` in the target file

3. **Name Resolution**:
   - Occurs at **link time** by LASM
   - Function names must be **unique** across all linked files
   - LASM reports error if:
     - Imported function doesn't exist in target file
     - Function name conflicts with local definitions

4. **Scope**:
   - Import declarations are **global** within the importing file
   - Must appear at **global scope** (outside function definitions)
   - Typically placed at the beginning of the file

**Multi-File Example**:

```c
// File: math.lan
@func add a, b {
    add a, b, sum
    @ret sum
}

@func multiply a, b {
    mul a, b, product
    @ret product
}

// File: main.lan
@import "math.lan", add, multiply      // Import two functions

@main start {
    @call add, 10, 20, = x
    @call multiply, x, 3, = y
    @ret
}
```

**Best Practices**:

- Group related imports together
- Import only needed functions (don't import entire files)
- Use descriptive function names to avoid conflicts
- Document dependencies in comments

### Directives

#### @asg - Register Assignment

Explicitly bind a variable (substitution symbol) to a physical register:

```c
// Syntax
@asg symbol, register

// Parameters:
// - symbol: Variable name (identifier)
// - register: Physical register name or register pair

// Examples - Single registers
@asg variable, r5                 // Assign variable to scalar register r5
@asg counter, r10
@asg data_ptr, ar0                // Assign to address register ar0
@asg a_ptr, ar1
@asg b_ptr, ar2
@asg result_ptr, ar3
@asg vector_temp, vr10            // Assign to vector register vr10
@asg offset_val, or5              // Assign to offset register or5

// Examples - Register pairs
@asg pair_val, vr3:vr2            // Assign to vector register pair
@asg wide_data, r21:r20           // Assign to scalar register pair
```

**Effect and Behavior**:

1. **Substitution**:
   - After `@asg`, all uses of `symbol` are **mapped** to the specified register
   - The symbol becomes an **alias** for the physical register
   - Subsequent references to `symbol` use the assigned register

2. **No Re-Allocation**:
   - The framework will **NOT** re-allocate this variable
   - The assignment is **permanent** within the function scope
   - Register allocator treats this register as **occupied**

3. **Scope**:
   - `@asg` must appear in **local scope** (inside function body)
   - Typically placed at the beginning of a function
   - Can appear anywhere before the variable's first use

4. **Register Availability**:
   - Assigned register must be **available** (not disabled by @dreg)
   - If register is already in use, LASM may report a conflict
   - User is responsible for avoiding register conflicts

**Usage Example**:

```c
@func compute_kernel addr_in, addr_out, N {
    // Explicit register assignments at function start
    @asg addr_in, ar0
    @asg addr_out, ar1
    @asg N, r10

    mov 0, sum                    // 'sum' will be allocated by framework

loop: 1, 1000
    load *ar0++[1], val           // ar0 is the assigned register for addr_in
    add sum, val, sum
    sub 1, r10, r10               // r10 is the assigned register for N
    [r10] br loop

    stor sum, *ar1                // ar1 is the assigned register for addr_out
    @ret
}
```

**When to Use @asg**:

- Performance-critical code requiring specific register allocation
- Interfacing with hand-written assembly or external code
- Working around register allocation heuristics
- Debugging register allocation issues

**Register Pair Assignment**:

```c
@asg wide_value, r31:r30          // Pair must follow architecture rules
load_pair *ar0, r31:r30           // Use the pair
// Both r31 and r30 are now occupied
```

#### @align - Memory Alignment

Specify memory alignment for the next address indicator:

```c
// Syntax
@align alignment [, offset]

// Parameters:
// - alignment: Minimum alignment in bytes (default: 4)
// - offset: Storage offset in bytes (default: 0)

// Examples
@align 8                               // 8-byte alignment, 0 offset
@align 16                              // 16-byte alignment, 0 offset
@align 4, 2                            // 4-byte alignment with 2-byte offset
@align 32                              // 32-byte alignment (cache line)
```

**Critical Behavior**:

`@align` affects only the **FIRST occurrence** of the next address indicator. It does NOT apply to subsequent declarations.

**Address Indicators**:
- Memory first address (defined by `@sect` or `@usect`)
- Function name (defined by `@func` or `@main`)
- Inner-function label (defined by `label:`)

**Alignment Examples**:

```c
// Example 1: Single alignment
@align 8
@usect ".bss", x, @b64, 10     // x is 8-byte aligned
@usect ".bss", y, @b32, 20     // y uses DEFAULT alignment (NOT 8-byte)

// Example 2: Alignment with offset
@align 8, 2
@usect ".bss", x, @bh, 32      // x is at 8n+2 address (8-byte aligned + 2 offset)

// Example 3: Multiple alignments
@align 4
@sect ".data", x, @b32, 1, 2, 3  // x will be 4-byte aligned
@usect ".bss", y, @bh, 32        // y will use DEFAULT alignment (not 4-byte)

// Example 4: Function alignment
@align 16
@func foo {                      // Function foo will be 16-byte aligned
    @ret
}
@func bar {                      // Function bar uses default alignment
    @ret
}

// Example 5: Section alignment
@align 8
@sect ".data", buffer, @b64, 100  // buffer is 8-byte aligned

@align 16
@usect ".bss", large_array, @b64, 1024  // large_array is 16-byte aligned
```

**Alignment Calculation**:

- **Without offset**: Address = N × alignment (where N is a non-negative integer)
- **With offset**: Address = N × alignment + offset

```c
@align 8        // Addresses: 0, 8, 16, 24, 32, ...
@align 8, 4     // Addresses: 4, 12, 20, 28, 36, ...
@align 16, 2    // Addresses: 2, 18, 34, 50, 66, ...
```

**Common Use Cases**:

1. **Cache Line Alignment**: `@align 64` or `@align 128`
2. **SIMD Alignment**: `@align 16` or `@align 32`
3. **Double-word Alignment**: `@align 8`
4. **Page Alignment**: `@align 4096`

**Best Practices**:

- Use alignment for performance-critical data structures
- Align to cache line boundaries for frequently accessed data
- Match alignment to hardware requirements (e.g., SIMD loads)
- Document why specific alignment is needed

#### @dreg - Disable Registers

Mark physical registers as unavailable for automatic register allocation:

```c
// Syntax
@dreg reg1[, reg2, ...]

// Parameters:
// - reg1, reg2, ...: Physical register names to disable

// Examples
@dreg r10, r11, r12                   // Disable scalar registers
@dreg ar5, ar6                        // Disable address registers
@dreg vr20, vr21, vr22                // Disable vector registers
@dreg ar8, r11, vr1, vr0              // Disable mixed register types
@dreg or3, or4                        // Disable offset registers
```

**Purpose**:

Specify physical registers that are **disabled** during automatic register allocation. These registers will not be used by the framework for allocating symbolic variables.

**Important Limitations**:

This pseudo-operation does **NOT** disable registers that have been:
- Already **assigned by the user** (via `@asg`)
- Already **in use** by the program (explicitly named in instructions)

It **ONLY** affects the allocator's choices for **future symbolic variables**.

**Scope**:

- Can be used in **local scope** (inside function body)
- Can be used in **global scope** (outside functions)
- Affects register allocation decisions in the current scope

**Use Cases**:

1. **Reserve Registers for Specific Purposes**:
   ```c
   @func kernel {
       @dreg r10, r11, r12    // Reserve for special use
       // Allocator won't use r10-r12 for symbolic variables
       mov 0, r10             // Explicit use is allowed
       add x, y, z            // x,y,z allocated to other registers
   }
   ```

2. **Interfacing with External Code**:
   ```c
   @dreg r0, r1, r2          // Reserved by calling convention
   ```

3. **Debugging Register Allocation**:
   ```c
   @dreg vr20, vr21, vr22    // Force allocator to use different registers
   ```

4. **Working Around Hardware Limitations**:
   ```c
   @dreg ar15                // ar15 has hardware bug, don't use
   ```

**Example**:

```c
@func test_allocation {
    @dreg r5, r6, r7          // Disable r5-r7 for allocation
    @asg fixed_var, r8        // Explicitly assign r8 (always works)

    mov 0, temp1              // temp1 allocated to available register (NOT r5-r7)
    add temp1, 1, temp2       // temp2 allocated to available register (NOT r5-r7)

    mov 42, r5                // Explicit use of r5 is allowed
    add r5, temp1, result     // Mix explicit and allocated registers

    @ret
}
```

**Interaction with @asg**:

```c
@dreg r10, r11
@asg myvar, r10               // This is ALLOWED (explicit assignment)
// Allocator won't use r10/r11 for other variables
// But user can explicitly assign r10
```

#### @mdep - Memory Dependency

Declare memory address dependencies within a segment for correct optimization:

```c
// Syntax
@mdep sym1, sym2[, sym3, ...]

// Parameters:
// - sym1, sym2, ...: Memory symbols that may alias or have dependencies

// Examples
@mdep array1, array2                  // Declare dependency between two arrays
@mdep buffer1, buffer2, buffer3       // Multiple dependencies
@mdep input_buffer, output_buffer     // Buffers that may overlap
```

**Purpose**:

Declare memory address dependencies within a segment to ensure correct optimization behavior.

**Default LASM Assumption**:

**IMPORTANT**: LASM assumes there are **NO memory dependencies** within a function by default. This enables aggressive optimizations such as:
- Reordering of load/store operations
- Elimination of redundant loads
- Store-to-load forwarding
- Memory access scheduling

**When to Use @mdep**:

Use `@mdep` to explicitly declare dependencies when:

1. **Memory Aliasing**:
   ```c
   @func copy_with_overlap src, dst, size {
       @mdep src, dst             // src and dst may overlap
       // Prevents unsafe reordering of loads/stores
   }
   ```

2. **Shared Memory Segments**:
   ```c
   @mdep shared_input, shared_output  // Concurrent access possible
   ```

3. **Pointer Aliasing**:
   ```c
   @func process_pointers ptr1, ptr2 {
       @mdep ptr1, ptr2           // Pointers may point to same memory
       load *ptr1, val1
       stor val2, *ptr2           // Must respect dependency
       load *ptr1, val3           // Cannot assume val1 == val3
   }
   ```

**What Happens Without @mdep**:

If you don't declare dependencies, LASM may:
- Reorder memory operations that actually have dependencies
- Eliminate loads that are actually needed
- Produce incorrect code for aliased memory accesses

**Example of Incorrect Optimization Without @mdep**:

```c
// Without @mdep (UNSAFE if a and b alias)
@func unsafe_update a, b {
    load *a, val1
    stor 42, *b              // If b == a, this changes *a
    load *a, val2            // LASM may optimize this away, assuming val2 == val1
    @ret val2                // INCORRECT if a == b
}

// With @mdep (SAFE)
@func safe_update a, b {
    @mdep a, b               // Declare potential aliasing
    load *a, val1
    stor 42, *b              // If b == a, this changes *a
    load *a, val2            // LASM must reload from *a
    @ret val2                // CORRECT
}
```

**Scope**:

- Must be used in **local scope** (inside function body)
- Typically placed near the beginning of the function
- Affects all memory operations in the current function

**Performance Trade-off**:

- **With @mdep**: Correct but potentially slower (fewer optimizations)
- **Without @mdep**: Faster but unsafe if dependencies exist

**Best Practices**:

- Declare dependencies conservatively (better safe than sorry)
- Use when pointers may alias or overlap
- Document why dependency is needed
- Avoid declaring unnecessary dependencies (reduces optimization potential)

#### @bar - Optimization Barrier

Insert an optimization barrier to control optimization scope:

```c
// Syntax
@bar

// No parameters

// Examples
@icall setup_function
@bar                          // Isolate optimizations
@icall critical_function
@bar

@icall config_cvccr, 3
@icall config_scr, 3
@bar    // Mark address of next instruction
@icall _axpby_kernel, addrX, addrY, N, alpha, beta, = r1, r2
@bar
```

**Purpose**:

- **Isolates** contextual optimizations
- **Locates** optimization results for specific code sections
- **Prevents** unwanted optimization interactions between code regions

**Execution Mode Effects**:

1. **Single-Core Mode**:
   - Marks the **address** of the next instruction
   - Used for precise instrumentation and profiling
   - Helps locate specific code regions in output

2. **Multi-Core Mode**:
   - Serves as **synchronization point**
   - Ensures all preceding operations complete before proceeding
   - Acts like a memory barrier for cross-core visibility

**Optimization Effects**:

`@bar` prevents these optimizations from crossing the barrier:

1. **Code Motion**: Instructions won't be moved across `@bar`
2. **Inlining**: Function inlining stops at barriers
3. **Loop Optimizations**: Loop-invariant code motion is blocked
4. **Constant Propagation**: Constants don't propagate across barriers
5. **Dead Code Elimination**: DCE treats barrier as use of all live values

**Use Case 1: Preventing Optimization Interference**:

```c
@icall fast_function, input, = result
@bar                                // Isolate optimizations
@call slow_function, result         // Prevent optimization interference
```

**Use Case 2: Preventing Loop-Invariant Code Motion**:

Without `@bar`:
```c
LOOP: 1, 100
    @icall dat_copy, CHANNEL0, addrX+CORE_ID*N_INC, 0X11, 0X12, 0x13
    // LASM might hoist the inlined dat_copy outside the loop (WRONG)
[c] sub 1, c, c
[c] br LOOP
```

With `@bar`:
```c
LOOP: 1, 100
    @bar                              // Prevent hoisting
    @icall dat_copy, CHANNEL0, addrX+CORE_ID*N_INC, 0X11, 0X12, 0x13
    // The inlined dat_copy function will be blocked by @bar
    // and NOT hoisted outside the loop
[c] sub 1, c, c
[c] br LOOP
```

**Use Case 3: Isolating Optimization Contexts**:

```c
// Setup phase
@icall initialize_data
@icall configure_system
@bar                          // End setup phase

// Computation phase (optimized separately)
@icall compute_kernel
@bar                          // End computation phase

// Cleanup phase
@icall finalize_results
```

**Use Case 4: Precise Performance Measurement**:

```c
@bar                          // Start measurement point
@icall critical_kernel
@bar                          // End measurement point
// Ensures kernel code is not mixed with surrounding code
```

**When to Use @bar**:

- Isolating performance-critical sections
- Preventing unwanted inlining or code motion
- Ensuring correct execution order in multi-core scenarios
- Debugging optimization issues
- Marking specific code locations for profiling

**Performance Trade-off**:

- **Without @bar**: Maximum optimization, but may produce unexpected results
- **With @bar**: More predictable behavior, but fewer cross-region optimizations

#### @icp - Instruction Copy

Duplicate the following instruction or instruction group N times:

```c
// Syntax
@icp count
instruction [| parallel_instruction]

// Parameters:
// - count: Number of times to copy (positive integer)

// Example 1: Single instruction
@icp 3
vstor vr63, *ar2++[16]

// Expands to:
// vstor vr63, *ar2++[16]
// vstor vr63, *ar2++[16]
// vstor vr63, *ar2++[16]

// Example 2: Parallel instructions
@icp 2
  vstor vr63, *ar2++[32]
| vstor vr63, *+ar2[16]

// Expands to:
//   vstor vr63, *ar2++[32]
// | vstor vr63, *+ar2[16]
//   vstor vr63, *ar2++[32]
// | vstor vr63, *+ar2[16]

// Example 3: Multiple copies
@icp 5
vload *ar0++[16], vr1:vr0

// Expands to 5 identical vload instructions
```

**Behavior**:

1. **Instruction Duplication**:
   - Duplicates the next instruction (or instruction group) exactly `count` times
   - Each copy is identical to the original
   - Applies to the immediately following instruction(s)

2. **Parallelism Preservation**:
   - If instruction uses `|` for parallel execution, **parallelism is preserved**
   - Each copy maintains the same parallel structure
   - Useful for unrolling parallel instruction sequences

3. **Address Modification**:
   - Post-increment/decrement addressing modes work as expected
   - Each copy executes in sequence, modifying addresses progressively
   ```c
   @icp 3
   load *ar0++[1], val
   // First copy:  load *ar0++[1], val   (ar0 points to element 0, then increments)
   // Second copy: load *ar0++[1], val   (ar0 points to element 1, then increments)
   // Third copy:  load *ar0++[1], val   (ar0 points to element 2, then increments)
   // After all: ar0 has been incremented 3 times
   ```

**Use Cases**:

1. **Loop Unrolling Hint**:
   ```c
   @icp 4
   vload *ar0++[16], vr0
   // Loads 4 consecutive vector blocks
   ```

2. **Initialization**:
   ```c
   @icp 8
   vstor vr_zero, *ar_buffer++[16]
   // Zero out 8 vector regions
   ```

3. **Pipeline Filling**:
   ```c
   @icp 3
     vload *ar_in++[16], vr_temp
   | vadd vr_temp, vr_acc, vr_acc
   // Fill pipeline with 3 parallel operation pairs
   ```

**Interaction with Other Features**:

- **Variables**: Symbolic variables in copied instructions are the same variable
  ```c
  @icp 3
  add temp, 1, temp
  // temp = temp + 1 (three times) → temp = temp + 3
  ```

- **Constants**: Constants are duplicated as-is
  ```c
  @icp 2
  mov 42, r0
  // mov 42, r0 (twice) → Last write wins, r0 = 42
  ```

**Limitations**:

- Only applies to the **immediately following** instruction or parallel group
- Does not affect subsequent instructions
- Cannot nest `@icp` directives

**Comparison with Manual Duplication**:

```c
// Using @icp
@icp 3
vstor vr63, *ar2++[16]

// Equivalent manual code
vstor vr63, *ar2++[16]
vstor vr63, *ar2++[16]
vstor vr63, *ar2++[16]
```

Both produce identical results, but `@icp` is more concise and maintainable.

## Constants and Expressions

### Integer Constants

Four numeral systems are supported:

| System | Format | Meaning | Examples |
|--------|--------|---------|----------|
| Binary | `0[bB][01]+` | Complement | `0b101`, `0B1111` |
| Octal | `0[oO][0-7]+` | Complement | `0O17`, `0o77` |
| Decimal | `[+-]?[0-9]+` | Numeric value | `42`, `-100`, `+255` |
| Hexadecimal | `0[xX][0-9a-fA-F]+` | Complement | `0xFF`, `0x1A2B` |

**Important**:
- Only decimal constants have numeric meaning
- Other formats are 64-bit two's complement representations
- Decimal range: -9,223,372,036,854,775,808 to 18,446,744,073,709,551,615
- All constants occupy 64 bits (zero-padded if smaller, truncated with warning if larger)
- Constants are **not** sign-extended

### Floating-Point Constants

Three forms are accepted:

```c
// 1. IEEE754 hexadecimal (instruction operands only)
mov 0x3FF0000000000000, r0    // Double-precision 1.0

// 2. Decimal notation
1.5
-2.75
3.0

// 3. Scientific notation
1.5e-3      // 0.0015
-2.5e+2     // -250.0
```

Floating-point constants are interpreted as double-precision IEEE754 unless used in a context requiring a different precision.

### Character Constants

Single characters enclosed in single quotes:

```c
'a'     // 0x61
'A'     // 0x41
'\n'    // 0x0A (newline)
'\\'    // 0x5C (backslash)
'\''    // 0x27 (single quote)
''      // 0x00 (empty character)
```

Characters are 8-bit ASCII values, zero-extended to 64 bits.

### String Constants

Strings are sequences of characters:

```c
"hello"         // Character sequence
"line1\nline2"  // Escape sequences supported
```

**Behavior in Pseudo-Operations**:
```c
@b32 x, "abc"           // 'a','b','c' concatenated -> 0x00616263
@sect ".data", arr, @b8, "ab", 'c'  // Stores: 0x62, 0x63
```

Strings are concatenated into integers, then stored according to the specified bit width. High-order bits are truncated if the string exceeds the width.

### Symbolic Constants and Properties

Symbols defined by storage pseudo-operations become symbolic constants:

```c
@b64 SIZE, 1024
@bf PI, 3.14159

// Can be used in expressions
@b64 DOUBLE_SIZE, SIZE * 2
```

**Symbolic Properties**:

Address indicators (memory locations, function names, labels) have properties:

```c
.cnt    // Number of elements
.gra    // Bytes per element (granularity)

// Example
@usect ".bss", buffer, @b32, 256
// buffer.cnt = 256
// buffer.gra = 4 (32 bits = 4 bytes)
```

### Constant Expressions

Combine constants using operators:

```c
@b64 N, 24576 // 32             // Integer division
@b64 size, N * 4                // Multiplication
mov (i + 1) * 8, offset         // Expression in instruction
```

**Operator Precedence** (highest to lowest):

| Level | Operators | Description |
|-------|-----------|-------------|
| 0 | `(`, `)` | Parentheses |
| 1 | `+`, `-`, `~`, `!` | Unary |
| 2 | `*`, `/`, `//`, `%` | Multiplicative |
| 3 | `+`, `-` | Additive |
| 4 | `<<`, `>>` | Shift |
| 5 | `<`, `<=`, `>`, `>=`, `==`, `!=` | Comparison |
| 6 | `&` | Bitwise AND |
| 7 | `^` | Bitwise XOR |
| 8 | `|` | Bitwise OR |
| 9 | `&&` | Logical AND |
| 10 | `||` | Logical OR |

**Key Distinctions**:
- `/` - Floating-point division (result is double-precision IEEE754)
- `//` - Integer division with floor rounding
- If **any** operand is floating-point, result is double-precision
- If **all** operands are integers, result is 64-bit integer

```c
@b64 x, (1 + 2) * 3     // Result: 9 (integer)
@b64 y, (1.0 + 2) * 3   // Result: 0x4020000000000000 (double 9.0)
@b64 z, 100 // 3        // Result: 33 (floor division)
```

## Program Structure

### Pseudo-Operation Scopes

**Global Scope** (outside function bodies):
- `@func`, `@main` - Function declarations
- `@sect`, `@usect` - Segment management
- `@align` - Alignment directives
- `@import` - File imports
- `@bN`, `@bh`, `@bf`, `@bd` - Constant definitions (can also appear locally)

**Local Scope** (inside function bodies only):
- `label:` - Labels and loop annotations
- `@ret` - Function return
- `@call`, `@icall` - Function calls
- `@asg` - Register assignments
- `@mdep` - Memory dependencies
- `@icp` - Instruction copy
- `@bar` - Optimization barrier
- `@dreg` - Disable registers
- `@bN`, `@bh`, `@bf`, `@bd` - Local constants

### File Organization

Typical LAN file structure:

```c
// 1. Imports
@import "../lib/utilities.lan", helper1, helper2

// 2. Global constants
@b64 BUFFER_SIZE, 4096
@bf ALPHA, 0.5

// 3. Data segments
@sect ".data", init_array, @b32, 1, 2, 3, 4
@usect ".bss", workspace, @b64, 256

// 4. Code segment
@sect ".text"

// 5. Function definitions
@func helper arg1, arg2 {
    // Implementation
    @ret result
}

@main entry_point {
    @call helper, x, y, = z
    @ret
}
```

### Multi-File Projects

Projects can span multiple LAN files:

**File: math.lan**
```c
@sect ".text"
@func add a, b {
    add a, b, sum
    @ret sum
}

@func multiply a, b {
    mul a, b, product
    @ret product
}
```

**File: main.lan**
```c
@import "math.lan", add, multiply

@main start {
    @call add, 10, 20, = x
    @call multiply, x, 3, = y
    @ret
}
```

LASM resolves cross-file references during linking.
