import Foundation

public enum ConditionalHandlerError: Error
{
	case ExpectedConditionalPiNode
}

/// #START_DOC
/// - This defines the pi conditional node.
/// #END_DOC
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

public struct ConditionalOperationCode: OperationCode
{
	public let code: String = "COND"
}

public extension PiFrameworkHandler
{
	func processConditionalPiNode (node: ConditionalPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>)
	{
		controlStack.push(value: ConditionalOperationCode())
		controlStack.push(value: node.condition)
		valueStack.push(value: node)
	}
	
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
