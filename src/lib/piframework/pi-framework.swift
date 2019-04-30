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
	case UndefinedASTNode(AST_Pi)
	case UnexpectedNilValue
	case InvalidValueExpected
}

public class PiFramework
{
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
		let storage_pile: [String: Int] = [String: Int]()
		let enviroment_pile: [String: Int] = [String: Int]()
		repeat
		{
			do
			{
				try self.delta(control: control_pile, value: value_pile, storage: storage_pile, enviroment: enviroment_pile)
			}
			catch
			{
				throw error
			}
			// print("c: \(control_pile), v: \(value_pile), s: \(storage_pile)")
		}while(!control_pile.isEmpty())
		print("v: \(value_pile), s: \(storage_pile)")
	}

	private func delta (control: Pile<AST_Pi>, value: Pile<AST_Pi>, storage: [String: Int], enviroment: [String: Int]) throws
	{
		let command_tree: AST_Pi = control.pop()
		if command_tree is PiFuncNode
		{
			let functNode: PiFuncNode = command_tree as! PiFuncNode
			var operation: Float
			var nodeHelper: AtomNode = value.pop() as! AtomNode
			let number_tree1: Float = Float(nodeHelper.value)!
			
			nodeHelper = value.pop() as! AtomNode
			let number_tree2: Float = Float(nodeHelper.value)!
			switch (functNode.function)
			{
				case "#MUL":
					operation = number_tree1*number_tree2
					break
				case "#DIV":
					operation = number_tree1/number_tree2
					break
				case "#SUM":
					operation = number_tree1+number_tree2
					break
				case "#SUB":
					operation = number_tree1-number_tree2
					break
				default:
					throw AutomatonError.UndefinedCommand(functNode.function)
			}
			let node: AST_Pi = AtomNode(function: "NUM", value: "\(operation)")
			value.push(value: node)
		}
		else if command_tree is BinaryOperatorNode
		{
			let operatorNode: BinaryOperatorNode = command_tree as! BinaryOperatorNode
			switch (operatorNode.operation)
			{
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
				case "ASSIGN":
					control.push(value: PiFuncNode(function: "#ASG"))
					break
				case "LOOP":
					control.push(value: PiFuncNode(function: "#LOOP"))
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
				default:
					control.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
			}
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
		else
		{
			throw AutomatonError.UndefinedASTNode(command_tree)
		}
	}
}
