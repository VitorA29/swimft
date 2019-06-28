import Foundation

/// - Define the enumeration for the error that can be throw during logical expression nodes handling.
public enum LogicalExpressionHandlerError: Error
{
	case UnexpectedAutomatonValue
}

/// - This defines the pi node for all pi logical expressions.
public protocol LogicalExpressionPiNode: ExpressionPiNode
{
}

/// - This defines the pi node for the pi equal to operation.
public struct EqualToOperationPiNode: LogicalExpressionPiNode
{
	let lhs: ExpressionPiNode
	let rhs: ExpressionPiNode
	public var description: String
	{
		return "Eq(\(lhs), \(rhs))"
	}
}

/// - This defines the pi node for all pi logical connections
public protocol LogicalConnectionPiNode: LogicalExpressionPiNode
{
    var operation: String { get }
	var lhs: LogicalExpressionPiNode { get }
	var rhs: LogicalExpressionPiNode { get }
}

/// - This extension is for creating the default description used by all of it's implementations
public extension LogicalConnectionPiNode
{
	var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

/// - This defines the pi node for the pi and conective operation.
public struct AndConnectivePiNode: LogicalConnectionPiNode
{
	public let operation: String = "And"
	public let lhs: LogicalExpressionPiNode
	public let rhs: LogicalExpressionPiNode
}

/// - This defines the pi node for the pi or conective operation.
public struct OrConnectivePiNode: LogicalConnectionPiNode
{
	public let operation: String = "Or"
	public let lhs: LogicalExpressionPiNode
	public let rhs: LogicalExpressionPiNode
}

/// - This defines the pi node for all pi inequality operation
public protocol InequalityOperationPiNode: LogicalExpressionPiNode
{
    var operation: String { get }
	var lhs: ArithmeticExpressionPiNode { get }
	var rhs: ArithmeticExpressionPiNode { get }
}

/// - This extension is for creating the default description used by all of it's implementations
public extension InequalityOperationPiNode
{
	var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

/// - This defines the pi node for the pi lower than operation.
public struct LowerThanOperationPiNode: InequalityOperationPiNode
{
	public let operation: String = "Lt"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

/// - This defines the pi node for the pi lower equal to operation.
public struct LowerEqualToOperationPiNode: InequalityOperationPiNode
{
	public let operation: String = "Le"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

/// - This defines the pi node for the pi greater than operation.
public struct GreaterThanOperationPiNode: InequalityOperationPiNode
{
	public let operation: String = "Gt"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

/// - This defines the pi node for the pi greater equal to operation.
public struct GreaterEqualToOperationPiNode: InequalityOperationPiNode
{
	public let operation: String = "Ge"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

/// - This defines the pi node for the pi negation operation.
public struct NegationPiNode: LogicalExpressionPiNode
{
	public let logicalExpression: LogicalExpressionPiNode
	public var description: String
	{
		return "Not(\(logicalExpression))"
	}
}

/// - This defines the pi automaton operation code for the equal to operation.
public struct EqualToOperationCode: OperationCode
{
	public let code: String = "EQ"
}

/// - This defines the pi automaton operation code for the and conective operation.
public struct AndConnectiveOperationCode: OperationCode
{
	public let code: String = "AND"
}

/// - This defines the pi automaton operation code for the or connctive operation.
public struct OrConnectiveOperationCode: OperationCode
{
	public let code: String = "OR"
}

/// - This defines the pi automaton operation code for the lower than operation.
public struct LowerThanOperationCode: OperationCode
{
	public let code: String = "LT"
}

/// - This defines the pi automaton operation code for the lower equal to operation.
public struct LowerEqualToOperationCode: OperationCode
{
	public let code: String = "LE"
}

/// - This defines the pi automaton operation code for the greater than operation.
public struct GreaterThanOperationCode: OperationCode
{
	public let code: String = "GT"
}

/// - This defines the pi automaton operation code for the greater equal to operation.
public struct GreaterEqualToOperationCode: OperationCode
{
	public let code: String = "GE"
}

/// - This defines the pi automaton operation code for the negation operation.
public struct NegationOperationCode: OperationCode
{
	public let code: String = "NOT"
}

/// Addition of the handlers for the logical expressions.
public extension PiFrameworkHandler
{
	/// - Handler for the analysis of a node contening a equality logic operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Eq(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #EQ :: C, V, S)
	func processEqualToOperationPiNode (node: EqualToOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
        controlStack.push(value: EqualToOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}

	/// - Helper function for handling with the equality operation.
	/// 	Here the below delta match will occur.
	/// 	δ(#EQ :: C, B₁ :: B₂ :: V, S) = δ(C, B₁ == B₂ :: V, S)
    ///     δ(#EQ :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ == N₂ :: V, S)
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

	/// - Handler for the analysis of a node contening a and conective operation.
	/// 	Here the below delta match will occur.
	/// 	δ(And(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #AND :: C, V, S)
	func processAndConnectivePiNode (node: AndConnectivePiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: AndConnectiveOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}

	/// - Helper function for handling with the and conective operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#AND :: C, B₁ :: B₂ :: V, S) = δ(C, B₁ ∧ B₂ :: V, S)
	func processAndConnectiveOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Bool = try popBooValue(valueStack: valueStack)
		let value2: Bool = try popBooValue(valueStack: valueStack)
		valueStack.push(value: value1 && value2)
	}

	/// - Handler for the analysis of a node contening a or conective operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Or(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #OR :: C, V, S)
	func processOrConnectivePiNode (node: OrConnectivePiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: OrConnectiveOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}

	/// - Helper function for handling with the or conective operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#OR :: C, B₁ :: B₂ :: V, S) = δ(C, B₁ ∨ B₂ :: V, S)
	func processOrConnectiveOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Bool = try popBooValue(valueStack: valueStack)
		let value2: Bool = try popBooValue(valueStack: valueStack)
		valueStack.push(value: value1 || value2)
	}

	/// - Handler for the analysis of a node contening a lower than comparation operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Lt(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #LT :: C, V, S)
	func processLowerThanOperationPiNode (node: LowerThanOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: LowerThanOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// - Helper function for handling with the lower than comparation operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#LT :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ < N₂ :: V, S)
	func processLowerThanOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 < value2)
	}

	/// - Handler for the analysis of a node contening a lower than comparation operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Le(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #LE :: C, V, S)
	func processLowerEqualToOperationPiNode (node: LowerEqualToOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: LowerEqualToOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// - Helper function for handling with the lower than comparation operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#LE :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ <= N₂ :: V, S)
	func processLowerEqualToOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 <= value2)
	}

	/// - Handler for the analysis of a node contening a greater than comparation operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Gt(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #GT :: C, V, S)
	func processGreaterThanOperationPiNode (node: GreaterThanOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: GreaterThanOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// - Helper function for handling with the greater than comparation operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#GT :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ > N₂ :: V, S)
	func processGreaterThanOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 > value2)
	}

	/// - Handler for the analysis of a node contening a greater than comparation operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Ge(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #GE :: C, V, S)
	func processGreaterEqualToOperationPiNode (node: GreaterEqualToOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: GreaterEqualToOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// - Helper function for handling with the greater than comparation operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#GE :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ >= N₂ :: V, S)
	func processGreaterEqualToOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 >= value2)
	}
	
	/// - Handler for the analysis of a node contening a <negation> operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Not(E) :: C, V, S) = δ(E :: #NOT :: C, V, S)
	func processNegationPiNode (node: NegationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: NegationOperationCode())
		controlStack.push(value: node.logicalExpression)
	}

	/// - Helper function for handling with the negation operation.
	/// 	Here the below delta match will occur.
	/// 	δ(#NOT :: C, True :: V, S) = δ(C, False :: V, S), δ(#NOT :: C, False :: V, S) = δ(C, True :: V, S)
	func processNegationOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value: Bool = try popBooValue(valueStack: valueStack)
        valueStack.push(value: !value)
	}
}
