import { useEffect } from 'react';
import { resolveAsset } from 'tgui/assets';
import { useBackend } from 'tgui/backend';
import { dragStartHandler } from 'tgui/drag';
import { suspendStart } from 'tgui/events/handlers/suspense';
import { Window } from 'tgui/layouts';
import { TitleBar } from 'tgui/layouts/TitleBar';
import { logger } from 'tgui/logging';
import { Box, Icon, Stack, Tabs } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { useConstantPrefs } from './constant_data';
import { TAB_CHARACTER, TAB_GAMESETTINGS, TAB_KEYBIND } from './constants';
import type { AllPagesData } from './data';
import { CharacterSheet } from './tabs/CharacterSheet';
import { GameSettings } from './tabs/GameSettings';
import { KeyBinds } from './tabs/KeyBinds';

export const CharacterSetup = (props) => {
  useEffect(() => {
    Byond.winset(Byond.windowId, { 'background-color': '#ff0000' });
    Byond.winset(Byond.windowId, { 'transparent-color': '#ff0000' });
    Byond.winset(`${Byond.windowId}.browser`, {
      'inner-background-color': 'transparent',
    });
    document.body.style = 'background-color: rgba(0, 0, 0, 0)';
  }, []);

  return (
    <Box style={{ border: '2px solid #ff0000', borderRadius: '4px' }}>
      <Stack vertical>
        <Stack.Item>
          <TitleBar
            title="Transparent Window"
            onDragStart={dragStartHandler}
            onClose={suspendStart}
            canClose={true}
          />
        </Stack.Item>
        <Stack.Item>
          <Box height={10}>
            <Stack align="center" justify="center" fill>
              <Stack.Item>
                <Icon name="toolbox" color="blue" spin size={4} />
              </Stack.Item>
            </Stack>
          </Box>
        </Stack.Item>
        <Stack.Item>
          This is a popup browser window with no background!
        </Stack.Item>
      </Stack>
    </Box>
  );
};

export const CharacterSetupReal = (props) => {
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
      <Window.Content className="CharacterSetupContent">
        <CharacterSetupContent />
      </Window.Content>
    </Window>
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
