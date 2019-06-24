import Foundation

/// #START_DOC
/// - Define the enumeration for the error that can be throw during translations.
/// #END_DOC
public enum TranslatorError: Error
{
	case UndefinedOperator(String)
	case UndefinedAbstractSyntaxTreeNode(AbstractSyntaxTree)
}

/// #START_DOC
/// - Protocal that define basic the logic needed in the translation.
/// #END_DOC
public protocol Translator
{
	/// #START_DOC
	/// - This class' constructor.
	/// #END_DOC
	init (ast: [AbstractSyntaxTree]) throws

    /// #START_DOC
	/// - The main logic of the translation to Pi-ir.
	/// - Return
	/// 	- The relative abstract syntax tree of Pi-ir for be used in the Pi Framework.
	/// #END_DOC
    func translate () throws -> AbstractSyntaxTreePi
}