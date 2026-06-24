import { describe, expect, test } from 'bun:test';
import { act, render, screen, within } from '@testing-library/react';
import { gameDataAtom, store } from 'tgui/events/store';

import { type ConstantData, constantDataAtom } from '../constant_data';
import type { KeybindsPageData } from '../data';
import { KeyBinds } from '../tabs/KeyBinds';

const KEYBIND_DATA: KeybindsPageData = {
  keybindings: [
    {
      full_name: 'Move Forward',
      name: 'Move Forward',
      default_keys: null,
      user_binds: ['UniqueKey1'],
    },
    {
      full_name: 'Move Backwards',
      name: 'Move Backwards',
      default_keys: null,
      user_binds: ['UniqueKey2', 'UniqueKey3', 'UniqueKey4'],
    },
    {
      full_name: 'Move Upwards',
      name: 'Move Upwards',
      default_keys: null,
      user_binds: null,
    },
  ],
};

store.set(gameDataAtom, KEYBIND_DATA);

const CONST_DATA: ConstantData = {
  classes: {},
  MAX_KEYS_PER_KEYBIND: 3,
  MINIMUM_FLAVOR_TEXT: 0,
  MINIMUM_OOC_NOTES: 0,
  MAX_VICES: 3,
  tgui_themes: {},
};

store.set(constantDataAtom, CONST_DATA);

describe('Keybind Page Tests', () => {
  test('loads without failing', () => {
    act(() => render(<KeyBinds />));

    expect(screen.getByText('Keybinds')).toBeDefined();
  });

  test('displays all keybindings', () => {
    act(() => render(<KeyBinds />));

    for (const keybind of KEYBIND_DATA.keybindings) {
      expect(screen.getByText(`${keybind.full_name}:`)).toBeDefined();
    }
  });

  test('displays all keys set', () => {
    act(() => render(<KeyBinds />));

    for (const keybind of KEYBIND_DATA.keybindings) {
      for (const key of keybind.user_binds || []) {
        expect(screen.getByText(key)).toBeDefined();
      }
    }
  });

  test('only displays unbound button when unbound', () => {
    act(() => render(<KeyBinds />));

    for (const keybind of KEYBIND_DATA.keybindings) {
      const unboundPresent = !!within(
        screen.getByText(`${keybind.full_name}:`).parentElement!,
      ).queryByText('Unbound');

      if (keybind.user_binds?.length) {
        expect(unboundPresent).toBeFalse();
      } else {
        expect(unboundPresent).toBeTrue();
      }
    }
  });

  test('only displays add button when 0 < binds.length < MAX_KEYS_PER_KEYBIND', () => {
    act(() => render(<KeyBinds />));

    for (const keybind of KEYBIND_DATA.keybindings) {
      const addButtonPresent = !!within(
        screen.getByText(`${keybind.name}:`).parentElement!,
      ).queryByText('Add Secondary');
      const length = keybind.user_binds?.length || 0;

      if (0 < length && length < CONST_DATA.MAX_KEYS_PER_KEYBIND) {
        expect(addButtonPresent).toBeTrue();
      } else {
        expect(addButtonPresent).toBeFalse();
      }
    }
  });
});
