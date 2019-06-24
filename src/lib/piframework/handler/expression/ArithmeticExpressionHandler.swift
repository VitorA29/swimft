import Foundation

public enum ArithmeticExpressionHandlerError: Error
{
	case UndefinedArithmeticOperation(String)
	case UndefinedArithmeticOperationCode(String)
}

public protocol ArithmeticExpressionPiNode: ExpressionPiNode
{
}

public struct ArithmeticOperationPiNode: ArithmeticExpressionPiNode
{
	let operation: String
	let lhs: ArithmeticExpressionPiNode
	let rhs: ArithmeticExpressionPiNode
	public var description: String
	{
		return "\(operation)(\(lhs), \(rhs))"
	}
}

public struct ArithmeticOperationCode: OperationCode
{
	public let code: String
}

/// #START_DOC
/// - Handler for all operations relative to <arithmetic_expression> ramifications.
/// #END_DOC
public extension PiFrameworkHandler
{
	/// #START_DOC
	/// - Handler for the analysis of a node contening a arithmetic operation.
	/// 	Here the below delta match will occur,  meaning that `operation` will be one of 'Sum', 'Mul', 'Div' and 'Sub' and `code` will be it relative operation code form of the `operation`.
	/// 	δ(`operation`(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: `code` :: C, V, S)
	/// #END_DOC
	func processArithmeticOperationPiNode (node: ArithmeticOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>) throws
	{
		switch (node.operation)
		{
			case "Mul":
				controlStack.push(value: ArithmeticOperationCode(code: "MUL"))
			case "Div":
				controlStack.push(value: ArithmeticOperationCode(code: "DIV"))
			case "Sum":
				controlStack.push(value: ArithmeticOperationCode(code: "SUM"))
			case "Sub":
				controlStack.push(value: ArithmeticOperationCode(code: "SUB"))
			default:
					throw ArithmeticExpressionHandlerError.UndefinedArithmeticOperation(node.operation)
		}
		controlStack.push(value: node.lhs)
		controlStack.push(value: node.rhs)
	}
	
	/// #START_DOC
	/// - Handler for perform the relative arithmetic operation with the desired values.
	/// 	Here the below delta match will occur,  meaning that `code` will be one of '#SUM', '#MUL', '#DIV' and '#SUB' and `aritimetic_operator` will be it relative arithmetic operator.
	/// 	δ(`code` :: C, N₁ :: N₂ :: V, S) = δ(C, N₁ `aritimetic_operator` N₂ :: V, S)
	/// #END_DOC
	func processArithmeticOperationCode (operationCode: ArithmeticOperationCode, valueStack: Stack<AutomatonValue>) throws
	{
		let value1: Float = try popNumValue(valueStack: valueStack)
		let value2: Float = try popNumValue(valueStack: valueStack)
		switch(operationCode.code)
		{
			case "MUL":
				valueStack.push(value: value1 * value2)
				break
			case "DIV":
				valueStack.push(value: value1 / value2)
				break
			case "SUM":
				valueStack.push(value: value1 + value2)
				break
			case "SUB":
				valueStack.push(value: value1 - value2)
				break
			default:
					throw ArithmeticExpressionHandlerError.UndefinedArithmeticOperationCode(operationCode.code)
		}
	}
}
