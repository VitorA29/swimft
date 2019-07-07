/// - This is just a class for wrapping a Dictionary.
public class EnvironmentCollection: AutomatonValue
{
	private var collection: [String: AutomatonBindable]
	
	/// - This class initializer.
	/// - Parameter(s)
	/// 	- collection: A optional value representing a starting collection, if nothing is passed it will assume the default value of nil.
	/// - Return
	/// 	- A new instance of bindable collection object.
	init (collection:[String: AutomatonBindable]? = nil)
	{
		if collection != nil
		{
			self.collection = collection!
		}
		else
		{
			self.collection = [String: AutomatonBindable]()
		}
	}
	
	/// - Function for adding a new entry to the wrapped collection.
	/// - Parameter(s)
	/// 	- key: A new entry key.
	/// 	- value: A new entry value.
	public func add (key: String, value: AutomatonBindable)
	{
		self.collection[key] = value
	}

	/// - Function for adding a new entry to the wrapped collection.
	/// - Parameter(s)
	/// 	- entry: A dict contening a dictionary entry.
	public func add (entry: [String: AutomatonBindable])
	{
		self.collection.merge(entry) { (_, new) in new }
	}
	
	/// - This is the getter for the collection element.
	/// - Return
	/// 	- The wrapped dictionary element.
	public func getCollection () -> [String: AutomatonBindable]
	{
		return self.collection
	}
	
	public var description: String
	{
		return "\(collection)"
	}
}

/// - This is just a class for wrapping a location colection.
public class LocationCollection: AutomatonValue
{
	private var collection: [Location]
	
	/// - This class initializer.
	/// - Parameter(s)
	/// 	- collection: A optional value representing a starting collection, if nothing is passed it will assume the default value of nil.
	/// - Return
	/// 	- A new instance of location collection object.
	init (collection: [Location]? = nil)
	{
		if collection != nil
		{
			self.collection = collection!
		}
		else
		{
			self.collection = [Location]()
		}
	}
	
	/// - This is the getter for the collection element.
	/// - Return
	/// 	- The wrapped location collection element.
	public func getCollection () -> [Location]
	{
		return self.collection
	}
	
	public var description: String
	{
		return "\(collection)"
	}
}
