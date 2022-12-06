# EASM Language Guide


## File structure

### Dependencies file `.asd`  
Contains library dependencies of the project. This file is mandatory. Only one in a project.


### Header file `.ash`
Contains declarations of global variables, functions and function variables.


### Implementations file `.asm`
Contains the main implementation and implementations of functions defined in header files.


## Defining dependencies
Use the `import` statement in `.asd` file. For importing built-in libraries use `#import` statement.
```
#import Standard
#import Math
import mypath/mylib.asl
```

