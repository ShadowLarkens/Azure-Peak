import type { JSONRPCParams } from 'json-rpc-2.0';
import type {
  InitializeParams,
  InitializeResult,
  Location,
  TextDocumentPositionParams,
} from 'vscode-languageserver-protocol';
import { getServerCommand } from './autoupdate.ts';
import { REPO_ROOT } from './index.ts';
import { JSONRPCEndpoint } from './json_rpc.ts';

export type DmLSP = {
  child: Bun.Subprocess;
  client: DMLSPClient;
};

export type Var = {
  is_declaration: boolean;
  kind: number;
  location: Location;
  name: string;
};

export type DMObject = {
  children: DMObject[];
  kind: number;
  name: string;
  vars: Var[];
};

export type AnnotationVariable = {
  type: 'Variable';
  idents: string[];
};

export type AnnotationTreePath = {
  type: 'TreePath';
  is_absolute: boolean;
  idents: string[];
};

export type AnnotationInSequence = {
  type: 'InSequence';
  index: number;
};

export type AnnotationTreeBlock = {
  type: 'TreeBlock';
  idents: string[];
};

export type AnnotationDiscriminated =
  | AnnotationVariable
  | AnnotationTreePath
  | AnnotationTreeBlock
  | AnnotationInSequence;

export type Annotation = {
  annotation: AnnotationDiscriminated;
  range: Location;
};

export class DMLSPClient {
  private endpoint: JSONRPCEndpoint;

  public constructor(endpoint: JSONRPCEndpoint) {
    this.endpoint = endpoint;
    this.endpoint.on('error', (error) => {
      throw error;
    });
  }

  public initialize(params: InitializeParams): PromiseLike<InitializeResult> {
    return this.endpoint.request('initialize', params);
  }

  public notify(method: string, params?: JSONRPCParams) {
    this.endpoint.notify(method, params);
  }

  public onNotification(
    notifName: string,
    listener: (params: unknown) => void,
  ) {
    this.endpoint.on(notifName, listener);
  }

  public queryObjectTree(path?: string): PromiseLike<DMObject> {
    return this.endpoint.request('experimental/dreammaker/objectTree2', {
      path,
    });
  }

  public queryObjectTreeRecursive(path?: string): PromiseLike<DMObject> {
    return this.endpoint.request('experimental/dreammaker/objectTree2', {
      path,
      recursive: true,
    });
  }

  public queryAnnotation(
    params: TextDocumentPositionParams,
  ): PromiseLike<{ outputAnnotations: Annotation[] }> {
    return this.endpoint.request(
      'experimental/dreammaker/queryAnnotation',
      params,
    );
  }
}

export const startDmLSP = async (): Promise<DmLSP | null> => {
  const command = await getServerCommand();
  if (!command) {
    return null;
  }

  const child = Bun.spawn([command], {
    stdin: 'pipe',
    stdout: 'pipe',
    stderr: 'ignore',
  });

  const jsonRPC = new JSONRPCEndpoint(child.stdin, child.stdout);
  const client = new DMLSPClient(jsonRPC);

  await client.initialize({
    processId: process.pid,
    rootUri: `file://${REPO_ROOT}`,
    capabilities: {
      experimental: { dreammaker: { objectTree2: true } },
    },
  });

  return {
    child,
    client,
  };
};
