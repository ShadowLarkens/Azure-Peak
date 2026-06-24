import { useBackend } from 'tgui/backend';
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { Antag, GamePreferencesData } from '../data';

export const GamePreferences = (props) => {
  return (
    <Stack fill justify="space-around">
      <Stack.Item grow>
        <Settings />
      </Stack.Item>
      <Stack.Item grow>
        <SpecialRoles />
      </Stack.Item>
    </Stack>
  );
};

const Settings = (props) => {
  const { act, data } = useBackend<GamePreferencesData>();
  const {
    tgui_theme,
    parchment_skin,
    statbrowser_theme,
    tgui_input,
    tgui_lock,
    ambientocclusion,
    windowflashing,
    clientfps,
    auto_fit_viewport,
    schizo_voice,
  } = data;

  return (
    <Section title="Game Settings">
      <LabeledList>
        <LabeledList.Item
          label="TGUI Theme"
          tooltip="UI Theme to use by default for generic UI windows"
        >
          <Button onClick={() => act('tgui_theme')}>{tgui_theme}</Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="Parchment Theme"
          tooltip="UI Theme to use for paper-themed UI windows"
        >
          <Button onClick={() => act('parchment_skin')}>
            {parchment_skin}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Panel Theme" tooltip="UI Theme for Side Panel">
          <Button onClick={() => act('statbrowser_theme')}>
            {statbrowser_theme}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="TGUI Input"
          tooltip="Use TGUI input modals instead of old BYOND ones"
        >
          <Button onClick={() => act('tgui_input')}>
            {tgui_input ? 'Yes' : 'No'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="TGUI Monitors"
          tooltip="Lock TGUI windows to primary monitor or not"
        >
          <Button onClick={() => act('tgui_lock')}>
            {tgui_lock ? 'Primary' : 'All'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="Ambient Occlusion"
          tooltip="Fake ambient occlusion effect"
        >
          <Button onClick={() => act('ambientocclusion')}>
            {ambientocclusion ? 'Enabled' : 'Disabled'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="Flash Taskbar"
          tooltip="Flash the windows taskbar when polls or ghost notifications happen."
        >
          <Button onClick={() => act('windowflashing')}>
            {windowflashing ? 'Yes' : 'No'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="FPS"
          tooltip="Target FPS for the client to run on, higher values mean smoother animations"
        >
          <Button onClick={() => act('clientfps')}>{clientfps}</Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="Fit Viewport"
          tooltip="Automatically resize the right panel to maximize vertical space of the map window"
        >
          <Button onClick={() => act('auto_fit_viewport')}>
            {auto_fit_viewport ? 'Yes' : 'No'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label="Be Voice"
          tooltip="Voices receive meditations from players asking about game mechanics."
        >
          <Button onClick={() => act('schizo_voice')}>
            {schizo_voice ? 'Yes' : 'No'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const SpecialRoles = (props) => {
  const { act, data } = useBackend<GamePreferencesData>();
  const { antags, no_storyteller_events } = data;

  return (
    <Section title="Special Roles">
      <LabeledList>
        {antags.map((antag) => (
          <AntagListItem key={antag.key} antag={antag} />
        ))}
        <LabeledList.Item
          label="Storyteller Events"
          tooltip="Opt out of being picked for God's Chosen and similar events."
        >
          <Button onClick={() => act('no_storyteller_events')}>
            {no_storyteller_events
              ? 'You will never be chosen for storyteller events.'
              : 'You may be chosen for storyteller events.'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const AntagListItem = (props: { antag: Antag }) => {
  const { act } = useBackend();
  const { antag } = props;

  let innerContent: React.ReactNode;

  if (antag.banned) {
    innerContent = (
      <NoticeBox textAlign="center" p={0.5} pr={1} m={0} danger>
        BANNED
        <Button
          ml={1}
          onClick={() => act('bancheck', { bancheck: antag.key })}
          color="bad"
        >
          Why?
        </Button>
      </NoticeBox>
    );
  } else if (antag.days_remaining) {
    innerContent = (
      <NoticeBox textAlign="center" p={0.5} pr={1} m={0}>
        [IN {antag.days_remaining} DAYS]
      </NoticeBox>
    );
  } else {
    innerContent = (
      <Button.Checkbox
        onClick={() => act('be_special', { be_special_type: antag.key })}
        checked={antag.enabled}
        selected={antag.enabled}
      >
        {antag.enabled ? 'Enabled' : 'Disabled'}
      </Button.Checkbox>
    );
  }

  return (
    <LabeledList.Item key={antag.key} label={antag.key}>
      {innerContent}
    </LabeledList.Item>
  );
};
