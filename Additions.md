# Additions

## Immediate values
```
 lda @34
 
 outc @"k"
 ```
 
 ## Function calls
 
 ```
 call foo(i: $v)
 ```
 instead of:
 ```
 push $v
 call $foo
 ```

## Syscalls

```
syscall alloc($num)
syscall alloc(@2)
```

## Unmanaged variable
variable with no type.

```
var g: any = later  // <--- doesn't have a concrete type
```
can be written as:
```
var g = later
```

Constants always have a type specified.

## Pointers

### Pointer type

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
