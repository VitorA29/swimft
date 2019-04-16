import Foundation

public enum TranformerError: Error
{
	case UndefinedOperator(String)
	case UndefinedASTNode
}

public enum AutomatonError: Error
{
	case UndefinedOperation(String)
	case UndefinedCommand(String)
	case UnexpectedNilValue
	case InvalidValueExpected
}

public class PiFramework
{
	public func transformer (ast_imp: AST_Node) throws -> Tree3<String>
	{
		var ast_pi: Tree3<String>
		if ast_imp is BinaryOpNode
		{
			let node: BinaryOpNode = ast_imp as! BinaryOpNode
			switch (node.op)
			{
				case "*":
					ast_pi = Tree3<String>(value: "MUL")
					break
				case "/":
					ast_pi = Tree3<String>(value: "DIV")
					break
				case "+":
					ast_pi = Tree3<String>(value: "SUM")
					break
				case "-":
					ast_pi = Tree3<String>(value: "SUB")
					break
				default:
					throw TranformerError.UndefinedOperator(node.op)
			}
			ast_pi.insert(tree: try transformer(ast_imp: node.lhs))
			ast_pi.insert(tree: try transformer(ast_imp: node.rhs))
		}
		else if ast_imp is NumberNode
		{
			let node: NumberNode = ast_imp as! NumberNode
			ast_pi = Tree3<String>(value: "NUM")
			ast_pi.insert(tree: Tree3<String>(value: "\(node.value)"))
		}
		else
		{
			throw TranformerError.UndefinedASTNode
		}
		return ast_pi
	}
	
	public func pi_automaton (ast_pi: Tree3<String>) throws
	{
		let control_pile: Pile<Tree3<String>> = Pile<Tree3<String>>()
		control_pile.push(value: ast_pi)
		let value_pile: Pile<Tree3<String>> = Pile<Tree3<String>>()
		let storage_pile: Pile<String> = Pile<String>()
		let enviroment_pile: Pile<String> = Pile<String>()
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
		}while(control_pile.isEmpty() == false)
		let value_tree: Tree3<String> = value_pile.pop()
		print("\(value_tree)")
	}

	private func delta (control: Pile<Tree3<String>>, value: Pile<Tree3<String>>, storage: Pile<String>, enviroment: Pile<String>) throws
	{
		let command_tree: Tree3<String> = control.pop()
		if (command_tree.key.hasPrefix("#"))
		{
			var operation: Float
			let number_tree1: Float = Float(value.pop().middle!.key)!
			let number_tree2: Float = Float(value.pop().middle!.key)!
			switch (command_tree.key)
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
					throw AutomatonError.UndefinedCommand(command_tree.key)
			}
			let node: Tree3<String> = Tree3<String>(value: "NUM")
			node.insert(tree: Tree3<String>(value: "\(operation)"))
			value.push(value: node)
		}
		else
		{
			var operation = true
			switch (command_tree.key)
			{
				case "MUL":
					control.push(value: Tree3<String>(value: "#MUL"))
					break
				case "DIV":
					control.push(value: Tree3<String>(value: "#DIV"))
					break
				case "SUM":
					control.push(value: Tree3<String>(value: "#SUM"))
					break
				case "SUB":
					control.push(value: Tree3<String>(value: "#SUB"))
					break
				case "NUM":
					value.push(value: command_tree)
					operation = false
					break
				default:
					throw AutomatonError.UndefinedOperation(command_tree.key)
			}
			if (operation == true)
			{
				control.push(value: command_tree.left)
				control.push(value: command_tree.right)
			}
		}
	}
}