/// - This defines the pi node for the pi print operation.
public struct PrintPiNode: CommandPiNode
{
    let expression: ExpressionPiNode
	public var description: String
	{
		return "Print(\(expression))"
	}
}

/// - This defines the pi automaton operation code for the print operation.
public struct PrintOperationCode: OperationCode
{
	public let code: String = "PRINT"
}

/// Addition of the handlers for the print operation.
public extension PiFrameworkHandler
{
	/// - Handler for the analysis of a node contening a print operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Print(E) :: C, V, E, S, L) = δ(E :: #PRINT :: C, V, E, S, L)
	func processPrintPiNode (node: PrintPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>)
	{
		controlStack.push(value: PrintOperationCode())
		controlStack.push(value: node.expression)
	}
	
	/// - Handler for perform the relative print operation.
	/// 	Here the below delta match will occur.
	/// 	δ(#PRINT :: C, T :: V, E, S, L) = δ(C, V, E, S, L)
	func processPrintOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let bindable: AutomatonBindable = try popBindableValue(valueStack: valueStack)
		print("\(bindable)")
	}
}
