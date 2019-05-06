public protocol AST_Pi_Extended: CustomStringConvertible
{
}

public protocol AST_Pi: AST_Pi_Extended
{
}

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

public struct UnaryOperatorNode: AST_Pi
{
	let operation: String
	let expression: AST_Pi
	
	public var description: String
	{
		return "\(operation)(\(expression))"
	}
}

public struct OnlyOperatorNode: AST_Pi
{
	let operation: String
	public var description: String
	{
		return "\(operation)()"
	}
}

public struct AtomNode: AST_Pi
{
	let operation: String
	let value: String
	
	public var description: String
	{
		return "\(operation)(\(value))"
	}
}

public struct PiFuncNode: AST_Pi_Extended
{
	let function: String
	
	public var description: String
	{
		return "\(function)"
	}
}
