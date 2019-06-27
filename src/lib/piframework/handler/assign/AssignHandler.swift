import Foundation

/// #START_DOC
/// - Define the enumeration for the error that can be throw during assign node handling.
/// #END_DOC
public enum AssignHandlerError: Error
{
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

/// #START_DOC
/// - This defines the pi automaton operation code for the assign operation.
/// #END_DOC
public struct AssignOperationCode: OperationCode
{
	public let code: String = "ASSIGN"
}


public extension PiFrameworkHandler
{
	/// #START_DOC
	/// - Handler for the analysis of a node contening a assign operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Assign(W, X) :: C, V, E, S) = δ(X :: #ASSIGN :: C, W :: V, E, S)
	/// #END_DOC
	func processAssignPiNode (node: AssignPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>)
	{
		controlStack.push(value: AssignOperationCode())
		valueStack.push(value: node.identifier)
		controlStack.push(value: node.expression)
	}

	/// #START_DOC
	/// - Handler for perform the relative arithmetic operation with the desired values.
	/// 	Here the below delta match will occur.
	/// 	δ(#ASSIGN :: C, T :: W :: V, E, S) = δ(C, V, E, S'), where E[W] = l and S' = S||[l ↦ T]
	/// #END_DOC
	func processAssignOperationCode (valueStack: Stack<AutomatonValue>, storage: inout [Int: AutomatonStorable], environment: [String: AutomatonBindable]) throws
	{
		let storable: AutomatonStorable = try popStorableValue(valueStack: valueStack)
		let identifier: String = try popIdValue(valueStack: valueStack)

		let bindable: AutomatonBindable = try getBindableValueFromEnvironment(key: identifier, environment: environment)
		if !(bindable is Location)
		{
			throw AssignHandlerError.UnexpectedImmutableVariable
		}
		let localizable: Location = bindable as! Location
		storage[localizable.address] = storable
	}
}
