/// #START_DOC
/// - This is just a class for wrapping a Dictionary.
/// #END_DOC
public class EnvironmentCollection: AutomatonValue
{
	private var collection: [String: AutomatonBindable]
	
	/// #START_DOC
	/// - This class initializer.
	/// - Parameter(s)
	/// 	- collection: A optional value representing a starting collection, if nothing is passed it will assume the default value of nil.
	/// - Return
	/// 	- A new instance of bindable collection object.
	/// #END_DOC
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
	
	/// #START_DOC
	/// - Function for adding a new entry to the wrapped collection.
	/// - Parameter(s)
	/// 	- key: A new entry key.
	/// 	- value: A new entry value.
	/// #END_DOC
	public func add (key: String, value: AutomatonBindable)
	{
		self.collection[key] = value
	}
	
	/// #START_DOC
	/// - This is the getter for the collection element.
	/// - Return
	/// 	- The wrapped dictionary element.
	/// #END_DOC
	public func getCollection () -> [String: AutomatonBindable]
	{
		return self.collection
	}
	
	public var description: String
	{
		return "\(collection)"
	}
}

/// #START_DOC
/// - This is just a class for wrapping a location colection.
/// #END_DOC
public class LocationCollection: AutomatonValue
{
	private var collection: [Location]
	
	/// #START_DOC
	/// - This class initializer.
	/// - Parameter(s)
	/// 	- collection: A optional value representing a starting collection, if nothing is passed it will assume the default value of nil.
	/// - Return
	/// 	- A new instance of location collection object.
	/// #END_DOC
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
	
	/// #START_DOC
	/// - This is the getter for the collection element.
	/// - Return
	/// 	- The wrapped location collection element.
	/// #END_DOC
	public func getCollection () -> [Location]
	{
		return self.collection
	}
	
	public var description: String
	{
		return "\(collection)"
	}
}
