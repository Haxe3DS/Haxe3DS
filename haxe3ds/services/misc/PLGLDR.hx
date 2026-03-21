package haxe3ds.services.misc;

import haxe3ds.types.Result;

/**
 * A Miscellaneous Plugin Loader Service for the 3DS.
 * 
 * This is only available to any 3DS with CFW running Luma3DS, Anything else running will do nothing, Using an emulator for this will also NOT do anything.
 * 
 * @since 1.8.0
 */
@:cppInclude('haxe3ds_Utils.h')
@:cppNamespaceCode('
static int	plgldr_refcount;
static Handle plgldr_handle;
')
class PLGLDR {
	/**
	 * Initializes Plugin Loader to Use Your Loader Settings, The result is returned to depend if something went wrong.
	 */
	public static function init():Result {
		var result:Result = 0;
		untyped __cpp__('
			if (AtomicPostIncrement(&plgldr_refcount) == 0) {
				result = svcConnectToPort(&plgldr_handle, "plg:ldr");
			}
		');
		return result;
	}

	/**
	 * Exits Plugin Loader, nothing is returned if it's loaded.
	 */
	public static function exit() {
		untyped __cpp__('
			if (AtomicDecrement(&plgldr_refcount)) {
				return;
			} if (plgldr_handle) {
				svcCloseHandle(plgldr_handle);
			}
			plgldr_handle = 0;
		');
	}

	/**
	 * Functions that displays a Luma3DS Message in the Bottom Screen.
	 * 
	 * There can be a Prompt to exit out the Luma3DS Message, this can also be used for an error message or a menu or whatever you want.
	 * 
	 * @param title The title of the Body, it will colored in Dark Blue and is located in the Top Left.
	 * @param message The message (body) of the Body, this will be colored white, used for informational stuff.
	 * @param result The result to use in hexadecimal, leave as `0` to exclude using the error result.
	 * @return Result to indicate if something went wrong or not.
	 */
	public static function displayMessage(title:String, message:String, result:Result = 0):Result {
		var res:Result = 0;

		untyped __cpp__('
			bool resultIsNone = result != 0;

			u32 *cmdBuf = getThreadCommandBuffer();
			cmdBuf[0] = IPC_MakeHeader(resultIsNone ? 7 : 6, resultIsNone ? 1 : 0, 4);
			if (resultIsNone) cmdBuf[1] = (u32)result;
			cmdBuf[1 + resultIsNone] = IPC_Desc_Buffer(title.length, IPC_BUFFER_R);
			cmdBuf[2 + resultIsNone] = (u32)title.c_str();
			cmdBuf[3 + resultIsNone] = IPC_Desc_Buffer(message.length, IPC_BUFFER_R);
			cmdBuf[4 + resultIsNone] = (u32)message.c_str();

			if (R_SUCCEEDED((res = svcSendSyncRequest(plgldr_handle)))) res = cmdBuf[1];
		');
		return res;
	}
}