import { ColorButton, ensureColorHash } from 'cs/components/ColorButton';
import { useConstantPrefs } from 'cs/constant_data';
import { LoadingScreen } from 'interfaces/common/LoadingScreen';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import type { CharacterSheetData, Virtue } from '../data';

export const SubtabIdentity = (props) => {
  return (
    <Section
      fill
      scrollable
      className="CharacterSetup__Section__NoChildPadding"
    >
      <Stack justify="space-around" fill>
        <Stack.Item basis="47%">
          <Stack vertical fill>
            <Stack.Item>
              <SubtabIdentityCardInfo />
            </Stack.Item>
            <Stack.Item>
              <SubtabIdentityCardVoice />
            </Stack.Item>
            <Stack.Item>
              <SubtabIdentityCardVirtues />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item basis="47%">
          <Stack vertical fill>
            <Stack.Item>
              <SubtabIdentityCardSpecies />
            </Stack.Item>
            <Stack.Item>
              <SubtabIdentityCardGameplay />
            </Stack.Item>
            <Stack.Item>
              <SubtabIdentityCardFaith />
            </Stack.Item>
            <Stack.Item>
              <SubtabIdentityCardVices />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      {/* INSTRUCTIONS FOR DOWNSTREAM:  Place a <DownstreamSubtabIdentity /> in here */}
    </Section>
  );
};

export const SubtabIdentityCardInfo = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();

  return (
    <Section title="Info">
      <LabeledList>
        <LabeledList.Item label="Name" verticalAlign="center">
          <Stack>
            <Stack.Item grow>
              <Button
                onClick={() => act('real_name')}
                fluid
                style={{
                  wordBreak: 'break-word',
                  whiteSpace: 'wrap',
                }}
              >
                {data.real_name}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() => act('randomize_real_name')}
                icon="dice"
                tooltip="Randomize Name"
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Nickname">
          <Stack>
            <Stack.Item grow>
              <Button
                onClick={() => act('nickname')}
                fluid
                style={{
                  wordBreak: 'break-word',
                  whiteSpace: 'wrap',
                }}
              >
                {data.nickname || 'Unset'}
              </Button>
            </Stack.Item>
            <Stack.Item>
              {data.highlight_color ? (
                <ColorButton
                  onClick={() => act('highlight_color')}
                  backgroundColor={data.highlight_color}
                  tooltip={`Highlight Color: ${ensureColorHash(data.highlight_color)}`}
                />
              ) : (
                <ColorButton
                  onClick={() => act('highlight_color')}
                  backgroundColor="#000"
                  tooltip="Highlight Color: UNSET"
                />
              )}
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Pronouns">
          <Button onClick={() => act('pronouns')} fluid>
            {data.pronouns}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Titles">
          <Button onClick={() => act('titles')} fluid>
            {data.titles_pref}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Clothing">
          <Button onClick={() => act('clothespref')} fluid>
            {data.clothes_pref}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const SubtabIdentityCardSpecies = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();
  const { species_base_name, species_sub_name, species_check, race_bonus } =
    data;

  return (
    <Section
      title="Species"
      buttons={
        <Tooltip content="Selecting species or subspecies will reset all visual features.">
          <Box
            fontSize={1.2}
            as="span"
            style={{
              borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
            }}
            textAlign="right"
          >
            You should select this first!
          </Box>
        </Tooltip>
      }
    >
      {/* <Stack mb={1} justify="center">
        <Stack.Item>
        </Stack.Item>
      </Stack> */}
      <LabeledList>
        {/* TODO: in-menu selection */}
        <LabeledList.Item label="Species">
          <Button onClick={() => act('species')} fluid>
            {species_base_name} {species_check ? null : '(!)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Subspecies">
          <Button onClick={() => act('subspecies')} fluid>
            {species_sub_name} {species_check ? null : '(!)'}
          </Button>
        </LabeledList.Item>
        {race_bonus !== null ? (
          <LabeledList.Item label="Species Bonus">
            <Button onClick={() => act('race_bonus_select')} fluid>
              {race_bonus || 'None'}
            </Button>
          </LabeledList.Item>
        ) : null}
      </LabeledList>
    </Section>
  );
};

export const SubtabIdentityCardGameplay = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();

  return (
    <Section title="Gameplay">
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Origin">
              <Stack>
                <Stack.Item grow>
                  {/* TODO: In-menu selector with origin help included */}
                  <Button onClick={() => act('origin')} fluid>
                    {data.virtue_origin}
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => act('originhelp')}
                    tooltip="Origin Help"
                  >
                    ❖
                  </Button>
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Free Language">
              <Button onClick={() => act('extra_language')} fluid>
                {data.free_language}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Statpack">
              {/* TODO: in-menu selection */}
              <Button onClick={() => act('statpack')} fluid>
                {data.statpack_name}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              <Button onClick={() => act('age')} fluid>
                {data.age}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Dominance">
              <Button onClick={() => act('domhand')} fluid>
                {data.domhand === 1 ? 'Right-handed' : 'Left-handed'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Combat Music">
              {/* TODO: in-menu selection */}
              <Button onClick={() => act('combat_music')} fluid>
                {data.combat_music}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Unrevivable">
              <Button onClick={() => act('dnr_pref')} fluid>
                {data.dnr_pref ? 'Yes' : 'No'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          {/* TODO: in-menu selection */}
          <Button onClick={() => act('culinary_prefs')} icon="utensils" fluid>
            Food Preferences
          </Button>
          <Button onClick={() => act('familiar_prefs')} icon="paw" fluid mt={1}>
            Familiar Preferences
          </Button>
          <Button
            onClick={() => act('open_loadout')}
            icon="wand-sparkles"
            fluid
            mt={1}
          >
            Open Loadout
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const SubtabIdentityCardFaith = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();

  return (
    <Section
      title={'\u16C9 Faith \u16E3'}
      className="CharacterSetup__Section__Faith"
    >
      <LabeledList>
        {/* TODO: in-menu selection */}
        <LabeledList.Item label="Faith">
          <Button onClick={() => act('faith')} fluid>
            {data.selected_faith}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Patron">
          <Button onClick={() => act('patron')} fluid>
            {data.selected_patron}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const SubtabIdentityCardVoice = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();
  const {
    voice_type,
    voice_color,
    voice_pack,
    voice_pitch,
    bark_id,
    bark_name,
    bark_pitch,
    bark_speed,
    bark_variance,
  } = data;

  return (
    <Section
      title="Voice"
      fill
      // This just makes for perfect alignment
      style={{ marginTop: 0 }}
    >
      <LabeledList>
        <LabeledList.Item
          label="Type"
          tooltip="These options are used to determine how your audible emotes sound!"
          verticalAlign="middle"
        >
          <Stack fill>
            <Stack.Item grow>
              <Button onClick={() => act('voicetype')} fluid>
                {voice_type}
              </Button>
            </Stack.Item>
            <Stack.Item>
              {voice_color ? (
                <ColorButton
                  onClick={() => act('voice_color')}
                  backgroundColor={voice_color}
                  tooltip={`Voice Color: ${ensureColorHash(voice_color)}`}
                />
              ) : (
                <ColorButton
                  onClick={() => act('voice_color')}
                  backgroundColor="#000"
                  tooltip="Voice Color: UNSET"
                />
              )}
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        {/* TODO: Dropdown */}
        <LabeledList.Item label="Pack">
          <Stack>
            <Stack.Item grow>
              <Button onClick={() => act('voicepack')} fluid>
                {voice_pack || 'Unset'}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() => act('voicepack_preview')}
                icon="volume-up"
                inline
                tooltip="Preview Voice"
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        {/* TODO: Slider */}
        <LabeledList.Item label="Pitch">
          <Stack>
            <Stack.Item grow>
              <Button onClick={() => act('voice_pitch')} fluid>
                {voice_pitch}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() => act('voicepack_preview_emote')}
                icon="face-laugh"
                inline
                tooltip="Preview Emote"
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
      </LabeledList>
      <Section title="Vocal Bark" mt={1}>
        <LabeledList>
          {/* TODO: dropdown */}
          <LabeledList.Item
            label="Type"
            tooltip="This sound will be repeated an appropriate amount of times to represent your character talking."
          >
            <Stack>
              <Stack.Item grow>
                <Button onClick={() => act('barksound')} fluid>
                  {bark_name || `Invalid: ${bark_id}`}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  onClick={() => act('barkpreview')}
                  icon="volume-down"
                  inline
                  tooltip="Preview Bark (Single)"
                />
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
          <LabeledList.Item label="Speed">
            <Stack>
              <Stack.Item grow>
                {/* TODO: slider */}
                <Button onClick={() => act('barkspeed')} fluid>
                  {bark_speed}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  onClick={() => act('barkpreview_long')}
                  icon="volume-up"
                  inline
                  tooltip="Preview Bark (Long)"
                />
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
          {/* TODO: slider */}
          <LabeledList.Item label="Pitch">
            <Button onClick={() => act('barkpitch')} fluid>
              {bark_pitch}
            </Button>
          </LabeledList.Item>
          {/* TODO: slider */}
          <LabeledList.Item label="Vary">
            <Button onClick={() => act('barkvary')} fluid>
              {bark_variance}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Section>
  );
};

export const SubtabIdentityCardVirtues = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();

  return (
    <Section className="CharacterSetup__Section__Virtues" title="Virtues">
      <Stack vertical>
        <Stack.Item>
          <VirtueEntry name="Virtue" entry="virtue1" virtue={data.virtue} />
        </Stack.Item>
        <Stack.Item>
          {data.virtue2 ? (
            <VirtueEntry
              name="Second Virtue"
              entry="virtue2"
              virtue={data.virtue2}
            />
          ) : null}
        </Stack.Item>
        {/* INSTRUCTIONS FOR DOWNSTREAM: Add another stack.item copying from virtue2 to virtue3 */}
      </Stack>
    </Section>
  );
};

export const VirtueEntry = (props: {
  name: string;
  entry: string;
  virtue: Virtue;
}) => {
  const { act } = useBackend();
  const { name, entry, virtue } = props;

  return (
    <Box>
      <Stack align="center">
        <Stack.Item>
          {name}{' '}
          {virtue.tricost > 0 ? (
            <Box inline textColor="white">
              ({virtue.tricost} TRI)
            </Box>
          ) : null}
          :
        </Stack.Item>
        <Stack.Item grow>
          <Button onClick={() => act('select_virtue', { key: entry })} fluid>
            {virtue.name}
          </Button>
        </Stack.Item>
      </Stack>
      {virtue.picked_choices.map((choice) => (
        <Button
          onClick={() =>
            act('subvirtue', {
              key: entry,
              task: 'remove',
              index: choice.index,
            })
          }
          fluid
          ml={2}
          mt={1}
          key={choice.choice}
          tooltip={choice.tooltip}
        >
          {choice.choice}
        </Button>
      ))}
      {virtue.picked_choices.length < virtue.max_choices ? (
        <Button
          onClick={() => act('subvirtue', { key: entry, task: 'add' })}
          fluid
          ml={2}
          mt={1}
        >
          Pick Bonus {virtue.next_cost > 0 ? `(${virtue.next_cost} TRI)` : null}
        </Button>
      ) : null}
    </Box>
  );
};

export const SubtabIdentityCardVices = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();
  const [constantData] = useConstantPrefs();

  if (!constantData) {
    return (
      <Section className="CharacterSetup__Section__Vices" title="Vices">
        <LoadingScreen />
      </Section>
    );
  }

  return (
    <Section className="CharacterSetup__Section__Vices" title="Vices">
      {data.charflaws.map((flaw) => (
        <Button
          // TODO: make sure this looks good
          color={flaw.warning ? 'bad' : undefined}
          onClick={() => act('charflaw', { task: 'remove', index: flaw.index })}
          key={flaw.index}
          fluid
        >
          {flaw.name}
          {flaw.warning ? ' (Requires Extra Vice!)' : null}
        </Button>
      ))}
      {data.charflaws.length < constantData.MAX_VICES ? (
        <Button ml={4} onClick={() => act('charflaw', { task: 'add' })} fluid>
          Add Vice
        </Button>
      ) : null}
      {data.has_averse ? (
        <LabeledList>
          <LabeledList.Item label="Loathed Group">
            <Button mt={2} onClick={() => act('charflaw_averse_choice')} fluid>
              {data.averse_chosen_faction}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      ) : null}
    </Section>
  );
};
