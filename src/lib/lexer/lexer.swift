import Foundation

/// #START_DOC
/// - A enumeration for define all tokens of the ImΠ language.
/// #END_DOC
public enum Token
{
	case IDENTIFIER(String)
	case NUMBER(Float)
	case BRACKET_LEFT
	case BRACKET_RIGHT
	case OPERATOR(String)
	case ASSIGN
	case BOOLEAN(Bool)
	case NOP
	case WHILE
	case DO
	case NEGATION
	case COMMA
	case END
	case IF
	case THEN
	case ELSE
	case REF
	case LET
	case IN
	case VAR
	case CONS
	case OTHER(String)
}


/// #START_DOC
/// - Helper type used in the lexer analysis, it define a func that receives a String and returns a Optional Token.
/// #END_DOC
typealias TokenGenerator = (String) -> Token?

/// #START_DOC
/// - Constant that describ ImΠ grammar.
/// #END_DOC
let tokenList: [(String, TokenGenerator)] =
[
	("[ \t\n]", { _ in nil }),
	("#.*(\n|$)", { _ in nil }), // ignore comments
	("(?![0-9])[a-zA-Z_][a-zA-Z_0-9]*", { (m: String) in matchName(string: m) }),
	("\\(", { _ in .BRACKET_LEFT }),
	("\\)", { _ in .BRACKET_RIGHT }),
	("(\\+|\\*|\\/|-|<=?|>=?|==)", { (m: String) in .OPERATOR(m) }),
	(":=", { _ in .ASSIGN }),
	("=", { _ in .REF }),
	("([1-9][0-9]*|0)?(\\.[0-9]*[1-9]|\\.0)?", { (m: String) in .NUMBER((m as NSString).floatValue) }),
]

/// #START_DOC
/// - Helper function for dealing with the word processing.
/// - Parameter(s)
/// 	- string: The matched value to be converted into a Token.
/// - Return
/// 	- The token relative to the matched value.
/// #END_DOC
private func matchName (string: String) -> Token?
{
	if string == "True" || string == "False"
	{
		return .BOOLEAN((string.lowercased() as NSString).boolValue)
	}
	else if string == "nop"
	{
		return .NOP
	}
	else if string == "while"
	{
		return .WHILE
	}
	else if string == "do"
	{
		return .DO
	}
	else if string == "end"
	{
		return .END
	}
	else if string == "not"
	{
		return .NEGATION
	}
	else if string == "and" || string == "or"
	{
		return .OPERATOR(string)
	}
	else if string == "if"
	{
		return .IF
	}
	else if string == "then"
	{
		return .THEN
	}
	else if string == "else"
	{
		return .ELSE
	}
	else if string == "let"
	{	
		return .LET
	}
	else if string == "var"
	{
		return .VAR
	}
	else if string == "cons"
	{
		return .CONS
	}
	else if string == "in"
	{
		return .IN
	}
	else 
	{
		return .IDENTIFIER(string)
	}
}

/// #START_DOC
/// - Class that define all the logic behind the lexer analysis.
/// #END_DOC
public class Lexer
{
	let input: String
	
	/// #START_DOC
	/// - This class initializer.
	/// - Parameter(s)
	/// 	- The ImΠ program to be processed.
	/// #END_DOC
	init (input: String)
	{
		self.input = input
	}
	
	/// #START_DOC
	/// - The main function of the lexer, here is where the program is converted into a list of tokens.
	/// - Return
	/// 	- The list of tokens that represents the argument ImΠ program.
	/// #END_DOC
	public func tokenize () -> [Token]
	{
		var tokens = [Token]()
		var content = input
		
		while (content.count > 0)
		{
			var matched = false
			for (pattern, generator) in tokenList
			{
				if let m = content.match(regex: pattern)
				{
					if let t = generator(m)
					{
						tokens.append(t)
					}
					
					let index = content.index(content.startIndex, offsetBy: m.count)
					content = String(content[index...])
					matched = true
					break
				}
			}
			
			if (!matched)
			{
				let index: String.Index = content.index(content.startIndex, offsetBy: 1)
				tokens.append(.OTHER(String(content[..<index])))
				content = String(content[index...])
			}
		}
		
		return tokens
	}
}
