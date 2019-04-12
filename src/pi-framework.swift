public class PiFramework
{
	func transformer (ast_imp: Tree3<String>?) -> Tree3<String>?
	{
		if (ast_imp == nil)
		{
			return nil
		}
		
		var ast_pi: Tree3<String>
		if (ast_imp?.middle?.key == "<op>")
		{
			switch (ast_imp?.middle?.middle?.key)
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
					print("Invalid case in line 28")
					return nil
			}
			ast_pi.insert(tree: transformer(ast_imp: ast_imp?.left))
			ast_pi.insert(tree: transformer(ast_imp: ast_imp?.right))
		}
		else
		{
			switch (ast_imp?.middle?.key)
			{
				case "<digit>":
					ast_pi = Tree3<String>(value: "NUM")
					break
				case "<bool>":
					ast_pi = Tree3<String>(value: "BOL")
					break
				default:
					print("Invalid case in line 45")
					return nil
			}
			ast_pi.insert(tree: transformer(ast_imp: ast_imp?.middle?.middle))
		}
		return ast_pi
	}

	func delta (control: Pile<Tree3<String>>, value: Pile<Tree3<String>>, storage: Pile<String>, enviroment: Pile<String>)
	{
		let command_tree: Tree3<String> = control.pop()!
		if (command_tree.key.hasPrefix("#"))
		{
			var operation: Int
			let number_tree1: Int = Int(value.pop()!.middle!.key)!
			let number_tree2: Int = Int(value.pop()!.middle!.key)!
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
					print("Invalid case in line 76")
					return
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
					print("Invalid case in line 102")
					return
			}
			if (operation == true)
			{
				control.push(value: command_tree.right)
				control.push(value: command_tree.left)
			}
		}
	}
}
