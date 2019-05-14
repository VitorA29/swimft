import Foundation

/// #START_DOC
/// - Define the enumeration for the error that can be throw during arguments processing.
/// #END_DOC
public enum ConfigurationError: Error
{
	case InvalidArgument(String)
}

/// #START_DOC
/// - Class for the used for setting up all the environment configurations.
/// #END_DOC
public class Configuration
{
	let file_name: String
	var tokens_print: Bool = false
	var ast_imp_print: Bool = false
	var ast_pi_print: Bool = false
	var state_print: Bool = false
	
	/// #START_DOC
	/// - This class initializer.
	/// #END_DOC
	init () throws
	{
		file_name = CommandLine.arguments[1]
		if CommandLine.arguments.count > 2
		{
			try processArguments()
		}
	}
	
	/// #START_DOC
	/// - Helper function for processing the argument flags if exists any.
	/// #END_DOC
	private func processArguments () throws
	{
		for i in 2..<CommandLine.arguments.count
		{
			switch (CommandLine.arguments[i])
			{
				case "-debug":
					tokens_print = true
					ast_imp_print = true
					ast_pi_print = true
					state_print = true
					break
				case "-tokens":
					tokens_print = true
					break
				case "-ast_imp":
					ast_imp_print = true
					break
				case "-ast_pi":
					ast_pi_print = true
					break
				case "-state":
					state_print = true
					break
				default:
					throw ConfigurationError.InvalidArgument(CommandLine.arguments[i])				
			}
		}
	}
}

public let envConfiguration: Configuration = try Configuration()

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
		let code: String = try filePath()!
		print("{ code: \(code) }")
		let lexer = Lexer(input: code)
		let tokens = lexer.tokenize()
		if envConfiguration.tokens_print
		{
			print("{ tokens: \(tokens) }")
		}
		
		let parser = Parser(tokens: tokens)
		let ast_imp: [AST_Imp] = try parser.parse()
		if envConfiguration.ast_imp_print
		{
			print("{ ast_imp: \(ast_imp) - \(ast_imp.count) }")
		}
		
		let piFramework: PiFramework = PiFramework()
		
		let ast_pi: AST_Pi = try piFramework.translate(ast_imp: ast_imp)
		if envConfiguration.ast_pi_print
		{
			print("{ ast_pi: \(ast_pi) }")
		}
		
		try piFramework.pi_automaton(ast_pi: ast_pi)
	}
	catch
	{
		print(error)
	}
}

main()
