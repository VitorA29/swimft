public protocol AST_Imp: CustomStringConvertible
{
}

public protocol ExpressionNode: AST_Imp
{
}

public protocol BoolNode: ExpressionNode
{
}

public protocol ArithNode: ExpressionNode
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
	let lhs: ExpressionNode
	let rhs: ExpressionNode
	public var description: String
	{
		return "'\(op)'(\(lhs), \(rhs))"
	}
}

public struct NoOpNode: AST_Imp
{
	public var description: String
	{
		return "NoOpNode()"
	}
}

public struct AssignNode: AST_Imp
{
	let variable: IdentifierNode
	let expression: ExpressionNode
	public var description: String
	{
		return "Assign(\(variable), \(expression))"
	}
}

public struct WhileNode: AST_Imp
{
	let condition: BoolNode
	let command: [AST_Imp]
	public var description: String
	{
		return "While(\(condition), [\(command) - \(command.count)])"
	}
}

public struct ConditionalNode: AST_Imp
{
	let condition: BoolNode
	let commandTrue: [AST_Imp]
	let commandFalse: [AST_Imp]
	public var description: String
	{
		return "Conditional(\(condition), [\(commandTrue) - \(commandTrue.count) ], [ \(commandFalse) - \(commandFalse.count) ])"
	}
}
