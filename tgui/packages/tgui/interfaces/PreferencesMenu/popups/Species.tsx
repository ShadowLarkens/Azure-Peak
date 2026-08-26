import type { ConstantPreferenceDataType } from 'common/preferences_bindings';
import { groupBy, sortBy } from 'es-toolkit/array';
import { PrefPopupGuard, TabCollapsible } from 'pm/components';
import { type ConstantData, useConstantPrefs } from 'pm/constant_data';
import { registerPopup, useKeyscrollEffect, usePopupBackend } from 'pm/popups';
import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { usePreferences } from '../datumized_data';

const PopupSpeciesSelector = () => {
  const prefs = usePreferences(['/datum/preference/species']);
  const [constantData] = useConstantPrefs();

  return (
    <PrefPopupGuard
      title="Selecting Race"
      loadingScreenText="Races Loading..."
      width="80vw"
      height="60vh"
      dependencies={[constantData, prefs]}
    >
      <PopupSpeciesSelectorInner constantData={constantData!} />
    </PrefPopupGuard>
  );
};

// Register it
declare module 'pm/popups' {
  interface PopupRegistry {
    Species: 'species';
  }
}
registerPopup('Species', 'species', PopupSpeciesSelector);

const PopupSpeciesSelectorInner = (props: { constantData: ConstantData }) => {
  const prefs = usePreferences(['/datum/preference/species'])!;
  const {
    species: { base_species, sub_species },
  } = prefs;
  const { constantData } = props;
  const { species } = constantData;
  const [viewing, setViewing] = useState(sub_species);

  const speciesByBasename = Object.fromEntries(
    Object.entries(groupBy(species, (s) => s.base_name)).map(([k, v]) => [
      k,
      sortBy(v, ['sub_name']),
    ]),
  );
  const baseNames = Object.keys(speciesByBasename).sort();
  const flatSpeciesList = baseNames.flatMap((k) =>
    speciesByBasename[k].map((s) => s.sub_name),
  );

  useKeyscrollEffect({
    list: flatSpeciesList,
    currentIndex: flatSpeciesList.indexOf(viewing),
    setter: (v) => setViewing(v),
  });

  useEffect(() => {
    document
      .getElementById(`PreferencesMenuPopupSpeciesSelectorTab_${viewing}`)
      ?.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }, [viewing]);

  return (
    <Stack fill>
      <Stack.Item basis="25%">
        <Section fill scrollable>
          <Tabs vertical>
            {baseNames.map((name) => (
              <TabCollapsible
                key={name}
                title={name}
                forceOpen={
                  speciesByBasename[name].find((v) => v.sub_name === viewing)
                    ? true
                    : undefined
                }
                startOpen={
                  // this is just polish, it makes it so that you can see
                  // the tab that opens by default
                  name === base_species
                }
              >
                {speciesByBasename[name].map((s) => (
                  <Tooltip
                    key={s.type}
                    content={
                      !s.is_subrace
                        ? `This is the default subrace for ${name}.`
                        : null
                    }
                  >
                    <Tabs.Tab
                      ml={2}
                      id={`PreferencesMenuPopupSpeciesSelectorTab_${s.sub_name}`}
                      icon={
                        sub_species === s.sub_name
                          ? 'check'
                          : !s.is_subrace
                            ? 'asterisk'
                            : undefined
                      }
                      selected={s.sub_name === viewing}
                      onClick={() => setViewing(s.sub_name)}
                    >
                      {s.sub_name}
                    </Tabs.Tab>
                  </Tooltip>
                ))}
              </TabCollapsible>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <RightPane species={species.find((v) => v.sub_name === viewing)} />
      </Stack.Item>
    </Stack>
  );
};

// Extract from the zod schema
type ConstantSpecies = Pick<
  ConstantPreferenceDataType,
  'species'
>['species'][0];

const RightPane = (props: { species: ConstantSpecies | undefined }) => {
  const prefs = usePreferences(['/datum/preference/species'])!;
  const {
    species: { sub_species },
  } = prefs;
  const { species } = props;
  const { act } = usePopupBackend();

  if (!species) {
    return (
      <Box fontSize={1.2} m={2}>
        No Race Selected.
      </Box>
    );
  }

  const selected = sub_species === species.sub_name;

  return (
    <Section
      fill
      scrollable
      title={species.desc_title || species.sub_name}
      buttons={
        <Stack>
          <Stack.Divider />
          <Stack.Item>
            <Button.Confirm
              disabled={selected}
              confirmContent="This will reset appearance and jobs! Confirm?"
              onClick={() => {
                act('select_species', { species: species.type });
              }}
            >
              {selected ? 'Already Selected' : 'Select This Species'}
            </Button.Confirm>
          </Stack.Item>
        </Stack>
      }
    >
      <Stack vertical>
        <Stack.Item>
          <Section title="Description">
            <Box
              preserveWhitespace
              dangerouslySetInnerHTML={{ __html: species.desc }}
            />
          </Section>
        </Stack.Item>
        {species.bonus_stats ? (
          <Stack.Item>
            <Section title="Bonus Stats">
              <Box
                preserveWhitespace
                dangerouslySetInnerHTML={{ __html: species.bonus_stats }}
              />
            </Section>
          </Stack.Item>
        ) : null}
        {species.bonus_traits ? (
          <Stack.Item>
            <Section title="Bonus Traits">
              <Box
                preserveWhitespace
                dangerouslySetInnerHTML={{ __html: species.bonus_traits }}
              />
            </Section>
          </Stack.Item>
        ) : null}
        {species.mechanics ? (
          <Stack.Item>
            <Section title="Mechanics">
              <Box
                preserveWhitespace
                dangerouslySetInnerHTML={{
                  __html: species.mechanics.trim(),
                }}
              />
            </Section>
          </Stack.Item>
        ) : null}
        {species.languages ? (
          <Stack.Item>
            <Section title="Languages">
              <Box
                preserveWhitespace
                dangerouslySetInnerHTML={{ __html: species.languages }}
              />
            </Section>
          </Stack.Item>
        ) : null}
      </Stack>
    </Section>
  );
};
