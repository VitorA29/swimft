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

public protocol LogicalConnectionPiNode: LogicalExpressionPiNode
{
    var operation: String { get }
	var lhs: LogicalExpressionPiNode { get }
	var rhs: LogicalExpressionPiNode { get }
}

public extension LogicalConnectionPiNode
{
	var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

public struct AndConnectivePiNode: LogicalConnectionPiNode
{
	public let operation: String = "And"
	public let lhs: LogicalExpressionPiNode
	public let rhs: LogicalExpressionPiNode
}

public struct OrConnectivePiNode: LogicalConnectionPiNode
{
	public let operation: String = "Or"
	public let lhs: LogicalExpressionPiNode
	public let rhs: LogicalExpressionPiNode
}

public protocol InequalityOperationPiNode: LogicalExpressionPiNode
{
    var operation: String { get }
	var lhs: ArithmeticExpressionPiNode { get }
	var rhs: ArithmeticExpressionPiNode { get }
}

public extension InequalityOperationPiNode
{
	var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

public struct LowerThanOperationPiNode: InequalityOperationPiNode
{
	public let operation: String = "Lt"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

public struct LowerEqualToOperationPiNode: InequalityOperationPiNode
{
	public let operation: String = "Le"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

public struct GreaterThanOperationPiNode: InequalityOperationPiNode
{
	public let operation: String = "Gt"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

public struct GreaterEqualToOperationPiNode: InequalityOperationPiNode
{
	public let operation: String = "Ge"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
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

public struct AndConnectiveOperationCode: OperationCode
{
	public let code: String = "AND"
}

public struct OrConnectiveOperationCode: OperationCode
{
	public let code: String = "OR"
}

public struct LowerThanOperationCode: OperationCode
{
	public let code: String = "LT"
}

public struct LowerEqualToOperationCode: OperationCode
{
	public let code: String = "LE"
}

public struct GreaterThanOperationCode: OperationCode
{
	public let code: String = "GT"
}

public struct GreaterEqualToOperationCode: OperationCode
{
	public let code: String = "GE"
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
	/// - Handler for the analysis of a node contening a and conective operation.
	/// 	δ(And(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #AND :: C, V, S)
	/// #END_DOC
	func processAndConnectivePiNode (node: AndConnectivePiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: AndConnectiveOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}

	/// #START_DOC
	/// - Helper function for handling with the and conective operation with the desired values.
	/// 	δ(#AND :: C, B₁ :: B₂ :: V, S) = δ(C, B₁ ∧ B₂ :: V, S)
	/// #END_DOC
	func processAndConnectiveOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Bool = try popBooValue(valueStack: valueStack)
		let value2: Bool = try popBooValue(valueStack: valueStack)
		valueStack.push(value: value1 && value2)
	}

	/// #START_DOC
	/// - Handler for the analysis of a node contening a or conective operation.
	/// 	δ(Or(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #OR :: C, V, S)
	/// #END_DOC
	func processOrConnectivePiNode (node: OrConnectivePiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: OrConnectiveOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}

	/// #START_DOC
	/// - Helper function for handling with the or conective operation with the desired values.
	/// 	δ(#OR :: C, B₁ :: B₂ :: V, S) = δ(C, B₁ ∨ B₂ :: V, S)
	/// #END_DOC
	func processOrConnectiveOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Bool = try popBooValue(valueStack: valueStack)
		let value2: Bool = try popBooValue(valueStack: valueStack)
		valueStack.push(value: value1 || value2)
	}

    /// #START_DOC
	/// - Handler for the analysis of a node contening a lower than comparation operation.
	/// 	δ(Lt(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #LT :: C, V, S)
	/// #END_DOC
	func processLowerThanOperationPiNode (node: LowerThanOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: LowerThanOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// #START_DOC
	/// - Helper function for handling with the lower than comparation operation with the desired values.
	/// 	δ(#LT :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ < N₂ :: V, S)
	/// #END_DOC
	func processLowerThanOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 < value2)
	}

	/// #START_DOC
	/// - Handler for the analysis of a node contening a lower than comparation operation.
	/// 	δ(Le(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #LE :: C, V, S)
	/// #END_DOC
	func processLowerEqualToOperationPiNode (node: LowerEqualToOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: LowerEqualToOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// #START_DOC
	/// - Helper function for handling with the lower than comparation operation with the desired values.
	/// 	δ(#LE :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ <= N₂ :: V, S)
	/// #END_DOC
	func processLowerEqualToOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 <= value2)
	}

	/// #START_DOC
	/// - Handler for the analysis of a node contening a greater than comparation operation.
	/// 	δ(Gt(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #GT :: C, V, S)
	/// #END_DOC
	func processGreaterThanOperationPiNode (node: GreaterThanOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: GreaterThanOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// #START_DOC
	/// - Helper function for handling with the greater than comparation operation with the desired values.
	/// 	δ(#GT :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ > N₂ :: V, S)
	/// #END_DOC
	func processGreaterThanOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 > value2)
	}

	/// #START_DOC
	/// - Handler for the analysis of a node contening a greater than comparation operation.
	/// 	δ(Ge(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #GE :: C, V, S)
	/// #END_DOC
	func processGreaterEqualToOperationPiNode (node: GreaterEqualToOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: GreaterEqualToOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// #START_DOC
	/// - Helper function for handling with the greater than comparation operation with the desired values.
	/// 	δ(#GE :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ >= N₂ :: V, S)
	/// #END_DOC
	func processGreaterEqualToOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 >= value2)
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
	/// - Helper function for handling with the negation operation.
	/// 	δ(#NOT :: C, True :: V, S) = δ(C, False :: V, S), δ(#NOT :: C, False :: V, S) = δ(C, True :: V, S)
	/// #END_DOC
	func processNegationOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value: Bool = try popBooValue(valueStack: valueStack)
        valueStack.push(value: !value)
	}
}
