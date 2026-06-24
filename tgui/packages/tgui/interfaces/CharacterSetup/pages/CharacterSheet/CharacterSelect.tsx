import { ReactSortable } from 'react-sortablejs';
import { useBackend } from 'tgui/backend';
import { Button, Section, Stack } from 'tgui-core/components';

import { LoadingScreen } from '../../../common/LoadingScreen';
import { CharacterSheetData, Slot } from './data';

export const CharacterSelect = (props: {
  setCs: (nextState: boolean) => void;
}) => {
  const { setCs } = props;
  const { act, data } = useBackend<CharacterSheetData>();
  const { slots, favorited_slots } = data;

  let innerContent;

  if (!slots) {
    innerContent = (
      <Stack fill vertical>
        <Stack.Item>
          <LoadingScreen />
        </Stack.Item>
      </Stack>
    );
  } else {
    let favorites: (Slot & { id: number })[] = [];
    let regular: Slot[] = [];

    // form two lists from data.favorited_slots and data.slots
    for (const slot of slots) {
      if (favorited_slots.includes(slot.index)) {
        favorites.push({ id: slot.index, ...slot });
      } else {
        regular.push(slot);
      }
    }

    // sort favorites by favorited_slot order
    favorites.sort(
      (a, b) =>
        favorited_slots.indexOf(a.index) - favorited_slots.indexOf(b.index),
    );

    innerContent = (
      <>
        {favorites.length ? (
          <Section
            title="Favorites"
            buttons={
              <Button icon="question" tooltip="Drag and drop to reorder" />
            }
          >
            <ReactSortable
              list={favorites}
              setList={(list) => {
                let id_list: number[] = [];
                for (const slot of list) {
                  id_list.push(slot.index);
                }
                act('reorder_favorited_slots', { slots: id_list });
              }}
            >
              {favorites.map((slot) => (
                <CharacterSlot
                  key={slot.id}
                  favorite
                  slot={slot}
                  setCs={setCs}
                />
              ))}
            </ReactSortable>
          </Section>
        ) : null}
        <Section title="Slots">
          <Stack fill vertical>
            {regular.map((slot) => (
              <Stack.Item key={slot.index}>
                <CharacterSlot slot={slot} setCs={setCs} />
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </>
    );
  }

  return (
    <Section
      title="Character Select"
      buttons={<Button icon="x" onClick={() => setCs(false)} />}
      backgroundColor="black"
      style={{ borderRadius: '5px' }}
      width={60}
      height={40}
      fill
      scrollable
    >
      {innerContent}
    </Section>
  );
};

export const CharacterSlot = (props: {
  favorite?: boolean;
  slot: Slot;
  setCs: (nextState: boolean) => void;
}) => {
  const { act, data } = useBackend<CharacterSheetData>();
  const { favorite, slot, setCs } = props;

  return (
    <Section>
      <Stack align="center">
        <Stack.Item bold={data.slot === slot.index}>{slot.index}</Stack.Item>
        <Stack.Item
          fontSize={1.2}
          basis="60%"
          bold={data.slot === slot.index}
          style={
            data.slot === slot.index
              ? { textDecoration: 'underline' }
              : undefined
          }
        >
          {slot.real_name || 'No Data'}
          {slot.topjob ? ` - ${slot.topjob}` : null}
        </Stack.Item>
        <Stack.Item>{slot.species}</Stack.Item>
        <Stack.Item grow />
        <Stack.Item>
          <Button
            onClick={() => {
              setCs(false);
              act('changeslot_index', { index: slot.index });
            }}
          >
            Load
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={favorite ? 'star' : 'star-o'}
            onClick={() =>
              act(favorite ? 'unfavorite_slot' : 'favorite_slot', {
                index: slot.index,
              })
            }
            selected={favorite}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
