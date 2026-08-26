//! Almost entirely taken from https://github.com/SpaceManiac/vscode-dm-langclient/blob/master/src/misc.ts
import crypto from "node:crypto";
import fs from "node:fs";
import util from "node:util";

export async function is_executable(path: string): Promise<boolean> {
	try {
		await util.promisify(fs.access)(path, fs.constants.R_OK | fs.constants.X_OK);
		return true;
	} catch (e) {
		return false;
	}
}

export async function md5_file(path: string): Promise<string> {
  const hash = crypto.createHash("md5");

  const stream = fs.createReadStream(path);

  for await (const chunk of stream) {
    hash.update(chunk as Buffer);
  }

  return hash.digest("hex");
}
