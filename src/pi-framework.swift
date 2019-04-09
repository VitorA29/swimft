import util

func transformer (Tree3<String>? ast_imp) -> Tree3<String>?
{
	if (ast_imp == nil)
	{
		return nil
	}
	
	var ast_pi: Tree<String>? = nil
	if (ast_imp.middle.key == "<op>")
	{
		switch (ast_imp.middle.middle.key)
		{
			case "*":
				result = Tree3<String>("MUL")
				break
			case "/":
				result = Tree3<String>("DIV")
				break
			case "+":
				result = Tree3<String>("SUM")
				break
			case "-":
				result = Tree3<String>("SUB")
				break
			default:
				exit(1)
		}
		result.insert(transformer(ast_imp.left))
		result.insert(transformer(ast_imp.right))
	}
	else
	{
		switch (ast_imp.middle.key)
		{
			case "<digit>":
				result = Tree3<String>("NUM")
				break
			case "<bool>":
				result = Tree3<String>("BOL")
				break
			default:
				exit(1)
		}
		result.insert(transformer(ast_imp.middle.middle.key))
	}
	return result
}

func delta (Pile<Tree3<String>> control, Pile<Tree3<String>> value, Pile<String> storage, Pile<String> enviroment)
{
	command_tree = control.pop()
	if (command_tree.key.beginWith("#")
	{
		var operation: Int
		var number_tree1 = value.pop().middle.key
		var number_tree2 = value.pop().middle.key
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
				exit(1)
		}
		value.push(Tree3<String>("NUM").insert(operation))
	}
	else
	{
		var operation = true
		switch (command_tree.key)
		{
			case "MUL":
				control.push(Tree3<String>("#MUL"))
				break
			case "DIV":
				control.push(Tree3<String>("#DIV"))
				break
			case "SUM":
				control.push(Tree3<String>("#SUM"))
				break
			case "SUB":
				control.push(Tree3<String>("#SUB"))
				break
			case "NUM":
				value.push(command_tree)
				operation = false
				break
			default:
				exit(1)
		}
		if (operation)
		{
			control.push(command_tree.right)
			control.push(command_tree.left)
		}
	}
}
