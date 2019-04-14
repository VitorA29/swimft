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
	piFramework.pi_automaton(ast_pi: create_test_tree_simple_calculator())
}

piTest()
