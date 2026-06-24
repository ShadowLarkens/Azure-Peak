import { createContext, useContext } from "react";
import { BooleanLike } from "tgui-core/react";

export type ConstantData = {
  MAX_VICES: number;
  MINIMUM_FLAVOR_TEXT: number;
  MINIMUM_OOC_NOTES: number;
  tgui_themes: Record<string, string>;
  classes: Record<string, ConstantClass>;
}

// getClassDisplayTitle(constantData, job.type, data.title_prefs)
export function getClassDisplayTitle(c: ConstantData, title: string, titles_pref: string): string {
  return c.classes[title].titles[titles_pref] || title;
}

export function getClassDepartment(c: ConstantData, title: string): DepartmentEnum {
  return DEPARTMENT_FLAG_TO_ENUM[c.classes[title].department_flag] || DepartmentEnum.NONE;
}

export function getClassDisplayOrder(c: ConstantData, title: string): number {
  return c.classes[title].display_order || 0;
}

export type ConstantClass = {
  titles: Record<string, string>,
  department_flag: DepartmentFlag,
  display_order: number;
  class_setup_examine: BooleanLike;
  tutorial: string;
  round_contrib_points: number;
}

export enum DepartmentFlag {
  NOBLEMEN = 1 << 0,
  COURTIERS = 1 << 1,
  RETINUE = 1 << 2,
  GARRISON = 1 << 3,
  CHURCHMEN = 1 << 4,
  BURGHERS = 1 << 5,
  PEASANTS = 1 << 6,
  SIDEFOLK = 1 << 7,
  WANDERERS = 1 << 8,
  INQUISITION = 1 << 9,
  ANTAGONIST = 1 << 10,
}

export enum DepartmentEnum {
  NOBLEMEN = "NOBLEMEN",
  COURTIERS = "COURTIERS",
  SIDEFOLK = "SIDEFOLK",
  RETINUE = "RETINUE",
  GARRISON = "GARRISON",
  BURGHERS = "BURGHERS",
  CHURCHMEN = "CHURCHMEN",
  INQUISITION = "INQUISITION",
  ANTAGONIST = "ANTAGONIST",
  PEASANTS = "PEASANTS",
  WANDERERS = "WANDERERS",
  NONE = "NONE",
}

export const DEPARTMENT_FLAG_TO_ENUM = {
  [DepartmentFlag.NOBLEMEN]: DepartmentEnum.NOBLEMEN,
  [DepartmentFlag.COURTIERS]: DepartmentEnum.COURTIERS,
  [DepartmentFlag.RETINUE]: DepartmentEnum.RETINUE,
  [DepartmentFlag.GARRISON]: DepartmentEnum.GARRISON,
  [DepartmentFlag.CHURCHMEN]: DepartmentEnum.CHURCHMEN,
  [DepartmentFlag.BURGHERS]: DepartmentEnum.BURGHERS,
  [DepartmentFlag.PEASANTS]: DepartmentEnum.PEASANTS,
  [DepartmentFlag.SIDEFOLK]: DepartmentEnum.SIDEFOLK,
  [DepartmentFlag.WANDERERS]: DepartmentEnum.WANDERERS,
  [DepartmentFlag.INQUISITION]: DepartmentEnum.INQUISITION,
  [DepartmentFlag.ANTAGONIST]: DepartmentEnum.ANTAGONIST,
};

// Context stuff
export const ConstantDataContext = createContext<ConstantData | undefined>(
  undefined,
);

/**
 * ## WARNING: MAY RETURN UNDEFINED
 * ## THIS MUST BE HANDLED GRACEFULLY
 * @returns 
 */
export function useConstantPrefs() {
  return useContext(ConstantDataContext);
}
