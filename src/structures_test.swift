public func test_tree ()
{
	let tree: Tree3<String> = Tree3<String>(value: "root")
	tree.insert(tree: Tree3<String>(value: "left"))
	tree.insert(tree: Tree3<String>(value: "middle"))
	tree.insert(tree: Tree3<String>(value: "right"))
	tree.print_tree(terminator:"\n")
}

public func test_pile ()
{
	let pile: Pile<String> = Pile<String>()
	pile.push(value: "first")
	pile.push(value: "second")
	pile.push(value: "third")
	pile.print_pile()
	print(pile.pop()!)
	print(pile.pop()!)
	pile.print_pile()
	print(pile.pop()!)
	print(pile.pop() == nil)
}
