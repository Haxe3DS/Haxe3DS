package haxe3ds.types;

/**
 * Event Handling for Functions that has been added to this event.
 * @since 1.7.0
 */
class Event<Args> {
	private var listeners:Array<Args->Void> = [];

	/**
	 * Initializes a new Event for Handling.
	 * @param defFn The default function to call, this will not be stored in the array
	 */
	public function new(defFn:Void->Void = null) {
		if (defFn != null) {
			defFn();
		}
	}

	/**
	 * Adds a new function listener to the array.
	 * @param listener The listener function.
	 * @returns Int, -1 for null
	 */
	public function addEvent(listener:Args->Void):Int {
		if (listener == null) {
			return -1;
		}
		return listeners.push(listener);
	}

	/**
	 * Calls all the stored functions by the argument.
	 * @param argument The argument to use.
	 */
	public function callEvents(argument:Args) {
		for (listener in listeners) {
			listener(argument);
		}
	}

	/**
	 * Clears all the functions stored from the array.
	 */
	public inline function clear() {
		listeners.splice(0, listeners.length);
		listeners = [];
	}
}