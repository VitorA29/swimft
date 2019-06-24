import Foundation

public enum LoopHandlerError: Error
{
	case ExpectedLoopPiNode
}

public struct LoopPiNode: CommandPiNode, AutomatonValue
{
	let condition: LogicalExpressionPiNode
	let command: CommandPiNode
	public var description: String
	{
		return "Loop(\(condition), \(command))"
	}
}

public struct LoopOperationCode: OperationCode
{
	public let code: String = "LOOP"
}

public extension PiFrameworkHandler
{
	func processLoopPiNode (node: LoopPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>)
	{
		controlStack.push(value: LoopOperationCode())
		controlStack.push(value: node.condition)
		valueStack.push(value: node)
	}
	
	func processLoopOperationCode (controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>) throws
	{
		let conditionValue: Bool = try popBooValue(valueStack: valueStack)
		if valueStack.isEmpty() || !(valueStack.peek() is LoopPiNode)
		{
			throw LoopHandlerError.ExpectedLoopPiNode
		}

		let node: LoopPiNode = valueStack.pop() as! LoopPiNode
		if (conditionValue)
		{
			controlStack.push(value: node)
			controlStack.push(value: node.command)
		}
	}
}
