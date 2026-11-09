# Potato VLIW Processor - LASM Extension Guide

**Potato** is a fictional VLIW (Very Long Instruction Word) vector processor designed to demonstrate how to extend LASM for new VLIW architectures. It serves as a reference implementation showing machine description file structure, LAN assembly programs, and compilation workflow.

---

## Quick Start

### Prerequisites

The Potato example includes a pre-built LASM compiler for Linux (x86_64). Grant executable permissions before use:

```bash
chmod +x tools/lasm
```

### Compile Your First Program

```bash
# Compile scalar GEMM example
./tools/lasm lan4test/gemm_scalar.lan \
    --layout tools/potato.json \
    --dce --licm \
    --laems --ec=0-8 --ims --sms --fbbfc --fbbfl --tdlsc --tdlsl \
    --output gemm_scalar.s

# Compile vector GEMM with fused multiply-add
./tools/lasm lan4test/sgemm_vector_muladd.lan \
    --layout tools/potato.json \
    --dce --licm \
    --laems --ec=0-8 --ims --fbbfc --fbbfl --tdlsc --tdlsl \
    --output sgemm_muladd.s

# Compile vector GEMM with separate multiply and add
./tools/lasm lan4test/sgemm_vector_mul_and_add.lan \
    --layout tools/potato.json \
    --dce --licm \
    --laems --ec=0-8 --ims --fbbfc --fbbfl --tdlsc --tdlsl \
    --output sgemm_mul_add.s
```

**View all LASM options:** `./tools/lasm --help`

---

## Directory Structure

```
Potato/
├── README.md              # This file
├── lan4test/              # Example LAN programs
│   ├── gemm_scalar.lan    # Scalar matrix multiplication
│   ├── sgemm_vector_muladd.lan          # Vector GEMM (fused multiply-add)
│   └── sgemm_vector_mul_and_add.lan     # Vector GEMM (separate mul/add)
└── tools/                 # LASM compiler and configuration
    ├── lasm               # Pre-built LASM executable (Linux x86_64)
    └── potato.json        # Memory layout and calling convention config
```

---

## Compilation Workflow

### Basic Compilation

```bash
./tools/lasm <input.lan> \
    --layout tools/potato.json \
    --output <output.s>
```

- `<input.lan>`: LAN assembly source file
- `--layout tools/potato.json`: Memory layout and ABI configuration
- `--output <output.s>`: Generated assembly output

### Scheduling Strategy Options

LASM supports multiple scheduling strategies that can be composed:

| Option | Type | Description |
|--------|------|-------------|
| `--laems` | Cyclic (loop) | Longevity-Aware Expanded Modulo Scheduling |
| `--ec=<l-h>` | Parameter | Expansion Count range for LAEMS, e.g., `--ec=0-8` |
| `--fbbfc` | Cyclic (loop) | Front-Back Block Fusion for loops |
| `--fbbfl` | Linear (basic block) | Front-Back Block Fusion for basic blocks |
| `--tdlsc` | Cyclic (loop) | Top-Down List Scheduler for loops |
| `--tdlsl` | Linear (basic block) | Top-Down List Scheduler for basic blocks |
| `--ims` | Cyclic (loop) | Iterative Modulo Scheduling |
| `--sms` | Cyclic (loop) | Swing Modulo Scheduling |

### Pre-Scheduling Optimizations

| Option | Description |
|--------|-------------|
| `--dce` | Dead Code Elimination |
| `--licm` | Loop Invariant Code Motion |
| `--max-inline=<N>` | Maximum instructions for function inlining (default: 512) |

### Example: Full Multi-Strategy Compilation

```bash
./tools/lasm lan4test/sgemm_vector_muladd.lan \
    --layout tools/potato.json \
    --laems --ec=0-8 --dce --licm \
    --tdlsl --fbbfl --tdlsc --ims --fbbfc \
    --output sgemm_optimized.s
```

LASM executes all enabled strategies in parallel and selects the best schedule for each code region.

---

## Potato Processor Overview

**Potato** is a fictional VLIW vector processor designed to demonstrate how to extend LASM for new VLIW architectures. It serves as a reference implementation for defining machine description files.

### Register File

| Type | Name | Count | Width | Description |
|------|------|-------|-------|-------------|
| Scalar | `R0`-`R63` | 64 | 64-bit | General-purpose scalar registers |
| Address | `AR0`-`AR15` | 16 | 36-bit | Address registers for memory operations |
| Offset | `OR0`-`OR15` | 16 | 36-bit | Offset registers for addressing calculations |
| Vector | `VR0`-`VR63` | 64 | 64-bit × 16 lanes | Vector registers (16-wide SIMD) |

**Register Naming**:
- Register names are case-sensitive: `R0`, `AR5` and `VR10` are physical registers
- Lowercase names such as `r0`, `ar_5` or `vr10` are symbolic variables allocated by LASM

### Functional Units

Potato's default configuration (`_TARGET_CFG == 6`) has 15 functional units in 5 groups:

| Unit | Group | Purpose |
|------|-------|---------|
| A1, A2 | Group 0 | Scalar load/store |
| B1 | Group 1 | Branch/control flow |
| C1, C2 | Group 2 | Scalar arithmetic (add, sub, mul, mov) |
| D1, D2 | Group 3 | Vector load/store |
| E1-E8 | Group 4 | Vector arithmetic (vadd, vmul, vmuladd, vsub) |

Each unit issues at most one instruction per cycle, so up to 15 instructions can execute in parallel. Units in the same group serve the same class of instructions.

### Instruction Set Summary

**Scalar Operations**:
- `mov` - Move data between registers or from immediate
- `add` - Addition (supports AR, OR, and R registers)
- `sub` - Subtraction
- `mul` - Multiplication
- `load` - Load from memory
- `stor` - Store to memory
- `br` - Branch (conditional or unconditional)
- `nop` - No operation

**Vector Operations**:
- `vmov` - Vector move
- `vadd` - Vector addition
- `vmul` - Vector multiplication
- `vmuladd` - Fused vector multiply-add
- `vsub` - Vector subtraction
- `bcast` - Broadcast scalar to vector
- `vload` - Vector load (supports register groups for wider loads)
- `vstor` - Vector store

**Addressing**:
- Supports immediate offsets: `*ar++[N]`, `*+ar[N]`
- Supports offset register: `*ar++[or]`
- Memory increment/decrement modes

### Conditional Execution

Scalar instructions can be predicated on `R0`-`R6`; vector arithmetic and vector memory instructions use vector predicates (`VR0`-`VR6`):
```c
[R5] add 1, counter, counter    ; Execute if R5 != 0
[!R0] br exit_label              ; Execute if R0 == 0
```

### Instruction Parallelism

Example of one VLIW packet (6 instructions issued in the same cycle):
```c
  load *AR0++[1], R1             ; A1 unit
| load *AR1++[1], R2             ; A2 unit
| add R1, R2, R3                 ; C1 unit
| sub R4, R5, R6                 ; C2 unit
| vload *AR4++[16], VR1:VR0     ; D1 unit
| vadd VR1, VR2, VR3             ; E1 unit
```

Note: Actual parallel execution depends on dependencies and resource availability. LASM handles dependency analysis and resource conflict detection.



## Examples

### Example 1: Scalar Matrix Multiply

Simple scalar GEMM (General Matrix Multiply) kernel demonstrating basic LAN features:

```c
; Start code segment
@sect ".text"
@func _sample_code addrA, addrB, addrC, M, N, K { ; Function: C = A * B
                                                  ; Parameters: addresses and dimensions
    ; Initialize address pointers (symbolic variables, will be allocated to address registers)
    mov addrA, aA                                 ; aA points to matrix A
    mov addrB, aB                                 ; aB points to matrix B
    mov addrC, aC                                 ; aC points to matrix C (output)
    mov M, i                                      ; i = outer loop counter (M iterations)

_LOOP_M:                                          ; Outer loop: iterate over M rows
    mov N, j                                      ; j = middle loop counter (N iterations)
    _LOOP_N: 512, 512                             ; Middle loop: N columns (bounds hint: exactly 512)
        mov 0, ts                                 ; ts = temporary sum (accumulator for dot product)
        mov K, k                                  ; k = inner loop counter (K iterations)
        _LOOP_K: 64, 64                           ; Inner loop: K elements (bounds hint: exactly 64)
            load *aA++[1], ta                     ; Load A[i,k] into ta, then aA += 1
            load *aB++[1], tb                     ; Load B[k,j] into tb, then aB += 1
            mul ta, tb, t                         ; t = ta * tb (multiply corresponding elements)
            add t, ts, ts                         ; ts += t (accumulate into sum)
            sub 1, k, k                           ; k-- (decrement inner loop counter)
            [k] br _LOOP_K                        ; If k != 0, branch back to _LOOP_K (continue inner loop)

        ; Inner loop done: ts contains dot product result
        load *aC++[1], tc                         ; Load C[i,j] into tc, then aC += 1
        sub ts, tc, tc                            ; tc = ts - tc (compute final value: A*B - C)
        stor tc, *aC                              ; Store tc back to C[i,j] (aC already incremented)
        sub 1, j, j                               ; j-- (decrement middle loop counter)
        [j] br _LOOP_N                            ; If j != 0, branch back to _LOOP_N (continue middle loop)

    ; Middle loop done
    sub 1, i, i                                   ; i-- (decrement outer loop counter)
    [i] br _LOOP_M                                ; If i != 0, branch back to _LOOP_M (continue outer loop)

    ; All loops done
    @ret                                          ; Return from function (no return value)
}
```

**Key Features Demonstrated**:
- **Loop Annotations**: `_LOOP_N: 512, 512` provides iteration bounds for optimization
- **Symbolic Variables**: `ts`, `ta`, `tb`, `tc`, `t` are allocated by the framework
- **Post-Increment Addressing**: `*aA++[1]` loads from `*aA`, then `aA += 1`
- **Conditional Branches**: `[k] br _LOOP_K` executes only if `k != 0`
- **Nested Loop Structure**: Three-level nesting (M, N, K) for matrix multiply
- **Memory Access Pattern**: Sequential access through matrices A, B, C

### Example 2: Vector GEMM with Separate Multiply-Add

Vector GEMM using separate `vmul` and `vadd` instructions for explicit pipeline control:

```c
; Start code segment
@sect ".text"
@func _sgemm_64_mul_and_add addrA, addrB, addrC, M, K, N { ; Vector GEMM: C = A * B
                                                            ; Operates on 64-element vectors

    ; Initialize loop counter and address pointers
    mov     M, i                                 ; i = outer loop counter (M iterations)
    mov     addrA, ar_a                          ; ar_a = pointer to matrix A
    mov     addrC, ar_c                          ; ar_c = pointer to matrix C (output)

_LOOP_M:                                         ; Outer loop: iterate over M rows
    mov     addrB, ar_b                          ; Reset ar_b to start of matrix B for each row
    mov     K, k                                 ; k = inner loop counter (K iterations)

    ; Initialize vector accumulators to zero (will hold partial sums)
    vmov    0, ab_0                              ; ab_0 = zero vector (lower 16 FP32 elements)
    vmov    0, ab_1                              ; ab_1 = zero vector (upper 16 FP32 elements)
                                                 ; Together ab_1:ab_0 handles 32 FP32 elements

_LOOP_K: 512, 512                                ; Inner loop: K iterations (bounds hint: exactly 512)
    ; Load scalar from A and broadcast to all vector lanes
    load    *ar_a++, a_1                         ; Load A[i,k] (scalar), then ar_a += 1
    bcast   a_1, a_N                             ; Broadcast a_1 to all lanes of vector a_N
                                                 ; Now a_N = {a_1, a_1, a_1, ..., a_1}

    ; Load vector from B (32 FP32 elements = 2 vector registers)
    vload   *ar_b++[16], b_1:b_0                 ; Load B[k,j:j+31] into register pair
                                                 ; b_0 = B[k, j:j+15] (16 FP32 elements)
                                                 ; b_1 = B[k, j+16:j+31] (16 FP32 elements)
                                                 ; Then ar_b += 16 (advance by 16 elements)

    ;;;                                          ; Visual separator (a comment)
                                                 ; Marks VLIW instruction word boundary

    ; Perform vector multiply and add (separate operations)
    vmul    b_0, a_N, t0                         ; t0 = b_0 * a_N (element-wise multiply, 16 elements)
    vadd    t0, ab_0, ab_0                       ; ab_0 += t0 (accumulate into lower accumulator)
    vmul    b_1, a_N, t1                         ; t1 = b_1 * a_N (element-wise multiply, 16 elements)
    vadd    t1, ab_1, ab_1                       ; ab_1 += t1 (accumulate into upper accumulator)

    ;;;                                          ; Visual separator (a comment)

[k] sub     1, k, k                              ; k-- (decrement inner loop counter)
[k] br      _LOOP_K                              ; If k != 0, continue inner loop

    ; Inner loop done: ab_1:ab_0 contains accumulated results

    ; Load C vector, compute final result, and store back
    vload   *ar_c, c_1:c_0                       ; Load C[i, j:j+31] into register pair
                                                 ; c_0 = C[i, j:j+15], c_1 = C[i, j+16:j+31]

    vsub    ab_0, c_0, c_0                       ; c_0 = ab_0 - c_0 (compute final lower 16 elements)
    vsub    ab_1, c_1, c_1                       ; c_1 = ab_1 - c_1 (compute final upper 16 elements)

    vstor   c_1:c_0, *ar_c++[16]                 ; Store c_1:c_0 back to C[i, j:j+31]
                                                 ; Then ar_c += 16 (advance by 16 elements)

[i] sub     1, i, i                              ; i-- (decrement outer loop counter)
[i] br      _LOOP_M                              ; If i != 0, continue outer loop

    ; All loops done
    @ret                                         ; Return from function
}
```

**Key Features Demonstrated**:
- **Vector Register Pairs**: `b_1:b_0` and `c_1:c_0` hold 32 FP32 elements (2×16)
- **Broadcasting**: `bcast a_1, a_N` replicates scalar to all vector lanes
- **Vector Load/Store**: `vload`, `vstor` handle multiple elements per instruction
- **Visual Separators**: `;;;` is a comment that groups related instructions; LASM decides the actual bundling
- **Vector Arithmetic**: `vmul`, `vadd`, `vsub` operate element-wise on vectors
- **Separate Multiply-Add**: Explicit `vmul` followed by `vadd` (vs. fused in Example 3)
- **Post-Increment Addressing**: `*ar_b++[16]` advances pointer by 16 elements

### Example 3: Vector GEMM with Fused Multiply-Add

Version using the fused `vmuladd` instruction:

```c
; Start code segment
@sect ".text"
@func _sgemm_64_muladd addrA, addrB, addrC, M, K, N { ; Vector GEMM: C = A * B
                                                      ; Uses fused multiply-add for efficiency

    ; Initialize loop counter and address pointers (identical to Example 2)
    mov     M, i                                 ; i = outer loop counter (M iterations)
    mov     addrA, ar_a                          ; ar_a = pointer to matrix A
    mov     addrC, ar_c                          ; ar_c = pointer to matrix C (output)

_LOOP_M:                                         ; Outer loop: iterate over M rows
    mov     addrB, ar_b                          ; Reset ar_b to start of matrix B for each row
    mov     K, k                                 ; k = inner loop counter (K iterations)

    ; Initialize vector accumulators to zero
    vmov    0, ab_0                              ; ab_0 = zero vector (lower 16 FP32 elements)
    vmov    0, ab_1                              ; ab_1 = zero vector (upper 16 FP32 elements)

_LOOP_K: 512, 512                                ; Inner loop: K iterations (bounds hint: exactly 512)
    ; Load and broadcast scalar from A (identical to Example 2)
    load    *ar_a++, a_1                         ; Load A[i,k] (scalar), then ar_a += 1
    bcast   a_1, a_N                             ; Broadcast a_1 to all lanes of vector a_N

    ; Load vector from B (identical to Example 2)
    vload   *ar_b++[16], b_1:b_0                 ; Load B[k,j:j+31] into register pair
                                                 ; b_0 = lower 16 elements, b_1 = upper 16 elements
                                                 ; Then ar_b += 16

    ;;;                                          ; Visual separator (a comment)

    ; FUSED multiply-add operations (KEY DIFFERENCE from Example 2)
    vmuladd b_0, a_N, ab_0, ab_0                 ; ab_0 = b_0 * a_N + ab_0
                                                 ; Fuses multiply and add into single operation
                                                 ; Syntax: vmuladd src1, src2, src3, dest
                                                 ; Computes: dest = src1 * src2 + src3

    vmuladd b_1, a_N, ab_1, ab_1                 ; ab_1 = b_1 * a_N + ab_1
                                                 ; Same fused operation for upper 16 elements

    ;;;                                          ; Visual separator (a comment)

[k] sub     1, k, k                              ; k-- (decrement inner loop counter)
[k] br      _LOOP_K                              ; If k != 0, continue inner loop

    ; Post-loop processing (identical to Example 2)
    vload   *ar_c, c_1:c_0                       ; Load C[i, j:j+31] into register pair
    vsub    ab_0, c_0, c_0                       ; c_0 = ab_0 - c_0 (compute final lower 16 elements)
    vsub    ab_1, c_1, c_1                       ; c_1 = ab_1 - c_1 (compute final upper 16 elements)
    vstor   c_1:c_0, *ar_c++[16]                 ; Store results back to C[i, j:j+31]

[i] sub     1, i, i                              ; i-- (decrement outer loop counter)
[i] br      _LOOP_M                              ; If i != 0, continue outer loop

    ; All loops done
    @ret                                         ; Return from function
}
```

**Key Improvements Over Example 2**:

1. **Fused Multiply-Add**:
   - Example 2: Two instructions (`vmul` + `vadd`) per vector operation
   - Example 3: One instruction (`vmuladd`) per vector operation
   - **Result**: 50% fewer arithmetic instructions in the hot loop

2. **Performance Benefits**:
   - Reduced instruction count → fewer VLIW instruction words
   - Better instruction packing → more parallel execution
   - Fewer intermediate registers → reduced register pressure
   - One latency instead of two → shorter dependency chain

3. **Hardware Efficiency**:
   - `vmuladd` typically uses dedicated FMA (Fused Multiply-Add) units
   - No rounding between multiply and add → better numerical accuracy
   - Lower power consumption (one operation vs. two)

**Comparison**:

| Aspect | Example 2 (Separate) | Example 3 (Fused) |
|--------|---------------------|-------------------|
| Instructions per iteration | 4 arithmetic ops | 2 arithmetic ops |
| Register pressure | Higher (need temp t0, t1) | Lower (no temps) |
| Latency | 7 cycles (`vmul` 6 + `vadd` 1) | 6 cycles |
| Numerical accuracy | 2 rounding steps | 1 rounding step |
| Code size | Larger | Smaller |

**When to Use Each**:
- Use **Example 2** when: Target doesn't support FMA, need pipeline visibility
- Use **Example 3** when: Target supports FMA (most modern processors do)

### Example 4: Loop with Register Assignment

Demonstrating explicit register allocation using `@asg`:

```c
@sect ".text"
@func compute_kernel addr_in, addr_out, N {     ; Function: sum elements and store result
                                                 ; Parameters: input addr, output addr, count

    ; EXPLICIT REGISTER ASSIGNMENTS (using @asg directive)
    @asg addr_in, AR0                            ; Force addr_in to use address register AR0
                                                 ; From now on, addr_in is synonymous with AR0
    @asg addr_out, AR1                           ; Force addr_out to use address register AR1
    @asg N, R5                                   ; Force N to use scalar register R5

    ; Initialize accumulator (symbolic variable, will be auto-allocated)
    mov 0, sum                                   ; sum = 0 (framework chooses register for 'sum')

loop: 1, 1000                                    ; Loop: 1 to 1000 iterations (bounds hint)
    load *AR0++[1], val                          ; Load value from *AR0 into 'val'
                                                 ; Then AR0 += 1 (advance to next element)
                                                 ; 'val' is a symbolic variable (auto-allocated)

    add sum, val, sum                            ; sum += val (accumulate)

    sub 1, R5, R5                                ; R5-- (decrement N, which is assigned to R5)
                                                 ; Using explicit register R5 because of @asg

    [R5] br loop                                 ; If R5 != 0, continue loop
                                                 ; Conditional branch on explicitly assigned register

    ; Store result
    stor sum, *AR1                               ; Store accumulated sum to *AR1 (output address)
                                                 ; AR1 is the explicitly assigned register for addr_out

    @ret                                         ; Return from function
}
```

**Key Features Demonstrated**:

1. **Explicit Register Assignment (`@asg`)**:
   - `@asg addr_in, AR0` → All uses of `addr_in` map to `AR0`
   - `@asg addr_out, AR1` → All uses of `addr_out` map to `AR1`
   - `@asg N, R5` → All uses of `N` map to `R5`
   - Framework will NOT re-allocate these variables

2. **Mixed Allocation Strategy**:
   - `addr_in`, `addr_out`, `N`: Explicitly assigned by user
   - `sum`, `val`: Automatically allocated by framework
   - This provides control where needed, flexibility where possible

3. **Register Usage**:
   - `AR0`, `AR1`: Explicitly assigned address registers (user-controlled)
   - `R5`: Explicitly assigned scalar register (user-controlled)
   - Registers for `sum` and `val`: Framework-chosen

**Why Use @asg**:

1. **Performance Tuning**: Force specific register choices for optimal pipeline usage
2. **ABI Compliance**: Match calling conventions or external interfaces
3. **Debugging**: Reproduce specific register allocation for testing
4. **Hardware Constraints**: Work around register limitations or bugs

**Without @asg** (for comparison):
```c
@sect ".text"
@func compute_kernel addr_in, addr_out, N {
    ; No @asg directives
    ; Framework automatically allocates ALL registers
    mov 0, sum
loop: 1, 1000
    load *addr_in++[1], val       ; Framework chooses register for addr_in
    add sum, val, sum
    sub 1, N, N                   ; Framework chooses register for N
    [N] br loop
    stor sum, *addr_out           ; Framework chooses register for addr_out
    @ret
}
; Framework has full flexibility to optimize register allocation
```

**Trade-offs**:

| Approach | Pros | Cons |
|----------|------|------|
| With @asg | Predictable, user control | Constrains allocation and scheduling |
| Without @asg | LASM chooses all registers | Less predictable, harder to debug |

### Example 5: Multi-File Program

Demonstrating modular program structure with cross-file function calls:

**File: vector_ops.lan** (Library file with reusable vector operations)
```c
; Start code segment
@sect ".text"

@func vector_add vec_a, vec_b, vec_c, count {   ; Vector addition: vec_c = vec_a + vec_b
                                                 ; Parameters: three vector addresses, element count

    ; Initialize address pointers
    mov vec_a, ar_a                              ; ar_a points to input vector A
    mov vec_b, ar_b                              ; ar_b points to input vector B
    mov vec_c, ar_c                              ; ar_c points to output vector C
    mov count, k                                 ; k = loop counter (number of vector blocks)

loop: 1, 64                                      ; Loop: process up to 64 vector blocks
                                                 ; Each iteration handles 32 FP32 elements (2 vectors)

    ; Load vectors from A and B (32 elements = 2 vector registers)
    vload *ar_a++[16], a_1:a_0                   ; Load A[i:i+31] into register pair a_1:a_0
                                                 ; a_0 = A[i:i+15], a_1 = A[i+16:i+31]
                                                 ; Then ar_a += 16 (advance by 16 elements)

    vload *ar_b++[16], b_1:b_0                   ; Load B[i:i+31] into register pair b_1:b_0
                                                 ; b_0 = B[i:i+15], b_1 = B[i+16:i+31]
                                                 ; Then ar_b += 16

    ; Perform element-wise addition
    vadd a_0, b_0, c_0                           ; c_0 = a_0 + b_0 (lower 16 elements)
    vadd a_1, b_1, c_1                           ; c_1 = a_1 + b_1 (upper 16 elements)

    ; Store result vector
    vstor c_1:c_0, *ar_c++[16]                   ; Store C[i:i+31] = c_1:c_0
                                                 ; Then ar_c += 16 (advance output pointer)

    ; Loop control
    sub 1, k, k                                  ; k-- (decrement loop counter)
    [k] br loop                                  ; If k != 0, continue loop

    @ret                                         ; Return from function (no return value)
}
; This function can be imported and used by other files
```

**File: main.lan** (Main program that uses the library)
```c
; IMPORT FUNCTION FROM LIBRARY FILE
@import "vector_ops.lan", vector_add            ; Import vector_add function from vector_ops.lan
                                                ; Now we can call vector_add in this file

; INITIALIZE DATA IN .data SEGMENT
@sect ".data", array_a, @b32, 1, 2, 3, 4, 5, 6, 7, 8
                                                ; Define array_a in .data segment
                                                ; Initialize with 8 32-bit values: 1,2,3,4,5,6,7,8
                                                ; array_a.cnt = 8, array_a.gra = 4

@sect ".data", array_b, @b32, 10, 20, 30, 40, 50, 60, 70, 80
                                                ; Define array_b in .data segment
                                                ; Initialize with 8 32-bit values: 10,20,30,40,50,60,70,80
                                                ; array_b.cnt = 8, array_b.gra = 4

; RESERVE SPACE IN .bss SEGMENT (uninitialized)
; Reserve space for array_c in .bss segment
@usect ".bss", array_c, @b32, 8
                                                ; 8 elements × 4 bytes = 32 bytes total
                                                ; array_c.cnt = 8, array_c.gra = 4
                                                ; After @usect, automatically return to previous segment (.data)

; DEFINE CONSTANT
@b64 COUNT, 1                                   ; COUNT = 1 (process 1 vector block)

; DEFINE ENTRY POINT
; Switch back to the code segment
@sect ".text"
@main test_addition {                           ; Main function (program entry point)

    ; LOAD DATA ADDRESSES (data symbols are address constants)
    mov array_a, pa
    mov array_b, pb
    mov array_c, pc

    ; CALL IMPORTED FUNCTION
    @icall vector_add, pa, pb, pc, COUNT
                                                ; Inline call hint to vector_add function
                                                ; Arguments:
                                                ;   vec_a = pa (address of array_a)
                                                ;   vec_b = pb (address of array_b)
                                                ;   vec_c = pc (address of array_c)
                                                ;   count = COUNT (number of blocks = 1)
                                                ; Computes: array_c = array_a + array_b
                                                ; Result: array_c = {11, 22, 33, 44, 55, 66, 77, 88}

_halt:                                          ; @main does not return:
    br _halt                                    ; finish with an idle loop
}
```

**Key Features Demonstrated**:

1. **Cross-File Function Import**:
   - `@import "vector_ops.lan", vector_add` makes `vector_add` callable
   - Function defined in one file, used in another
   - Promotes code reuse and modularity

2. **Data Segment Initialization**:
   - `@sect ".data", symbol, type, values...` creates initialized data
   - `array_a` and `array_b` initialized with concrete values
   - Data resides in read-write memory

3. **BSS Segment Reservation**:
   - `@usect ".bss", symbol, type, count` reserves uninitialized space
   - `array_c` allocated but not initialized (will hold results)
   - Saves space in binary (no initial values stored)

4. **Symbolic Constants**:
   - `@b64 COUNT, 1` defines a named constant
   - Can be used throughout the program
   - Improves code readability and maintainability

5. **Inline Call Hint**:
   - `@icall` suggests inlining the function
   - Framework may inline `vector_add` into `test_addition`
   - Eliminates call overhead for better performance

**Build Process**:

Compile the entry file only; LASM follows `@import` and builds the whole program in one invocation:

```bash
./tools/lasm main.lan --layout tools/potato.json --dce --licm --laems --fbbf --tdls --output main.s
```

**Program Execution Flow**:

```
Program Start
  ↓
test_addition (main)
  ↓
vector_add(array_a, array_b, array_c, COUNT=1)
  ↓
Process 32 elements (1 block)
  ↓
Return to test_addition
  ↓
Idle loop (_halt)
```

**Expected Result**:

```
array_c[0:7] = {11, 22, 33, 44, 55, 66, 77, 88}
```
---

## Machine Description Files

The `machine/` directory contains five files that define the Potato processor architecture for LASM. These files are required for LASM to understand the target processor's capabilities and constraints.

### Register File (`machine/register`)

Defines all register types available in the processor:

```c
HANDLE_REGISTER(R,  64, 0, 63, 0, 0,  0, 1)  // Scalar registers: R0-R63 (64-bit)
HANDLE_REGISTER(AR, 36, 0, 15, 0, 0,  0, 1)  // Address registers: AR0-AR15 (36-bit)
HANDLE_REGISTER(OR, 36, 0, 15, 0, 0,  0, 1)  // Offset registers: OR0-OR15 (36-bit)
HANDLE_REGISTER(VR, 64, 0, 63, 0, 15, 0, 1)  // Vector registers: VR0-VR63 (64-bit × 16 lanes)
```

**Format**: `HANDLE_REGISTER(prefix, bitwidth, start_id, end_id, lane_start, lane_end, enable2, allocatable)`

### Functional Units (`machine/funit`)

Defines execution units and their grouping for VLIW instruction packing:

```c
#define _TARGET_CFG   6  // Default configuration: 15 functional units

HANDLE_FUNIT(A1, 0, .A1, 1)  // Group 0: Scalar load/store
HANDLE_FUNIT(A2, 0, .A2, 1)
HANDLE_FUNIT(B1, 1, .B1, 1)  // Group 1: Branch/control flow
HANDLE_FUNIT(C1, 2, .C1, 1)  // Group 2: Scalar arithmetic
HANDLE_FUNIT(C2, 2, .C2, 1)
HANDLE_FUNIT(D1, 3, .D1, 1)  // Group 3: Vector load/store
HANDLE_FUNIT(D2, 3, .D2, 1)
HANDLE_FUNIT(E1, 4, .E1, 1)  // Group 4: Vector arithmetic
...
HANDLE_FUNIT(E8, 4, .E8, 1)
```

**Format**: `HANDLE_FUNIT(unit_name, group_id, text_suffix, enabled)`
- **group_id**: Functional group; units in the same group serve the same class of instructions
- **_TARGET_CFG**: Determines how many functional units are active

### Instruction Set (`machine/instruct`)

Defines all supported instructions with operand types, latencies, and functional unit bindings:

```c
// Example: Vector multiply-add instruction
HANDLE_INST(1,   OP, INST_OPRULE("*,+:1,2,3",  F2), 1, vmuladd,
    C=X:VR:0:6{}S=X:VR:0:63{}S=X:VR:0:63{}S=X:VR:0:63{}D=X:VR:0:63{6:6},
    6,
    INST_MCODE(7, 40, E1:0:E2:0:E3:0:E4:0:E5:0:E6:0:E7:0:E8:0))
```

**Format**: `HANDLE_INST(enabled, kind, OPRULE, enable_temp, mnemonic, operands, latency, MCODE)`
- **kind**: Instruction category (NOP, JUMP, LOAD, STOR, OP, MOV)
- **OPRULE**: Algebraic rule for optimization (e.g., "*,+:1,2,3" for multiply-add)
- **operands**: Condition (C), Source (S), Destination (D) with register types and ranges
- **latency**: {read_latency:write_latency} in cycles
- **MCODE**: Machine code encoding reference

### Execution Constraints (`machine/limits`)

Defines additional constraints on instruction packing beyond functional unit conflicts:

```c
static bool INSTEXECPACK(INST_BITN_CNT_MAP& MPBITS) {
    // Example: Limit total instruction word size
    // Example: Restrict certain instruction combinations
    return true;  // Potato has no additional constraints
}
```

Use this to enforce:
- Maximum instruction word bit width
- Restrictions on specific instruction combinations
- Resource limitations not captured by functional unit groups

---

## LAN Assembly Language

The **LAN (VLIW Assembly Notation)** language is a symbolic assembly language designed for VLIW processors. It supports:

- **Symbolic variables**: Automatic register allocation
- **Explicit register assignment**: User-controlled allocation via `@asg`
- **Loop annotations**: Iteration bounds for optimization hints
- **Parallel execution**: `|` prefix for explicit parallelism
- **Conditional execution**: Predicated instructions (e.g., `[R5] add 1, counter, counter`)
- **Addressing modes**: Post-increment, pre-increment, offset registers
- **Register groups**: Multi-register operands (e.g., `VR1:VR0`)

### LAN Syntax Reference

For detailed LAN language specification, including:
- Directive syntax (`@sect`, `@func`, `@import`, `@main`, `@ret`, etc.)
- Addressing modes and memory operands
- Data type annotations (`@b32`, `@b64`, etc.)
- Complete instruction syntax
- Multi-file program structure

**See: [`docs/LAN-spec-v2.0.md`](../docs/LAN-spec-v2.0.md)**

---

## Configuration File (`tools/potato.json`)

Defines memory layout and calling convention for the Potato processor:

```json
{
  "ARCHID": "Potato",
  "ENDIAN": "little-endian",
  "SEGMENT": {
    ".sstk": ["0x0021011F000", "0x0021011FFFF", 36],  // Scalar stack (4KB)
    ".vstk": ["0x002100B0000", "0x002100BFFFF", 36],  // Vector stack (64KB)
    ".sreg": ["0x0021011EF80", "0x0021011EFFF", 36],  // Scalar register save area
    ".vreg": ["0x002100AFC00", "0x002100AFFFF", 36],  // Vector register save area
    ".text@ro|.rodata@ro|.data|.bss": ["0x00200000000", "0x002007FFFFF", 36]  // Code/data (16MB)
  },
  "VALPASS": {
    "RETA": ["R63"],           // Return address register
    "DATA": ["R10", ..., "R25"], // Argument passing registers
    "SSTK": ["AR15"],          // Scalar stack pointer
    "VSTK": ["AR7"],           // Vector stack pointer
    "SREG": ["AR13"],          // Scalar spill-area pointer
    "VREG": ["AR5"]            // Vector spill-area pointer
  }
}
```

**Format**:
- **SEGMENT**: Memory regions with [start_address, end_address, address_width]
- **VALPASS**: Calling-convention registers (return address, arguments, stack and spill-area pointers)

---

## Example Programs in `lan4test/`

### `gemm_scalar.lan`

Scalar matrix multiplication (C = A × B) demonstrating basic LAN features:
- Loop annotations with iteration bounds
- Symbolic variable allocation
- Post-increment addressing
- Conditional branches

**Compile**: `./tools/lasm lan4test/gemm_scalar.lan --layout tools/potato.json --output gemm_scalar.s`

### `sgemm_vector_mul_and_add.lan`

Vector GEMM using separate `vmul` and `vadd` instructions:
- Vector register pairs (handle 32 FP32 elements)
- Broadcasting (scalar to vector)
- `;;;` comments as visual separators
- Demonstrates higher register pressure (needs temp registers)

**Compile**: `./tools/lasm lan4test/sgemm_vector_mul_and_add.lan --layout tools/potato.json --laems --ec=0-8 --output sgemm_mul_add.s`

### `sgemm_vector_muladd.lan`

Optimized vector GEMM using fused `vmuladd` instruction:
- 50% fewer arithmetic instructions vs. separate multiply-add
- Lower register pressure (no temp registers needed)
- Better numerical accuracy (single rounding step)
- Demonstrates performance benefits of FMA units

**Compile**: `./tools/lasm lan4test/sgemm_vector_muladd.lan --layout tools/potato.json --laems --ec=0-8 --fbbfc --output sgemm_muladd.s`

**Performance Comparison**:

| Program | Instructions/Iteration | Register Pressure | Latency |
|---------|----------------------|-------------------|---------|
| `sgemm_vector_mul_and_add.lan` | 4 arithmetic ops | Higher (needs t0, t1) | 2× (mul + add) |
| `sgemm_vector_muladd.lan` | 2 arithmetic ops | Lower (no temps) | 1× (fused) |

