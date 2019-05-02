import Foundation

// defining all tokens types
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
	case OTHER(String)
}


// defining all tokens matchs
typealias TokenGenerator = (String) -> Token?
let tokenList: [(String, TokenGenerator)] =
[
	("[ \t\n]", { _ in nil }),
	("#.*(\n|$)", { _ in nil }), // ignore comments
	("(?![0-9])[a-zA-Z_][a-zA-Z_0-9]*", { (m: String) in matchName(string: m) }),
	("\\(", { _ in .BRACKET_LEFT }),
	("\\)", { _ in .BRACKET_RIGHT }),
	("(\\+|\\*|\\/|-|<=?|>=?|==)", { (m: String) in .OPERATOR(m) }),
	(":=", { _ in .ASSIGN }),
	("([1-9][0-9]*|0)?(.[0-9]*[1-9]|.0)?", { (m: String) in .NUMBER((m as NSString).floatValue) }),
]

private func matchName(string: String) -> Token?
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
	else
	{
		return .IDENTIFIER(string)
	}
}

public class Lexer
{
	let input: String
	
	init (input: String)
	{
		self.input = input
	}
	
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
