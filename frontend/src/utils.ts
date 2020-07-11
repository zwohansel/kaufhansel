import { ShoppingListItem } from "./ShoppingListItem";

export function unique<T>(array: T[]): T[] {
  const set = new Set<T>();
  const result: T[] = [];

  for (const element of array) {
    if (!set.has(element)) {
      result.push(element);
      set.add(element);
    }
  }

  return result;
}

export function groupBy<K, V, T>(array: T[], keyMapper: (item: T) => K, valueMapper: (item: T) => V): Map<K, V[]> {
  const map = new Map<K, V[]>();

  for (const item of array) {
    const key = keyMapper(item);
    const value = valueMapper(item);

    const valueList = map.get(key);

    if (valueList) {
      valueList.push(value);
    } else {
      map.set(key, [value]);
    }
  }

  return map;
}

export function omitTypename(item: ShoppingListItem): ShoppingListItem {
  const copy = { ...item };

  delete copy.__typename;

  return copy;
}

export function omitTypenames(items: ShoppingListItem[]): ShoppingListItem[] {
  return items.map(omitTypename);
}

export function parseUserIdFromCookieString(cookieString: string): string {
  const logInCookieKeyIndex = cookieString.indexOf("SHOPPER_LOGGED_IN");

  if (logInCookieKeyIndex < 0) {
    return "";
  }

  const logInCookieKeyValueSeperatorIndex = cookieString.indexOf("=", logInCookieKeyIndex);

  if (logInCookieKeyValueSeperatorIndex < 0) {
    return "";
  }

  const userIdStart = logInCookieKeyValueSeperatorIndex + 1;
  let userIdEnd = cookieString.indexOf(";", userIdStart);
  if (userIdEnd < 0) {
    userIdEnd = cookieString.length;
  }

  return cookieString.substring(userIdStart, userIdEnd).trim();
}
