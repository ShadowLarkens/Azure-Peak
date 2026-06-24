import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { ColorButton } from '../../../components/ColorButton';
import { CharacterSheetData } from '../data';

export const SubtabBody = (props) => {
  return (
    <Section fill scrollable>
      <SubtabBodyCardBasics />
    </Section>
  );
};

export const SubtabBodyCardBasics = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();

  return (
    <Section title="Basics">
      <LabeledList>
        <LabeledList.Item label="Body Type">
          <Button onClick={() => act('bodytype')} fluid>
            {data.body_type}
          </Button>
        </LabeledList.Item>
        {/* TODO: in-menu selection */}
        <LabeledList.Item label="Race">
          <Button onClick={() => act('species')} fluid>
            {data.species_base_name} {data.species_check ? null : '(!)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Subrace">
          <Button onClick={() => act('subspecies')} fluid>
            {data.species_sub_name} {data.species_check ? null : '(!)'}
          </Button>
        </LabeledList.Item>
        {data.race_bonus !== null ? (
          <LabeledList.Item label="Race Bonus">
            <Button onClick={() => act('race_bonus_select')} fluid>
              {data.race_bonus || 'None'}
            </Button>
          </LabeledList.Item>
        ) : null}
        {data.allowed_taur_types.length ? (
          <LabeledList.Item label="Taur Body Type">
            {/* TODO: Preview Popup */}
            <Stack>
              <Stack.Item grow>
                <Button onClick={() => act('taur_type')} fluid>
                  {data.taur_name || 'None'}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <ColorButton
                  onClick={() => act('taur_color')}
                  backgroundColor={'#' + data.taur_color}
                  tooltip={'Taur Color: #' + data.taur_color}
                />
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
        ) : null}
        {data.use_skintones ? (
          <LabeledList.Item label={data.skin_tone_wording}>
            <Button onClick={() => act('s_tone')} fluid>
              Change
            </Button>
          </LabeledList.Item>
        ) : null}
        {data.use_mutcolor ? (
          <>
            <LabeledList.Item label="Mutant Color #1" verticalAlign="middle">
              <ColorButton
                onClick={() => act('mutant_color')}
                backgroundColor={'#' + data.mcolor}
                tooltip={'#' + data.mcolor}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Mutant Color #2" verticalAlign="middle">
              <ColorButton
                onClick={() => act('mutant_color2')}
                backgroundColor={'#' + data.mcolor2}
                tooltip={'#' + data.mcolor2}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Mutant Color #3" verticalAlign="middle">
              <ColorButton
                onClick={() => act('mutant_color3')}
                backgroundColor={'#' + data.mcolor3}
                tooltip={'#' + data.mcolor3}
              />
            </LabeledList.Item>
          </>
        ) : null}
        <LabeledList.Item label="Sprite Scale">
          <Button onClick={() => act('body_size')}>{data.body_size}%</Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
