package haxe3ds.services;

import haxe3ds.types.Result;

/**
 * NS (Nintendo Shell) service.
 */
@:cppInclude("3ds.h")
class NS {
	/**
	 * Initializes NS.
	 */
	public static inline function init():Result {
		return untyped __cpp__('nsInit');
	}

	/**
	 * Exits NS.
	 */
	public static inline function exit() {
		return untyped __cpp__('nsExit()');
	}

	/**
	 * Reboots the system
	 */
	public static inline function rebootSystem():Result {
		return untyped __cpp__('NS_RebootSystem()');
	}

	/**
	 * If called, force terminates the application and throws a popup being "An error has occurred, forcing the software to close. The system will now restart."
	 * 
	 * Wrapper of `PMApp:TerminateTitle`
	 */
	public static inline function terminate():Result {
		return untyped __cpp__('NS_TerminateTitle()');
	}
}