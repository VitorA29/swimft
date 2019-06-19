/// #START_DOC
/// - Handler for all operations relative to <arith_expression> ramifications.
/// #END_DOC
public class ArithExpressionHandler: PiFrameworkHandler
{
	/// #START_DOC
	/// - Handler for the analysis of a node contening a arithmetic operation.
	/// 	Here the below delta match will occur,  meaning that `operation` will be one of 'Sum', 'Mul', 'Div' and 'Sub' and `operationOpCode` will be it relative operation code form of the `operation`.
	/// 	δ(`operation`(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: `operationOpCode` :: C, V, S)
	/// #END_DOC
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
	
	/// #START_DOC
	/// - Handler for perform the relative arithmetic operation with the desired values.
	/// 	Here the below delta match will occur,  meaning that `operationOpCode` will be one of '#SUM', '#MUL', '#DIV' and '#SUB' and `aritimetic_operator` will be it relative arithmetic operator.
	/// 	δ(`operationOpCode` :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ `aritimetic_operator` N₂ :: V, S)
	/// #END_DOC
	public func processOpCode(code: String, value: Pile<Automaton_Value>) throws
	{
		let value1: Float = try popNumValue(value: value)
		let value2: Float = try popNumValue(value: value)
		switch(code)
		{
			case "#MUL":
				value.push(value: value1 * value2)
				break
			case "#DIV":
				value.push(value: value1 / value2)
				break
			case "#SUM":
				value.push(value: value1 + value2)
				break
			case "#SUB":
				value.push(value: value1 - value2)
				break
			default:
					throw AutomatonError.UndefinedArithOpCode(code)
		}
	}
}
