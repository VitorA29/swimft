/// #START_DOC
/// - This define the abstract syntax tree for the ImΠ language(<S>).
/// #END_DOC
public protocol AbstractSyntaxTreeImp: AbstractSyntaxTree
{
}

/// #START_DOC
/// - This wraps all command of the ImΠ language(<command>).
/// #END_DOC
public protocol CommandImpNode: AbstractSyntaxTreeImp
{
}

/// #START_DOC
/// - This wrap the no operation('nop').
/// #END_DOC
public struct NoOpImpNode: CommandImpNode
{
	public var description: String
	{
		return "NoOpNode()"
	}
}

/// #START_DOC
/// - This wrap the assign operation(<assign>).
/// #END_DOC
public struct AssignImpNode: CommandImpNode
{
	let identifier: IdentifierImpNode
	let expression: ExpressionImpNode
	public var description: String
	{
		return "AssignNode(\(identifier), \(expression))"
	}
}

/// #START_DOC
/// - This wrap the while operation(<while>).
/// #END_DOC
public struct WhileImpNode: CommandImpNode
{
	let condition: LogicalExpressionImpNode
	let command: [CommandImpNode]
	public var description: String
	{
		return "WhileNode(\(condition), [\(command) - \(command.count)])"
	}
}

/// #START_DOC
/// - This wrap the conditional operation(<conditional>).
/// #END_DOC
public struct ConditionalImpNode: CommandImpNode
{
	let condition: LogicalExpressionImpNode
	let commandTrue: [CommandImpNode]
	let commandFalse: [CommandImpNode]
	public var description: String
	{
		return "ConditionalNode(\(condition), [\(commandTrue) - \(commandTrue.count) ], [ \(commandFalse) - \(commandFalse.count) ])"
	}
}

/// #START_DOC
/// - This wraps all the forms of expressions(<expression>).
/// #END_DOC
public protocol ExpressionImpNode: CommandImpNode
{
}

/// #START_DOC
/// - This wrap the block operation(<block>).
/// #END_DOC
public struct BlockImpNode: CommandImpNode
{
	let declaration: [DeclarationImpNode]
	let command: [CommandImpNode]
	public var description: String
	{
		return "BlockNode([\(declaration) - \(declaration.count)], [\(command) - \(command.count)])"
	}
}

/// #START_DOC
/// - This wrap the print operation(<print>).
/// #END_DOC
public struct PrintImpNode: CommandImpNode
{
	let expression: ExpressionImpNode
	public var description: String
	{
		return "PrintNode(\(expression))"
	}
}

/// #START_DOC
/// - This wrap the identifier value(<identifier>).
/// #END_DOC
public struct IdentifierImpNode: LogicalExpressionImpNode, ArithmeticExpressionImpNode
{
	let name: String
	public var description: String
	{
		return "IdentifierNode(\(name))"
	}
}

/// #START_DOC
/// - This wrap the reference operations(<reference>).
/// #END_DOC
public protocol ReferenceImpNode: ExpressionImpNode
{
	var identifier: IdentifierImpNode { get }
}

/// #START_DOC
/// - This wraps all the forms of logical expressions(<logical_expression>).
/// #END_DOC
public protocol LogicalExpressionImpNode: ExpressionImpNode
{
}


/// #START_DOC
/// - This wraps all the forms of arithmetic expressions(<arithmetic_expression>).
/// #END_DOC
public protocol ArithmeticExpressionImpNode: ExpressionImpNode
{
}

/// #START_DOC
/// - This wraps all the forms of declarations(<declaration>).
/// #END_DOC
public protocol DeclarationImpNode: AbstractSyntaxTreeImp
{
}

/// #START_DOC
/// - This wrap the address reference operation(<address_reference>).
/// #END_DOC
public struct AddressReferenceImpNode: ReferenceImpNode
{
	public let identifier: IdentifierImpNode
	public var description: String
	{
		return "AddressReferenceNode(\(identifier))"
	}
}

/// #START_DOC
/// - This wrap the value reference operation(<value_reference>).
/// #END_DOC
public struct ValueReferenceImpNode: ReferenceImpNode, LogicalExpressionImpNode, ArithmeticExpressionImpNode
{
	public let identifier: IdentifierImpNode
	public var description: String
	{
		return "ValueReferenceNode(\(identifier))"
	}
}

/// #START_DOC
/// - This wrap the logical classification values(<logical_classification>).
/// #END_DOC
public struct LogicalClassificationImpNode: LogicalExpressionImpNode
{
	let value: Bool
	public var description: String
	{
		return "LogicalClassificationNode(\(value))"
	}
}

/// #START_DOC
/// - This wrap the negation operation(<negation>).
/// #END_DOC
public struct NegationImpNode: LogicalExpressionImpNode
{
	let logicalExpression: LogicalExpressionImpNode
	public var description: String
	{
		return "!(\(logicalExpression))"
	}
}

/// #START_DOC
/// - This wraps all logical operations(<logical_operation>).
/// #END_DOC
public protocol LogicalOperationImpNode: LogicalExpressionImpNode
{
}

/// #START_DOC
/// - This wrap the number value(<number>).
/// #END_DOC
public struct NumberImpNode: ArithmeticExpressionImpNode
{
	let value: Float
	public var description: String
	{
		return "NumberNode(\(value))"
	}
}

/// #START_DOC
/// - This wrap all arithmatic operations(<addition>, <subtraction>, <multiplication>, <division>).
/// #END_DOC
public struct ArithmeticOperationImpNode: ArithmeticExpressionImpNode
{
	let op: String
	let lhs: ArithmeticExpressionImpNode
	let rhs: ArithmeticExpressionImpNode
	public var description: String
	{
		return "'\(op)'(\(lhs), \(rhs))"
	}
}

/// #START_DOC
/// - This wrap the variable node(<variable_declaration>).
/// #END_DOC
public struct VariableDeclarationImpNode: DeclarationImpNode
{
	let identifier: IdentifierImpNode
	let expression: ExpressionImpNode
	
	public var description: String
	{
		return "VariableNode(\(identifier), \(expression))"
	}
}

/// #START_DOC
/// - This wrap the constant node(<constant_declaration>).
/// #END_DOC
public struct ConstantDeclarationImpNode: DeclarationImpNode
{
	let identifier: IdentifierImpNode
	let expression: ExpressionImpNode
	
	public var description: String
	{
		return "ConstantNode(\(identifier), \(expression))"
	}
}

/// #START_DOC
/// - This wrap the equality node(<equality>).
/// #END_DOC
public struct EqualityImpNode: LogicalOperationImpNode
{
	let lhs: ExpressionImpNode
	let rhs: ExpressionImpNode
	public var description: String
	{
		return "'=='(\(lhs), \(rhs))"
	}
}

/// #START_DOC
/// - This wrap the logical connection node(<logical_connection>).
/// #END_DOC
public struct LogicalConnectionImpNode: LogicalOperationImpNode
{
	let op: String
	let lhs: LogicalExpressionImpNode
	let rhs: LogicalExpressionImpNode
	public var description: String
	{
		return "'\(op)'(\(lhs), \(rhs))"
	}
}

/// #START_DOC
/// - This wrap the inequality operation node(<inequality_operation>).
/// #END_DOC
public struct InequalityOperationImpNode: LogicalOperationImpNode
{
	let op: String
	let lhs: ArithmeticExpressionImpNode
	let rhs: ArithmeticExpressionImpNode
	public var description: String
	{
		return "'\(op)'(\(lhs), \(rhs))"
	}
}
