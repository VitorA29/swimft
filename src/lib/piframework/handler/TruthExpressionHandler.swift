/// #START_DOC
/// - Handler for all operations relative to <bool_expression> ramifications.
/// #END_DOC
public class TruthExpressionHandler: PiFrameworkHandler
{
	/// #START_DOC
	/// - Handler for the analysis of a node contening a logic operation.
	/// 	Here the below delta matchs will occur,  meaning that `operation` will be one of 'Lt', 'Le', 'Gt', 'Ge', 'Eq', 'And' and 'Or' and `operationOpCode` will be it relative operation code form of the `operation`.
	/// 	δ(`operation`(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #`operationOpCode` :: C, V, S)
	/// #END_DOC
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
	
	/// #START_DOC
	/// - Handler for the analysis of a node contening a logic operation.
	/// 	Here the below delta matchs will occur, processing the <negation> operation.
	/// 	δ(Not(E) :: C, V, S) = δ(E :: #NOT :: C, V, S)
	/// #END_DOC
	public func processNode(node: UnaryOperatorNode, control: Pile<AST_Pi_Extended>) throws
	{
		switch (node.operation)
		{
			case "Not":
				control.push(value: PiOpCodeNode(function: "#NOT"))
				break
			default:
					throw AutomatonError.UndefinedTruthOperation(node.operation)
		}
		control.push(value: node.expression)
	}
	
	/// #START_DOC
	/// - Helper function for handling with inequality operations, here the below math will occur and the following pi operations codes will be processed '#LT', '#LE', '#GT' and '#GE'.
	/// 	δ(`operationOpCode` :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ `inequality_operator` N₂ :: V, S)
	/// #END_DOC
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
	
	/// #START_DOC
	/// - Helper function for handling with combination logic operations, here the below math will occur and the following pi operations codes will be processed '#AND' and '#OR'.
	/// 	δ(`operationOpCode` :: C, Boo(B₁) :: Boo(B₂) :: V, S) = δ(C, B₁ `logical_operator` B₂ :: V, S)
	/// #END_DOC
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
	
	/// #START_DOC
	/// - Handler for perform the relative logial operation with the desired values.
	/// 	Here the below delta match will occur,  meaning that `operationOpCode` will be one of '#LT', '#LE', '#GT' and '#GE' and `inequality_operator` will be it relative inequality operator.
	/// 	δ(`operationOpCode` :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ `inequality_operator` N₂ :: V, S)
	/// 	Here the below delta match will occur,  meaning that `operationOpCode` will be one of '#AND' and '#OR' and `logical_operator` will be it relative logical operator.
	/// 	δ(`operationOpCode` :: C, Boo(B₁) :: Boo(B₂) :: V, S) = δ(C, B₁ `logical_operator` B₂ :: V, S)
	/// 	Here the below delta match will occur, meaning that '#NOT' will be processed here.
	/// 	δ(#NOT :: C, Boo(True) :: V, S) = δ(C, False :: V, S), δ(#NOT :: C, Boo(False) :: V, S) = δ(C, True :: V, S)
	/// #END_DOC
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
