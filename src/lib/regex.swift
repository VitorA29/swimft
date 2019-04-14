import Foundation

var expressions = [String: NSRegularExpression]()
public extension String
{
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
