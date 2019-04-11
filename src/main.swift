public func main ()
{
	let tree: Tree3<String> = Tree3<String>(value: "root")
	tree.insert(tree: Tree3<String>(value: "left"))
	tree.insert(tree: Tree3<String>(value: "middle"))
	tree.insert(tree: Tree3<String>(value: "right"))
	tree.print_tree()
	print("\nend")
}

main()
