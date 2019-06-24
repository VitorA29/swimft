import Foundation

public enum LogicalExpressionHandlerError: Error
{
    case UndefinedInequalityOperation(String)
    case UndefinedLogicalConnection(String)
    case UndefinedInequalityOperationCode(String)
    case UndefinedLogicalConnectionOperationCode(String)
    case UnexpectedAutomatonValue
}

public protocol LogicalExpressionPiNode: ExpressionPiNode
{
}

public struct EqualToOperationPiNode: LogicalExpressionPiNode
{
	let lhs: ExpressionPiNode
	let rhs: ExpressionPiNode
	public var description: String
	{
		return "Eq(\(lhs), \(rhs))"
	}
}

public struct LogicalConnectionPiNode: LogicalExpressionPiNode
{
    let operation: String
	var lhs: LogicalExpressionPiNode
	var rhs: LogicalExpressionPiNode
    public var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

public struct InequalityOperationPiNode: LogicalExpressionPiNode
{
    let operation: String
	var lhs: ArithmeticExpressionPiNode
	var rhs: ArithmeticExpressionPiNode
    public var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

public struct NegationPiNode: LogicalExpressionPiNode
{
	public let logicalExpression: LogicalExpressionPiNode
	public var description: String
	{
		return "Not(\(logicalExpression))"
	}
}

public struct EqualToOperationCode: OperationCode
{
	public let code: String = "EQ"
}

public struct LogicalConnectionOperationCode: OperationCode
{
	public let code: String
}

public struct InequalityOperationCode: OperationCode
{
	public let code: String
}

public struct NegationOperationCode: OperationCode
{
	public let code: String = "NOT"
}


/// #START_DOC
/// - Handler for all operations relative to <logical_expression> ramifications.
/// #END_DOC
public extension PiFrameworkHandler
{
	/// #START_DOC
	/// - Handler for the analysis of a node contening a equality logic operation.
	/// 	δ(Eq(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #EQ :: C, V, S)
	/// #END_DOC
	func processEqualToOperationPiNode (node: EqualToOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
        controlStack.push(value: EqualToOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}

    /// #START_DOC
	/// - Handler for the analysis of a node contening a binary logic operation.
	/// 	Here the below delta matchs will occur,  meaning that `operation` will be one of 'Lt', 'Le', 'Gt', 'Ge', 'Eq', 'And' and 'Or' and `operationOpCode` will be it relative operation code form of the `operation`.
	/// 	δ(`operation`(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: `operationOpCode` :: C, V, S)
	/// #END_DOC
	func processLogicalConnectionPiNode (node: LogicalConnectionPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		switch (node.operation)
		{
			case "And":
				controlStack.push(value: LogicalConnectionOperationCode(code: "AND"))
			case "Or":
				controlStack.push(value: LogicalConnectionOperationCode(code: "OR"))
			default:
                throw LogicalExpressionHandlerError.UndefinedLogicalConnection(node.operation)
		}
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}

    /// #START_DOC
	/// - Handler for the analysis of a node contening a inequality operation.
	/// 	Here the below delta matchs will occur,  meaning that `operation` will be one of 'Lt', 'Le', 'Gt' and 'Ge', meaning that `operationOpCode` will be it relative operation code form of the `operation`.
	/// 	δ(`operation`(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: `operationOpCode` :: C, V, S)
	/// #END_DOC
	func processInequalityOperationPiNode (node: InequalityOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		switch (node.operation)
		{
			case "Lt":
				controlStack.push(value: InequalityOperationCode(code: "LT"))
			case "Le":
				controlStack.push(value: InequalityOperationCode(code: "LE"))
			case "Gt":
				controlStack.push(value: InequalityOperationCode(code: "GT"))
			case "Ge":
				controlStack.push(value: InequalityOperationCode(code: "GE"))
			default:
                throw LogicalExpressionHandlerError.UndefinedInequalityOperation(node.operation)
		}
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// #START_DOC
	/// - Handler for the analysis of a node contening a <negation> operation.
	/// 	δ(Not(E) :: C, V, S) = δ(E :: #NOT :: C, V, S)
	/// #END_DOC
	func processNegationPiNode (node: NegationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: NegationOperationCode())
		controlStack.push(value: node.logicalExpression)
	}

    /// #START_DOC
	/// - Helper function for handling with the equality operation.
	/// 	δ(#EQ :: C, B₁ :: B₂ :: V, S) = δ(C, B₁ == B₂ :: V, S)
    ///     δ(#EQ :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ == N₂ :: V, S)
	/// #END_DOC
	func processEqualToOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		if valueStack.peek() is Float
        {
            let value1: Float = try popNumValue(valueStack: valueStack)
            let value2: Float = try popNumValue(valueStack: valueStack)
            valueStack.push(value: value1 == value2)
        }
        else if valueStack.peek() is Bool
        {
            let value1: Bool = try popBooValue(valueStack: valueStack)
            let value2: Bool = try popBooValue(valueStack: valueStack)
            valueStack.push(value: value1 == value2)
        }
        else
        {
            throw LogicalExpressionHandlerError.UnexpectedAutomatonValue
        }
	}
	
	/// #START_DOC
	/// - Helper function for handling with inequality operations, here the below math will occur and the following pi operations codes will be processed '#LT', '#LE', '#GT' and '#GE'.
	/// 	δ(`operationCodeNode` :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ `inequality_operator` N₂ :: V, S)
	/// #END_DOC
	func processInequalityOperationCode (operationCode: InequalityOperationCode, valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		switch(operationCode.code)
		{
			case "LT":
				valueStack.push(value: value1 < value2)
			case "LE":
				valueStack.push(value: value1 <= value2)
			case "GT":
				valueStack.push(value: value1 > value2)
			case "GE":
				valueStack.push(value: value1 >= value2)
			default:
					throw LogicalExpressionHandlerError.UndefinedInequalityOperationCode(operationCode.code)
		}
	}
	
	/// #START_DOC
	/// - Helper function for handling with logical connectives, here the below math will occur and the following pi operations codes will be processed '#AND' and '#OR'.
	/// 	δ(`operationCodeNode` :: C, B₁ :: B₂ :: V, S) = δ(C, B₁ `logical_operator` B₂ :: V, S)
	/// #END_DOC
	func processLogicalConnectionOperationCode (operationCode: LogicalConnectionOperationCode, valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Bool = try popBooValue(valueStack: valueStack)
		let value2: Bool = try popBooValue(valueStack: valueStack)
		switch(operationCode.code)
		{
			case "AND":
				valueStack.push(value: value1 && value2)
			case "OR":
				valueStack.push(value: value1 || value2)
			default:
					throw LogicalExpressionHandlerError.UndefinedLogicalConnectionOperationCode(operationCode.code)
		}
	}

    /// #START_DOC
	/// - Helper function for handling with the negation operation.
	/// 	δ(#NOT :: C, True :: V, S) = δ(C, False :: V, S), δ(#NOT :: C, False :: V, S) = δ(C, True :: V, S)
	/// #END_DOC
	func processNegationOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value: Bool = try popBooValue(valueStack: valueStack)
        valueStack.push(value: !value)
	}
}
