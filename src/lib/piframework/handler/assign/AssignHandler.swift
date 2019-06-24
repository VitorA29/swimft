import Foundation

public enum AssignHandlerError: Error
{
	case UndefinedVariable
	case UnexpectedImmutableVariable
}

/// #START_DOC
/// - This defines the pi node for the assign pi node.
/// #END_DOC
public struct AssignPiNode: CommandPiNode
{
	let identifier: IdentifierPiNode
	let expression: ExpressionPiNode
	public var description: String
	{
		return "Assign(\(identifier), \(expression))"
	}
}

public struct AssignOperationCode: OperationCode
{
	public let code: String = "ASSIGN"
}


public extension PiFrameworkHandler
{
	func processAssignPiNode (node: AssignPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>)
	{
		controlStack.push(value: AssignOperationCode())
		valueStack.push(value: node.identifier)
		controlStack.push(value: node.expression)
	}

	func processAssignOperationCode (valueStack: Stack<AutomatonValue>, storage: inout [Int: AutomatonStorable], environment: [String: AutomatonBindable]) throws
	{
		let storable: AutomatonStorable = try popStorableValue(valueStack: valueStack)
		let identifier: String = try popIdValue(valueStack: valueStack)
		if environment[identifier] == nil
		{
			throw AssignHandlerError.UndefinedVariable
		}

		let bindable: AutomatonBindable = environment[identifier]!
		if !(bindable is Location)
		{
			throw AssignHandlerError.UnexpectedImmutableVariable
		}
		let localizable: Location = bindable as! Location
		storage[localizable.address] = storable
	}
}
