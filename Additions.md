# Additions


- [] Immediate values
- [] Function calls
- [] Syscalls
- [] Type-erased variables
- [] Pointers


## Immediate values

```
 lda @34
 
 outc @"k"
 ```
 
 ## Function calls [ ]
 
 ```
 call foo(i: $v)
 ```
 instead of:
 ```
 push $v
 call $foo
 ```

## Syscalls [ ]

```
syscall alloc($num)
syscall alloc(@2)
```

## Type-erased variables [ ]
variable with no type.

```
var g: any = later  // <--- doesn't have a concrete type
```
can be written as:
```
var g = later
```

Constants always have a type specified.

## Pointers [ ]

### Pointer type [ ]

```
const j: int = 89
const ptrj: *int = &j
var ptrk: **int = &ptrj
var anyptr = &ptrk
```

```
func bar(a: char, b: *int) -> c: *char {

}
```

### Usage in code [ ]

```
mkptr $j // make pointer to the address of variable `j`

stptr $ptrj // stores the created pointer to variable `ptrj`. It now contains a pointer.

ldptr $ptrj // loads the pointer stored in `ptrj` to the pointer register.

storea ptr // stores content of A-register to ram at the address the pointer is pointing to.
```
