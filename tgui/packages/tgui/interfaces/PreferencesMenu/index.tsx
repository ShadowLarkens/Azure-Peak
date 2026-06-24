import { useEffect } from 'react';
import { resolveAsset } from 'tgui/assets';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { logger } from 'tgui/logging';
import { Box, Stack, Tabs } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { useConstantPrefs } from './constant_data';
import { TAB_CHARACTER, TAB_GAMESETTINGS, TAB_KEYBIND } from './constants';
import type { AllPagesData } from './data';
import { CharacterCreator } from './tabs/CharacterCreator';
import { GameSettings } from './tabs/GameSettings';
import { KeyBinds } from './tabs/KeyBinds';

export const PreferencesMenu = (props) => {
  const { config } = useBackend();
  const [, setConstantData] = useConstantPrefs();

  // deny trey liam lol
  const theme =
    config.window?.theme === 'trey_liam'
      ? 'azure_ascendant'
      : config.window.theme;

  useEffect(() => {
    fetchRetry(resolveAsset('preferences.json'))
      .then((response) => response.json())
      .then((data) => {
        setConstantData(data);
      })
      .catch((error) => {
        logger.log('Failed to fetch preferences.json', error);
      });
  }, []);

  return (
    <Window width={1000} height={900} theme={theme}>
      <Window.Content className="PreferencesMenuContent">
        <PreferencesMenuContent />
      </Window.Content>
    </Window>
  );
};

export const PreferencesMenuContent = (props) => {
  const { act, data } = useBackend<AllPagesData>();
  const { current_tab } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            icon="person"
            selected={current_tab === TAB_CHARACTER}
            onClick={() => act('change_tab', { tab: TAB_CHARACTER })}
          >
            Character Sheet
          </Tabs.Tab>
          <Tabs.Tab
            icon="cog"
            selected={current_tab === TAB_GAMESETTINGS}
            onClick={() => act('change_tab', { tab: TAB_GAMESETTINGS })}
          >
            Game Settings
          </Tabs.Tab>
          <Tabs.Tab
            icon="keyboard"
            selected={current_tab === TAB_KEYBIND}
            onClick={() => act('change_tab', { tab: TAB_KEYBIND })}
          >
            Keybinds
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <PreferencesMenuTabs />
      </Stack.Item>
    </Stack>
  );
};

export const PreferencesMenuTabs = (props) => {
  const { data } = useBackend<AllPagesData>();
  const { current_tab } = data;

  switch (current_tab) {
    case TAB_CHARACTER:
      return <CharacterCreator />;
    case TAB_GAMESETTINGS:
      return <GameSettings />;
    case TAB_KEYBIND:
      return <KeyBinds />;
    default:
      return <Box>Invalid preferences tab, please switch...</Box>;
  }
};
