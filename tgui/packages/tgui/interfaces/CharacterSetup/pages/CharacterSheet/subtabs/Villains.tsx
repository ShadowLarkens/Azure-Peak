import { useBackend } from 'tgui/backend';
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { ColorButton, HeadshotButton } from '../../../components';
import { CharacterSheetData } from '../data';

export const SubtabVillain = () => {
  const { data } = useBackend<CharacterSheetData>();
  const { antag_banned } = data;

  return (
    <>
      {antag_banned ? (
        <NoticeBox danger>I am banned from antagonist roles.</NoticeBox>
      ) : null}
      <Stack>
        <Stack.Item grow>
          <VillainSettings />
        </Stack.Item>
        <Stack.Item grow>
          <BountySettings />
        </Stack.Item>
      </Stack>
    </>
  );
};

const VillainSettings = () => {
  const { act, data } = useBackend<CharacterSheetData>();
  const {
    lich_headshot_link,
    vampire_headshot_link,
    vampire_skin,
    vampire_eyes,
    vampire_hair,
    vampire_ears,
    qsr_pref,
  } = data;

  return (
    <Section title="Villain Settings">
      <Stack vertical>
        <Stack.Item>
          <Stack justify="space-around">
            <Stack.Item>
              <HeadshotButton
                action="lich_headshot"
                link={lich_headshot_link}
                subtitle="Lich Headshot"
                tooltip="Overrides your default headshot when you are a lich."
                tooltipPosition="bottom-start"
              />
            </Stack.Item>
            <Stack.Item>
              <HeadshotButton
                action="vampire_headshot"
                link={vampire_headshot_link}
                subtitle="Vampire Headshot"
                tooltip="Overrides your default headshot when you are a vampire with your disguise turned off."
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Vampire Skin Color" verticalAlign="middle">
              <Stack align="center">
                <Stack.Item grow>
                  <ColorButton
                    onClick={() => act('vampire_skin')}
                    backgroundColor={vampire_skin || '#FFFFFF'}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button onClick={() => act('vampire_skin_clear')}>C</Button>
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Vampire Eye Color" verticalAlign="middle">
              <Stack align="center">
                <Stack.Item grow>
                  <ColorButton
                    onClick={() => act('vampire_eyes')}
                    backgroundColor={vampire_eyes || '#FFFFFF'}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button onClick={() => act('vampire_eyes_clear')}>C</Button>
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Vampire Hair Color" verticalAlign="middle">
              <Stack align="center">
                <Stack.Item grow>
                  <ColorButton
                    onClick={() => act('vampire_hair')}
                    backgroundColor={vampire_hair || '#FFFFFF'}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button onClick={() => act('vampire_hair_clear')}>C</Button>
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Vampire Ear Color" verticalAlign="middle">
              <Stack align="center">
                <Stack.Item grow>
                  <ColorButton
                    onClick={() => act('vampire_ears')}
                    backgroundColor={vampire_ears || '#FFFFFF'}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button onClick={() => act('vampire_ears_clear')}>C</Button>
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item
              label="Quicksilver Resistant"
              verticalAlign="middle"
            >
              <Button.Checkbox
                onClick={() => act('qsr_pref')}
                checked={qsr_pref}
                selected={qsr_pref}
              >
                {qsr_pref ? 'Yes' : 'No'}
              </Button.Checkbox>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const BountySettings = () => {
  const { act, data } = useBackend<CharacterSheetData>();
  const {
    preset_bounty_enabled,
    bounty_posters,
    wretch_severities,
    bandit_severities,
    preset_bounty_crime,
  } = data;

  return (
    <Section title="Bounty Settings">
      <LabeledList>
        <LabeledList.Item label="Use Preset Bounty">
          <Button.Checkbox
            onClick={() => act('preset_bounty_toggle')}
            fluid
            selected={preset_bounty_enabled}
            checked={preset_bounty_enabled}
          >
            {preset_bounty_enabled ? 'Enabled' : 'Disabled'}
          </Button.Checkbox>
        </LabeledList.Item>
        {preset_bounty_enabled ? (
          <>
            <LabeledList.Item label="Bounty Poster">
              <Button
                onClick={() => act('preset_bounty_poster_key')}
                ellipsis
                fluid
              >
                {bounty_posters || 'None'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Crime Severity">
              <Button
                onClick={() => act('preset_bounty_severity_key')}
                ellipsis
                fluid
              >
                {wretch_severities || 'None'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Crime Severity (Bandit)">
              <Button
                onClick={() => act('preset_bounty_severity_b_key')}
                ellipsis
                fluid
              >
                {bandit_severities || 'None'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Crime">
              <Button onClick={() => act('preset_bounty_crime')} ellipsis fluid>
                {preset_bounty_crime || 'None'}
              </Button>
            </LabeledList.Item>
          </>
        ) : null}
      </LabeledList>
    </Section>
  );
};
