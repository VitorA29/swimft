<p align="center">
	<img src="https://img.shields.io/badge/language-swift-orange.svg" alt="Language">
	<img src="https://img.shields.io/badge/license-MIT-000000.svg" alt="License">
	<img src="https://img.shields.io/badge/ubuntu-v18.04-orange.svg" alt="system">
</p>

# Swimft - A ImΠ compiler writen in Swift

Just a simple compiler and interpreter for the ImΠ programming language.

## ImΠ grammar
```
<S> ::=  <cmd> | <comment>

<cmd> ::= 'nop' | <assign> | <while> | <conditional> | <expression>

<comment> ::= /#.*\s/

<assign> ::= <identifier> ':=' <expression>

<while> ::= 'while' <bool_expression> 'do' <cmd><S>* 'end'

<conditional> ::= 'if' <bool_expression> 'then' <cmd><S>* 'else' <cmd><S>* 'end'
		| 'if' <bool_expression> 'then' <cmd><S>* 'end'

<expression> ::= <bool_expression> | <arith_expression> | '(' <expression> ')'

<identifier> ::= /(?!\d)\w+/ 

<bool_expression> ::= <truth> | <identifier> | <negation> | <equality> | <conjunction> | <disjunction>
                | <lowerthan> | <lowereq> | <greaterthan> | <greatereq> | '(' <bool_expression> ')'

<arith_expression> ::= <number> | <identifier> | <addition> | <subtraction>
		| <multiplication> | <division> | '(' <arith_expression> ')'

<truth> ::= 'True' | 'False'

<negation> ::= 'not' <bool_expression> 

<equality> ::= <arith_expression> "==" <arith_expression> | <bool_expression> "==" <bool_expression>

<conjunction> ::= <bool_expression> "and" <bool_expression>

<disjunction> ::= <bool_expression> "or" <bool_expression>

<lowerthan> ::= <arith_expression> "<" <arith_expression>

<lowereq> ::= <arith_expression> "<=" <arith_expression>

<greaterthan> ::= <arith_expression> ">" <arith_expression>

<greatereq> ::= <arith_expression> ">=" <arith_expression>

<number> ::= /\d+/

<addition> ::= <arith_expression> "+" <arith_expression>

<subtraction> ::= <arith_expression> "-" <arith_expression>

<multiplication> ::= <arith_expression> "*" <arith_expression>

<division> ::= <arith_expression> "/" <arith_expression>
```

## Instalation and Execution

### Using Make

The enviroment configuration is ensure by this logic, after everything set up(eq. at least a 'make' call) the swift source code is downloaded and it's dependences resolved(So in order of running this, a internet conection is required) and the Swimft executable is created in the 'output' folder, it's name is swimft.

- 'make compile_src': This will compile the code;
- 'make build': This will clean the compiled files and then will call compile\_src
- 'make execute\_imp\_zero': This will execute the expected Imp codes;
- 'make': This will prepare all environment, installing all dependences if needed after will call build and finally will call execute\_imp\_zero;
- 'make reset': This will clean the instalation, deleting everything after will call make.

### Using commom bash

_*This will assume a previous execution of 'make' and/or 'make compile\_src*_

The executable will expect at least the imp file name as parameter.

#### Flags
```
-tokens: Will notice the program to print the tokens list;
-ast_imp: Will notice the program to print the ImΠ AST;
-ast_pi: Will notice the program to print the Pi AST;
-state: Will notice the program to print every state of the automaton;
-debug: Will active all flags.
```
