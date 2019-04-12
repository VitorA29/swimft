public func create_test_tree_simple_calculator () -> Tree3<String>
{
	let tree: Tree3<String> = Tree3<String>(value: "MUL")
	
	// create NUM(5) node
	var tree_helper: Tree3<String> = Tree3<String>(value: "NUM")
	tree_helper.insert(tree: Tree3<String>(value: "5"))
	tree.insert(tree: tree_helper)
	
	// creating SUM(NUM(3),NUM(2)) node
	let tree_sum: Tree3<String> = Tree3<String>(value: "SUM")
	tree_helper = Tree3<String>(value: "NUM")
	tree_helper.insert(tree: Tree3<String>(value: "3"))
	tree_sum.insert(tree: tree_helper)
	tree_helper = Tree3<String>(value: "NUM")
	tree_helper.insert(tree: Tree3<String>(value: "2"))
	tree_sum.insert(tree: tree_helper)
	tree.insert(tree: tree_sum)
	
	return tree
}

public func piTest ()
{
	let piFramework: PiFramework = PiFramework()
	let control_pile: Pile<Tree3<String>> = Pile<Tree3<String>>()
	control_pile.push(value: create_test_tree_simple_calculator())
	let value_pile: Pile<Tree3<String>> = Pile<Tree3<String>>()
	repeat
	{
		piFramework.delta(control: control_pile, value: value_pile, storage: Pile<String>(), enviroment: Pile<String>())
	}while(control_pile.isEmpty() == false)
	value_pile.pop()?.print_tree(terminator: "\n")
}

piTest()
