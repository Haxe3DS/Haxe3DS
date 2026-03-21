package haxe3ds.types;

import cpp.UInt64;

/**
 * The time that was parsed by Nano Time (READ ONLY, EDITING NOT POSSIBLE).
 * @since 1.7.0
 */
enum abstract NanoTime(UInt64) from UInt64 to UInt64 {
	/**
	 * Converts a Number to a String.
	 * @return String
	 */
	public function toString():String {
		final symbol = ["d", "h", "m", "s", "ms", "us", "ns"];
		final time = [day, hour, minute, second, millisecond, microsecond, nanosecond];
		final output = new StringBuf();

		var canAdd = false;
		for (index => str in symbol) {
			final number = time[index];
			if (canAdd = number != 0 || canAdd) {
				output.add('$number$str ');
			}
		}

		return output.length == 0 ? "0ns" : output.toString().substr(0, output.length - 1);
	}

	/**
	 * The current nanosecond for the Nano Time
	 */
	public var nanosecond(get, set):Int;
	function get_nanosecond():Int return this.toInt() % 1000;
	function set_nanosecond(_:Int):Int return this.toInt();

	/**
	 * The current microsecond for the Nano Time
	 */
	public var microsecond(get, set):Int;
	function get_microsecond():Int return Std.int(this.toInt() / 1000) % 1000;
	function set_microsecond(_:Int):Int return this.toInt();

	/**
	 * The current millisecond for the Nano Time
	 */
	public var millisecond(get, set):Int;
	function get_millisecond():Int return Std.int(this.toInt() / 1000 / 1000) % 1000;
	function set_millisecond(_:Int):Int return this.toInt();

	/**
	 * The current second for the Nano Time
	 */
	public var second(get, set):Int;
	function get_second():Int return Std.int(this.toInt() / 1000 / 1000 / 1000) % 60;
	function set_second(_:Int):Int return this.toInt();

	/**
	 * The current minute for the Nano Time
	 */
	public var minute(get, set):Int;
	function get_minute():Int return Std.int(this.toInt() / 1000 / 1000 / 1000 / 60) % 60;
	function set_minute(_:Int):Int return this.toInt();

	/**
	 * The current hour for the Nano Time
	 */
	public var hour(get, set):Int;
	function get_hour():Int return Std.int(this.toInt() / 1000 / 1000 / 1000 / 60 / 60) % 24;
	function set_hour(_:Int):Int return this.toInt();

	/**
	 * The current day for the Nano Time
	 */
	public var day(get, set):Int;
	function get_day():Int return Std.int(this.toInt() / 1000 / 1000 / 1000 / 60 / 60 / 24);
	function set_day(_:Int):Int return this.toInt();
}