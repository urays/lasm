### LASM IR - Constant
> Latest update: 2024-5-9, by urays@foxmail.com

#### 1 Basic Constant

Basic constants include integer constants, floating-point constants, and character constants.LASM reserves 64 bits for each basic constant. Basic constants are not sign-extensible. If a constant is specified with fewer than 64 bits, LASM calibrates its value from the right, padding any unspecified bits with zeros. If a constant is specified with more than 64 bits, LASM will simply truncate it, taking only the lower 64 bits (the truncation will be fed back to the user in the form of a warning).Floating-point constants in non-machine-code formats are automatically expressed as 64-bit double-precision following the IEEE754 standard.

###### 1. Integer Constant

```python
//:) Brief
Integer constants come in four numeric systems: binary, octal, decimal, and hexadecimal. 
Only decimal constants have numeric meanings, all other integer constants are treated as 64-bit complements. 
The range of decimal constants is -9,223,372,036,854,775,808 ~ 18,446,744,073,709,551,615.
```

| Numeral system | Format | Meaning |  Examples | 
| --- | --- | --- | --- |
| Binary | ^0[bB][10]+ |  Complement | 0b101、0B1001 |
| Octal | ^0[oO][0-7]+ | Complement | 0O5、0o11 |
| Decimal | [+-^][0-9]+ |  Numeric |  5、9、-2|
| Hexadecimal | ^0[xX][0-9a-fA-F]+ |  Complement  | 0x5、0x9 |

###### 2. Float Constant


There are three types of floating-point constants:
(1) machine-code representations following the IEEE754 standard (only supported for direct use in instructions, otherwise LASM defaults to integer constants);
(2) decimal number forms with a decimal point, e.g., 1.2, -1.53; 
(3) scientific notation, e.g., 1e-2, -1e2, 2e + 5.

```c
//:) Case 1
SMOVI 0xBFF8000000000000, R10 //Direct use of machine code representation following IEEE754.
SMOVI 1e-2, R11   // 1e-2 -> 0x3F847AE147AE147B
SFMULD R10, R11, R10 // -1.5 * 1e-2 = -0.05,  R10 = 0xBF8EB851EB851EB8

//:) Case 2
SMOVI (-1+2.0)*3, R10  //(-1+2.0)*3 -> 0x4008000000000000
SMOVI 2.0, R11   // 2.0 -> 0x4000000000000000
SFMULD R10, R11, R10
//Note that if the constant expression has a floating-point constant, the result of the expression is in double-precision IEEE754 format. 
//If there is no floating point constant in the expression, the result of the expression is a 64-bit integer constant.
SMOVI (-1+2)*3, R10  // 0x0000000000000003 -> R10

//:) Other cases detailed in lasm-pseudo.md.
```

###### 3. Character Constant

Character constants are single characters enclosed in single quotes. Internally, characters are represented as 8-bit ASCII characters. If single quotes are part of a character constant, just add the '\\' before them. Character constants consisting of only two single quotes are valid and are assigned 0 by default.

```c
//:) Cases
'a'  -> 0x0000000000000061
'C'  -> 0x0000000000000043
'\'' -> 0x0000000000000027
''   -> 0x0000000000000000
'\n' -> 0x000000000000000A
'\\' -> 0x000000000000005C
```

#### 2 Symbolic Constant

Symbolic constants consist of two types, one defined by the @bN,@bh,@bf or @bd, and the other being properties of address indicators. Here, we focus on symbolic properties.
Symbolic properties are symbols used to describe properties specific to address indicator symbols. Symbolic properties include .cnt (The number of data elements) and .gra (The number of bytes required by a data element). For example, @usect ".bss", Arr, @b10, 128, where Arr is an address indicator, Arr.cnt = 128, Arr.gra = 2 Bytes.

#### 3 Complex Constant

Complex constants are combinations of basic constants, categorized as strings and constant expressions.

###### 1. String
A string is an ordered sequence of multiple character constants. LASM performs character concatenation operations in character order, resulting in a hexadecimal representation of an integer constant.

```python
:) Cases
@b32 x, "abc"                       // -> 'a', 'b', 'c' -> 0x616263 -> 0x00616263
@b32 y, 'a'<< 4+'b'                 // ->  0x6162 -> 0x00006162
@sect ".data", addx,@b8, "ab", 'c'  // 'ab', 'c' -> 0x6162, 0x63 -> 0x62, 0x63
@sect ".data", addx, @b4 "ab", 'c'  // 'ab', 'c' -> 0x6162, 0x63 -> 0x2, 0x3
@b1 x, 'c'                          // 'c' -> 0x01
@sect ".data", addx, @b16,'a'<< 4+'b', 'c'<<4+'d'  // 0x6162, 0x6364
```

###### 2. Constant Expression

A constant expression is a sequence of basic or symbolic constants separated by arithmetic operators. Legitimate constant expressions are divided into two categories: simplifiable and non-simplifiable. Non-simplifiable constant expressions contain symbols whose values cannot be determined at the compilation stage, i.e., address indicators.

```python
//:) Operands (i.e., basic or symbolic constants)
1. Three basic constants (integer constants, non-IEEE754 format floating-point constants, character constants).
2. Address indicators (including memory first address, function name, and in-function label).
3. Symbolic Constant.

//:) Operator
Constant expressions support 23 operators, including unary and binary operators. The binary operators include six logical comparison operators. The table below lists all the operators and their priorities supported by LASM IR. 
Note that any constant expression containing "/" is calculated as double-precision following the IEEE754 standard.
The following table lists the operation priority of each operator, the smaller the value the higher the priority.
```

|  Priority   |  Operator  | Description |
| --- | --- | --- |
| 0 | ( | Left bracket. |
|  | ) | Right bracket. |
|  1   |  +   |   Unary plus.  |
|     |  -   |   Unary minus.  |
|     |  ~   |  Bitwise negation.   |
|     |  !   |  Logical negation.  |
|  2   |  *   |  Multiplication |
|     |  /   |  Signed division. |
|     |  //   |  Signed division.(round down) |
|     |  %   |  Signed remainder. |
|  3   |  +   |  Addition. |
|     |  -   |  Subtraction. |
|  4   |  <<   | Shift left.  |
|     |  >>   |  Arithmetic shift right. |
|  5   |  <  |  Signed less than comparison. |
|     |  <=  |  Signed less than or equal comparison.  |
|     |  >  | Signed greater than comparison.  |
|     |  >=  |  Signed greater than or equal comparison. |
|     |  ==  |  equality comparison. |
|     |  !=  | Inequality comparison.  |
|  6   |  &  |  Bitwise and. |
|     |  ^  |  Bitwise exclusive or.  |
|     |  \|  |  Bitwise or. |
|  7 | && |  Logical and. |
|   | \|\| |  Logical or.  |

