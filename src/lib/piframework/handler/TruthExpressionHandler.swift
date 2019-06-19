public class TruthExpressionHandler: PiFrameworkHandler
{
	public func processNode(node: BinaryOperatorNode, control: Pile<AST_Pi_Extended>) throws
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
	
	private func processInequalityOperation(code: String, value: Pile<Automaton_Value>) throws
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
	
	private func processJoinOperation(code: String, value: Pile<Automaton_Value>) throws
	{
		let value1: Bool = try popBooValue(value: value)
		let value2: Bool = try popBooValue(value: value)
		var result: AtomNode
		switch(code)
		{
			case "#AND":
				result = AtomNode(operation: "Boo", value: "\(value1&&value2)")
				break
			case "#OR":
				result = AtomNode(operation: "Boo", value: "\(value1||value2)")
				break
			default:
					throw AutomatonError.UndefinedTruthOpCode(code)
		}
		value.push(value: result)
	}
	
	public func processOpCode(code: String, value: Pile<Automaton_Value>) throws
	{
		switch(code)
		{
			case "#LT", "#LE", "#GT", "#GE":
				try processInequalityOperation(code: code, value: value)
				break
			case "#AND", "#OR":
				try processJoinOperation(code: code, value: value)
				break
			case "#EQ":
				let nodeHelper: AtomNode = try popAtomNode(value: value)
				var result: AtomNode
				if nodeHelper.operation == "Num"
				{
					let value1: Float = Float(nodeHelper.value)!
					let value2: Float = try popNumValue(value: value)
					result = AtomNode(operation: "Boo", value: "\(value1==value2)")
				}
				else if nodeHelper.operation == "Boo"
				{
					let value1: Bool = Bool(nodeHelper.value)!
					let value2: Bool = try popBooValue(value: value)
					result = AtomNode(operation: "Boo", value: "\(value1==value2)")
				}
				else
				{
					throw AutomatonError.UnexpectedTypeValue
				}
				value.push(value: result)
				break
			case "#NOT":
				let booValue: Bool = try popBooValue(value: value)
				value.push(value: AtomNode(operation: "Boo", value: "\(!booValue)"))
				break
			default:
				throw AutomatonError.UndefinedTruthOpCode(code)
		}
	}
}
