# mini-LISP interpreter

## Development Environment and Tools
* Ubuntu 18.04 on Windows 10 WSL
* flex 2.6.4
* bison 3.5.4
* g++ 7.5.0

### Setting Up
Get the latest version on github and compile it
```shell=
git clone https://github.com/CatsSky/mLISP.git
make
# The program is now compiled, execute it by running ./mlisp
./mlisp
```

### Type System
The language consists of 3 fundamental types of data.
* Integer
* Boolean
* Function

Integer values are represented as such: `5`, `-8`, `19`...
Boolean values: `#t` for true and `#f` for false

### Definition
We can assign values to variables in mini lisp.

* (def *identifier* *identifier*)
* (def *identifier* *expression*)

## TODO: finish syntax documentation
