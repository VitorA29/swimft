import Foundation

public enum TranformerError: Error
{
	case UndefinedOperator(String)
	case UndefinedASTNode(AST_Node)
}

public enum AutomatonError: Error
{
	case UndefinedOperation(String)
	case UndefinedCommand(String)
	case UndefinedASTPi(AST_Pi)
	case UnexpectedNilValue
	case InvalidValueExpected
	case ExpectedIdentifier
}

private struct Localizable: CustomStringConvertible
{
	let address: Int
	
	public var description: String
	{
		return "Localizable(address: \(address))"
	}
}

public class PiFramework
{
	var memorySpace: Int
	
	init ()
	{
		self.memorySpace = 0
	}
	
	private func combineExpressionNodes (ast_pi_forest: [ExpressionNode]) -> ExpressionNode
	{
		let head: ExpressionNode = ast_pi_forest[0]
		var tail: [ExpressionNode] = ast_pi_forest
		tail.remove(at: 0)
		if tail.isEmpty
		{
			return head
		}
		let rhs: ExpressionNode = combineExpressionNodes(ast_pi_forest: tail)
		return BinaryOperatorNode(operation: "CmdSeq", lhs: head, rhs: rhs)
	}

	public func transformer (ast_imp: AST_Node) throws -> AST_Pi
	{
		var ast_pi: AST_Pi
		if ast_imp is BinaryOpNode
		{
			let node: BinaryOpNode = ast_imp as! BinaryOpNode
			var operation: String
			switch (node.op)
			{
				// Aritimetic Operators
				case "*":
					operation = "MUL"
					break
				case "/":
					operation = "DIV"
					break
				case "+":
					operation = "SUM"
					break
				case "-":
					operation = "SUB"
					break
				// Logical Operators
				case "<":
					operation = "LOW"
					break
				case "<=":
					operation = "LEQ"
					break
				case ">":
					operation = "GTR"
					break
				case ">=":
					operation = "GEQ"
					break
				case "==":
					operation = "EQL"
					break
				case "and":
					operation = "AND"
					break
				case "or":
					operation = "OR"
					break
				default:
					throw TranformerError.UndefinedOperator(node.op)
			}
			let lhs: ExpressionNode = try transformer(ast_imp: node.lhs) as! ExpressionNode
			let rhs: ExpressionNode = try transformer(ast_imp: node.rhs) as! ExpressionNode
			ast_pi = BinaryOperatorNode(operation: operation, lhs: lhs, rhs: rhs)
		}
		else if ast_imp is AssignNode
		{
			let node: AssignNode = ast_imp as! AssignNode
			let lhs: ExpressionNode = try transformer(ast_imp: node.variable) as! ExpressionNode
			let rhs: ExpressionNode = try transformer(ast_imp: node.expression) as! ExpressionNode
			ast_pi = BinaryOperatorNode(operation: "ASSIGN", lhs: lhs, rhs: rhs)
		}
		else if ast_imp is WhileNode
		{
			let node: WhileNode = ast_imp as! WhileNode
			let lhs: ExpressionNode = try transformer(ast_imp: node.condition) as! ExpressionNode
			let cmds: Pile<AST_Node> = Pile<AST_Node>(list: node.command)
			var ast_pi_forest: [ExpressionNode] = [ExpressionNode]()
			repeat
			{
				ast_pi_forest.append(try transformer(ast_imp: cmds.pop()) as! ExpressionNode)
			}while (!cmds.isEmpty())
			let rhs: ExpressionNode = combineExpressionNodes(ast_pi_forest: ast_pi_forest)
			ast_pi = BinaryOperatorNode(operation: "LOOP", lhs: lhs, rhs: rhs)
		}
		else if ast_imp is ConditionalNode
		{
			let node: ConditionalNode = ast_imp as! ConditionalNode
			let lhs: ExpressionNode = try transformer(ast_imp: node.condition) as! ExpressionNode
			
			let cmdsTrue: Pile<AST_Node> = Pile<AST_Node>(list: node.commandTrue)
			var ast_pi_forest: [ExpressionNode] = [ExpressionNode]()
			repeat
			{
				ast_pi_forest.append(try transformer(ast_imp: cmdsTrue.pop()) as! ExpressionNode)
			}while (!cmdsTrue.isEmpty())
			let chs: ExpressionNode = combineExpressionNodes(ast_pi_forest: ast_pi_forest)
			
			let cmdsFalse: Pile<AST_Node> = Pile<AST_Node>(list: node.commandFalse)
			ast_pi_forest = [ExpressionNode]()
			while (!cmdsFalse.isEmpty())
			{
				ast_pi_forest.append(try transformer(ast_imp: cmdsFalse.pop()) as! ExpressionNode)
			}
			var rhs: ExpressionNode? = nil
			if (!ast_pi_forest.isEmpty)
			{
				rhs = combineExpressionNodes(ast_pi_forest: ast_pi_forest)
			}
			ast_pi = TernaryOperatorNode(operation: "COND", lhs: lhs, chs: chs, rhs: rhs)
		}
		else if ast_imp is NegationNode
		{
			let node: NegationNode = ast_imp as! NegationNode
			let expression: ExpressionNode = try transformer(ast_imp: node.expression) as! ExpressionNode
			ast_pi = UnaryOperatorNode(operation: "NEG", expression: expression)
		}
		else if ast_imp is NumberNode
		{
			let node: NumberNode = ast_imp as! NumberNode
			ast_pi = AtomNode(function: "NUM", value: "\(node.value)")
		}
		else if ast_imp is VariableNode
		{
			let node: VariableNode = ast_imp as! VariableNode
			ast_pi = AtomNode(function: "ID", value: "\(node.name)")
		}
		else if ast_imp is BooleanNode
		{
			let node: BooleanNode = ast_imp as! BooleanNode
			ast_pi = AtomNode(function: "BOOL", value: "\(node.value)")
		}
		else if ast_imp is NoOpNode
		{
			ast_pi = SkipOperatorNode()
		}
		else
		{
			throw TranformerError.UndefinedASTNode(ast_imp)
		}
		return ast_pi
	}
	
	public func pi_automaton (ast_pi_forest: [AST_Pi]) throws
	{
		let control_pile: Pile<AST_Pi> = Pile<AST_Pi>(list: ast_pi_forest)
		let value_pile: Pile<AST_Pi> = Pile<AST_Pi>()
		var storage_pile: [Int: AtomNode] = [Int: AtomNode]()
		var enviroment_pile: [String: Localizable] = [String: Localizable]()
		repeat
		{
			do
			{
				try self.delta(control: control_pile, value: value_pile, storage: &storage_pile, enviroment: &enviroment_pile)
			}
			catch
			{
				throw error
			}
			// print("{ c: \(control_pile), v: \(value_pile), s: \(storage_pile), e: \(enviroment_pile) }")
		}while(!control_pile.isEmpty())
		print("{ v: \(value_pile), s: \(storage_pile), e: \(enviroment_pile) }")
	}

	private func delta (control: Pile<AST_Pi>, value: Pile<AST_Pi>, storage: inout [Int: AtomNode], enviroment: inout [String: Localizable]) throws
	{
		let command_tree: AST_Pi = control.pop()
		if command_tree is PiFuncNode
		{
			let functNode: PiFuncNode = command_tree as! PiFuncNode
			var operationResultFunction: String
			var operationResult: String
			switch(functNode.function)
			{
				// Aritimetical Operators
				case "#MUL":
					operationResultFunction = "NUM"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: Float = Float(nodeHelper.value)!
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: Float = Float(nodeHelper.value)!
					operationResult = "\(value1*value2)"
					break
				case "#DIV":
					operationResultFunction = "NUM"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: Float = Float(nodeHelper.value)!
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: Float = Float(nodeHelper.value)!
					operationResult = "\(value1/value2)"
					break
				case "#SUM":
					operationResultFunction = "NUM"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: Float = Float(nodeHelper.value)!
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: Float = Float(nodeHelper.value)!
					operationResult = "\(value1+value2)"
					break
				case "#SUB":
					operationResultFunction = "NUM"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: Float = Float(nodeHelper.value)!
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: Float = Float(nodeHelper.value)!
					operationResult = "\(value1-value2)"
					break
				// Logical Operators
				case "#LOW":
					operationResultFunction = "BOOL"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: Float = Float(nodeHelper.value)!
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: Float = Float(nodeHelper.value)!
					operationResult = "\(value1<value2)"
					break
				case "#LEQ":
					operationResultFunction = "BOOL"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: Float = Float(nodeHelper.value)!
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: Float = Float(nodeHelper.value)!
					operationResult = "\(value1<=value2)"
					break
				case "#GTR":
					operationResultFunction = "BOOL"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: Float = Float(nodeHelper.value)!
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: Float = Float(nodeHelper.value)!
					operationResult = "\(value1>value2)"
					break
				case "#GEQ":
					operationResultFunction = "BOOL"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: Float = Float(nodeHelper.value)!
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: Float = Float(nodeHelper.value)!
					operationResult = "\(value1>=value2)"
					break
				case "#EQL":
					operationResultFunction = "BOOL"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: String = nodeHelper.value
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: String = nodeHelper.value
					operationResult = "\(value1==value2)"
					break
				case "#AND":
					operationResultFunction = "BOOL"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: Bool = Bool(nodeHelper.value)!
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: Bool = Bool(nodeHelper.value)!
					operationResult = "\(value1&&value2)"
					break
				case "#OR":
					operationResultFunction = "BOOL"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value1: Bool = Bool(nodeHelper.value)!
					
					nodeHelper = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let value2: Bool = Bool(nodeHelper.value)!
					operationResult = "\(value1||value2)"
					break
				case "#NEG":
					operationResultFunction = "BOOL"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let booleanHelper: Bool = Bool(nodeHelper.value)!
					operationResult = "\(!booleanHelper)"
					break
				// Other functions
				case "#ASG":
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function != "ID")
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
					nodeHelper = value.pop() as! AtomNode
					storage[localizable.address] = nodeHelper
					return
				case "#LOOP":
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let conditionValue: Bool = Bool(nodeHelper.value)!
					let cmds: ExpressionNode = value.pop() as! ExpressionNode
					let loop_node: AST_Pi = value.pop()
					
					if (conditionValue)
					{
						control.push(value: loop_node)
						control.push(value: cmds)
					}
					return
				case "#COND":
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.function == "ID")
					{
						let localizable: Localizable = enviroment[nodeHelper.value]!
						nodeHelper = storage[localizable.address]!
					}
					let conditionValue: Bool = Bool(nodeHelper.value)!
					let cmds: ExpressionNode
					if (conditionValue)
					{
						cmds = value.pop() as! ExpressionNode
						value.skip()
						control.push(value: cmds)
					}
					else
					{
						value.skip()
						cmds = value.pop() as! ExpressionNode
						control.push(value: cmds)
					}
					return
				case "#NOP":
					return
				default:
					throw AutomatonError.UndefinedCommand(functNode.function)
			}
			let node: AST_Pi = AtomNode(function: operationResultFunction, value: operationResult)
			value.push(value: node)
		}
		else if command_tree is TernaryOperatorNode
		{
			let operatorNode: TernaryOperatorNode = command_tree as! TernaryOperatorNode
			switch (operatorNode.operation)
			{
				case "COND":
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
				case "MUL":
					control.push(value: PiFuncNode(function: "#MUL"))
					break
				case "DIV":
					control.push(value: PiFuncNode(function: "#DIV"))
					break
				case "SUM":
					control.push(value: PiFuncNode(function: "#SUM"))
					break
				case "SUB":
					control.push(value: PiFuncNode(function: "#SUB"))
					break
				// Logical Operators
				case "LOW":
					control.push(value: PiFuncNode(function: "#LOW"))
					break
				case "LEQ":
					control.push(value: PiFuncNode(function: "#LEQ"))
					break
				case "GTR":
					control.push(value: PiFuncNode(function: "#GTR"))
					break
				case "GEQ":
					control.push(value: PiFuncNode(function: "#GEQ"))
					break
				case "EQL":
					control.push(value: PiFuncNode(function: "#EQL"))
					break
				case "AND":
					control.push(value: PiFuncNode(function: "#AND"))
					break
				case "OR":
					control.push(value: PiFuncNode(function: "#OR"))
					break
				// Other functions
				case "ASSIGN":
					control.push(value: PiFuncNode(function: "#ASG"))
					break
				case "LOOP":
					control.push(value: PiFuncNode(function: "#LOOP"))
					break
				case "CmdSeq":
					break
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
			switch (operatorNode.operation)
			{
				case "LOOP":
					control.push(value: operatorNode.lhs)
					value.push(value: command_tree)
					value.push(value: operatorNode.rhs)
					break
				case "CmdSeq":
					control.push(value: operatorNode.rhs)
					control.push(value: operatorNode.lhs)
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
				case "NEG":
					control.push(value: PiFuncNode(function: "#NEG"))
					break
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
			control.push(value: operatorNode.expression)
		}
		else if command_tree is AtomNode
		{
			let operatorNode: AtomNode = command_tree as! AtomNode
			switch (operatorNode.function)
			{
				case "NUM":
					break
				case "BOOL":
					break
				case "ID":
					break
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.function)
			}
			value.push(value: command_tree)
		}
		else if command_tree is SkipOperatorNode
		{
			control.push(value: PiFuncNode(function: "#NOP"))
		}
		else
		{
			throw AutomatonError.UndefinedASTPi(command_tree)
		}
	}
}
