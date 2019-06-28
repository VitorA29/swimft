import Foundation

/// - A dictionary for helping in execution time the processing of regular expressions.
var expressions = [String: NSRegularExpression]()

/// - A extention of the String class.
public extension String
{
	/// - A helper function for processing regular expressions.
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
