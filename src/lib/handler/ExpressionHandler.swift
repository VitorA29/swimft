public class ExpressionHandler
{
	public func processNode(node: BinaryOperatorNode, control: Pile<AST_Pi_Extended>) throws
	{
		return
	}
	public func processOpCode(code: String, value: Pile<Automaton_Value>) throws
	{
		return
	}
	
	/// #START_DOC
	/// - Helper function for getting a <number> value from the value pile.
	/// #END_DOC
	internal func popNumValue(value: Pile<Automaton_Value>) throws -> Float
	{
		if !(value.peek() is AtomNode)
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
	internal func popBooValue(value: Pile<Automaton_Value>) throws -> Bool
	{
		if !(value.peek() is AtomNode)
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
}
