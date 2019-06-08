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
	var stop_tokens: Bool = false
	var ast_imp_print: Bool = false
	var stop_ast_imp: Bool = false
	var ast_pi_print: Bool = false
	var stop_ast_pi: Bool = false
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
				case "-stokens":
					tokens_print = true
					stop_tokens = true
					break
				case "-sast_imp":
					ast_imp_print = true
					stop_ast_imp = true
					break
				case "-sast_pi":
					ast_pi_print = true
					stop_ast_pi = true
					break
				default:
					throw ConfigurationError.InvalidArgument(CommandLine.arguments[i])				
			}
		}
	}
}
