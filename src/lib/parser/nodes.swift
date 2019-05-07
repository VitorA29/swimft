public protocol AST_Node: CustomStringConvertible
{
}

public protocol ExprNode: AST_Node
{
}

public protocol BoolNode: ExprNode
{
}

public protocol ArithNode: ExprNode
{
}

public struct NumberNode: ArithNode
{
	let value: Float
	public var description: String
	{
		return "NumberNode(\(value))"
	}
}

public struct TruthNode: BoolNode
{
	let value: Bool
	public var description: String
	{
		return "TruthNode(\(value))"
	}
}

public struct IdentifierNode: BoolNode, ArithNode
{
	let name: String
	public var description: String
	{
		return "IdentifierNode(\(name))"
	}
}

public struct NegationNode: BoolNode
{
	let expression: BoolNode
	public var description: String
	{
		return "!(\(expression))"
	}
}

public struct ArithOpNode: ArithNode
{
	let op: String
	let lhs: ArithNode
	let rhs: ArithNode
	public var description: String
	{
		return "'\(op)'(\(lhs), \(rhs))"
	}
}

public struct BoolOpNode: BoolNode
{
	let op: String
	let lhs: ExprNode
	let rhs: ExprNode
	public var description: String
	{
		return "'\(op)'(\(lhs), \(rhs))"
	}
}

public struct NoOpNode: AST_Node
{
	public var description: String
	{
		return "NoOpNode()"
	}
}

public struct AssignNode: AST_Node
{
	let variable: IdentifierNode
	let expression: ExprNode
	public var description: String
	{
		return "Assign(\(variable), \(expression))"
	}
}

public struct WhileNode: AST_Node
{
	let condition: BoolNode
	let command: [AST_Node]
	public var description: String
	{
		return "While(\(condition), [\(command) - \(command.count)])"
	}
}

public struct ConditionalNode: AST_Node
{
	let condition: BoolNode
	let commandTrue: [AST_Node]
	let commandFalse: [AST_Node]
	public var description: String
	{
		return "Conditional(\(condition), [\(commandTrue) - \(commandTrue.count) ], [ \(commandFalse) - \(commandFalse.count) ])"
	}
}
