import { useBackend, useSharedState } from 'tgui/backend';
import {
  Box,
  Button,
  ByondUi,
  Dimmer,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { HeadshotButton, SaveUndo } from '../../components';
import { CharacterSelect } from './CharacterSelect';
import { CharacterSheetData } from './data';
import { SubtabBody } from './subtabs/Body';
import { SubtabClass } from './subtabs/Class';
import { SubtabDescriptors } from './subtabs/Descriptors';
import { SubtabFeatures } from './subtabs/Features';
import { SubtabIdentity } from './subtabs/Identity';
import { SubtabMarkings } from './subtabs/Markings';
import { SubtabVillain } from './subtabs/Villains';

enum Subtab {
  IDENTITY = 0,
  BODY = 1,
  FEATURES = 2,
  MARKINGS = 3,
  DESCRIPTORS = 4,
  CLASS = 5,
  VILLAIN = 6,
}

export const CharacterSheet = (props) => {
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
                selected={subtab === Subtab.IDENTITY}
                onClick={() => setSubtab(Subtab.IDENTITY)}
              >
                Identity
              </Tabs.Tab>
              <Tabs.Tab
                selected={subtab === Subtab.BODY}
                onClick={() => setSubtab(Subtab.BODY)}
              >
                Body
              </Tabs.Tab>
              <Tabs.Tab
                selected={subtab === Subtab.FEATURES}
                onClick={() => setSubtab(Subtab.FEATURES)}
              >
                Features
              </Tabs.Tab>
              <Tabs.Tab
                selected={subtab === Subtab.MARKINGS}
                onClick={() => setSubtab(Subtab.MARKINGS)}
              >
                Markings
              </Tabs.Tab>
              <Tabs.Tab
                selected={subtab === Subtab.DESCRIPTORS}
                onClick={() => setSubtab(Subtab.DESCRIPTORS)}
              >
                Descriptors
              </Tabs.Tab>
              <Tabs.Tab
                selected={subtab === Subtab.CLASS}
                onClick={() => setSubtab(Subtab.CLASS)}
              >
                Class
              </Tabs.Tab>
              <Tabs.Tab
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
  const { act, data } = useBackend<CharacterSheetData>();

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
        {/* TODO: Reevalute margin/sizing when actually using ByondUi preview */}
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
            <Button onClick={() => act('playerquality')} fluid>
              {/* eslint-disable-next-line react/no-danger */}
              PQ: <span dangerouslySetInnerHTML={{ __html: data.pq }} />
            </Button>
          </Stack.Item>
        )}
        <Stack.Item>
          <Button onClick={() => act('triumphs')} fluid>
            Triumphs: {data.triumphs}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => act('agevet')} fluid>
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
          <Button onClick={() => act('lore_primer')} fluid>
            Lore Primer
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => act('changelog')} fluid>
            Changelog
          </Button>
        </Stack.Item>
        <Stack.Item grow />
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
    case Subtab.BODY:
      return <SubtabBody />;
    case Subtab.FEATURES:
      return <SubtabFeatures />;
    case Subtab.MARKINGS:
      return <SubtabMarkings />;
    case Subtab.DESCRIPTORS:
      return <SubtabDescriptors />;
    case Subtab.CLASS:
      return <SubtabClass />;
    case Subtab.VILLAIN:
      return <SubtabVillain />;
  }
};
