// defining the node structure
public class Node<T>
{
	var value: T
	var next: Node<T>?
	weak var previus: Node<T>?

	init (value: T)
	{
		self.value = value
	}
	
	public func print_node ()
	{
		print(value, terminator:"")
	}
}

// defining the pile structure
public class Pile<T>
{
	private var top: Node<T>?

	init ()
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
			return top?.value
		}
	}

	public func push (value: T)
	{
		let new = Node(value: value)
		new.next = self.top
		top?.previus = new
		top = new
	}

	public func print_pile ()
	{
		var cursor: Node<T>? = top
		print("[ ", terminator:"")
		while (cursor != nil)
		{
			cursor?.print_node()
			print(" ", terminator:"")
			cursor = cursor?.next
		}
		print("]")
	}
}

// defining the ternary tree structure
public class Tree3<T>
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

	public func insert(tree: Tree3<T> )
	{
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

	public func print_tree ()
	{
		print("<'\(self.key)'", terminator:"")

		// left path
		if (self.left == nil)
		{
			print("<nil>", terminator:"")
		}
		else
		{
			self.left?.print_tree()
		}
		
		// middle path
		if (self.middle == nil)
		{
			print("<nil>", terminator:"")
		}
		else
		{
			self.middle?.print_tree()
		}

		// right path
		if (self.right == nil)
		{
			print("<nil>", terminator:"")
		}
		else
		{
			self.right?.print_tree()
		}
		print(">", terminator:"")
	}
}
