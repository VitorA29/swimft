import Foundation

/// #START_DOC
/// - This define a generic abstract syntax tree.
/// #END_DOC
public protocol AbstractSyntaxTree: CustomStringConvertible
{
}

/// #START_DOC
/// - Define the enumeration for the error that can be throw during parsing.
/// #END_DOC
public enum ParserError: Error
{
	case ExpectedToken(String) // Token
	case UnexpectedToken(Token)
}

/// #START_DOC
/// - Protocal that define basic the logic needed in the syntax analysis.
/// #END_DOC
public protocol Parser
{
	/// #START_DOC
	/// - This class initializer.
	/// - Parameter(s)
	/// 	- A list of Tokens relative to the program.
	/// #END_DOC
	init (tokens: [Token]) throws
	
	/// #START_DOC
	/// - The main logic of the grammar.
	/// - Return
	/// 	- The relative forest to the argument program.
	/// #END_DOC
	func parse () throws -> [AbstractSyntaxTree]
}
