/// #START_DOC
/// - This define the extention for the AST_Pi to be used in the Pi-Framework, it's mainly used in the control pile.
/// #END_DOC
public protocol AST_Pi_Extended: CustomStringConvertible
{
}

/// #START_DOC
/// - This define the type accepted in the value pile of the pi automaton.
/// #END_DOC
public protocol Automaton_Value: CustomStringConvertible
{
}

/// #START_DOC
/// - This define the type accepted in the value pile of the pi automaton.
/// #END_DOC
public protocol Automaton_Bindable: Automaton_Value
{
}

/// #START_DOC
/// - This define the type accepted in the value pile of the pi automaton.
/// #END_DOC
public protocol Automaton_Storable: Automaton_Value
{
}

/// #START_DOC
/// - This define the general AST_Pi node.
/// #END_DOC
public protocol AST_Pi: AST_Pi_Extended, Automaton_Value
{
}

/// #START_DOC
/// - This defines operations that have tree values to be processed.
/// #END_DOC
public struct TernaryOperatorNode: AST_Pi
{
	let operation: String
	let lhs: AST_Pi
	let chs: AST_Pi
	let rhs: AST_Pi?
	
	public var description: String
	{
		if (rhs == nil)
		{
			return "\(operation)(\(lhs), \(chs), nil)"
		}
		else
		{
			return "\(operation)(\(lhs), \(chs), \(rhs!))"
		}
	}
}

/// #START_DOC
/// - This defines operations that have two values to be processed.
/// #END_DOC
public struct BinaryOperatorNode: AST_Pi
{
	let operation: String
	let lhs: AST_Pi
	let rhs: AST_Pi
	
	public var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

/// #START_DOC
/// - This defines operations that have one value to be processed.
/// #END_DOC
public struct UnaryOperatorNode: AST_Pi
{
	let operation: String
	let expression: AST_Pi
	
	public var description: String
	{
		return "\(operation)(\(expression))"
	}
}

/// #START_DOC
/// - This defines the operation that don't have any expression or value.
/// #END_DOC
public struct OnlyOperatorNode: AST_Pi
{
	let operation: String
	public var description: String
	{
		return "\(operation)()"
	}
}

/// #START_DOC
/// - This defines the AST terminary node, it's used for wrapping the primal type of ImΠ.
/// #END_DOC
public struct AtomNode: AST_Pi, Automaton_Bindable, Automaton_Storable
{
	let operation: String
	let value: String
	
	public var description: String
	{
		return "\(operation)(\(value))"
	}
}

/// #START_DOC
/// - This node defines the extension for the AST_Pi, used by the Pi-Framework.
/// #END_DOC
public struct PiOpCodeNode: AST_Pi_Extended
{
	let function: String
	
	public var description: String
	{
		return "\(function)"
	}
}

/// #START_DOC
/// - This defines the localizable struct to be used in the memory storage linking.
/// #END_DOC
public struct Localizable: Automaton_Bindable, Automaton_Storable
{
	let address: Int
	
	public var description: String
	{
		return "Localizable(address: \(address))"
	}
}

/// #START_DOC
/// - This defines a pair of key and value, it's just a simplification of a Dictionary.
/// #END_DOC
public struct Map<K,V>: Automaton_Value
{
	let key: K
	var value: V
	
	public var description: String
	{
		return "\(key):\(value)"
	}
}
