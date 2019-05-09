/// #START_DOC
/// - .
/// #END_DOC
public protocol AST_Imp: CustomStringConvertible
{
}

/// #START_DOC
/// - .
/// #END_DOC
public protocol ExpressionNode: AST_Imp
{
}

/// #START_DOC
/// - .
/// #END_DOC
public protocol BoolNode: ExpressionNode
{
}

/// #START_DOC
/// - .
/// #END_DOC
public protocol ArithNode: ExpressionNode
{
}

/// #START_DOC
/// - .
/// #END_DOC
public struct NumberNode: ArithNode
{
	let value: Float
	public var description: String
	{
		return "NumberNode(\(value))"
	}
}

/// #START_DOC
/// - .
/// #END_DOC
public struct TruthNode: BoolNode
{
	let value: Bool
	public var description: String
	{
		return "TruthNode(\(value))"
	}
}

/// #START_DOC
/// - .
/// #END_DOC
public struct IdentifierNode: BoolNode, ArithNode
{
	let name: String
	public var description: String
	{
		return "IdentifierNode(\(name))"
	}
}

/// #START_DOC
/// - .
/// #END_DOC
public struct NegationNode: BoolNode
{
	let expression: BoolNode
	public var description: String
	{
		return "!(\(expression))"
	}
}

/// #START_DOC
/// - .
/// #END_DOC
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

/// #START_DOC
/// - .
/// #END_DOC
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

/// #START_DOC
/// - .
/// #END_DOC
public struct NoOpNode: AST_Imp
{
	public var description: String
	{
		return "NoOpNode()"
	}
}

/// #START_DOC
/// - .
/// #END_DOC
public struct AssignNode: AST_Imp
{
	let variable: IdentifierNode
	let expression: ExpressionNode
	public var description: String
	{
		return "Assign(\(variable), \(expression))"
	}
}

/// #START_DOC
/// - .
/// #END_DOC
public struct WhileNode: AST_Imp
{
	let condition: BoolNode
	let command: [AST_Imp]
	public var description: String
	{
		return "While(\(condition), [\(command) - \(command.count)])"
	}
}

/// #START_DOC
/// - .
/// #END_DOC
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
