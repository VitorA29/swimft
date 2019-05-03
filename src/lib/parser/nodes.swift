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

public struct BooleanNode: ExprNode
{
	let value: Bool
	public var description: String
	{
		return "BoolNode(\(value))"
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

public struct NegationNode: ExprNode
{
	let expression: ExprNode
	public var description: String
	{
		return "NegationNode(\(expression))"
	}
}

public struct NoOpNode: ExprNode
{
	public var description: String
	{
		return "NoOpNode()"
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

public struct AssignNode: ExprNode
{
	let variable: VariableNode
	let expression: ExprNode
	public var description: String
	{
		return "AssignNode(variable: \(variable), expression: \(expression))"
	}
}

public struct WhileNode: ExprNode
{
	let condition: ExprNode
	let command: [AST_Node]
	public var description: String
	{
		return "WhileNode(condition: \(condition), command: \(command) - length: \(command.count))"
	}
}

public struct ConditionalNode: ExprNode
{
	let condition: ExprNode
	let commandTrue: [AST_Node]
	let commandFalse: [AST_Node]
	public var description: String
	{
		return "ConditionalNode(condition: \(condition), [ commandTrue: \(commandTrue) - length: \(commandTrue.count) ], [ commandFalse: \(commandFalse) - length: \(commandFalse.count) ])"
	}
}
