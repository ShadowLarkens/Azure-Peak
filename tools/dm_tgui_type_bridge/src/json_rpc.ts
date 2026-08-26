// Large parts of this taken from https://github.com/ImperiumMaximus/ts-lsp-client/blob/main/src/jsonRpcTransform.ts
import type { FileSink } from 'bun';
import {
  JSONRPCClient,
  type JSONRPCParams,
  type JSONRPCRequest,
  type JSONRPCResponse,
} from 'json-rpc-2.0';

type Fn = (...args: any[]) => void;

class EventEmitter {
  private listeners: Record<string, Fn[]>;

  constructor() {
    this.listeners = {};
  }

  on(name: string, listener: Fn): () => void {
    this.listeners[name] = this.listeners[name] || [];
    this.listeners[name].push(listener);

    return () => {
      const listeners = this.listeners[name];
      if (!listeners) {
        throw new Error(`There is no listeners for "${name}"`);
      }
      this.listeners[name] = listeners.filter((existingListener) => {
        return existingListener !== listener;
      });
    };
  }

  emit(name: string, ...params: any[]): void {
    const listeners = this.listeners[name];
    if (!listeners) {
      return;
    }
    for (const listener of listeners) {
      listener(...params);
    }
  }

  clear(): void {
    this.listeners = {};
  }
}

type ReceiveState = 'content-length' | 'jsonrpc';

class JSONRPCTransform extends EventEmitter implements Bun.UnderlyingSink {
  private _state: ReceiveState;
  private _curContentLength: number;
  private _curChunk: Buffer;

  constructor() {
    super();
    this._curContentLength = 0;
    this._curChunk = Buffer.from([]);
    this._state = 'content-length';
  }

  write(chunk: any) {
    const encoding = 'utf-8';

    chunk = Buffer.from(chunk, encoding);
    this._curChunk = Buffer.concat([this._curChunk, chunk]);

    const prefixLength = Buffer.byteLength('Content-Length: ', encoding);
    const prefixRegex = /^Content-Length: /i;
    const digitLength = Buffer.byteLength('0', encoding);
    const digitRe = /^[0-9]/;
    const suffixLength = Buffer.byteLength('\r\n\r\n', encoding);
    const suffixExistsRe = /\r\n\r\n/;
    const suffixRe = /^\r\n\r\n/;

    while (true) {
      if (this._state === 'content-length') {
        // Not enough data for a content length match
        if (!suffixExistsRe.test(this._curChunk.toString(encoding))) break;

        const leading = this._curChunk.subarray(0, prefixLength);
        if (!prefixRegex.test(leading.toString(encoding))) {
          this.emit(
            'error',
            new Error(
              `[_transform] Bad header: ${this._curChunk.toString(encoding)}`,
            ),
          );
          return;
        }

        let numString = '';
        let position = leading.length;
        while (this._curChunk.length - position > digitLength) {
          const ch = this._curChunk
            .subarray(position, position + digitLength)
            .toString(encoding);
          if (!digitRe.test(ch)) break;

          numString += ch;
          position += 1;
        }

        if (
          position === leading.length ||
          this._curChunk.length - position < suffixLength ||
          !suffixRe.test(
            this._curChunk
              .subarray(position, position + suffixLength)
              .toString(encoding),
          )
        ) {
          this.emit(
            'error',
            new Error(
              `[_transform] Bad header: ${this._curChunk.toString(encoding)}`,
            ),
          );
          return;
        }

        this._curContentLength = Number(numString);
        this._curChunk = this._curChunk.subarray(position + suffixLength);
        this._state = 'jsonrpc';
      }

      if (this._state === 'jsonrpc') {
        if (this._curChunk.length >= this._curContentLength) {
          this.emit(
            'data',
            this._curChunk
              .subarray(0, this._curContentLength)
              .toString(encoding),
          );
          this._curChunk = this._curChunk.subarray(this._curContentLength);
          this._state = 'content-length';

          continue;
        }
      }

      break;
    }
  }
}

export class JSONRPCEndpoint extends EventEmitter {
  private writable: FileSink;
  private readable: ReadableStream;
  private transform: JSONRPCTransform;

  private client: JSONRPCClient;

  private nextId: number = 0;

  public constructor(
    writable: FileSink,
    readable: ReadableStream<Uint8Array<ArrayBuffer>>,
  ) {
    super();

    const createId = () => this.nextId++;

    this.writable = writable;
    this.readable = readable;
    this.transform = new JSONRPCTransform();

    this.client = new JSONRPCClient(async (jsonRPCRequest) => {
      const jsonRPCRequestStr = JSON.stringify(jsonRPCRequest);
      // console.debug('sending', jsonRPCRequestStr);
      const contentLength = Buffer.from(jsonRPCRequestStr, 'utf-8').byteLength;
      this.writable.write(
        `Content-Length: ${contentLength}\r\n\r\n${jsonRPCRequestStr}`,
      );
    }, createId);

    this.transform.on('data', (data: string) => {
      const jsonrpc = JSON.parse(data);
      // console.log('[transform]', jsonrpc);

      if (
        Object.hasOwn(jsonrpc, 'id') &&
        (Object.hasOwn(jsonrpc, 'result') || Object.hasOwn(jsonrpc, 'error'))
      ) {
        const jsonRPCResponse: JSONRPCResponse = jsonrpc;
        if (jsonRPCResponse.id === this.nextId - 1) {
          this.client.receive(jsonRPCResponse);
        } else {
          this.emit(
            'error',
            new Error(
              `Received ID mismatch, expected ${this.nextId - 1}, got ${jsonRPCResponse.id}`,
            ),
          );
        }
      } else if (Object.hasOwn(jsonrpc, 'method')) {
        const jsonRPCRequest: JSONRPCRequest = jsonrpc;
        this.emit(
          jsonRPCRequest.method,
          jsonRPCRequest.params,
          jsonRPCRequest.id,
        );
      } else {
        this.emit(
          'error',
          new Error(`Received invalid JSON-RPC message: ${data}`),
        );
      }
    });

    this.readable.pipeTo(new WritableStream(this.transform));
  }

  public request(
    method: string,
    message?: JSONRPCParams,
  ): ReturnType<JSONRPCClient['request']> {
    return this.client.request(method, message);
  }

  public notify(method: string, params?: JSONRPCParams) {
    this.client.notify(method, params);
  }
}
