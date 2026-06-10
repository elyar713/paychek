/** Coach IA (Gemini) — orchestration modules. */
const {createCoachAiCallable} = require("./coach_ai_runtime");

function createCoachAiExports(deps) {
  return {paychekAiCoach: createCoachAiCallable(deps)};
}

module.exports = {createCoachAiExports};
