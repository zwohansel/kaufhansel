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
