import { HeadshotButton, SaveUndo } from 'pm/components';
import { useBackend, useSharedState } from 'tgui/backend';
import {
  Box,
  Button,
  ByondUi,
  Dimmer,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { CharacterSelect } from './CharacterCreator/CharacterSelect';
import type { AllPagesData } from './CharacterCreator/data';
import { SubtabAppearance } from './CharacterCreator/subtabs/Appearance';
import { SubtabClass } from './CharacterCreator/subtabs/Class';
import { SubtabDescriptors } from './CharacterCreator/subtabs/Descriptors';
import { SubtabIdentity } from './CharacterCreator/subtabs/Identity';
import { SubtabVillain } from './CharacterCreator/subtabs/Villains';

enum Subtab {
  IDENTITY = 0,
  APPEARANCE = 1,
  DESCRIPTORS = 2,
  CLASS = 3,
  VILLAIN = 4,
}

export const CharacterCreator = (props) => {
  const [subtab, setSubtab] = useSharedState(
    'charactersheetsubtab',
    Subtab.IDENTITY,
  );

  const [cs, setCs] = useSharedState('character_select', false);

  return (
    <Stack fill>
      {cs ? (
        <Dimmer>
          <CharacterSelect setCs={setCs} />
        </Dimmer>
      ) : null}
      {subtab !== Subtab.CLASS ? <Sidebar cs={cs} setCs={setCs} /> : null}
      <Stack.Item grow>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="address-card"
                selected={subtab === Subtab.IDENTITY}
                onClick={() => setSubtab(Subtab.IDENTITY)}
              >
                Identity
              </Tabs.Tab>
              <Tabs.Tab
                icon="person-rays"
                selected={subtab === Subtab.APPEARANCE}
                onClick={() => setSubtab(Subtab.APPEARANCE)}
              >
                Appearance
              </Tabs.Tab>
              <Tabs.Tab
                icon="note-sticky"
                selected={subtab === Subtab.DESCRIPTORS}
                onClick={() => setSubtab(Subtab.DESCRIPTORS)}
              >
                Descriptors
              </Tabs.Tab>
              <Tabs.Tab
                icon="dungeon"
                selected={subtab === Subtab.CLASS}
                onClick={() => setSubtab(Subtab.CLASS)}
              >
                Class
              </Tabs.Tab>
              <Tabs.Tab
                icon="skull"
                selected={subtab === Subtab.VILLAIN}
                onClick={() => setSubtab(Subtab.VILLAIN)}
              >
                Villain
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <CharacterSheetSubtab subtab={subtab} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const Sidebar = (props: {
  cs: boolean;
  setCs: (nextState: boolean) => void;
}) => {
  const { cs, setCs } = props;
  const { act, data } = useBackend<AllPagesData>();

  return (
    <Stack.Item width="172px" mr={2} mt={1}>
      <Stack vertical fill>
        <Stack.Item>
          <Button onClick={() => setCs(true)} icon="person" fluid>
            Change Character
          </Button>
        </Stack.Item>
        <Stack.Item mb={3} />
        <Stack.Item fontSize={1.2} style={{ wordBreak: 'break-all' }}>
          {data.real_name}
        </Stack.Item>
        <Stack.Item height="192px" width="172px">
          {data.character_preview_view && !cs ? (
            <ByondUi
              params={{
                id: data.character_preview_view,
                type: 'map',
              }}
              height="192px"
              width="172px"
            />
          ) : (
            <Box position="relative">
              {/* Stand in for preview */}
              <Box
                position="absolute"
                backgroundColor="black"
                height="192px"
                width="172px"
              />
              <Box position="absolute" top={6} left={6}>
                YCH
              </Box>
            </Box>
          )}
        </Stack.Item>
        <Stack.Item mb={2}>
          <Stack>
            <Stack.Item grow>
              <Stack align="center" justify="center">
                <Stack.Item>
                  <HeadshotButton
                    action="headshot"
                    link={data.headshot_link}
                    subtitle="Headshot"
                    tooltip="Optional headshot image that will be shown to other players in the examine panel and chat."
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item>
                  <Button
                    onClick={() => act('rotate_character_preview')}
                    icon="rotate-right"
                    tooltip="Rotate"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => act('refresh_character_preview')}
                    icon="refresh"
                    tooltip="Refresh"
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {data.hide_pq ? null : (
          <Stack.Item>
            <Button
              icon="person-circle-check"
              onClick={() => act('playerquality')}
              fluid
            >
              PQ: <span dangerouslySetInnerHTML={{ __html: data.pq }} />
            </Button>
          </Stack.Item>
        )}
        <Stack.Item>
          <Button icon="trophy" onClick={() => act('triumphs')} fluid>
            Triumphs: {data.triumphs}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button icon="baby" onClick={() => act('agevet')} fluid>
            Verified:{' '}
            {data.agevet ? (
              <Box inline color="#74cde0">
                YAE!
              </Box>
            ) : (
              <Box inline color="#897472">
                NAE?
              </Box>
            )}
          </Button>
        </Stack.Item>
        <Stack.Item mt={2}>
          <Button icon="scroll" onClick={() => act('lore_primer')} fluid>
            Lore Primer
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="scale-unbalanced"
            onClick={() => act('changelog')}
            fluid
          >
            Changelog
          </Button>
        </Stack.Item>
        <Stack.Item grow />
        <Stack.Item>
          <Button icon="download" onClick={() => act('export_save')} fluid>
            Export Savefile
          </Button>
        </Stack.Item>
        <SaveUndo />
      </Stack>
    </Stack.Item>
  );
};

const CharacterSheetSubtab = (props: { subtab: Subtab }) => {
  const { subtab } = props;

  switch (subtab) {
    case Subtab.IDENTITY:
      return <SubtabIdentity />;
    case Subtab.APPEARANCE:
      return <SubtabAppearance />;
    case Subtab.DESCRIPTORS:
      return <SubtabDescriptors />;
    case Subtab.CLASS:
      return <SubtabClass />;
    case Subtab.VILLAIN:
      return <SubtabVillain />;
  }
};
