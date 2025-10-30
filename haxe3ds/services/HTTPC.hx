package haxe3ds.services;

import cxx.VoidPtr;
import haxe3ds.Types.Result;

/**
 * Enumerator for the callback that displays what type was triggered.
 * 
 * @since 1.5.0
 */
enum abstract HTTPCInfo(Int) {
    /**
     * The download is currently pending.
     * 
     * Array arguments (by index):
     * - 0: `UInt8`  Bytes Downloaded.
     * - 1: `Uint32` The content size that got downloaded.
     * - 2: `Uint32` Total downloaded size.
     * - 3: `Uint32` The length of the content.
     */
    var DOWNLOAD_PENDING = 1;

    /**
     * The download is finished!
     * 
     * No Arguments.
     */
    var DOWNLOAD_FINISHED = 2;
}

/**
 * HTTPC Service.
 * 
 * @since 1.5.0
 */
@:cppInclude("haxe3ds_Utils.h")
class HTTPC {
    /**
     * Initializes HTTPC to allow downloading stuff.
     * 
     * @return Result code to check whetever something went wrong or not.
     */
    public static function init():Result {
        return untyped __cpp__('httpcInit(0x1000)');
    }

    /**
     * Exits HTTPC. If there's any downloads running don't EXIT.
     */
    @:native("httpcExit")
    public static function exit() {}
}

/**
 * Class context.
 * 
 * @since 1.5.0
 */
@:cppFileCode('
void HTTPHandler(haxe3ds::services::HTTPContext* cont) {
	httpcContext context;
    u32 status = 0, size = 0, bw = 0, readSize = 0;
    u8* data;

    while (true) {
        cont->result = httpcOpenContext(&context, HTTPC_METHOD_GET, cont->url.c_str(), 0);
        if (R_FAILED(cont->result)) {
            cont->reason = "httpcOpenContext failed";
            goto fail;
        }

        cont->result = httpcSetSSLOpt(&context, SSLCOPT_DisableVerify);
        if (R_FAILED(cont->result)) {
            cont->reason = "httpcSetSSLOpt failed";
            goto fail;
        }

        cont->result = httpcSetKeepAlive(&context, HTTPC_KEEPALIVE_ENABLED);
        if (R_FAILED(cont->result)) {
            cont->reason = "httpcSetSSLOpt failed";
            goto fail;
        }

        httpcAddRequestHeaderField(&context, "User-Agent", "httpc-example/1.0.0");
        httpcAddRequestHeaderField(&context, "Connection", "Keep-Alive");

        cont->result = httpcBeginRequest(&context);
        if (R_FAILED(cont->result)) {
            cont->reason = "httpcBeginRequest failed";
            goto fail;
        }

        cont->result = httpcGetResponseStatusCode(&context, &status);
        if (R_FAILED(cont->result)) {
            cont->reason = "httpcGetResponseStatusCode failed";
            goto fail;
        }

        if ((status >= 301 && status <= 303) || (status >= 307 && status <= 308)) {
            char* newurl = (char*)malloc(0x1000);
            cont->result = httpcGetResponseHeader(&context, "Location", newurl, 0x1000);
            if (R_FAILED(cont->result)) {
                cont->reason = "httpcGetResponseHeader failed to get Location";
                free(newurl);
                goto fail;
            }

			cont->url = newurl;
            if (cont->url == "") {
                free(newurl);
                break;
            }

			httpcCloseContext(&context);
            free(newurl);

            continue;
		}

        break;
    }

    if (status != 200) {
        cont->reason = "Got Status Error " + std::to_string(status);
        goto fail;
    }

    cont->result = httpcGetDownloadSizeState(&context, NULL, &size);
    if (R_FAILED(cont->result)) {
        cont->reason = "httpcGetDownloadSizeState failed";
        goto fail;
    }

    if (cont->callback == nullptr) {
        cont->reason = "Callback is null!";
        goto fail;
    }

    data = (u8*)malloc(cont->downloadSpeed);
    cont->result = HTTPC_RESULTCODE_DOWNLOADPENDING;
    while (cont->result == HTTPC_RESULTCODE_DOWNLOADPENDING) {
        cont->result = httpcDownloadData(&context, data, cont->downloadSpeed, &readSize);
        cont->callback(1, std::make_shared<std::deque<void*>>(std::deque<void*>{data, (void*)readSize, (void*)(bw + readSize), (void*)size}));
        bw += readSize;
    }
        
    free(data);
    cont->callback(2, std::make_shared<std::deque<void*>>(std::deque<void*>{}));

    fail:
    httpcCloseContext(&context);
}')
@:headerInclude("deque")
class HTTPContext {
    /**
     * Predicted path that's going to be downloaded from.
     */
    public var file:String = "";

    /**
     * URL Path.
     */
    public var url(default, null):String = "";

    /**
     * Result code to indicate that if something went wrong with your code.
     */
    public var result(default, null):Result = 0;

    /**
     * If result code is failed, this will display the reason on what it failed.
     */
    public var reason(default, null):String = "";

    /**
     * Whetever or not you want to keep it alive.
     */
    public var keepAlive:Bool = false;

    /**
     * Checker if the HTTP request is completed.
     */
    public var complete(default, null):Bool = false;

    /**
     * The current download speed to use.
     * 
     * Must not be set if it's currently downloading.
     */
    public var downloadSpeed:Int = 0x4000;

    /**
     * The callback for this HTTP context.
     * 
     * ## STRICTLY REQUIRED to be set or else the file won't download.
     * 
     * But it can be set in the constructor's 2nd argument.
     * 
     * @see HTTPCCallback Enum.
     */
    public var callback:(HTTPCInfo, Array<VoidPtr>)->Void;

    /**
     * Creates a new HTTPC context.
     * @param url URL to use.
     */
    public function new(url:String, callback:(HTTPCInfo, Array<VoidPtr>)->Void) {
        this.url = url;

        // Strip path to get the file name.
        final last:Int = url.lastIndexOf("/");
        this.file = url.substr(last, url.indexOf("?")-last);
        this.callback = callback;
    }

    /**
     * Starts requesting using this HTTP Context.
     * 
     * Note: If downloading in bytes and saving to a file, Use `FSFile.writeVoid`!
     */
    public function request() {
        untyped __cpp__('HTTPHandler(this)');
    }
}