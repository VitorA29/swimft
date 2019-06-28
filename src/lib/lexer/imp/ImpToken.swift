import Foundation

/// - A enumeration for define all tokens of the ImΠ language.
public enum ImpToken: Token
{
	case IDENTIFIER(String)
	case NUMBER(Float)
	case BRACKET_LEFT
	case BRACKET_RIGHT
	case OPERATOR(String)
	case ASSIGN
	case CLASSIFICATION(Bool)
	case NOP
	case WHILE
	case DO
	case NEGATION
	case COMMA
	case END
	case CONDITIONAL
	case THEN
	case ELSE
	case INITIALIZER
	case REFERENCE(String)
	case LET
	case IN
	case DECLARATION(String)
	case PRINT
}

/// - Constant that describ ImΠ grammar.
public let IMP_TOKEN_PROCESSOR: [(String, TokenGenerator<ImpToken>)] =
[
	("[ \t\r\n]", { _ in nil }),
	("#.*(\r?\n|$)", { _ in nil }), // ignore comments
	("(?![0-9])[a-zA-Z_][a-zA-Z_0-9]*", { (m: String) in matchName(string: m) }),
	("(&|\\(\\*)", { (m: String) in ImpToken.REFERENCE(m) }),
	("\\(", { _ in ImpToken.BRACKET_LEFT }),
	("\\)", { _ in ImpToken.BRACKET_RIGHT }),
	("(\\+|\\*|\\/|-|<=?|>=?|==)", { (m: String) in ImpToken.OPERATOR(m) }),
	(":=", { _ in ImpToken.ASSIGN }),
	("=", { _ in ImpToken.INITIALIZER }),
	(",", { _ in ImpToken.COMMA }),
	("(([1-9][0-9]*|0)(\\.[0-9]*[1-9]|\\.0)?|\\.[0-9]*[1-9]|\\.0)", { (m: String) in ImpToken.NUMBER((m as NSString).floatValue) }),
]

/// - Helper function for dealing with the word processing.
/// - Parameter(s)
/// 	- string: The matched value to be converted into a Token.
/// - Return
/// 	- The token relative to the matched value.
private func matchName (string: String) -> ImpToken?
{
	if string == "True" || string == "False"
	{
		return ImpToken.CLASSIFICATION((string.lowercased() as NSString).boolValue)
	}
	else if string == "nop"
	{
		return ImpToken.NOP
	}
	else if string == "while"
	{
		return ImpToken.WHILE
	}
	else if string == "do"
	{
		return ImpToken.DO
	}
	else if string == "end"
	{
		return ImpToken.END
	}
	else if string == "not"
	{
		return ImpToken.NEGATION
	}
	else if string == "and" || string == "or"
	{
		return ImpToken.OPERATOR(string)
	}
	else if string == "if"
	{
		return ImpToken.CONDITIONAL
	}
	else if string == "then"
	{
		return ImpToken.THEN
	}
	else if string == "else"
	{
		return ImpToken.ELSE
	}
	else if string == "let"
	{	
		return ImpToken.LET
	}
	else if string == "var" || string == "cons" 
	{
		return ImpToken.DECLARATION(string)
	}
	else if string == "in"
	{
		return ImpToken.IN
	}
	else if string == "print"
	{
		return ImpToken.PRINT
	}
	else 
	{
		return ImpToken.IDENTIFIER(string)
	}
}