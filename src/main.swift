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
	let code: String = filePath()!
	print("{ code: \(code) }")
	let lexer = Lexer(input: code)
	let tokens = lexer.tokenize()
	print("{ tokens: \(tokens) }")
	let parser = Parser(tokens: tokens)
	do
	{
		let ast_imp: [AST_Imp] = try parser.parse()
		print("{ ast_imp: \(ast_imp) - \(ast_imp.count) }")
		
		let piFramework: PiFramework = PiFramework()
		
		let ast_pi: AST_Pi = try piFramework.translate(ast_imp: ast_imp)
		print("{ ast_pi: \(ast_pi) }")
		
		try piFramework.pi_automaton(ast_pi: ast_pi)
	}
	catch
	{
		print(error)
	}
}

main()
