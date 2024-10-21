export function parse(json) {
  return JSON.parse(json);
}

export function stringify(obj) {
  return JSON.stringify(obj, null, 2);
}
