public protocol AST_Node: CustomStringConvertible
{
}

public protocol ExprNode: AST_Node
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

public struct PrototypeNode: AST_Node
{
	let name: String
	let argumentNames: [String]
	public var description: String
	{
		return "PrototypeNode(name: \(name), argumentNames: \(argumentNames))"
	}
}

public struct FunctionNode: AST_Node
{
	let prototype: PrototypeNode
	let body: ExprNode
	public var description: String
	{
		return "FunctionNode(prototype: \(prototype), body: \(body))"
	}
}

public struct CallNode: ExprNode
{
	let call: String
	let arguments: [ExprNode]
	public var description: String
	{
		return "CallNode(call: \(call), arguments: \(arguments))"
	}
}
