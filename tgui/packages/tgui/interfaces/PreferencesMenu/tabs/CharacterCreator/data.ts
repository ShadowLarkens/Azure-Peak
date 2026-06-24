import type { Color, Path } from 'pm/data';
import type { BooleanLike } from 'tgui-core/react';

// --------------- AllPagesData ---------------
export type AllPagesData = {
  character_preview_view: string | null; // null indicates error

  real_name: string;
  headshot_link: string | null; // null indicates unset

  pq: TrustedHTML;
  hide_pq: BooleanLike;
  triumphs: number;

  agevet: BooleanLike;
};

// --------------- AppearanceData ---------------
export type AppearanceData = BodyData & FeaturesData & MarkingsData;

export type BodyData = {
  body_type: string | null; // null indicates agender species

  // Appearance stuff
  use_skintones: BooleanLike;
  skin_tone_wording: string;
  body_size: number;

  use_mutcolor: BooleanLike;
  mcolor: Color;
  mcolor2: Color;
  mcolor3: Color;

  // Taur stuff
  taur_type: Path | null;
  taur_name: string;
  taur_color: Color;
  allowed_taur_types: Path[];
};

// Customizers from code/modules/client/customizers
export type FeaturesData = {
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
  colors: AccessoryColor[] | null; // null indicates accessory colors are not allowed
};

export type AccessoryColor = {
  name: string;
  index: number;
  color: Color;
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
  color: Color;
  can_move_up: BooleanLike;
  can_move_down: BooleanLike;
};

// --------------- CharacterSelectData ---------------
export type CharacterSelectData = {
  slot: number;
  slots: Slot[] | null; // null when sharedState "character_select" is FALSE
  favorited_slots: number[];
};

export type Slot = {
  index: number;
  real_name: string | null; // null indicates nonexistent
  topjob: string | null; // null indicates nonexistent
  species: string | null; // null indicates nonexistent
};

// --------------- ClassData ---------------
export type ClassData = {
  joblessrole: string;
  classes: Class[];
};

export type Class = {
  title: string;
  unavailable: ClassAvailability;
  unavailable_details: string;
  spawn_positions: number;
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

// --------------- DescriptorData ---------------
export type DescriptorData = {
  descriptors: Descriptor[];
  descriptors_custom: CustomDescriptor[];
} & ExamineData;

export type Descriptor = {
  name: string;
  type: Path;
  descriptor: string;
};

export type CustomDescriptor = {
  index: number;
  name: string;
  content: string | null; // null means unset
  prefix_display: string | null; // null indicates it is not prefixed
};

export type ExamineData = {
  examine_theme: string | null;
  ooc_extra: string | null; // null indicates unset
  song_artist: string | null; // null indicates unset
  song_title: string | null; // null indicates unset

  img_gallery_len: number;
  nsfw_img_gallery_len: number;

  flavortext: string | null;
  nsfwflavortext: string | null;
  ooc_notes: string | null;
  erpprefs: string | null;

  flavortext_cached: TrustedHTML | null;
  nsfwflavortext_cached: TrustedHTML | null;
  ooc_notes_cached: TrustedHTML | null;
  erpprefs_cached: TrustedHTML | null;
};

// --------------- IdentityData ---------------
export type IdentityData = {
  species_base_name: string;
  species_sub_name: string;
  species_check: BooleanLike;
  race_bonus: string | null; // null indicates no race bonus

  nickname: string | null; // null indicates error
  highlight_color: Color | null; // null indicates error
  age: string;

  pronouns: string;
  titles_pref: string;
  clothes_pref: string;

  statpack_name: string;
  domhand: number | null; // null indicates error
  combat_music: string;
  dnr_pref: BooleanLike;

  virtue_origin: string;
  free_language: string;

  selected_faith: string | null; // null indicates error
  selected_patron: string | null; // null indicates error

  voice_type: string;
  voice_color: Color | null; // null indicates error
  voice_pack: string | null;
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

// --------------- VillainData ---------------
export type VillainData = {
  antag_banned: BooleanLike;

  lich_headshot_link: string | null; // null means unset
  vampire_headshot_link: string | null; // null means unset

  vampire_skin: string | null; // null means unset
  vampire_eyes: string | null; // null means unset
  vampire_hair: string | null; // null means unset
  vampire_ears: string | null; // null means unset

  qsr_pref: BooleanLike;

  preset_bounty_enabled: BooleanLike; // controls showing next three
  preset_bounty_crime: string | null; // null means unset

  bounty_posters: string | null; // null means unset
  wretch_severities: string | null; // null means unset
  bandit_severities: string | null; // null means unset
  vagabond_severities: string | null; // null means unset
};
