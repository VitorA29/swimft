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
		return "(!\(expression))"
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
		return "('\(op)', \(lhs), \(rhs))"
	}
}

public struct AssignNode: ExprNode
{
	let variable: VariableNode
	let expression: ExprNode
	public var description: String
	{
		return "(Assign, \(variable), \(expression))"
	}
}

public struct WhileNode: ExprNode
{
	let condition: ExprNode
	let command: [AST_Node]
	public var description: String
	{
		return "(While, \(condition), [\(command) - \(command.count)])"
	}
}

public struct ConditionalNode: ExprNode
{
	let condition: ExprNode
	let commandTrue: [AST_Node]
	let commandFalse: [AST_Node]
	public var description: String
	{
		return "(Conditional, \(condition), [\(commandTrue) - \(commandTrue.count) ], [ \(commandFalse) - \(commandFalse.count) ])"
	}
}
