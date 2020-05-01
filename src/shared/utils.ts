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
