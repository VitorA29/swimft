/// #START_DOC
/// - This wraps all the ast nodes for the ImΠ language(<S>).
/// #END_DOC
public protocol AST_Imp: CustomStringConvertible
{
}

/// #START_DOC
/// - This wraps all the forms of expressions(<expression>).
/// #END_DOC
public protocol ExpressionNode: AST_Imp
{
}

/// #START_DOC
/// - This wraps all the forms of boolean expressions(<bool_expression>).
/// #END_DOC
public protocol BoolNode: ExpressionNode
{
}

/// #START_DOC
/// - This wraps all the forms of arithmetic expressions(<arith_expression>).
/// #END_DOC
public protocol ArithNode: ExpressionNode
{
}

/// #START_DOC
/// - This wrap the number value(<number>).
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
/// - This wrap the truth value(<truth>).
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
/// - This wrap the identifier value(<identifier>).
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
/// - This wrap the reference operation(<reference>).
/// #END_DOC
public struct ReferenceNode: ExpressionNode
{
	let operation: String
	let identifier: IdentifierNode
	public var description: String
	{
		return "ReferenceNode(\(operation), \(identifier))"
	}
}

/// #START_DOC
/// - This wrap the negation operation(<negation>).
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
/// - This wrap all arithmatic operations(<addition>, <subtraction>, <multiplication>, <division>).
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
/// - This wrap all boolean operations(<equality>, <conjunction>, <disjunction>, <lowerthan>, <lowereq>, <greaterthan>, <greatereq>).
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
/// - This wrap the no operation('nop').
/// #END_DOC
public struct NoOpNode: AST_Imp
{
	public var description: String
	{
		return "NoOpNode()"
	}
}

/// #START_DOC
/// - This wrap the assing operation(<assign>).
/// #END_DOC
public struct AssignNode: AST_Imp
{
	let identifier: IdentifierNode
	let expression: ExpressionNode
	public var description: String
	{
		return "AssignNode(\(identifier), \(expression))"
	}
}

/// #START_DOC
/// - This wrap the while operation(<while>).
/// #END_DOC
public struct WhileNode: AST_Imp
{
	let condition: BoolNode
	let command: [AST_Imp]
	public var description: String
	{
		return "WhileNode(\(condition), [\(command) - \(command.count)])"
	}
}

/// #START_DOC
/// - This wrap the conditional operation(<conditional>).
/// #END_DOC
public struct ConditionalNode: AST_Imp
{
	let condition: BoolNode
	let commandTrue: [AST_Imp]
	let commandFalse: [AST_Imp]
	public var description: String
	{
		return "ConditionalNode(\(condition), [\(commandTrue) - \(commandTrue.count) ], [ \(commandFalse) - \(commandFalse.count) ])"
	}
}


/// #START_DOC
/// - This wraps all the forms of declarations(<declaration>).
/// #END_DOC
public protocol DeclarationNode: AST_Imp
{
}

/// #START_DOC
/// - This wrap the variable node(<var>).
/// #END_DOC
public struct VariableNode: DeclarationNode
{
	let identifier: IdentifierNode
	let expression: ExpressionNode
	
	public var description: String
	{
		return "VariableNode(\(identifier), \(expression))"
	}
}

/// #START_DOC
/// - This wrap the constant node(<const>).
/// #END_DOC
public struct ConstantNode: DeclarationNode
{
	let identifier: IdentifierNode
	let expression: ExpressionNode
	
	public var description: String
	{
		return "ConstantNode(\(identifier), \(expression))"
	}
}

/// #START_DOC
/// - This wrap the block operation(<block>).
/// #END_DOC
public struct BlockNode: AST_Imp
{
	let declaration: DeclarationNode
	let command: [AST_Imp]
	public var description: String
	{
		return "BlockNode(\(declaration), [\(command) - \(command.count)])"
	}
}

/// #START_DOC
/// - This wrap the print operation(<print>).
/// #END_DOC
public struct PrintNode: AST_Imp
{
	let expression: ExpressionNode
	public var description: String
	{
		return "PrintNode(\(expression))"
	}
}
