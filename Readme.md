<p align="center">
	<img src="https://img.shields.io/badge/language-swift-orange.svg" alt="Language">
	<img src="https://img.shields.io/badge/license-MIT-000000.svg" alt="License">
	<img src="https://img.shields.io/badge/ubuntu-v18.04-orange.svg" alt="system">
</p>

# Swimft - A ImΠ compiler writen in Swift

Just a simple compiler and interpreter for the ImΠ programming language.

## ImΠ grammar
```
<S> ::=  <command> | <comment>

<command> ::= 'nop' | <assign> | <while> | <conditional> | <expression> | <block> | <print> | <call>

<comment> ::= /#.*\s/

<assign> ::= <identifier> ':=' <expression>

<while> ::= 'while' <logical_expression> 'do' <S>*<command><S>* 'end'

<conditional> ::= 'if' <logical_expression> 'then' <S>*<command><S>* 'else' <S>*<command><S>* 'end'
			| 'if' <logical_expression> 'then' <S>*<command><S>* 'end'

<expression> ::= <reference> | <logical_expression> | <arithmetic_expression>

<block> ::= 'let' (<declaration>)? 'in' <S>*<command><S>* 'end'

<print> ::= 'print' '(' <expression> ')'

<call> ::= <identifier> '(' (<actual>)? ')'

<identifier> ::= /(?!\d)\w+/

<reference> ::= <address_reference> | <value_reference>

<logical_expression> ::= <logical_classification> | <identifier> | <value_reference>
			| <negation> | <logical_operation> | '(' <logical_expression> ')'
		
<arithmetic_expression> ::= <number> | <identifier> | <value_reference>
		| <arithmetic_operation> | '(' <arithmetic_expression> ')'
		
<declaration> ::= <declaration> ',' <declaration> | <variable_declaration>
			| <constant_declaration> | <function_declaration>

<actual> ::= <actual> ',' <actual> | <expression>

<address_reference> ::= '&' <identifier>

<value_reference> ::= '(*' <identifier> ')'

<logical_classification> ::= 'True' | 'False'

<negation> ::= 'not' <logical_expression>

<logical_operation> ::= <equality> | <logical_connection> | <inequality_operation>

<number> ::= /\d+/

<arithmetic_operation> ::= <addition> | <subtraction> | <multiplication> | <division>

<variable_declaration> ::= 'var' <identifier> = <expression>

<constant_declaration> ::= 'cons' <identifier> = <expression>

<function_declaration> ::= 'fn' <identifier> '(' (<formal>)? ')' = <block>

<equality> ::= <arithmetic_expression> '==' <arithmetic_expression>
		| <logical_expression> '==' <logical_expression>

<logical_connection> ::= <conjunction> | <disjunction>

<inequality_operation> ::= <lowerthan> | <lowereq> | <greaterthan> | <greatereq>

<addition> ::= <arithmetic_expression> '+' <arithmetic_expression>

<subtraction> ::= <arithmetic_expression> '-' <arithmetic_expression>

<multiplication> ::= <arithmetic_expression> '*' <arithmetic_expression>

<division> ::= <arithmetic_expression> '/' <arithmetic_expression>

<formal> ::= <formal> ',' <formal> | <identifier>

<conjunction> ::= <logical_expression> 'and' <logical_expression>

<disjunction> ::= <logical_expression> 'or' <logical_expression>

<lowerthan> ::= <arithmetic_expression> '<' <arithmetic_expression>

<lowereq> ::= <arithmetic_expression> '<=' <arithmetic_expression>

<greaterthan> ::= <arithmetic_expression> '>' <arithmetic_expression>

<greatereq> ::= <arithmetic_expression> '>=' <arithmetic_expression>
```

## Instalation and Execution

### Using Make

The enviroment configuration is ensure by this logic, after everything set up(eq. at least a 'make' call) the swift source code is downloaded and it's dependences resolved(So in order of running this, a internet conection is required) and the Swimft executable is created in the 'output' folder, it's name is swimft.

- 'make release_branch': This will change the branch to the latest release branch;
- 'make release\_imp\_zero': This will change the branch to the imp-zero release branch;
- 'make release\_imp\_one': This will change the branch to the imp-one release branch;
- 'make compile_src': This will compile the code;
- 'make build': This will clean the compiled files and then will call compile\_src
- 'make execute\_imp\_two': This will execute some Imp codes;
- 'make': This will prepare all environment, installing all dependences if needed after will call build and finally will call execute\_imp\_two;
- 'make reset': This will clean the instalation, deleting everything after will call make.

### Using commom bash

_`This will assume a previous execution of 'make' and/or 'make compile_src'`_

The executable will expect at least the imp file name as parameter.

#### Flags
```
-code: Will notice the program to print the executed code;
-tokens: Will notice the program to print the tokens list;
-stokens: Will notice the program to print the tokens list and stop execution after;
-ast_imp: Will notice the program to print the ImΠ AST;
-sast_imp: Will notice the program to print the ImΠ AST and stop execution after;
-ast_pi: Will notice the program to print the Pi AST;
-sast_pi: Will notice the program to print the Pi AST and stop execution after;
-state n: Will notice the program to print the nth state of the automaton or every state if no 'n' is passed;
-last_state n: Will notice the program to print the last state of the automaton;
-debug: Will active all print flags.
```
