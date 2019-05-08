/// #START_DOC
/// - Class that define the concept of pile.
/// #END_DOC
public class Pile<T>: CustomStringConvertible
{
	private var top: [T]

	/// #START_DOC
	/// - This class initializer.
	///
	/// - Parameter(s)
	/// 	- list: A optional value of a array of Any, if nothing is passed it will assume the default value of nil.
	///
	/// - Return
	/// 	- A new instance of pile object.
	/// #END_DOC
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
	
	/// #START_DOC
	/// - Function for check if the pile is empty.
	///
	/// - Parameter(s)
	///
	/// - Return
	/// 	- <code>true</code> if the pile is empty, <code>false</code> otherwise.
	/// #END_DOC
	public func isEmpty () -> Bool
	{
		return top.isEmpty
	}
	
	/// #START_DOC
	/// - Function for check the current value in the top of the pile.
	///
	/// - Parameter(s)
	///
	/// - Return
	/// 	- The top element of the pile.
	/// #END_DOC
	public func peek () -> T
	{
		return top[0]
	}

	/// #START_DOC
	/// - Function for remove and return the top element of the pile.
	///
	/// - Parameter(s)
	///
	/// - Return
	/// 	- The top element of the pile.
	/// #END_DOC
	public func pop () -> T
	{
		let result: T = top[0]
		top.remove(at: 0)
		return result
	}
	
	/// #START_DOC
	/// - Function for remove the top element of the pile.
	///
	/// - Parameter(s)
	///
	/// - Return
	/// #END_DOC
	public func skip ()
	{
		top.remove(at: 0)
	}

	/// #START_DOC
	/// - Function for adding a new element to the top of the pile.
	///
	/// - Parameter(s)
	/// 	- The new value to add in the pile, if nil is passed, it will just ignore it.
	///
	/// - Return
	/// #END_DOC
	public func push (value: T?)
	{
		if (value == nil)
		{
			return
		}
		top.insert(value!, at: 0)
	}

	/// #START_DOC
	/// - Function for helping in translating this class to a string value.
	///
	/// - Parameter(s)
	///
	/// - Return
	/// 	- This class string translation.
	/// #END_DOC
	public func create_description_func () -> String
	{
		var description: String = "[ "
		for element in top
		{
			description += "\(element) "
		}
		description += "]"
		return description
	}
	
	public var description: String
	{
		return create_description_func()
	}
}
