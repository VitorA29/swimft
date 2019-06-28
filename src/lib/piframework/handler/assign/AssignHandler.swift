import Foundation

/// - Define the enumeration for the error that can be throw during assign node handling.
public enum AssignHandlerError: Error
{
	case UnexpectedImmutableVariable
}

/// - This defines the pi node for the pi assign operation.
public struct AssignPiNode: CommandPiNode
{
	let identifier: IdentifierPiNode
	let expression: ExpressionPiNode
	public var description: String
	{
		return "Assign(\(identifier), \(expression))"
	}
}

/// - This defines the pi automaton operation code for the assign operation.
public struct AssignOperationCode: OperationCode
{
	public let code: String = "ASSIGN"
}

/// Addition of the handlers for the assign operation.
public extension PiFrameworkHandler
{
	/// - Handler for the analysis of a node contening a assign operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Assign(W, X) :: C, V, E, S, L) = δ(X :: #ASSIGN :: C, W :: V, E, S, L)
	func processAssignPiNode (node: AssignPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>)
	{
		controlStack.push(value: AssignOperationCode())
		valueStack.push(value: node.identifier)
		controlStack.push(value: node.expression)
	}

	/// - Handler for perform the relative assign operation.
	/// 	Here the below delta match will occur.
	/// 	δ(#ASSIGN :: C, T :: W :: V, E, S, L) = δ(C, V, E, S', L), where E[W] = l and S' = S||[l ↦ T]
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
