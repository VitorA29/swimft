public protocol AST_Pi: CustomStringConvertible
{
}

public protocol ExpressionNode: AST_Pi
{
}

public struct WhileLoopNode: AST_Pi
{
	let condition: ExpressionNode
	let command: Pile<AST_Pi>
	
	public var description: String
	{
		return "WhileLoopNode(condition: \(condition), command: \(command))"
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

public struct AtomNode: ExpressionNode
{
	let function: String
	let value: String
	
	public var description: String
	{
		return "AtomNode(Function: \(function), Value: \(value))"
	}
}
