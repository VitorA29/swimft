/// - This define the abstract syntax tree for the ImΠ language(<S>).
public protocol AbstractSyntaxTreeImp: AbstractSyntaxTree
{
}

/// - This wraps all command of the ImΠ language(<command>).
public protocol CommandImpNode: AbstractSyntaxTreeImp
{
}

/// - This wrap the no operation('nop').
public struct NoOpImpNode: CommandImpNode
{
	public var description: String
	{
		return "NoOpNode()"
	}
}

/// - This wrap the assign operation(<assign>).
public struct AssignImpNode: CommandImpNode
{
	let identifier: IdentifierImpNode
	let expression: ExpressionImpNode
	public var description: String
	{
		return "AssignNode(\(identifier), \(expression))"
	}
}

/// - This wrap the while operation(<while>).
public struct WhileImpNode: CommandImpNode
{
	let condition: LogicalExpressionImpNode
	let command: [CommandImpNode]
	public var description: String
	{
		return "WhileNode(\(condition), [\(command) - \(command.count)])"
	}
}

/// - This wrap the conditional operation(<conditional>).
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

/// - This wraps all the forms of expressions(<expression>).
public protocol ExpressionImpNode: CommandImpNode
{
}

/// - This wrap the block operation(<block>).
public struct BlockImpNode: CommandImpNode
{
	let declaration: [DeclarationImpNode]
	let command: [CommandImpNode]
	public var description: String
	{
		return "BlockNode([\(declaration) - \(declaration.count)], [\(command) - \(command.count)])"
	}
}

/// - This wrap the print operation(<print>).
public struct PrintImpNode: CommandImpNode
{
	let expression: ExpressionImpNode
	public var description: String
	{
		return "PrintNode(\(expression))"
	}
}

/// - This wrap the call node(<call>).
public struct CallImpNode: CommandImpNode
{
	let identifier: IdentifierImpNode
	let actual: [ExpressionImpNode]
	
	public var description: String
	{
		return "CallNode(\(identifier), [\(actual) - \(actual.count)])"
	}
}

/// - This wrap the identifier value(<identifier>).
public struct IdentifierImpNode: LogicalExpressionImpNode, ArithmeticExpressionImpNode
{
	let name: String
	public var description: String
	{
		return "IdentifierNode(\(name))"
	}
}

/// - This wrap the reference operations(<reference>).
public protocol ReferenceImpNode: ExpressionImpNode
{
	var identifier: IdentifierImpNode { get }
}

/// - This wraps all the forms of logical expressions(<logical_expression>).
public protocol LogicalExpressionImpNode: ExpressionImpNode
{
}


/// - This wraps all the forms of arithmetic expressions(<arithmetic_expression>).
public protocol ArithmeticExpressionImpNode: ExpressionImpNode
{
}

/// - This wraps all the forms of declarations(<declaration>).
public protocol DeclarationImpNode: AbstractSyntaxTreeImp
{
}

/// - This wrap the address reference operation(<address_reference>).
public struct AddressReferenceImpNode: ReferenceImpNode
{
	public let identifier: IdentifierImpNode
	public var description: String
	{
		return "AddressReferenceNode(\(identifier))"
	}
}

/// - This wrap the value reference operation(<value_reference>).
public struct ValueReferenceImpNode: ReferenceImpNode, LogicalExpressionImpNode, ArithmeticExpressionImpNode
{
	public let identifier: IdentifierImpNode
	public var description: String
	{
		return "ValueReferenceNode(\(identifier))"
	}
}

/// - This wrap the logical classification values(<logical_classification>).
public struct LogicalClassificationImpNode: LogicalExpressionImpNode
{
	let value: Bool
	public var description: String
	{
		return "LogicalClassificationNode(\(value))"
	}
}

/// - This wrap the negation operation(<negation>).
public struct NegationImpNode: LogicalExpressionImpNode
{
	let logicalExpression: LogicalExpressionImpNode
	public var description: String
	{
		return "!(\(logicalExpression))"
	}
}

/// - This wraps all logical operations(<logical_operation>).
public protocol LogicalOperationImpNode: LogicalExpressionImpNode
{
}

/// - This wrap the number value(<number>).
public struct NumberImpNode: ArithmeticExpressionImpNode
{
	let value: Float
	public var description: String
	{
		return "NumberNode(\(value))"
	}
}

/// - This wrap all arithmatic operations(<addition>, <subtraction>, <multiplication>, <division>).
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

/// - This wrap the variable node(<variable_declaration>).
public struct VariableDeclarationImpNode: DeclarationImpNode
{
	let identifier: IdentifierImpNode
	let expression: ExpressionImpNode
	
	public var description: String
	{
		return "VariableNode(\(identifier), \(expression))"
	}
}

/// - This wrap the constant node(<constant_declaration>).
public struct ConstantDeclarationImpNode: DeclarationImpNode
{
	let identifier: IdentifierImpNode
	let expression: ExpressionImpNode
	
	public var description: String
	{
		return "ConstantNode(\(identifier), \(expression))"
	}
}

/// - This wrap the function node(<function_declaration>).
public struct FunctionDeclarationImpNode: DeclarationImpNode
{
	let identifier: IdentifierImpNode
	let formal: [IdentifierImpNode]
	let block: BlockImpNode
	let isRecursive: Bool
	
	public var description: String
	{
		return "FunctionNode(\(identifier), [\(formal) - \(formal.count)], \(block))"
	}
}

/// - This wrap the equality node(<equality>).
public struct EqualityImpNode: LogicalOperationImpNode
{
	let lhs: ExpressionImpNode
	let rhs: ExpressionImpNode
	public var description: String
	{
		return "'=='(\(lhs), \(rhs))"
	}
}

/// - This wrap the logical connection node(<logical_connection>).
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

/// - This wrap the inequality operation node(<inequality_operation>).
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
