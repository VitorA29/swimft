// defining the pile structure
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

// defining the ternary tree structure
public class Tree3<T>: CustomStringConvertible
{
	public var key: T
	public var left: Tree3<T>?
	public var middle: Tree3<T>?
	public var right: Tree3<T>?
	private var degree: Int

	init (value: T)
	{
		self.key = value
		self.left = nil
		self.middle = nil
		self.right = nil
		self.degree = 0
	}

	public func insert(tree: Tree3<T>?)
	{
		if (tree == nil)
		{
			return
		}
		if (self.degree == 0)
		{
			self.middle = tree
			self.degree += 1
		}
		else
		{
			if (self.degree == 1)
			{
				self.left = self.middle
				self.middle  = nil
			}
			else
			{
				self.middle = self.right
			}
			self.right = tree
			self.degree += 1
		}
	}

	public func create_description_func () -> String
	{
		var description: String = "<'\(self.key)'"

		if (self.left != nil || self.middle != nil || self.right != nil)
		{
			// left path
			if (self.left == nil)
			{
				description += ""//"<nil>"
			}
			else
			{
				let left_unwrap: Tree3<T> = self.left!
				description += "\(left_unwrap)"
			}
			
			// middle path
			if (self.middle == nil)
			{
				description += ""//"<nil>"
			}
			else
			{
				let middle_unwrap: Tree3<T> = self.middle!
				description += "\(middle_unwrap)"
			}

			// right path
			if (self.right == nil)
			{
				description += ""//"<nil>"
			}
			else
			{
				let right_unwrap: Tree3<T> = self.right!
				description += "\(right_unwrap)"
			}
		}
		
		description += ">"
		return description
	}
	
	public var description: String
	{
		return create_description_func()
	}
}
