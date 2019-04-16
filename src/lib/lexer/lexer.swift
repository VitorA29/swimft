import Foundation

// defining all tokens types
public enum Token
{
	case DEFINE
	case IDENTIFIER(String)
	// case BOOLEAN(String)
	case NUMBER(Float)
	case BRACKET_LEFT
	case BRACKET_RIGHT
	case COMMA
	// case ARITIMETIC_OPERATOR(String)
	case OTHER(String)
}

// defining all tokens matchs
typealias TokenGenerator = (String) -> Token?
let tokenList: [(String, TokenGenerator)] =
[
	("[ \t\n]", { _ in nil }),
	("//.*\n", { _ in nil }), // ignore comments
	// ("(True|False)", { (r: String) in .BOOLEAN(r) }),
	("[a-zA-Z][a-zA-Z0-9]*", { $0 == "def" ? .DEFINE : .IDENTIFIER($0) }),
	("([1-9][0-9]*|0)(.([0-9]*[1-9]|0))?", { (r: String) in .NUMBER((r as NSString).floatValue) }),
	("\\(", { _ in .BRACKET_LEFT }),
	("\\)", { _ in .BRACKET_RIGHT }),
	(",", { _ in .COMMA }),
	// ("(\\+|\\*|\\/|-)", { (r: String) in .ARITIMETIC_OPERATOR(r) }),
]

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
