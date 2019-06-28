/// - Class that define the concept of pile.
public class Stack<T>: CustomStringConvertible
{
	private var top: [T]

	/// - This class initializer.
	/// - Parameter(s)
	/// 	- list: A optional value of a array of Any, if nothing is passed it will assume the default value of nil.
	/// - Return
	/// 	- A new instance of pile object.
	init (list: [T]? = nil)
	{
		if (list == nil)
		{
			top = [T]()
		}
		else
		{
			top = list!
		}
	}
	
	/// - Function for check if the pile is empty.
	/// - Return
	/// 	- <code>true</code> if the pile is empty, <code>false</code> otherwise.
	public func isEmpty () -> Bool
	{
		return top.isEmpty
	}
	
	/// - Function for check the current value in the top of the pile.
	/// - Return
	/// 	- The top element of the pile.
	public func peek () -> T
	{
		return top[0]
	}

	/// - Function for remove and return the top element of the pile.
	/// - Return
	/// 	- The top element of the pile.
	public func pop () -> T
	{
		let result: T = top[0]
		top.remove(at: 0)
		return result
	}
	
	/// - Function for remove the top element of the pile.
	public func skip ()
	{
		if top.isEmpty
		{
			return
		}
		top.remove(at: 0)
	}

	/// - Function for adding a new element to the top of the pile.
	/// - Parameter(s)
	/// 	- The new value to add in the pile, if nil is passed, it will just ignore it.
	public func push (value: T?)
	{
		if (value == nil)
		{
			return
		}
		top.insert(value!, at: 0)
	}

	/// - Function for translating this class to a string value.
	/// - Return
	/// 	- This class string format.
	public var description: String
	{
		var description: String = "[ "
		for element in top
		{
			description += "\(element) "
		}
		description += "]"
		return description
	}
}
