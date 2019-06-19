/// #START_DOC
/// - Protocol that defines the basic operation needed in all handlers.
/// #END_DOC
protocol PiFrameworkHandler
{
	/// #START_DOC
	/// - This is the function used in the handler for processing the operation node.
	/// #END_DOC
	func processNode(node: BinaryOperatorNode, control: Pile<AST_Pi_Extended>) throws

	/// #START_DOC
	/// - This is the function used in the handler for processing the pi framework op code.
	/// #END_DOC
	func processOpCode(code: String, value: Pile<Automaton_Value>) throws
}

/// #START_DOC
/// - Add the basic operations used in most handlers.
/// #END_DOC
extension PiFrameworkHandler
{
	/// #START_DOC
	/// - Helper function for getting a <number> value from the value pile.
	/// #END_DOC
	func popNumValue(value: Pile<Automaton_Value>) throws -> Float
	{
		if value.isEmpty() || !(value.peek() is AtomNode)
		{
			throw AutomatonError.ExpectedAtomNode
		}
		let nodeHelper: AtomNode = value.pop() as! AtomNode
		if nodeHelper.operation != "Num"
		{
			throw AutomatonError.ExpectedNumValue
		}
		return Float(nodeHelper.value)!
	}
	
	/// #START_DOC
	/// - Helper function for getting a <truth> value from the value pile.
	/// #END_DOC
	func popBooValue(value: Pile<Automaton_Value>) throws -> Bool
	{
		if value.isEmpty() || !(value.peek() is AtomNode)
		{
			throw AutomatonError.ExpectedAtomNode
		}
		let nodeHelper: AtomNode = value.pop() as! AtomNode
		if nodeHelper.operation != "Boo"
		{
			throw AutomatonError.ExpectedBooValue
		}
		return Bool(nodeHelper.value)!
	}

	/// #START_DOC
	/// - Helper function for getting a atomic node from the value pile.
	/// #END_DOC
	func popAtomNode(value: Pile<Automaton_Value>) throws -> AtomNode
	{
		if value.isEmpty() || !(value.peek() is AtomNode)
		{
			throw AutomatonError.ExpectedAtomNode
		}

		return value.pop() as! AtomNode
	}
}
