import { LinesAndColumns, type SourceLocation } from 'lines-and-columns';
import type { Location, Position } from 'vscode-languageserver-protocol';

const convertPosition = (p: Position): SourceLocation => {
  return { column: p.character, line: p.line };
};

export const resolveLocationToEOL = async (location: Location) => {
  const doc = Bun.file(Bun.fileURLToPath(location.uri));
  const text = await doc.text();

  const lines = new LinesAndColumns(text);
  const endOfRange = convertPosition(location.range.end);
  const idx = lines.indexForLocation(endOfRange)!;
  const first_chop = text.substring(idx);

  let nextNewline;
  const match = /\r|\n/.exec(first_chop);
  if (match) {
    nextNewline = match.index;
  }

  return first_chop.substring(0, nextNewline);
};
