//! By in large taken from https://github.com/SpaceManiac/vscode-dm-langclient/blob/master/src/extension.ts
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import util from 'node:util';
import { is_executable } from './misc.ts';

// Use the vscode langserver page

// Version of vscode-dm-langclient we're pretending to be
const VERSION = '0.1.1';

const BIN_FOLDER = path.resolve(`${__dirname}/../bin`);

const LINUX_BINARY = path.resolve(BIN_FOLDER, 'dm-langserver');
const LINUX_URL = `https://github.com/Metekillot/SpacemanDMM/releases/download/${VERSION}/dm-langserver`;

const WINDOWS_BINARY = path.resolve(BIN_FOLDER, 'dm-langserver.exe');
const WINDOWS_URL = `https://github.com/Metekillot/SpacemanDMM/releases/download/${VERSION}/dm-langserver.exe`;

export async function getServerCommand(): Promise<string> {
  const arch = os.arch();

  if (arch !== 'x64') {
    throw new Error(`${arch} is not supported, only x64 is supported`);
  }

  const platform = os.platform();

  let binary;
  let url;
  if (platform === 'linux') {
    binary = LINUX_BINARY;
    url = LINUX_URL;
  } else if (platform === 'win32') {
    binary = WINDOWS_BINARY;
    url = WINDOWS_URL;
  } else {
    throw new Error(`Platform ${platform} is not supported`);
  }

  if (await is_executable(binary)) {
    console.log('Using binary', binary);
    return binary;
  }

  console.log('Downloading new binary from', url, '...');

  const failure = await auto_update(url, binary);
  if (failure) {
    throw new Error(failure);
  }

  console.log('Using binary', binary);

  return binary;
}

async function auto_update(
  url: string,
  out_file: string,
): Promise<string | undefined> {
  let res;
  try {
    res = await fetch(url);
  } catch (e) {
    // network error
    return `${e}.`;
  }

  switch (res.status) {
    case 200: {
      const file = Bun.file(out_file);
      await Bun.write(file, res);
      await util.promisify(fs.chmod)(out_file, 0o755);

      return;
    }
    default: // Error
      return `Server returned ${res.status} ${res.statusText}.`;
  }
}
