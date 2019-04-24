public class Pile<T>: CustomStringConvertible
{
	private var top: [T]

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
	
	public func isEmpty () -> Bool
	{
		return top.isEmpty
	}
	
	public func peek () -> T
	{
		return top[0]
	}

	public func pop () -> T
	{
		let result: T = top[0]
		top.remove(at: 0)
		return result
	}
	
	public func skip ()
	{
		top.remove(at: 0)
	}

	public func push (value: T?)
	{
		if (value == nil)
		{
			return
		}
		top.insert(value!, at: 0)
	}

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
