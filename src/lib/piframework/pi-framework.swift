import Foundation

/// #START_DOC
/// - Define the enumeration for the error that can be throw during translations.
/// #END_DOC
public enum TranslatorError: Error
{
	case UndefinedOperator(String)
	case UndefinedASTNode(AST_Imp)
}

/// #START_DOC
/// - Define the enumeration for the error that can be throw during automaton.
/// #END_DOC
public enum AutomatonError: Error
{
	case UndefinedOperation(String)
	case UndefinedCommand(String)
	case UndefinedASTPi(AST_Pi_Extended)
	case UnexpectedNilValue
	case InvalidValueExpected
	case ExpectedIdentifier
	case ExpectedNumValue
	case ExpectedBooValue
}

/// #START_DOC
/// - This define the localizable struct to be used in the memory storage linking.
/// #END_DOC
private struct Localizable: CustomStringConvertible
{
	let address: Int
	public var description: String
	{
		return "Localizable(address: \(address))"
	}
}

/// #START_DOC
/// - Define the concept for the Pi-Framework, where the magic will happen.
/// #END_DOC
public class PiFramework
{
	var memorySpace: Int
	
	/// #START_DOC
	/// - This class initializer.
	/// #END_DOC
	init ()
	{
		self.memorySpace = 0
	}

	/// #START_DOC
	/// - Helper function for combining a pi forest node into a single pi node using CSeq.
	/// #END_DOC
	private func combineAST_PiNodes (ast_pi_forest: [AST_Pi]) -> AST_Pi
	{
		let head: AST_Pi = ast_pi_forest[0]
		var tail: [AST_Pi] = ast_pi_forest
		tail.remove(at: 0)
		if tail.isEmpty
		{
			return head
		}
		let rhs: AST_Pi = combineAST_PiNodes(ast_pi_forest: tail)
		return BinaryOperatorNode(operation: "CSeq", lhs: head, rhs: rhs)
	}

	/// #START_DOC
	/// - Function for convert a AST_Imp forest into it's correlative AST_Pi.
	/// #END_DOC
	public func translate (ast_imp: [AST_Imp]) throws -> AST_Pi
	{
		var ast_pi_forest: [AST_Pi] = [AST_Pi]()
		for node in ast_imp
		{
			let ast_pi = try translateNode(ast_imp: node)
			ast_pi_forest.append(ast_pi)
		}
		return combineAST_PiNodes(ast_pi_forest: ast_pi_forest)
	}

	/// #START_DOC
	/// - Helper function for converting a AST_Imp into a AST_Pi.
	/// #END_DOC
	private func translateNode (ast_imp: AST_Imp) throws -> AST_Pi
	{
		var ast_pi: AST_Pi
		if ast_imp is ArithOpNode
		{
			let node: ArithOpNode = ast_imp as! ArithOpNode
			var operation: String
			switch (node.op)
			{
				case "*":
					operation = "Mul"
					break
				case "/":
					operation = "Div"
					break
				case "+":
					operation = "Sum"
					break
				case "-":
					operation = "Sub"
					break
				default:
					throw TranslatorError.UndefinedOperator(node.op)
			}
			let lhs: AST_Pi = try translateNode(ast_imp: node.lhs)
			let rhs: AST_Pi = try translateNode(ast_imp: node.rhs)
			ast_pi = BinaryOperatorNode(operation: operation, lhs: lhs, rhs: rhs)
		}
		else if ast_imp is BoolOpNode
		{
			let node: BoolOpNode = ast_imp as! BoolOpNode
			var operation: String
			switch (node.op)
			{
				case "<":
					operation = "Lt"
					break
				case "<=":
					operation = "Le"
					break
				case ">":
					operation = "Gt"
					break
				case ">=":
					operation = "Ge"
					break
				case "==":
					operation = "Eq"
					break
				case "and":
					operation = "And"
					break
				case "or":
					operation = "Or"
					break
				default:
					throw TranslatorError.UndefinedOperator(node.op)
			}
			let lhs: AST_Pi = try translateNode(ast_imp: node.lhs)
			let rhs: AST_Pi = try translateNode(ast_imp: node.rhs)
			ast_pi = BinaryOperatorNode(operation: operation, lhs: lhs, rhs: rhs)
		}
		else if ast_imp is AssignNode
		{
			let node: AssignNode = ast_imp as! AssignNode
			let lhs: AST_Pi = try translateNode(ast_imp: node.variable)
			let rhs: AST_Pi = try translateNode(ast_imp: node.expression)
			ast_pi = BinaryOperatorNode(operation: "Assign", lhs: lhs, rhs: rhs)
		}
		else if ast_imp is WhileNode
		{
			let node: WhileNode = ast_imp as! WhileNode
			let lhs: AST_Pi = try translateNode(ast_imp: node.condition)
			let rhs: AST_Pi = try translate(ast_imp: node.command)
			ast_pi = BinaryOperatorNode(operation: "Loop", lhs: lhs, rhs: rhs)
		}
		else if ast_imp is ConditionalNode
		{
			let node: ConditionalNode = ast_imp as! ConditionalNode
			let lhs: AST_Pi = try translateNode(ast_imp: node.condition)
			let chs: AST_Pi = try translate(ast_imp: node.commandTrue)
			var rhs: AST_Pi? = nil
			if (!node.commandFalse.isEmpty)
			{
				rhs = try translate(ast_imp: node.commandFalse)
			}
			ast_pi = TernaryOperatorNode(operation: "Cond", lhs: lhs, chs: chs, rhs: rhs)
		}
		else if ast_imp is NegationNode
		{
			let node: NegationNode = ast_imp as! NegationNode
			let expression: AST_Pi = try translateNode(ast_imp: node.expression)
			ast_pi = UnaryOperatorNode(operation: "Not", expression: expression)
		}
		else if ast_imp is NumberNode
		{
			let node: NumberNode = ast_imp as! NumberNode
			ast_pi = AtomNode(operation: "Num", value: "\(node.value)")
		}
		else if ast_imp is IdentifierNode
		{
			let node: IdentifierNode = ast_imp as! IdentifierNode
			ast_pi = AtomNode(operation: "Id", value: "\(node.name)")
		}
		else if ast_imp is TruthNode
		{
			let node: TruthNode = ast_imp as! TruthNode
			ast_pi = AtomNode(operation: "Boo", value: "\(node.value)")
		}
		else if ast_imp is NoOpNode
		{
			ast_pi = OnlyOperatorNode(operation: "Nop")
		}
		else
		{
			throw TranslatorError.UndefinedASTNode(ast_imp)
		}
		return ast_pi
	}

	/// #START_DOC
	/// - Function for define the concept of the Pi-Framework automaton, for executing a AST_Pi.
	/// #END_DOC
	public func pi_automaton (ast_pi: AST_Pi) throws
	{
		let control_pile: Pile<AST_Pi_Extended> = Pile<AST_Pi_Extended>()
		control_pile.push(value: ast_pi)
		let value_pile: Pile<AST_Pi_Extended> = Pile<AST_Pi_Extended>()
		var storage_pile: [Int: AtomNode] = [Int: AtomNode]()
		var enviroment_pile: [String: Localizable] = [String: Localizable]()
		repeat
		{
			let lastState: String = "{ c: \(control_pile), v: \(value_pile), s: \(storage_pile), e: \(enviroment_pile) }"
			do
			{
				try self.delta(control: control_pile, value: value_pile, storage: &storage_pile, enviroment: &enviroment_pile)
			}
			catch
			{
				print("\(lastState)")
				throw error
			}
			// print("{ c: \(control_pile), v: \(value_pile), s: \(storage_pile), e: \(enviroment_pile) }")
		}while(!control_pile.isEmpty())
		print("{ v: \(value_pile), s: \(storage_pile), e: \(enviroment_pile) }")
	}
	
	/// #START_DOC
	/// - Helper function for getting the <number> values from the value pile.
	/// #END_DOC
	private func popNumValues(value: Pile<AST_Pi_Extended>) throws -> [Float]
	{
		var nodeHelper: AtomNode = value.pop() as! AtomNode
		if nodeHelper.operation != "Num"
		{
			throw AutomatonError.ExpectedNumValue
		}
		let value1: Float = Float(nodeHelper.value)!
		
		nodeHelper = value.pop() as! AtomNode
		if nodeHelper.operation != "Num"
		{
			throw AutomatonError.ExpectedNumValue
		}
		let value2: Float = Float(nodeHelper.value)!
		
		return [value1, value2]
	}
	
	/// #START_DOC
	/// - Helper function for getting the <bool> values from the value pile.
	/// #END_DOC
	private func popBooValues(value: Pile<AST_Pi_Extended>) throws -> [Bool]
	{
		var nodeHelper: AtomNode = value.pop() as! AtomNode
		if nodeHelper.operation != "Boo"
		{
			throw AutomatonError.ExpectedBooValue
		}
		let value1: Bool = Bool(nodeHelper.value)!
		
		nodeHelper = value.pop() as! AtomNode
		if nodeHelper.operation != "Boo"
		{
			throw AutomatonError.ExpectedBooValue
		}
		let value2: Bool = Bool(nodeHelper.value)!
		
		return [value1, value2]
	}

	/// #START_DOC
	/// - Helper function for the automaton, this define the logic for change the state of the automaton based in the argument values.
	/// #END_DOC
	private func delta (control: Pile<AST_Pi_Extended>, value: Pile<AST_Pi_Extended>, storage: inout [Int: AtomNode], enviroment: inout [String: Localizable]) throws
	{
		let command_tree: AST_Pi_Extended = control.pop()
		if command_tree is PiFuncNode
		{
			let functNode: PiFuncNode = command_tree as! PiFuncNode
			var operationResultFunction: String
			var operationResult: String
			switch(functNode.function)
			{
				// Aritimetical Operators
				case "#MUL":
					operationResultFunction = "Num"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]*values[1])"
					break
				case "#DIV":
					operationResultFunction = "Num"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]/values[1])"
					break
				case "#SUM":
					operationResultFunction = "Num"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]+values[1])"
					break
				case "#SUB":
					operationResultFunction = "Num"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]-values[1])"
					break
				// Logical Operators
				case "#LT":
					operationResultFunction = "Boo"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]<values[1])"
					break
				case "#LE":
					operationResultFunction = "Boo"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]<=values[1])"
					break
				case "#GT":
					operationResultFunction = "Boo"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]>values[1])"
					break
				case "#GE":
					operationResultFunction = "Boo"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]>=values[1])"
					break
				case "#EQ":
					operationResultFunction = "Boo"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					let type1: String = nodeHelper.operation
					let value1: String = nodeHelper.value
					
					nodeHelper = value.pop() as! AtomNode
					let type2: String = nodeHelper.operation
					let value2: String = nodeHelper.value
					if type1 != type2
					{
						if type1 == "Num"
						{
							throw AutomatonError.ExpectedNumValue
						}
						else if type1 == "Boo"
						{
							throw AutomatonError.ExpectedBooValue
						}
					}
					operationResult = "\(value1==value2)"
					break
				case "#AND":
					operationResultFunction = "Boo"
					let values: [Bool] = try popBooValues(value: value)
					operationResult = "\(values[0]&&values[1])"
					break
				case "#OR":
					operationResultFunction = "Boo"
					let values: [Bool] = try popBooValues(value: value)
					operationResult = "\(values[0]||values[1])"
					break
				case "#NOT":
					operationResultFunction = "Boo"
					let nodeHelper: AtomNode = value.pop() as! AtomNode
					let booleanHelper: Bool = Bool(nodeHelper.value)!
					operationResult = "\(!booleanHelper)"
					break
				// Other functions
				case "#ASSIGN":
					let nodeAsgValue: AtomNode = value.pop() as! AtomNode
					let nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.operation != "Id")
					{
						throw AutomatonError.ExpectedIdentifier
					}
					let idName: String = nodeHelper.value
					let localizable: Localizable
					if enviroment[idName] != nil
					{
						localizable = enviroment[idName]!
					}
					else
					{
						localizable = Localizable(address: memorySpace)
						memorySpace += 1
						enviroment[idName] = localizable
					}
					storage[localizable.address] = nodeAsgValue
					return
				case "#LOOP":
					let nodeHelper: AtomNode = value.pop() as! AtomNode
					let conditionValue: Bool = Bool(nodeHelper.value)!
					let loop_node: BinaryOperatorNode = value.pop() as! BinaryOperatorNode
					
					if (conditionValue)
					{
						control.push(value: loop_node)
						control.push(value: loop_node.rhs)
					}
					return
				case "#COND":
					let nodeHelper: AtomNode = value.pop() as! AtomNode
					let conditionValue: Bool = Bool(nodeHelper.value)!
					let cmds: AST_Pi
					if (conditionValue)
					{
						cmds = value.pop() as! AST_Pi
						value.skip()
						control.push(value: cmds)
					}
					else
					{
						value.skip()
						cmds = value.pop() as! AST_Pi
						control.push(value: cmds)
					}
					return
				case "#NOP":
					return
				default:
					throw AutomatonError.UndefinedCommand(functNode.function)
			}
			let node: AST_Pi = AtomNode(operation: operationResultFunction, value: operationResult)
			value.push(value: node)
		}
		else if command_tree is TernaryOperatorNode
		{
			let operatorNode: TernaryOperatorNode = command_tree as! TernaryOperatorNode
			switch (operatorNode.operation)
			{
				case "Cond":
					control.push(value: PiFuncNode(function: "#COND"))
					break
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
			control.push(value: operatorNode.lhs)
			if (operatorNode.rhs != nil)
			{
				value.push(value: operatorNode.rhs!)
			}
			else
			{
				value.push(value: PiFuncNode(function: "#NOP"))
			}
			value.push(value: operatorNode.chs)
		}
		else if command_tree is BinaryOperatorNode
		{
			let operatorNode: BinaryOperatorNode = command_tree as! BinaryOperatorNode
			switch (operatorNode.operation)
			{
				// Aritimetical Operators
				case "Mul":
					control.push(value: PiFuncNode(function: "#MUL"))
					break
				case "Div":
					control.push(value: PiFuncNode(function: "#DIV"))
					break
				case "Sum":
					control.push(value: PiFuncNode(function: "#SUM"))
					break
				case "Sub":
					control.push(value: PiFuncNode(function: "#SUB"))
					break
				// Logical Operators
				case "Lt":
					control.push(value: PiFuncNode(function: "#LT"))
					break
				case "Le":
					control.push(value: PiFuncNode(function: "#LE"))
					break
				case "Gt":
					control.push(value: PiFuncNode(function: "#GT"))
					break
				case "Ge":
					control.push(value: PiFuncNode(function: "#GE"))
					break
				case "Eq":
					control.push(value: PiFuncNode(function: "#EQ"))
					break
				case "And":
					control.push(value: PiFuncNode(function: "#AND"))
					break
				case "Or":
					control.push(value: PiFuncNode(function: "#OR"))
					break
				// Other functions
				case "Assign":
					control.push(value: PiFuncNode(function: "#ASSIGN"))
					break
				case "Loop":
					control.push(value: PiFuncNode(function: "#LOOP"))
					break
				case "CSeq":
					break
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
			switch (operatorNode.operation)
			{
				case "Loop":
					control.push(value: operatorNode.lhs)
					value.push(value: command_tree)
					break
				case "CSeq":
					control.push(value: operatorNode.rhs)
					control.push(value: operatorNode.lhs)
					break
				case "Assign":
					value.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
					break
				default:
					control.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
			}
		}
		else if command_tree is UnaryOperatorNode
		{
			let operatorNode: UnaryOperatorNode = command_tree as! UnaryOperatorNode
			switch (operatorNode.operation)
			{
				case "Not":
					control.push(value: PiFuncNode(function: "#NOT"))
					break
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
			control.push(value: operatorNode.expression)
		}
		else if command_tree is AtomNode
		{
			let operatorNode: AtomNode = command_tree as! AtomNode
			switch (operatorNode.operation)
			{
				case "Num":
					break
				case "Boo":
					break
				case "Id":
					let localizable: Localizable = enviroment[operatorNode.value]!
					let nodeHelper: AtomNode = storage[localizable.address]!
					value.push(value: nodeHelper)
					return
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
			value.push(value: command_tree)
		}
		else if command_tree is OnlyOperatorNode
		{
			let operatorNode: OnlyOperatorNode = command_tree as! OnlyOperatorNode
			switch (operatorNode.operation)
			{
				case "Nop":
					control.push(value: PiFuncNode(function: "#NOP"))
					break
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
		}
		else
		{
			throw AutomatonError.UndefinedASTPi(command_tree)
		}
	}
}
