export const TAB_CHARACTER = 0;
export const TAB_GAMESETTINGS = 1;
export const TAB_KEYBIND = 2;

export const MAX_CLASS_TUTORIAL_LENGTH = 400;

export const PRONOUN_TO_ICON: Record<string, string> = {
  'he/him': 'mars',
  'she/her': 'venus',
  'they/them': 'mars-and-venus',
  'it/its': 'genderless',
};

export const TITLEPREF_TO_ICON: Record<string, string> = {
  'Lord / Ser': 'mars',
  'Lady / Dame': 'venus',
  // used downstream! Does no harm to keep in the code to avoid merge conflicts.
  'Non-Binary': 'transgender',
};

export const CLOTHESPREF_TO_ICON: Record<string, string> = {
  Masculine: 'mars',
  Feminine: 'venus',
};

export const VOICETYPE_TO_ICON: Record<string, string> = {
  Masculine: 'mars',
  Feminine: 'venus',
  Androgynous: 'transgender',
};
