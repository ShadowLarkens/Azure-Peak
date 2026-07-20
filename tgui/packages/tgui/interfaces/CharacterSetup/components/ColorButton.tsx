import type { Color } from 'cs/data';
import { Button } from 'tgui-core/components';

// have to do this because asaycolor sometimes but only sometimes has the hash
export const ensureColorHash = (text: Color) => {
  if (!text.startsWith('#')) {
    return `#${text}`;
  }
  return text;
};

/**
 * This is a standardized {@link Button} that displays a full square of one color.
 */
export const ColorButton = (
  props: React.ComponentProps<typeof Button> & { backgroundColor: Color },
) => {
  let { height, minWidth, fluid, color, style, backgroundColor, ...rest } =
    props;

  if (height === undefined) {
    height = '100%';
  }

  if (minWidth === undefined) {
    minWidth = 2.1183; // calculated from margins + min-width of icon buttons
  }

  if (fluid === undefined) {
    fluid = true;
  }

  if (color === undefined) {
    color = 'transparent';
  }

  if (style === undefined) {
    style = {
      border: '1px solid #fff',
      outline: '1px solid var(--color-border)',
    };
  } else {
    style = {
      border: '1px solid #fff',
      outline: '1px solid var(--color-border)',
      ...style,
    };
  }

  backgroundColor = ensureColorHash(backgroundColor);

  return (
    <Button
      height={height}
      minWidth={minWidth}
      fluid={fluid}
      color={color}
      backgroundColor={backgroundColor}
      style={style}
      {...rest}
    />
  );
};
