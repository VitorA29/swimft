import Foundation

/// - Define the enumeration for the error that can be throw during tokenization.
public enum LexerError: Error
{
	case NoTokenMatch(String)
}

/// - This define a generic token.
public protocol Token
{
}

/// - Helper type used in the lexer analysis, it define a func that receives a String and returns a Optional Token.
public typealias TokenGenerator<T: Token> = (String) -> T?

/// - Class that define all the logic behind the lexer analysis.
public class Lexer<T: Token>
{
	let input: String
	let processor: [(String, TokenGenerator<T>)]
	
	/// - This class initializer.
	/// - Parameter(s)
	/// 	- The ImΠ program to be processed.
	/// 	- The processor to be used
	init (input: String, processor: [(String, TokenGenerator<T>)])
	{
		self.input = input
		self.processor = processor
	}
	
	/// - The main function of the lexer, here is where the program is converted into a list of tokens.
	/// - Return
	/// 	- The list of tokens that represents the argument ImΠ program.
	public func tokenize () throws -> [T]
	{
		var tokens = [T]()
		var content = input
		
		while (content.count > 0)
		{
			var matched = false
			for (pattern, generator) in processor
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
				if let matchTrash = content.match(regex: ".+\\s")
				{
					throw LexerError.NoTokenMatch(matchTrash)
				}
				else
				{
					throw LexerError.NoTokenMatch("")
				}
			}
		}
		
		return tokens
	}
}
