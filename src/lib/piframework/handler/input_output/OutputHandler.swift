public struct PrintPiNode: CommandPiNode
{
    let expression: ExpressionPiNode
	public var description: String
	{
		return "Print(\(expression))"
	}
}

public struct PrintOperationCode: OperationCode
{
	public let code: String = "PRINT"
}

public extension PiFrameworkHandler
{
	func processPrintPiNode (node: PrintPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>)
	{
		controlStack.push(value: PrintOperationCode())
		controlStack.push(value: node.expression)
	}
	
	func processPrintOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let bindable: AutomatonBindable = try popBindableValue(valueStack: valueStack)
		print("\(bindable)")
	}
}
