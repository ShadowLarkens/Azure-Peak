import { BooleanLike } from 'tgui-core/react';

import { Path } from '../../data';

/* INSTRUCTIONS FOR DOWNSTREAM:
In a new .ts file add:
import { CharacterSheetData } from "./data.ts";
export type CharacterSheetDataDownstream = CharacterSheetData & {
  new data...
}
*/

export type CharacterSheetData = CharacterSelectData &
  BasicCharacterData &
  IdentityData &
  BodyData &
  ExamineData &
  CustomizersData &
  MarkingsData &
  DescriptorData &
  ClassData &
  VillainData;

export type CharacterSelectData = {
  slot: number;
  slots: Slot[] | null; // null when sharedState "character_select" is FALSE
  favorited_slots: number[];
};

export type Slot = {
  index: number;
  real_name: string | null;
  topjob: string;
  species: string;
};

export type BasicCharacterData = {
  character_preview_view: string | null;

  real_name: string;
  headshot_link: string | null;

  pq: TrustedHTML;
  hide_pq: BooleanLike;
  triumphs: number;

  agevet: BooleanLike;
};

export type IdentityData = {
  nickname: string;
  highlight_color: string;

  pronouns: string;
  titles_pref: string;
  clothes_pref: string;

  virtue_origin: string;
  free_language: string;
  statpack_name: string;
  age: string;

  domhand: number;
  combat_music: string;
  dnr_pref: BooleanLike;

  selected_faith: string | null; // null indicates error
  selected_patron: string | null; // null indicates error

  voice_type: string;
  voice_color: string;
  voice_pack: string;
  voice_pitch: number;

  bark_id: string;
  bark_name: string | null; // null indicates bad bark_id
  bark_speed: number;
  bark_pitch: number;
  bark_variance: number;

  virtue: Virtue;
  virtue2: Virtue | null; // null indicates we're not on a virtuous statpack

  charflaws: CharFlaw[]; // look at constant.MAX_VICES
  has_averse: BooleanLike;
  averse_chosen_faction: string;
};

export type Virtue = {
  name: string;
  picked_choices: VirtueChoice[]; // note: may be length less than max_choices, show add button in that case
  max_choices: number;
  next_cost: number;
  tricost: number;
};

export type VirtueChoice = {
  index: number;
  choice: string;
  tooltip: string | null;
};

export type CharFlaw = {
  index: number;
  name: string;
  warning: BooleanLike;
};

export type BodyData = {
  body_type: string | null; // null indicates agender species

  species_base_name: string;
  species_sub_name: string;
  species_check: BooleanLike;
  race_bonus: string | null; // null indicates no race bonus

  // Taur stuff
  taur_type: Path;
  taur_name: string;
  taur_color: string;
  allowed_taur_types: Path[];

  // Appearance stuff
  use_skintones: BooleanLike;
  skin_tone_wording: string;
  body_size: number;

  use_mutcolor: BooleanLike;
  mcolor: string;
  mcolor2: string;
  mcolor3: string;
};

export type ExamineData = {
  examine_theme: string;
  ooc_extra: string | null; // null indicates unset
  song_artist: string | null; // null indicates unset
  song_title: string | null; // null indicates unset

  img_gallery_len: number;
  nsfw_img_gallery_len: number;

  flavortext: string;
  nsfwflavortext: string;
  ooc_notes: string;
  erpprefs: string;

  flavortext_cached: TrustedHTML | null;
  nsfwflavortext_cached: TrustedHTML | null;
  ooc_notes_cached: TrustedHTML | null;
  erpprefs_cached: TrustedHTML | null;
};

// Customizers from code/modules/client/customizers
export type CustomizersData = {
  customizers: Customizer[];
};

export type Customizer = {
  name: string;
  type: Path;
  disabled: BooleanLike;
  allows_disabling: BooleanLike;
  customizer_choices_enabled: BooleanLike;
  choices: CustomizerChoice;
};

export interface CustomizerChoice {
  template: string;
  name: string;
  accessory: Accessory | null;
}

export type Accessory = {
  name: string;
  show_accessory_color: BooleanLike;
  colors: AccessoryColor[];
};

export type AccessoryColor = {
  name: string;
  index: number;
  color: string;
};

// MARKINGS
export type MarkingsData = {
  markings: Marking[];
};

export type Marking = {
  zone: string;
  name: string;
  may_add: BooleanLike;
  keys: MarkingKey[] | null; // null signifies no markings data at all; order matters
};

export type MarkingKey = {
  key: string;
  color: string;
  can_move_up: BooleanLike;
  can_move_down: BooleanLike;
};

// DESCRIPTORS
export type DescriptorData = {
  descriptors: Descriptor[];
  descriptors_custom: CustomDescriptor[];
};

export type Descriptor = {
  name: string;
  type: Path;
  descriptor: string;
};

export type CustomDescriptor = {
  index: number;
  translation: string;
  descriptor: string;
};

// CLASSES
export type ClassData = {
  joblessrole: string;
  classes: Class[];
};

export type Class = {
  title: string;
  unavailable: ClassAvailability;
  unavailable_details: string;
  spawn_positions: number;
  total_positions: number;
  pref: ClassPreference | null; // null means "NEVER"
};

export enum ClassAvailability {
  AVAILABLE = 0,
  UNAVAILABLE_GENERIC = 1,
  UNAVAILABLE_BANNED = 2,
  UNAVAILABLE_PLAYTIME = 3,
  UNAVAILABLE_ACCOUNTAGE = 4,
  UNAVAILABLE_PATRON = 5,
  UNAVAILABLE_RACE = 6,
  UNAVAILABLE_SEX = 7,
  UNAVAILABLE_AGE = 8,
  UNAVAILABLE_WTEAM = 9,
  UNAVAILABLE_LASTCLASS = 10,
  UNAVAILABLE_JOB_COOLDOWN = 11,
  UNAVAILABLE_SLOTFULL = 12,
  UNAVAILABLE_VIRTUESVICE = 13,
  UNAVAILABLE_PQ = 14,
}

export const CLASSAVAIL_NAME = {
  [ClassAvailability.AVAILABLE]: '',
  [ClassAvailability.UNAVAILABLE_GENERIC]: 'Unavailable',
  [ClassAvailability.UNAVAILABLE_BANNED]: 'BANNED',
  [ClassAvailability.UNAVAILABLE_PLAYTIME]: 'Playtime Too Low',
  [ClassAvailability.UNAVAILABLE_ACCOUNTAGE]: 'Account Too Young',
  [ClassAvailability.UNAVAILABLE_PATRON]: 'Patron Locked',
  [ClassAvailability.UNAVAILABLE_RACE]: 'Race Locked',
  [ClassAvailability.UNAVAILABLE_SEX]: 'Sex Locked',
  [ClassAvailability.UNAVAILABLE_AGE]: 'Age Locked',
  [ClassAvailability.UNAVAILABLE_WTEAM]: 'WTEAM',
  [ClassAvailability.UNAVAILABLE_LASTCLASS]: 'Played Recently',
  [ClassAvailability.UNAVAILABLE_JOB_COOLDOWN]: 'Respawn Delay',
  [ClassAvailability.UNAVAILABLE_SLOTFULL]: 'Slot Full',
  [ClassAvailability.UNAVAILABLE_VIRTUESVICE]: 'Virtue/Vice Locked',
  [ClassAvailability.UNAVAILABLE_PQ]: 'PQ',
};

export const CLASSAVAIL_COLOR = {
  [ClassAvailability.AVAILABLE]: '',
  [ClassAvailability.UNAVAILABLE_GENERIC]: '#a59461',
  [ClassAvailability.UNAVAILABLE_BANNED]: '#a70202',
  [ClassAvailability.UNAVAILABLE_PLAYTIME]: '#a59461',
  [ClassAvailability.UNAVAILABLE_ACCOUNTAGE]: '#a59461',
  [ClassAvailability.UNAVAILABLE_PATRON]: '#a59461',
  [ClassAvailability.UNAVAILABLE_RACE]: '#a59461',
  [ClassAvailability.UNAVAILABLE_SEX]: '#a59461',
  [ClassAvailability.UNAVAILABLE_AGE]: '#a59461',
  [ClassAvailability.UNAVAILABLE_WTEAM]: '#a59461',
  [ClassAvailability.UNAVAILABLE_LASTCLASS]: '#a59461',
  [ClassAvailability.UNAVAILABLE_JOB_COOLDOWN]: '#a59461',
  [ClassAvailability.UNAVAILABLE_SLOTFULL]: '#6d6d6c',
  [ClassAvailability.UNAVAILABLE_VIRTUESVICE]: '#a59461',
  [ClassAvailability.UNAVAILABLE_PQ]: '#a59461',
};

export enum ClassPreference {
  JP_LOW = 1,
  JP_MEDIUM = 2,
  JP_HIGH = 3,
}

// VILLAINS
export type VillainData = {
  antag_banned: BooleanLike;
  lich_headshot_link: string;
  vampire_headshot_link: string;
  vampire_skin: string;
  vampire_eyes: string;
  vampire_hair: string;
  vampire_ears: string;
  qsr_pref: BooleanLike;
  preset_bounty_enabled: BooleanLike; // controls showing next three
  bounty_posters: string | null; // null means unset
  wretch_severities: string | null; // null means unset
  bandit_severities: string | null; // null means unset
  preset_bounty_crime: string | null;
};
