import Foundation

public func impTest ()
{
	let lexer = Lexer(input: filePath()!)
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

public func filePath () -> String?
{
	let currDir = FileManager.default.currentDirectoryPath
	
	let fileURL = URL(string: "file://\(currDir)/examples/test.imp")!
	do
	{
		print("\(fileURL)")
		let textRead = try String(contentsOf: fileURL, encoding: .utf8)
		return textRead
	}
	catch
	{
		print(error)
	}
	return nil
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

impTest()
