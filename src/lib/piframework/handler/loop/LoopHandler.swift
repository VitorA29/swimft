import Foundation

/// - Define the enumeration for the error that can be throw during loop node handling.
public enum LoopHandlerError: Error
{
	case ExpectedLoopPiNode
}

/// - This defines the pi node for the pi loop operation.
public struct LoopPiNode: CommandPiNode, AutomatonValue
{
	let condition: LogicalExpressionPiNode
	let command: CommandPiNode
	public var description: String
	{
		return "Loop(\(condition), \(command))"
	}
}

/// - This defines the pi automaton operation code for the loop operation.
public struct LoopOperationCode: OperationCode
{
	public let code: String = "LOOP"
}

/// Addition of the handlers for the loop operation.
public extension PiFrameworkHandler
{
	/// - Handler for the analysis of a node contening a conditional operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Loop(X, M) :: C, V, E, S, L) = δ(X :: #LOOP :: C, Loop(X, M) :: V, E, S, L)
	func processLoopPiNode (node: LoopPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>)
	{
		controlStack.push(value: LoopOperationCode())
		controlStack.push(value: node.condition)
		valueStack.push(value: node)
	}
	
	/// - Handler for perform the relative loop operation.
	/// 	Here the below delta match will occur.
	/// 	δ(#LOOP :: C, true :: Loop(X, M) :: V, E, S, L) = δ(M :: Loop(X, M) :: C, V, E, S, L)
	/// 	δ(#LOOP :: C, false :: Loop(X, M) :: V, E, S, L) = δ(C, V, E, S, L)
	func processLoopOperationCode (controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>) throws
	{
		let condition: Bool = try popBooValue(valueStack: valueStack)
		if valueStack.isEmpty() || !(valueStack.peek() is LoopPiNode)
		{
			throw LoopHandlerError.ExpectedLoopPiNode
		}

		let node: LoopPiNode = valueStack.pop() as! LoopPiNode
		if (condition)
		{
			controlStack.push(value: node)
			controlStack.push(value: node.command)
		}
	}
}
