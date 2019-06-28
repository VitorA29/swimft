/// - This defines the pi node for all pi arithmetic expressions.
public protocol ArithmeticExpressionPiNode: ExpressionPiNode
{
}

/// - This defines the pi node for all pi arithmetic operations
public protocol ArithmeticOperationPiNode: ArithmeticExpressionPiNode
{
	var operation: String { get }
	var lhs: ArithmeticExpressionPiNode { get }
	var rhs: ArithmeticExpressionPiNode { get }
}

/// - This extension is for creating the default description used by all of it's implementations
public extension ArithmeticOperationPiNode
{
	var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

/// - This defines the pi node for the pi multiplication operation.
public struct MultiplicationOperationPiNode: ArithmeticOperationPiNode
{
	public let operation: String = "Mul"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

/// - This defines the pi node for the pi division operation.
public struct DivisionOperationPiNode: ArithmeticOperationPiNode
{
	public let operation: String = "Div"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

/// - This defines the pi node for the pi sum operation.
public struct SumOperationPiNode: ArithmeticOperationPiNode
{
	public let operation: String = "Sum"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

/// - This defines the pi node for the pi sub operation.
public struct SubtractionOperationPiNode: ArithmeticOperationPiNode
{
	public let operation: String = "Sub"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

/// - This defines the pi automaton operation code for the multiplication operation.
public struct MultiplicationOperationCode: OperationCode
{
	public let code: String = "MUL"
}

/// - This defines the pi automaton operation code for the division operation.
public struct DivisionOperationCode: OperationCode
{
	public let code: String = "DIV"
}

/// - This defines the pi automaton operation code for the sum operation.
public struct SumOperationCode: OperationCode
{
	public let code: String = "SUM"
}

/// - This defines the pi automaton operation code for the subtraction operation.
public struct SubtractionOperationCode: OperationCode
{
	public let code: String = "SUB"
}

/// Addition of the handlers for the arithmetic expressions.
public extension PiFrameworkHandler
{
	/// - Handler for the analysis of a node contening a multiplication operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Mul(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #MUL :: C, V, S)
	func processMultiplicationOperationPiNode (node: MultiplicationOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: MultiplicationOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// - Handler for perform the relative multiplication operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#MUL :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ * N₂ :: V, S)
	func processMultiplicationOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 * value2)
	}

	/// - Handler for the analysis of a node contening a division operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Div(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #DIV :: C, V, S)
	func processDivisionOperationPiNode (node: DivisionOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: DivisionOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// - Handler for perform the relative division operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#DIV :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ / N₂ :: V, S)
	func processDivisionOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 / value2)
	}

	/// - Handler for the analysis of a node contening a sum operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Sum(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #SUM :: C, V, S)
	func processSumOperationPiNode (node: SumOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: SumOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// - Handler for perform the relative sum operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#SUM :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ + N₂ :: V, S)
	func processSumOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 + value2)
	}

	/// - Handler for the analysis of a node contening a subtraction operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Sub(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #SUB :: C, V, S)
	func processSubtractionOperationPiNode (node: SubtractionOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: SubtractionOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// - Handler for perform the relative subtraction operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#SUB :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ - N₂ :: V, S)
	func processSubtractionOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 - value2)
	}
}
