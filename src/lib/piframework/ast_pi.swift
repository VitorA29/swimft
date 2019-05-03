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
			return "TernaryOperatorNode(operation: \(operation), lhs: \(lhs), chs: \(chs))"
		}
		else
		{
			return "TernaryOperatorNode(operation: \(operation), lhs: \(lhs), chs: \(chs), rhs: \(rhs!))"
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
		return "BinaryOperatorNode(operation: \(operation), lhs: \(lhs), rhs: \(rhs))"
	}
}

public struct UnaryOperatorNode: ExpressionNode
{
	let operation: String
	let expression: ExpressionNode
	
	public var description: String
	{
		return "UnaryOperatorNode(operation: \(operation), expression: \(expression))"
	}
}

public struct SkipOperatorNode: ExpressionNode
{
	public var description: String
	{
		return "SkipOperatorNode()"
	}
}

public struct AtomNode: ExpressionNode
{
	let function: String
	let value: String
	
	public var description: String
	{
		return "AtomNode(function: \(function), value: \(value))"
	}
}

public struct PiFuncNode: AST_Pi
{
	let function: String
	
	public var description: String
	{
		return "PiFuncNode(function: \(function))"
	}
}
