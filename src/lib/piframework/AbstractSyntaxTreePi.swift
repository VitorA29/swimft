/// - This define the extention for the AbstractSyntaxTreePi to be used in the Pi-Framework, it's mainly used in the control pile.
public protocol AbstractSyntaxTreePiExtended: CustomStringConvertible
{
}

/// - This define the type accepted in the value pile of the pi automaton.
public protocol AutomatonValue: CustomStringConvertible
{
}

/// - This define the type that can be binded to a variable in the pi automaton.
public protocol AutomatonBindable: AutomatonValue
{
}

/// - This define the type that can be storable in the memory in the pi automaton.
public protocol AutomatonStorable: AutomatonValue
{
}

/// - This define the general abstract syntax tree Pi node.
public protocol AbstractSyntaxTreePi: AbstractSyntaxTreePiExtended
{
}

/// - This node defines a extension node for the abstract syntax tree of pi, this is the operation code used by the pi automaton to perform the operations.
public protocol OperationCode: AbstractSyntaxTreePiExtended
{
	var code: String { get }
}

/// - This extension is for creating the default description used by all of it's implementations
public extension OperationCode
{
	var description: String
	{
		return "#\(code)"
	}
}

/// - This defines the localizable struct to be used in the memory storage linking.
public struct Location: AutomatonValue, AutomatonBindable, AutomatonStorable
{
	let address: Int
	public var description: String
	{
		return "Loc(\(address))"
	}
}
