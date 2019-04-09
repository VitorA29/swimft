// defining the node structure
public class Node<T>
{
	var value: T
	var next: Node<T>?
	weak var previus: Node<T>?

	init(value: T)
	{
		self.value = value
	}
}

// defining the pile structure
public class Pile<T>
{
	private var top: Node<T>?

	init()
	{
		top = nil
	}

	public var pop: T?
	{
		if let helper = top
		{
			top = helper.next
			return helper.value
		}
		else
		{
			return top
		}
	}

	public func push(value: T)
	{
		let new = Node(value: value)
		new.next = self.top
		top?.previus = new
		top = new
	}
}

// defining the ternary tree structure
public class Tree3<T>
{
	public var key: T
	public var left: Tree3<T>?
	public var middle: Tree3<T>?
	public var right: Tree3<T>?

	init(value: T)
	{
		self.key = value
		self.left = nil
		self.middle = nil
		self.right = nil
	}

	public func insert(Tree3<T>?: T)
	{
		if(self.middle == nil)
		{
			self.middle = T
		}
		else if (self.right == nil)
		{
			self.left = middle
			self.middle  = nil
			self.right = T
		}
	}
}
