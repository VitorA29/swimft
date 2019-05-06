public protocol AST_Pi: CustomStringConvertible
{
}

public protocol ExpressionNode: AST_Pi
{
}

public struct TernaryOperatorNode: ExpressionNode
{
	let operation: String
	let lhs: ExpressionNode
	let chs: ExpressionNode
	let rhs: ExpressionNode?
	
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

public struct BinaryOperatorNode: ExpressionNode
{
	let operation: String
	let lhs: ExpressionNode
	let rhs: ExpressionNode
	
	public var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

public struct UnaryOperatorNode: ExpressionNode
{
	let operation: String
	let expression: ExpressionNode
	
	public var description: String
	{
		return "\(operation)(\(expression))"
	}
}

public struct OnlyOperatorNode: ExpressionNode
{
	let operation: String
	public var description: String
	{
		return "\(operation)()"
	}
}

public struct AtomNode: ExpressionNode
{
	let operation: String
	let value: String
	
	public var description: String
	{
		return "\(operation)(\(value))"
	}
}

public struct PiFuncNode: AST_Pi
{
	let function: String
	
	public var description: String
	{
		return "\(function)"
	}
}
