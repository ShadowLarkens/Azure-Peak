import { useBackend } from 'tgui/backend';
import { Button, Stack } from 'tgui-core/components';

/**
 * Save/Undo button stack used across the character creator.
 */
export const SaveUndo = (props) => {
  const { act } = useBackend();

  return (
    <>
      <Stack.Item>
        <Button fluid onClick={() => act('save')}>
          Save
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button fluid onClick={() => act('load')}>
          Undo
        </Button>
      </Stack.Item>
    </>
  );
};
