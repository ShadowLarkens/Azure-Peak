import { useBackend } from 'tgui/backend';
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { ColorButton, SaveUndo } from '../components';
import { Antag, GameSettingsData } from '../data';

export const GameSettings = (props) => {
  return (
    <Section
      fill
      scrollable
      className="CharacterSetup__Section__NoChildPadding"
    >
      <Stack vertical>
        <Stack.Item grow>
          <Settings />
          <SaveUndo />
        </Stack.Item>
        <Stack.Item grow>
          <SpecialRoles />
        </Stack.Item>
        <Stack.Item grow>
          <AdminPreferences />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Settings = (props) => {
  const { act, data } = useBackend<GameSettingsData>();
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
  const { act, data } = useBackend<GameSettingsData>();
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

// have to do this because asaycolor sometimes but only sometimes has the hash
const ensureHash = (text: string) => {
  if (!text.startsWith('#')) {
    return `#${text}`;
  }
  return text;
};

const AdminPreferences = (props) => {
  const { act, data } = useBackend<GameSettingsData>();

  if (!data.admin_prefs) {
    return null;
  }

  const {
    sound_adminhelp,
    sound_prayers,
    announce_login,
    combohud_lighting,
    show_dsay,
    show_prayer,
    allow_asaycolor,
    asaycolor,
    auto_deadmin_players,
    deadmin_player,
    auto_deadmin_antagonists,
    deadmin_antagonist,
    auto_deadmin_heads,
    deadmin_head,
  } = data.admin_prefs;

  return (
    <Section title="Admin">
      <LabeledList>
        <LabeledList.Item label="Adminhelp Sounds">
          <Button onClick={() => act('hear_adminhelps')}>
            {sound_adminhelp ? 'Enabled' : 'Disabled'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Prayer Sounds">
          <Button onClick={() => act('hear_prayers')}>
            {sound_prayers ? 'Enabled' : 'Disabled'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Announce Login">
          <Button onClick={() => act('announce_login')}>
            {announce_login ? 'Enabled' : 'Disabled'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Combo HUD Lighting">
          <Button onClick={() => act('combohud_lighting')}>
            {combohud_lighting ? 'Full-Bright' : 'No Change'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Hide Dead Chat">
          <Button onClick={() => act('toggle_dead_chat')}>
            {show_dsay ? 'Shown' : 'Hidden'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Hide Prayers">
          <Button onClick={() => act('toggle_prayers')}>
            {show_prayer ? 'Shown' : 'Hidden'}
          </Button>
        </LabeledList.Item>
        {allow_asaycolor ? (
          <LabeledList.Item label="ASAY Color" verticalAlign="middle">
            <ColorButton
              onClick={() => act('asaycolor')}
              backgroundColor={asaycolor ? ensureHash(asaycolor) : '#FF4500'}
              tooltip={asaycolor ? ensureHash(asaycolor) : '#FF4500'}
            />
          </LabeledList.Item>
        ) : null}
        <LabeledList.Divider />
        <LabeledList.Item label="Deadmin While Playing" />
        <LabeledList.Item label="Always Deadmin">
          {auto_deadmin_players ? (
            'FORCED'
          ) : (
            <Button onClick={() => act('toggle_deadmin_always')}>
              {deadmin_player ? 'Enabled' : 'Disabled'}
            </Button>
          )}
        </LabeledList.Item>
        {auto_deadmin_players ? null : (
          <>
            <LabeledList.Item label="As Antag">
              {auto_deadmin_antagonists ? (
                'FORCED'
              ) : (
                <Button onClick={() => act('toggle_deadmin_antag')}>
                  {deadmin_antagonist ? 'Enabled' : 'Disabled'}
                </Button>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="As Command">
              {auto_deadmin_heads ? (
                'FORCED'
              ) : (
                <Button onClick={() => act('toggle_deadmin_head')}>
                  {deadmin_head ? 'Enabled' : 'Disabled'}
                </Button>
              )}
            </LabeledList.Item>
          </>
        )}
      </LabeledList>
    </Section>
  );
};
