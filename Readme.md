<p align="center">
	<img src="https://img.shields.io/badge/language-swift-orange.svg" alt="Language">
	<img src="https://img.shields.io/badge/license-MIT-000000.svg" alt="License">
</p>

# Swimft - A Imp compiler writen in Swift

## ImΠ grammar
```
<S> ::=  <cmd>+

<cmd> ::= 'nop' | <assign> | <loop> | <conditional> | <comment>

<assign> ::= <identifier> ':=' <expression>

<loop> ::= 'while' <bool_expression> 'do' <cmd>+ 'end'

<conditional> ::= 'if' <bool_expression> 'then' <cmd>+ 'else' <cmd>+ 'end'
		| 'if' <bool_expression> 'then' <cmd>+ 'end'

<comment> ::= /#.*\s/

<identifier> ::= /(?!\d)\w+/ 

<expression> ::= <bool_expression> | <arith_expression>

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
