import Foundation

public func filePath () -> String?
{
	let currDir = FileManager.default.currentDirectoryPath
	
	let fileURL = URL(string: "file://\(currDir)/\(CommandLine.arguments[1])")!
	do
	{
		let textRead = try String(contentsOf: fileURL, encoding: .utf8)
		return textRead
	}
	catch
	{
		print(error)
	}
	return nil
}

public func main ()
{
	let lexer = Lexer(input: filePath()!)
	let tokens = lexer.tokenize()
	print(tokens)
	let parser = Parser(tokens: tokens)
	do
	{
		let ast_imp: [AST_Node] = try parser.parse()
		print("\(ast_imp) - length(\(ast_imp.count))")
		
		let piFramework: PiFramework = PiFramework()
		
		var ast_pi_forest: [AST_Pi] = [AST_Pi]()
		for node in ast_imp
		{
			let ast_pi = try piFramework.transformer(ast_imp: node)
			ast_pi_forest.append(ast_pi)
		}
		
		print("\(ast_pi_forest) - length(\(ast_pi_forest.count))")
		
		// try piFramework.pi_automaton(ast_pi: ast_pi)
	}
	catch
	{
		print(error)
	}
}

main()
