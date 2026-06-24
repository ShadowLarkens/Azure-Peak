import { Suspense, useEffect, useState } from 'react';
import { resolveAsset } from 'tgui/assets';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { logger } from 'tgui/logging';
import { Box, Stack, Tabs } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { LoadingScreen } from '../common/LoadingScreen';
import { ConstantData, ConstantDataContext } from './constant_data';
import { TAB_CHARACTER, TAB_GAMESETTINGS, TAB_KEYBIND } from './constants';
import { AllPagesData } from './data';
import { CharacterSheet } from './tabs/CharacterSheet';
import { GameSettings } from './tabs/GameSettings';
import { KeyBinds } from './tabs/KeyBinds';

export const CharacterSetup = (props) => {
  const { config } = useBackend();

  // deny trey liam lol
  const theme =
    config.window?.theme === 'trey_liam'
      ? 'azure_ascendant'
      : config.window.theme;

  return (
    <Window width={1000} height={900} theme={theme}>
      <Window.Content className="CharacterSetupContent">
        <Suspense fallback={<LoadingScreen />}>
          <ConstantDataLoader />
        </Suspense>
      </Window.Content>
    </Window>
  );
};

export const ConstantDataLoader = (props) => {
  const [constantData, setConstantData] = useState<ConstantData>();

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
    <ConstantDataContext value={constantData}>
      <CharacterSetupContent />
    </ConstantDataContext>
  );
};

export const CharacterSetupContent = (props) => {
  const { act, data } = useBackend<AllPagesData>();
  const { current_tab } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            selected={current_tab === TAB_CHARACTER}
            onClick={() => act('change_tab', { tab: TAB_CHARACTER })}
          >
            Character Sheet
          </Tabs.Tab>
          <Tabs.Tab
            selected={current_tab === TAB_GAMESETTINGS}
            onClick={() => act('change_tab', { tab: TAB_GAMESETTINGS })}
          >
            Game Settings
          </Tabs.Tab>
          <Tabs.Tab
            selected={current_tab === TAB_KEYBIND}
            onClick={() => act('change_tab', { tab: TAB_KEYBIND })}
          >
            Keybinds
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <CharacterSetupTabs />
      </Stack.Item>
    </Stack>
  );
};

export const CharacterSetupTabs = (props) => {
  const { data } = useBackend<AllPagesData>();
  const { current_tab } = data;

  switch (current_tab) {
    case TAB_CHARACTER:
      return <CharacterSheet />;
    case TAB_GAMESETTINGS:
      return <GameSettings />;
    case TAB_KEYBIND:
      return <KeyBinds />;
    default:
      return <Box>Invalid preferences tab, please switch...</Box>;
  }
};
