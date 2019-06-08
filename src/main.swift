import Foundation

public var envConfiguration: Configuration! = nil

/// #START_DOC
/// - Function for helping handleling with the opening and reading of the argument file.
/// - Return
/// 	- The content of the file if found, nil otherwise.
/// #END_DOC
private func filePath () throws -> String?
{
	let currDir = FileManager.default.currentDirectoryPath
	
	let fileURL = URL(string: "file://\(currDir)/\(envConfiguration.file_name)")!
	do
	{
		let textRead = try String(contentsOf: fileURL, encoding: .utf8)
		return textRead
	}
	catch
	{
		throw error
	}
}

/// #START_DOC
/// - The main function of this compiler logic, this will handle with everything by creating the compilation pipeline, printing every step.
/// #END_DOC
public func main ()
{
	do
	{
		envConfiguration = try Configuration()
		let code: String = try filePath()!
		print("{ code: \(code) }")
		let lexer = Lexer(input: code)
		let tokens = lexer.tokenize()
		if envConfiguration.tokens_print
		{
			print("{ tokens: \(tokens) }")
			if envConfiguration.stop_tokens
			{
				return
			}
		}
		
		let parser = Parser(tokens: tokens)
		let ast_imp: [AST_Imp] = try parser.parse()
		if envConfiguration.ast_imp_print
		{
			print("{ ast_imp: \(ast_imp) - \(ast_imp.count) }")
			if envConfiguration.stop_ast_imp
			{
				return
			}
		}
		
		let piFramework: PiFramework = PiFramework()
		
		let ast_pi: AST_Pi = try piFramework.translate(ast_imp: ast_imp)
		if envConfiguration.ast_pi_print
		{
			print("{ ast_pi: \(ast_pi) }")
			if envConfiguration.stop_ast_pi
			{
				return
			}
		}
		
		try piFramework.pi_automaton(ast_pi: ast_pi)
	}
	catch
	{
		print(error)
	}
}

main()
