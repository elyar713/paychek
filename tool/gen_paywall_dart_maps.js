const {
  COUNTRY_TO_CURRENCY,
  DEFAULT_PRICES_BY_CURRENCY,
} = require('../functions/paywall_pricing');

const countries = Object.entries(COUNTRY_TO_CURRENCY).sort((a, b) =>
  a[0].localeCompare(b[0]),
);
const currencies = Object.entries(DEFAULT_PRICES_BY_CURRENCY).sort((a, b) =>
  a[0].localeCompare(b[0]),
);

const countryMap = countries
  .map(([k, v]) => `  '${k}': '${v}',`)
  .join('\n');
const priceMap = currencies
  .map(
    ([k, v]) =>
      `  '${k}': _Amounts(${v.monthly}, ${v.quarterly}, ${v.annual}),`,
  )
  .join('\n');

console.log(`// ${countries.length} countries, ${currencies.length} currencies`);
console.log('const Map<String, String> _countryToCurrency = {');
console.log(countryMap);
console.log('};');
console.log('');
console.log('const Map<String, _Amounts> _pricesByCurrency = {');
console.log(priceMap);
console.log('};');
