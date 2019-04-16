public func simpleTest ()
{
	let source = """
		def foo (x, y)
			x + y * 2 + (4 + 5) / 3
		
		foo(3, 4)
		"""
		
	let simple_source = "2 - (4 + 5) / 3"
	
	let lexer = Lexer(input: simple_source)
	let tokens = lexer.tokenize()
	print(tokens)
	let parser = Parser(tokens: tokens)
	do
	{
		let ast_imp: AST_Node = try parser.parseExpression()
		print("\(ast_imp)")
		
		let piFramework: PiFramework = PiFramework()
		
		let ast_pi = try piFramework.transformer(ast_imp: ast_imp)
		
		print("\(ast_pi)")
		
		try piFramework.pi_automaton(ast_pi: ast_pi)
	}
	catch
	{
		print(error)
	}
}

simpleTest()
