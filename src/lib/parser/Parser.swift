import Foundation

/// - This define a generic abstract syntax tree.
public protocol AbstractSyntaxTree: CustomStringConvertible
{
}

/// - Define the enumeration for the error that can be throw during parsing.
public enum ParserError: Error
{
	case ExpectedToken(String) // Token
	case UnexpectedToken(Token)
}

/// - Protocal that define basic the logic needed in the syntax analysis.
public protocol Parser
{
	/// - This class initializer.
	/// - Parameter(s)
	/// 	- A list of Tokens relative to the program.
	init (tokens: [Token]) throws
	
	/// - The main logic of the grammar.
	/// - Return
	/// 	- The relative forest to the argument program.
	func parse () throws -> [AbstractSyntaxTree]
}
