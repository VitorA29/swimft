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
		if envConfiguration.code_print
		{
			print("{ code: \(code) }")
		}

		let lexer:Lexer<ImpToken> = Lexer<ImpToken>(input: code, processor: IMP_TOKEN_PROCESSOR) // should create a lexer factory
		let tokens: [ImpToken] = try lexer.tokenize()
		if envConfiguration.tokens_print
		{
			print("{ tokens: \(tokens) }")
			if envConfiguration.stop_tokens
			{
				return
			}
		}
		
		let parser: ImpParser = try ImpParser(tokens: tokens) // should create a parser factory
		let ast_imp: [AbstractSyntaxTreeImp] = try parser.parse() as! [AbstractSyntaxTreeImp]
		if envConfiguration.ast_imp_print
		{
			print("{ ast_imp: \(ast_imp) - \(ast_imp.count) }")
			if envConfiguration.stop_ast_imp
			{
				return
			}
		}

		let translator: ImpTranslator = try ImpTranslator(ast: ast_imp)
		let ast_pi: AbstractSyntaxTreePi = try translator.translate()
		if envConfiguration.ast_pi_print
		{
			print("{ ast_pi: \(ast_pi) }")
			if envConfiguration.stop_ast_pi
			{
				return
			}
		}
		
		let piFramework: PiFramework = PiFramework(ast_pi: ast_pi)
		try piFramework.execute()
	}
	catch
	{
		print(error)
	}
}

main()
