import { BooleanLike } from 'tgui-core/react';

export type Path = string;

export type AllPagesData = {
  current_tab: number;
};

export type GamePreferencesData = {
  tgui_theme: string;
  parchment_skin: string;
  statbrowser_theme: string;
  tgui_input: BooleanLike;
  tgui_lock: BooleanLike;
  ambientocclusion: BooleanLike;
  windowflashing: BooleanLike;
  clientfps: number;
  auto_fit_viewport: BooleanLike;
  schizo_voice: BooleanLike;
  no_storyteller_events: BooleanLike;
  antags: Antag[];
};

export type Antag = {
  key: string; // remember to capitalize for display!
  banned: BooleanLike;
  days_remaining: number | null;
  enabled: BooleanLike;
};
