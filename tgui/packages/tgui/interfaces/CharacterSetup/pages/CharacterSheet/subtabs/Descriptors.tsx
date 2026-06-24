import { useState } from 'react';
import { useBackend, useSharedState } from 'tgui/backend';
import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useConstantPrefs } from '../../../constant_data';
import { CharacterSheetData } from '../data';

export const SubtabDescriptors = (props) => {
  return (
    <Section fill scrollable>
      <Stack vertical>
        <Stack.Item>
          <Stack fill justify="space-between">
            <Stack.Item basis="47%">
              <MechanicalDescriptions />
            </Stack.Item>
            <Stack.Item basis="47%">
              <OtherInfo />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <TextDescriptions />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const FormattingHelp = (props) => {
  return (
    <Box fontSize={1.1}>
      <Box fontSize={1.2}>
        Note: Previews only update on submit as BYOND must parse your text.
      </Box>
      <br />
      You can use backslash (\\) to escape special characters.
      <br />
      # text : Defines a header.
      <br />
      Ctrl-T: |text| : Centers the text.
      <br />
      Ctrl-B: **text** : Makes the text <b>bold</b>.<br />
      Ctrl-I: *text* : Makes the text <i>italic</i>.<br />
      Ctrl-6: ^text^ : Increases the{' '}
      <Box inline fontSize={1.2}>
        size
      </Box>{' '}
      of the text.
      <br />
      ((text)) : Decreases the{' '}
      <Box inline fontSize={0.8}>
        size
      </Box>{' '}
      of the text.
      <br />
      * item : An unordered list item.
      <br />
      --- : Adds a horizontal rule.
      <br />
      -=FFFFFFtext=- : Adds a specific{' '}
      <Box inline textColor="#FFF">
        colour
      </Box>{' '}
      to text.
    </Box>
  );
};

const MechanicalDescriptions = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();

  return (
    <Section fill title="Mechanical Descriptions">
      <LabeledList>
        {data.descriptors.map((desc) => (
          <LabeledList.Item key={desc.type} label={desc.name}>
            <Button
              fluid
              onClick={() => act('choose_descriptor', { type: desc.type })}
            >
              {desc.descriptor}
            </Button>
          </LabeledList.Item>
        ))}
        {data.descriptors_custom.map((desc) => (
          <LabeledList.Item key={desc.index} label={`Custom #${desc.index}`}>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  onClick={() =>
                    act('custom_descriptor_prefix', { index: desc.index })
                  }
                >
                  {desc.translation}
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  onClick={() =>
                    act('custom_descriptor_content', { index: desc.index })
                  }
                >
                  {desc.descriptor}
                </Button>
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const OtherInfo = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();
  const {
    examine_theme,
    ooc_extra,
    song_artist,
    song_title,
    img_gallery_len,
    nsfw_img_gallery_len,
  } = data;

  return (
    <Section fill scrollable title="Other Info">
      <LabeledList>
        <LabeledList.Item label="Examine Theme">
          <Button onClick={() => act('examine_theme')} fluid>
            {examine_theme}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Song">
          <Stack vertical>
            <Stack.Item>
              <Button onClick={() => act('ooc_extra')} fluid ellipsis>
                {ooc_extra || 'No URL Set'}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item grow>
                  <Button onClick={() => act('change_artist')} fluid ellipsis>
                    {song_title || 'None'}
                  </Button>{' '}
                </Stack.Item>
                <Stack.Item>by</Stack.Item>
                <Stack.Item grow>
                  <Button onClick={() => act('change_title')} fluid ellipsis>
                    {song_artist || 'No One'}
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Image Gallery">
          <Stack>
            <Stack.Item grow>
              <Button onClick={() => act('img_gallery')} fluid>
                Add ({img_gallery_len}/3)
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => act('clear_gallery')}>Clear</Button>
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="NSFW Gallery">
          <Stack>
            <Stack.Item grow>
              <Button onClick={() => act('nsfw_img_gallery')} fluid>
                Add ({nsfw_img_gallery_len}/3)
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => act('clear_nsfw_gallery')}>Clear</Button>
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Rumors">
          <Button onClick={() => act('rumour')} fluid>
            Change
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Noble Gossip">
          <Stack>
            <Stack.Item grow>
              <Button onClick={() => act('gossip')} fluid>
                Change
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => act('rumour_preview')}>Preview</Button>
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const TextDescriptions = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();
  const constantData = useConstantPrefs();

  return (
    <Section
      title="Text Descriptions"
      buttons={
        <Button onClick={() => act('preview_examine')}>
          Preview Full Examine
        </Button>
      }
    >
      <Stack vertical mr={2}>
        <Stack.Item>
          <details>
            <summary>Formatting Help</summary>
            <FormattingHelp />
          </details>
        </Stack.Item>
        <Stack.Item>
          <TextEditor
            name="Flavor Text"
            warning="Flavortext should not include nonphysical nonsensory attributes such as backstory or the character's internal thoughts."
            sharedStatePreview="preview_flavortext"
            onSave={(val) => act('save_flavortext', { val })}
            requiredLength={constantData?.MINIMUM_FLAVOR_TEXT}
            value={data.flavortext}
            preview={data.flavortext_cached}
          />
        </Stack.Item>
        <Stack.Item>
          <TextEditor
            name="OOC Notes"
            warning="OOC notes should be used for roleplay hooks and general information about your character."
            sharedStatePreview="preview_ooc_notes"
            onSave={(val) => act('save_ooc_notes', { val })}
            requiredLength={constantData?.MINIMUM_OOC_NOTES}
            value={data.ooc_notes}
            preview={data.ooc_notes_cached}
          />
        </Stack.Item>
        <Stack.Item>
          <TextEditor
            name="NSFW Flavor Text"
            warning="NSFW Flavortext can be used for setting things like body descriptions and other physical details that may be conisdered explicit."
            sharedStatePreview="preview_nsfwflavortext"
            onSave={(val) => act('save_nsfwflavortext', { val })}
            value={data.nsfwflavortext}
            preview={data.nsfwflavortext_cached}
          />
        </Stack.Item>
        <Stack.Item>
          <TextEditor
            name="ERP Preferences"
            warning="Erotic Roleplay preferences. If you put 'anything goes' or 'no limits' here, do not be surprised if people take you up on it."
            sharedStatePreview="preview_erpprefs"
            onSave={(val) => act('save_erpprefs', { val })}
            value={data.erpprefs}
            preview={data.erpprefs_cached}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EDITOR_HEIGHT = 16;
const TextEditor = (props: {
  name: string;
  warning?: string;
  sharedStatePreview: string;
  onSave: (val: string) => void;
  requiredLength?: number;
  value: string;
  preview: TrustedHTML | null;
}) => {
  const { name, warning, sharedStatePreview, requiredLength, value, preview } =
    props;
  const [input, setInput] = useState(value);
  const [showPreview, setShowPreview] = useSharedState(
    sharedStatePreview,
    false,
  );

  const onType = (new_val: string) => {
    setInput(new_val);
  };

  const onSave = () => {
    props.onSave(input);
  };

  const unsaved = value !== input;

  let title = name;

  if (requiredLength && input.length < requiredLength) {
    title += ` (Too Short! ${input.length}/${requiredLength})`;
  }

  if (unsaved) {
    title += ' (Edited!)';
  }

  return (
    <Stack vertical>
      <Stack.Item>
        <Stack height={2} align="center">
          <Stack.Item className="Section__titleText" grow>
            {title}
          </Stack.Item>
          <Stack.Item>
            <Button.Checkbox
              checked={showPreview}
              selected={showPreview}
              onClick={() => setShowPreview(!showPreview)}
            >
              Preview
            </Button.Checkbox>
          </Stack.Item>
          {unsaved ? (
            <Stack.Item>
              <Button onClick={onSave}>Submit</Button>
            </Stack.Item>
          ) : null}
        </Stack>
      </Stack.Item>
      {warning ? (
        <Stack.Item italic fontSize={0.9}>
          {warning}
        </Stack.Item>
      ) : null}
      <Stack.Item>
        <TextArea
          className={
            unsaved ? 'CharacterSetup__TextEditor__Unsaved' : undefined
          }
          fluid
          userMarkup={{ t: '|', b: '**', i: '*', '6': '^' }}
          height={EDITOR_HEIGHT}
          onChange={onType}
          value={input}
        />
      </Stack.Item>
      {showPreview ? (
        <Stack.Item>
          <Section
            ml={1}
            mr={1}
            title="Preview"
            fill
            preserveWhitespace
            scrollable
            height={EDITOR_HEIGHT}
          >
            {preview ? (
              <div
                // eslint-disable-next-line react/no-danger
                dangerouslySetInnerHTML={{
                  __html: `<span className='Chat'>${preview}</span>`,
                }}
              />
            ) : (
              <Box fontSize={0.8} italic>
                Nothing to preview
              </Box>
            )}
          </Section>
        </Stack.Item>
      ) : null}
    </Stack>
  );
};
