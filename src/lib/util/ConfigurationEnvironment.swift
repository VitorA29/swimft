import Foundation

/// #START_DOC
/// - Define the enumeration for the error that can be throw during arguments processing.
/// #END_DOC
public enum ConfigurationError: Error
{
	case UndefinedFlag(String)
}

/// #START_DOC
/// - Class for the used for setting up all the environment configurations.
/// #END_DOC
public class Configuration
{
	let file_name: String
	var code_print: Bool = false
	var tokens_print: Bool = false
	var stop_tokens: Bool = false
	var ast_imp_print: Bool = false
	var stop_ast_imp: Bool = false
	var ast_pi_print: Bool = false
	var stop_ast_pi: Bool = false
	var state_print: Bool = false
	var state_n_print: Int = -1
	var last_state_print: Bool = false
	
	/// #START_DOC
	/// - This class initializer.
	/// #END_DOC
	init () throws
	{
		if (CommandLine.arguments.count > 1)
		{
			file_name = CommandLine.arguments[1]
			if CommandLine.arguments.count > 2
			{
				try processArguments()
			}
		}
		else
		{
			throw GenericError.InvalidArgument
		}
	}
	
	/// #START_DOC
	/// - Helper function for processing the argument flags if exists any.
	/// #END_DOC
	private func processArguments () throws
	{
		var i: Int = 2
		while i < CommandLine.arguments.count
		{
			switch (CommandLine.arguments[i])
			{
				case "-debug":
					tokens_print = true
					ast_imp_print = true
					ast_pi_print = true
					state_print = true
				case "-stokens":
					stop_tokens = true
					fallthrough
				case "-tokens":
					tokens_print = true
				case "-sast_imp":
					stop_ast_imp = true
					fallthrough
				case "-ast_imp":
					ast_imp_print = true
				case "-sast_pi":
					stop_ast_pi = true
					fallthrough
				case "-ast_pi":
					ast_pi_print = true
				case "-state":
					if i+1 < CommandLine.arguments.count && !CommandLine.arguments[i+1].starts(with: "-")
					{
						i+=1
						state_n_print = Int(CommandLine.arguments[i])!
					}
					else
					{
						state_print = true
					}
				case "-last_state":
					last_state_print = true
				case "-code":
					code_print = true
				default:
					throw ConfigurationError.UndefinedFlag(CommandLine.arguments[i])				
			}
			i+=1
		}
	}
}
