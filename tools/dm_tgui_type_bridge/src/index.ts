import path from 'node:path';
import ansis from 'ansis';
import { resolveLocationToEOL } from './helpers.ts';
import { type DMLSPClient, type DMObject, startDmLSP } from './langclient.ts';

/**
 * flat traversal of all children
 */
const getChildrenRecursive = (object: DMObject): DMObject[] => {
  let array = [object];
  for (const child of object.children) {
    array = array.concat(getChildrenRecursive(child));
  }
  return array;
};

/**
 * Gets the object tree recursively starting at path
 * but then flattens it into a list instead of a tree
 */
const flatObjectTree = async (
  client: DMLSPClient,
  path: string,
): Promise<DMObject[]> => {
  const object = await client.queryObjectTreeRecursive(path);
  return getChildrenRecursive(object);
};

/**
 * Traverses the tree upwards to find a variable value
 * @returns the value or null if it wasn't found
 */
const getVariableValue = async (
  objtree: DMObject[],
  target: DMObject,
  variable: string,
) => {
  const v = target.vars.find((v) => v.name === variable);
  if (v) {
    let value = await resolveLocationToEOL(v.location);
    const no_eq = /^\s*=\s*(.*)/.exec(value);
    if (no_eq) {
      value = no_eq[1]!.trim();
    }
    return value;
  }

  const parentName = target.name.substring(0, target.name.lastIndexOf('/'));
  const parent = objtree.find((v) => v.name === parentName);
  if (!parent) {
    return null;
  }

  return getVariableValue(objtree, parent, variable);
};

enum SavefileIdentifier {
  Player = 'Player',
  Character = 'Character',
}

type Pref = {
  name: string;
  savefile_key: string;
  savefile_identifier: SavefileIdentifier;
  zod_schema: string;
  zod_schema_constant?: string;
};

const getValidPrefs = async (client: DMLSPClient): Promise<Pref[]> => {
  const validPrefs = [];
  const allPrefs = await flatObjectTree(client, '/datum/preference');

  for (const pref of allPrefs) {
    const abstract_type = await getVariableValue(
      allPrefs,
      pref,
      'abstract_type',
    );
    if (pref.name === abstract_type) {
      // console.info('Skipping abstract type', pref.name);
      continue;
    }

    let savefile_key = await getVariableValue(allPrefs, pref, 'savefile_key');
    if (!savefile_key) {
      // console.info('Skipping type with no savefile_key', pref.name);
      continue;
    }

    const savefile_identifier = await getVariableValue(
      allPrefs,
      pref,
      'savefile_identifier',
    );
    if (!savefile_identifier) {
      // console.info('Skipping type with no savefile_identifier', pref.name);
      continue;
    }

    let zod_schema = await getVariableValue(allPrefs, pref, 'zod_schema');
    if (!zod_schema) {
      continue;
    }

    let zod_schema_constant = await getVariableValue(
      allPrefs,
      pref,
      'zod_schema_constant',
    );
    if (!zod_schema_constant) {
      zod_schema_constant = '""';
    }

    // Eat the quotes
    savefile_key = savefile_key.substring(1, savefile_key.length - 1);
    zod_schema = zod_schema.substring(1, zod_schema.length - 1);
    zod_schema_constant = zod_schema_constant.substring(
      1,
      zod_schema_constant.length - 1,
    );

    // Templating support
    zod_schema_constant = zod_schema_constant.replaceAll(
      '%SAVEFILE_KEY%',
      savefile_key,
    );

    let identEnum: SavefileIdentifier;
    if (savefile_identifier === 'PREFERENCE_PLAYER') {
      identEnum = SavefileIdentifier.Player;
    } else if (savefile_identifier === 'PREFERENCE_CHARACTER') {
      identEnum = SavefileIdentifier.Character;
    } else {
      throw new Error(
        `Unrecognized savefile_identifier: ${savefile_identifier}`,
      );
    }

    validPrefs.push({
      name: pref.name,
      savefile_key,
      savefile_identifier: identEnum,
      zod_schema,
      zod_schema_constant: zod_schema_constant.length
        ? zod_schema_constant
        : undefined,
    });
  }

  return validPrefs;
};

export const REPO_ROOT = path.resolve(__dirname, '..', '..', '..');
const BINDINGS_FILE = path.resolve(
  REPO_ROOT,
  'tgui',
  'packages',
  'common',
  'preferences_bindings.ts',
);

let TEMPLATE: string | undefined;
const generateTypescript = async (prefs: Pref[]) => {
  if (!TEMPLATE) {
    const file = Bun.file(path.resolve(__dirname, '_template.ts'));
    TEMPLATE = await file.text();
  }

  // Text to be inserted at /*GENERATED*/
  let GENERATED = '';

  // Generate the zod schema
  GENERATED +=
    '\n/** Zod schema for all savefile keys */\nexport const PreferenceData = z.object({\n';
  for (const pref of prefs) {
    GENERATED += `  '${pref.savefile_key}': (${pref.zod_schema}).register(preferenceRegistry, { id: PreferenceSavefileIdentifier.${
      pref.savefile_identifier === SavefileIdentifier.Character
        ? 'Character'
        : 'Player'
    }, type: '${pref.name}' }),\n`;
  }
  GENERATED += '}).partial();\n';

  // Generate the constant zod schema
  GENERATED +=
    '\n\n/** Zod schema for the constant data JSON */\nexport const ConstantPreferenceData = z.object({\n';
  for (const pref of prefs) {
    if (pref.zod_schema_constant) {
      GENERATED += `  ...(${pref.zod_schema_constant}).shape,\n`;
    }
  }
  GENERATED += '});\n';

  // Generate a list of all valid paths
  GENERATED +=
    '\n/** All valid preference datum typepaths */\nexport type PreferenceDatumPath = ';
  GENERATED += prefs.map((p) => `'${p.name}'`).join(' | ');
  GENERATED += ';\n';

  // Generate a mapping of path -> savefile_key
  GENERATED +=
    '\n/** Mapping from preference datum to its savefile key */\nexport const PATH_TO_SAVEFILE_KEY = {\n';
  for (const pref of prefs) {
    GENERATED += `  '${pref.name}': '${pref.savefile_key}',\n`;
  }
  GENERATED +=
    '} as const satisfies Record<PreferenceDatumPath, PreferenceDatumSavefileKey>;\n';

  // Generate a mapping of savefile_key -> path
  GENERATED +=
    '\n/** Mapping from savefile key to preference datum */\nexport const SAVEFILE_KEY_TO_PATH = {\n';
  for (const pref of prefs) {
    GENERATED += `  '${pref.savefile_key}': '${pref.name}',\n`;
  }
  GENERATED +=
    '} as const satisfies Record<PreferenceDatumSavefileKey, PreferenceDatumPath>;\n';

  // Generate a mapping of path -> savefile_identifier
  GENERATED +=
    '\n/** Mapping of preference datum to savefile identifier (character/player) */\nexport const PATH_TO_IDENT = {\n';
  for (const pref of prefs) {
    GENERATED += `  '${pref.name}': PreferenceSavefileIdentifier.`;
    GENERATED +=
      pref.savefile_identifier === SavefileIdentifier.Character
        ? 'Character'
        : 'Player';
    GENERATED += ',\n';
  }
  GENERATED +=
    '} as const satisfies Record<PreferenceDatumPath, PreferenceSavefileIdentifier>;\n';

  // Write template result document
  Bun.write(BINDINGS_FILE, TEMPLATE.replace('/*GENERATED*/', GENERATED));
};

/**
 * The magic happens here!~ ✨ <- not AI btw I just wanted to shitpost
 */
async function main() {
  console.log('Operating on repo', REPO_ROOT);

  const dmLSP = await startDmLSP();
  if (!dmLSP) {
    console.error('Unable to start LSP.');
    return;
  }

  const { child, client } = dmLSP;
  // tell it we're ready or it'll never answer our calls
  client.notify('initialized', {});

  // Actual meat of the program
  const validPrefs = await getValidPrefs(client);

  console.log('Generating types for', validPrefs.length, 'preferences...');
  await generateTypescript(validPrefs);

  const bindings_url = `file://${path.resolve(BINDINGS_FILE, '..')}`;
  console.log('Generated', ansis.green.link(bindings_url, BINDINGS_FILE));
  console.log(
    // "Generated" + (skip the repo directory) + 1 (so the cursor is on a character, not a slash)
    `${' '.repeat(10 + REPO_ROOT.length + 1)}${ansis.greenBright.link(bindings_url, '^--- View generated bindings')}`,
  );

  // Destroy The Child
  child.kill();
}

main();
