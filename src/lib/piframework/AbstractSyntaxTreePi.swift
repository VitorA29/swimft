/// #START_DOC
/// - This define the extention for the AbstractSyntaxTreePi to be used in the Pi-Framework, it's mainly used in the control pile.
/// #END_DOC
public protocol AbstractSyntaxTreePiExtended: CustomStringConvertible
{
}

/// #START_DOC
/// - This define the type accepted in the value pile of the pi automaton.
/// #END_DOC
public protocol AutomatonValue: CustomStringConvertible
{
}

/// #START_DOC
/// - This define the type that can be binded to a variable in the pi automaton.
/// #END_DOC
public protocol AutomatonBindable: AutomatonValue
{
}

/// #START_DOC
/// - This define the type that can be storable in the memory in the pi automaton.
/// #END_DOC
public protocol AutomatonStorable: AutomatonValue
{
}

/// #START_DOC
/// - This define the general abstract syntax tree Pi node.
/// #END_DOC
public protocol AbstractSyntaxTreePi: AbstractSyntaxTreePiExtended
{
}

/// #START_DOC
/// - This node defines a extension node for the abstract syntax tree of pi, this is the operation code used by the pi automaton to perform the operations.
/// #END_DOC
public protocol OperationCode: AbstractSyntaxTreePiExtended
{
	var code: String { get }
}

public extension OperationCode
{
	var description: String
	{
		return "#\(code)"
	}
}

/// #START_DOC
/// - This defines the localizable struct to be used in the memory storage linking.
/// #END_DOC
public struct Location: AutomatonValue, AutomatonBindable, AutomatonStorable
{
	let address: Int
	public var description: String
	{
		return "Loc(\(address))"
	}
}
