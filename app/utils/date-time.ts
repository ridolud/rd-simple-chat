import { intlFormatDistance } from "date-fns";

export function toFormatRelative(date: Date | string) {
  return intlFormatDistance(date, new Date());
}
