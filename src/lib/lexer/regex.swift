import Foundation

/// #START_DOC
/// - A dictionary for helping in execution time the processing of regular expressions.
/// #END_DOC
var expressions = [String: NSRegularExpression]()

/// #START_DOC
/// - A extention of the String class.
/// #END_DOC
public extension String
{
	/// #START_DOC
	/// - A helper function for processing regular expressions.
	/// #END_DOC
	func match (regex: String) -> String?
	{
		let expression: NSRegularExpression
		if let exists = expressions[regex]
		{
			expression = exists
		}
		else
		{
			expression = try! NSRegularExpression(pattern: "^\(regex)", options: [])
			expressions[regex] = expression
		}
		
		if let match = expression.firstMatch(in: self, options: [], range: NSMakeRange(0, self.utf16.count))
		{
			return (self as NSString).substring(with: match.range)
		}
		return nil
	}
}
