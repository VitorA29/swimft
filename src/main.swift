private func fibonacciFunction() -> String
{
	return """
	# Compute the x'th fibonacci number.
	def fib (x)
		if x < 3 then
			1
		else
			fib(x-1)+fib(x-2)
			
	# This expression will compute the 40th number
	fib(40)
	"""
}

private func atan2Function() -> String
{
	return """
	extern sin(arg);
	extern cos(arg);
	extern atan2(arg1, arg2);
	
	atan2(sin(0.4), cos(42))
	"""
}

public func kaleidoscopeTest ()
{
	let lexer = Lexer(input: atan2Function())
	let tokens = lexer.tokenize()
	print(tokens)
	let parser = Parser(tokens: tokens)
	do
	{
		let ast_imp: [AST_Node] = try parser.parse()
		print("\(ast_imp) - length(\(ast_imp.count))")
		
		// let piFramework: PiFramework = PiFramework()
		
		// let ast_pi = try piFramework.transformer(ast_imp: ast_imp)
		
		// print("\(ast_pi)")
		
		// try piFramework.pi_automaton(ast_pi: ast_pi)
	}
	catch
	{
		print(error)
	}
}

public func calculatorTest ()
{
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

kaleidoscopeTest()
