extension StringProtocol
{
	subscript(bounds: CountableClosedRange<Int>) -> SubSequence
	{
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(start, offsetBy: bounds.count)
		return self[start..<end]
	}
	
	subscript(bounds: CountableRange<Int>) -> SubSequence
	{
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(start, offsetBy: bounds.count)
		return self[start..<end]
	}
}
