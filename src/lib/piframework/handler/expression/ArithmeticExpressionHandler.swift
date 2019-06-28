import Foundation

public protocol ArithmeticExpressionPiNode: ExpressionPiNode
{
}

public protocol ArithmeticOperationPiNode: ArithmeticExpressionPiNode
{
	var operation: String { get }
	var lhs: ArithmeticExpressionPiNode { get }
	var rhs: ArithmeticExpressionPiNode { get }
}

public extension ArithmeticOperationPiNode
{
	var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

public struct MultiplicationOperationPiNode: ArithmeticOperationPiNode
{
	public let operation: String = "Mul"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

public struct DivisionOperationPiNode: ArithmeticOperationPiNode
{
	public let operation: String = "Div"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

public struct SumOperationPiNode: ArithmeticOperationPiNode
{
	public let operation: String = "Sum"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

public struct SubtractionOperationPiNode: ArithmeticOperationPiNode
{
	public let operation: String = "Sub"
	public let lhs: ArithmeticExpressionPiNode
	public let rhs: ArithmeticExpressionPiNode
}

public struct MultiplicationOperationCode: OperationCode
{
	public let code: String = "MUL"
}

public struct DivisionOperationCode: OperationCode
{
	public let code: String = "DIV"
}

public struct SumOperationCode: OperationCode
{
	public let code: String = "SUM"
}

public struct SubtractionOperationCode: OperationCode
{
	public let code: String = "SUB"
}

/// #START_DOC
/// - Handler for all operations relative to <arithmetic_expression> ramifications.
/// #END_DOC
public extension PiFrameworkHandler
{
	/// #START_DOC
	/// - Handler for the analysis of a node contening a multiplication operation.
	/// 	δ(Mul(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #MUL :: C, V, S)
	/// #END_DOC
	func processMultiplicationOperationPiNode (node: MultiplicationOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: MultiplicationOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// #START_DOC
	/// - Handler for perform the relative multiplication operation with the desired values.
	/// 	δ(#MUL :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ * N₂ :: V, S)
	/// #END_DOC
	func processMultiplicationOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 * value2)
	}

	/// #START_DOC
	/// - Handler for the analysis of a node contening a division operation.
	/// 	δ(Div(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #DIV :: C, V, S)
	/// #END_DOC
	func processDivisionOperationPiNode (node: DivisionOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: DivisionOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// #START_DOC
	/// - Handler for perform the relative division operation with the desired values.
	/// 	δ(#DIV :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ / N₂ :: V, S)
	/// #END_DOC
	func processDivisionOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 / value2)
	}

	/// #START_DOC
	/// - Handler for the analysis of a node contening a sum operation.
	/// 	δ(Sum(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #SUM :: C, V, S)
	/// #END_DOC
	func processSumOperationPiNode (node: SumOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: SumOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// #START_DOC
	/// - Handler for perform the relative sum operation with the desired values.
	/// 	δ(#SUM :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ + N₂ :: V, S)
	/// #END_DOC
	func processSumOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 + value2)
	}

	/// #START_DOC
	/// - Handler for the analysis of a node contening a subtraction operation.
	/// 	δ(Sub(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #SUB :: C, V, S)
	/// #END_DOC
	func processSubtractionOperationPiNode (node: SubtractionOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		controlStack.push(value: SubtractionOperationCode())
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// #START_DOC
	/// - Handler for perform the relative subtraction operation with the desired values.
	/// 	δ(#SUB :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ - N₂ :: V, S)
	/// #END_DOC
	func processSubtractionOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		valueStack.push(value: value1 - value2)
	}
}
