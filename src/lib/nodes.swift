public protocol ExprNode: CustomStringConvertible
{
}

public struct NumberNode: ExprNode
{
	let value: Float
	public var description: String
	{
		return "NumberNode(\(value))"
	}
}

public struct VariableNode: ExprNode
{
	let name: String
	public var description: String
	{
		return "VariableNode(\(name))"
	}
}

public struct BinaryOpNode: ExprNode
{
	let op: String
	let lhs: ExprNode
	let rhs: ExprNode
	public var description: String
	{
		return "BinaryOpNode(op: \(op), lhs: \(lhs), rhs: \(rhs))"
	}
}
