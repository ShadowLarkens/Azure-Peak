import {
  PATH_TO_SAVEFILE_KEY,
  PreferenceData,
  type PreferenceDataType,
  type PreferenceDatumPath,
  type PreferenceDatumSavefileKey,
} from 'common/preferences_bindings';
import { useEffect, useMemo } from 'react';
import { useBackendStrict } from 'tgui/backend';
import { sendAct } from 'tgui/events/act';

// UI state of all currently required prefs
const CURRENTLY_REQUIRED_PREFS: Partial<Record<PreferenceDatumPath, number>> =
  {};

const preferenceSessionId = crypto.randomUUID();

let clientRevision = 0;

let lastRequestedPrefs = new Set<PreferenceDatumPath>();

const getRequestedPrefs = (): Set<PreferenceDatumPath> => {
  return new Set(
    Object.keys(CURRENTLY_REQUIRED_PREFS) as PreferenceDatumPath[],
  );
};

const sameSet = <T>(a: Set<T>, b: Set<T>): boolean => {
  return a.size === b.size && a.values().every((value) => b.has(value));
};

// TODO: test how long mounting actually takes and adjust this
const DEBOUNCE_MS = 20;
let debounceTimer: ReturnType<typeof setTimeout> | undefined;

const updateRequestedPrefs = () => {
  if (debounceTimer !== undefined) {
    clearTimeout(debounceTimer);
  }

  debounceTimer = setTimeout(() => {
    debounceTimer = undefined;

    const next = getRequestedPrefs();

    if (sameSet(lastRequestedPrefs, next)) {
      return;
    }

    lastRequestedPrefs = new Set(next);
    clientRevision += 1;

    sendAct('update_requested_prefs', {
      session_id: preferenceSessionId,
      client_revision: clientRevision,
      requested_prefs: [...next],
    });
  }, DEBOUNCE_MS);
};

// Advanced typescript nonsense
type PreferenceKeyForPath<P> = P extends PreferenceDatumPath
  ? (typeof PATH_TO_SAVEFILE_KEY)[P]
  : never;

type RequiredKey<R extends readonly PreferenceDatumPath[]> = Extract<
  PreferenceKeyForPath<R[number]>,
  PreferenceDatumSavefileKey
>;

type RequiredMask<R extends readonly PreferenceDatumPath[]> = {
  [K in RequiredKey<R>]: true;
};

// The actual data
type Data = {
  prefs_revision: number;
  datumized: PreferenceDataType;
};

export const usePreferences = <const R extends readonly PreferenceDatumPath[]>(
  required: R,
) => {
  const { data } = useBackendStrict<Data>();

  // Stable as long as teh contents and order of required are unchanged.
  const requiredKey = required.join('');

  const uniqueRequired = useMemo(() => [...new Set(required)], [requiredKey]);

  const requiredShape = useMemo(() => {
    return Object.fromEntries(
      uniqueRequired.map((path) => [PATH_TO_SAVEFILE_KEY[path], true]),
    ) as RequiredMask<R>;
  }, [uniqueRequired]);

  const schema = useMemo(() => {
    return PreferenceData.pick<RequiredMask<R>>(
      // Zod's Typescript definition isn't QUITE complex enough to handle this
      requiredShape as never,
    ).required();
  }, [requiredShape]);

  useEffect(() => {
    for (const path of required) {
      CURRENTLY_REQUIRED_PREFS[path] =
        (CURRENTLY_REQUIRED_PREFS[path] ?? 0) + 1;
    }

    updateRequestedPrefs();

    return () => {
      for (const path of required) {
        const count = CURRENTLY_REQUIRED_PREFS[path];

        if (count === undefined || count <= 1) {
          delete CURRENTLY_REQUIRED_PREFS[path];
        } else {
          CURRENTLY_REQUIRED_PREFS[path] = count - 1;
        }
      }

      updateRequestedPrefs();
    };
  }, [requiredKey]);

  const result = useMemo(() => {
    return schema.safeParse(data.datumized);
  }, [schema, data.datumized]);

  // TODO: figure out a good way to tell devs about the errors!
  // Just have to be careful that null/not yet updated does NOT print errors
  if (!result.success) {
    for (const issue of result.error.issues) {
      // Ignore these, they happen when we are in the middle of switching to a new set of requested prefs
      if (issue.code === 'invalid_type' && issue.expected === 'nonoptional') {
        continue;
      }

      console.error('Zod validation error:', issue);
    }
    return null;
  }

  return result.data;
};
