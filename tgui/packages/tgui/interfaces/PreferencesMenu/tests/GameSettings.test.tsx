import { beforeAll, describe, expect, test } from 'bun:test';
import { act, render, screen } from '@testing-library/react';
import { gameDataAtom, store } from 'tgui/events/store';

import { type ConstantData, constantDataAtom } from '../constant_data';
import type { GameSettingsData } from '../data';
import { GameSettings } from '../tabs/GameSettings';

const GAMESETTINGS_DATA: GameSettingsData = {
  tgui_theme: 'TGUI Theme 1',
  parchment_skin: 'Parchment Skin 1',
  statbrowser_theme: 'Statbrowser Theme 1',
  tgui_input: false,
  tgui_lock: false,
  ambientocclusion: true,
  windowflashing: true,
  clientfps: 40,
  auto_fit_viewport: false,
  schizo_voice: true,
  no_storyteller_events: false,
  antags: [
    {
      key: 'Antag1',
      banned: false,
      days_remaining: null,
      enabled: true,
    },
    {
      key: 'Antag2',
      banned: true,
      days_remaining: null,
      enabled: false,
    },
    {
      key: 'Antag3',
      banned: false,
      days_remaining: 4,
      enabled: false,
    },
  ],
  admin_prefs: null,
};

// Same thing but with admin_prefs filled out
const GAMESETTINGS_DATA_ADMIN: GameSettingsData = {
  ...GAMESETTINGS_DATA,
  admin_prefs: {
    sound_adminhelp: false,
    sound_prayers: false,
    announce_login: false,
    combohud_lighting: false,
    show_dsay: false,
    show_prayer: false,
    allow_asaycolor: false,
    asaycolor: null,
    auto_deadmin_players: false,
    deadmin_player: false,
    auto_deadmin_antagonists: false,
    deadmin_antagonist: false,
    auto_deadmin_heads: false,
    deadmin_head: false,
  },
};

const CONST_DATA: ConstantData = {
  classes: {},
  MAX_KEYS_PER_KEYBIND: 3,
  MINIMUM_FLAVOR_TEXT: 0,
  MINIMUM_OOC_NOTES: 0,
  MAX_VICES: 3,
  tgui_themes: {},
};

store.set(constantDataAtom, CONST_DATA);

describe('GameSettings Page Tests (User)', () => {
  beforeAll(() => {
    store.set(gameDataAtom, GAMESETTINGS_DATA);
  });

  test('Admin preferences is hidden when user is not an admin', () => {
    act(() => render(<GameSettings />));
    expect(screen.queryByText('Admin')).toBeNull();
  });
});

describe('GameSettings Page Tests (Admin)', () => {
  beforeAll(() => {
    store.set(gameDataAtom, GAMESETTINGS_DATA_ADMIN);
  });

  test('Admin preferences is not hidden when user is an admin', () => {
    act(() => render(<GameSettings />));
    expect(screen.getByText('Admin')).toBeDefined();
  });
});
