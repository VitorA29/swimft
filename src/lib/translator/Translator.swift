import Foundation

/// - Define the enumeration for the error that can be throw during translations.
public enum TranslatorError: Error
{
	case UndefinedOperator(String)
	case UndefinedAbstractSyntaxTreeNode(AbstractSyntaxTree)
}

/// - Protocal that define basic the logic needed in the translation.
public protocol Translator
{
	/// - This class' constructor.
	init (ast: [AbstractSyntaxTree]) throws

	/// - The main logic of the translation to Pi-ir.
	/// - Return
	/// 	- The relative abstract syntax tree of Pi-ir for be used in the Pi Framework.
    func translate () throws -> AbstractSyntaxTreePi
}
