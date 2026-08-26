import * as z from 'zod';

/** Whether this preference is in the character or player section of the save */
export enum PreferenceSavefileIdentifier {
  Character = 'Character',
  Player = 'Player',
}

/** Registry for zod schema storing metadata */
export const preferenceRegistry = z.registry<{
  id: PreferenceSavefileIdentifier;
  type: string;
}>();

/** Useful BYOND type: for typepaths */
export const typepath = z.stringFormat(
  'typepath',
  /^(\/[_a-zA-Z][_a-zA-Z0-9]*)(\/[_a-zA-Z][_a-zA-Z0-9]*)*$/,
);

/** Useful BYOND type: for refs */
export const ref = z.stringFormat('ref', /^\[0x[0-9a-f]+\]$/);

//////////////////////////
// GENERATED CODE START //
//////////////////////////
/*GENERATED*/
//////////////////////////
// GENERATED CODE END   //
//////////////////////////

/** Preferences loaded at runtime via usePreferences */
export type PreferenceDataType = z.infer<typeof PreferenceData>;
/** All valid preference datum typepaths */
export type PreferenceDatumSavefileKey = keyof PreferenceDataType;
/** Constant preference data loaded from JSON */
export type ConstantPreferenceDataType = z.infer<typeof ConstantPreferenceData>;
