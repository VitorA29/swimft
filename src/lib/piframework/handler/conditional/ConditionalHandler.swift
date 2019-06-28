import Foundation

/// - Define the enumeration for the error that can be throw during conditional node handling.
public enum ConditionalHandlerError: Error
{
	case ExpectedConditionalPiNode
}

/// - This defines the pi node for the pi conditional operation.
public struct ConditionalPiNode: CommandPiNode, AutomatonValue
{
	let condition: LogicalExpressionPiNode
	let commandTrue: CommandPiNode
	let commandFalse: CommandPiNode?
	public var description: String
	{
		if commandFalse == nil
		{
			return "Cond(\(condition), \(commandTrue), nil)"
		}
		else
		{
			return "Cond(\(condition), \(commandTrue), \(commandFalse!))"
		}
	}
}

/// - This defines the pi automaton operation code for the conditional operation.
public struct ConditionalOperationCode: OperationCode
{
	public let code: String = "COND"
}

/// Addition of the handlers for the conditional operation.
public extension PiFrameworkHandler
{
	/// - Handler for the analysis of a node contening a conditional operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Cond(X, M₁, M₂) :: C, V, E, S, L) = δ(X :: #COND :: C, Cond(X, M₁, M₂) :: V, E, S, L)
	func processConditionalPiNode (node: ConditionalPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>)
	{
		controlStack.push(value: ConditionalOperationCode())
		controlStack.push(value: node.condition)
		valueStack.push(value: node)
	}
	
	/// - Handler for perform the relative conditional operation.
	/// 	Here the below delta match will occur.
	/// 	δ(#COND :: C, true :: Cond(X, M₁, M₂) :: V, E, S, L) = δ(M₁ :: C, V, E, S, L)
	/// 	δ(#COND :: C, false :: Cond(X, M₁, M₂) :: V, E, S, L) = δ(M₂ :: C, V, E, S, L)
	func processConditionalOperationCode (controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>) throws
	{
		let conditionValue: Bool = try popBooValue(valueStack: valueStack)
		if valueStack.isEmpty() || !(valueStack.peek() is ConditionalPiNode)
		{
			throw ConditionalHandlerError.ExpectedConditionalPiNode
		}

		let node: ConditionalPiNode = valueStack.pop() as! ConditionalPiNode
		if (conditionValue)
		{
			controlStack.push(value: node.commandTrue)
		}
		else
		{
			controlStack.push(value: node.commandFalse)
		}
	}
}
