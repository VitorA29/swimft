public class ArithExpressionHandler: PiFrameworkHandler
{
	public func processNode(node: BinaryOperatorNode, control: Pile<AST_Pi_Extended>) throws
	{
		switch (node.operation)
		{
			case "Mul":
				control.push(value: PiOpCodeNode(function: "#MUL"))
				break
			case "Div":
				control.push(value: PiOpCodeNode(function: "#DIV"))
				break
			case "Sum":
				control.push(value: PiOpCodeNode(function: "#SUM"))
				break
			case "Sub":
				control.push(value: PiOpCodeNode(function: "#SUB"))
				break
			default:
					throw AutomatonError.UndefinedArithOperation(node.operation)
		}
		control.push(value: node.lhs)
		control.push(value: node.rhs)
	}
	
	public func processOpCode(code: String, value: Pile<Automaton_Value>) throws
	{
		let value1: Float = try popNumValue(value: value)
		let value2: Float = try popNumValue(value: value)
		var result: AtomNode
		switch(code)
		{
			case "#MUL":
				result = AtomNode(operation: "Num", value: "\(value1*value2)")
				break
			case "#DIV":
				result = AtomNode(operation: "Num", value: "\(value1/value2)")
				break
			case "#SUM":
				result = AtomNode(operation: "Num", value: "\(value1+value2)")
				break
			case "#SUB":
				result = AtomNode(operation: "Num", value: "\(value1-value2)")
				break
			default:
					throw AutomatonError.UndefinedArithOpCode(code)
		}
		value.push(value: result)
	}
}
