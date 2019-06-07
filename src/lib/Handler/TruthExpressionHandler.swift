public class TruthExpressionHandler: ExpressionHandler
{
	override public func processNode(node: BinaryOperatorNode, control: Pile<AST_Pi_Extended>) throws
	{
		switch (node.operation)
		{
			case "Lt":
				control.push(value: PiOpCodeNode(function: "#LT"))
				break
			case "Le":
				control.push(value: PiOpCodeNode(function: "#LE"))
				break
			case "Gt":
				control.push(value: PiOpCodeNode(function: "#GT"))
				break
			case "Ge":
				control.push(value: PiOpCodeNode(function: "#GE"))
				break
			case "Eq":
				control.push(value: PiOpCodeNode(function: "#EQ"))
				break
			case "And":
				control.push(value: PiOpCodeNode(function: "#AND"))
				break
			case "Or":
				control.push(value: PiOpCodeNode(function: "#OR"))
				break
			default:
					throw AutomatonError.UndefinedTruthOperation(node.operation)
		}
		control.push(value: node.lhs)
		control.push(value: node.rhs)
	}
	
	override public func processOpCode(code: String, value: Pile<Automaton_Value>) throws
	{
		let value1: Float = try popNumValue(value: value)
		let value2: Float = try popNumValue(value: value)
		var result: AtomNode
		switch(code)
		{
			case "#LT":
				result = AtomNode(operation: "Boo", value: "\(value1<value2)")
				break
			case "#LE":
				result = AtomNode(operation: "Boo", value: "\(value1<=value2)")
				break
			case "#GT":
				result = AtomNode(operation: "Boo", value: "\(value1>value2)")
				break
			case "#GE":
				result = AtomNode(operation: "Boo", value: "\(value1>=value2)")
				break
			default:
					throw AutomatonError.UndefinedTruthOpCode(code)
		}
		value.push(value: result)
	}
}
