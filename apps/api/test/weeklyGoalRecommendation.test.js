const test = require("node:test");
const assert = require("node:assert/strict");

const { __testables } = require("../src/controllers/goalController");

test("sanitizeGoalProblems trims inputs and defaults missing complexity", () => {
  const sanitized = __testables.sanitizeGoalProblems([
    {
      problemName: "  Moore Voting  ",
      patternName: " Arrays ",
      timeComplexity: ""
    },
    {
      problemName: "",
      patternName: "Graph",
      timeComplexity: "O(V + E)"
    }
  ]);

  assert.deepEqual(sanitized, [
    {
      problemName: "Moore Voting",
      patternName: "Arrays",
      timeComplexity: "Not set"
    }
  ]);
});

test("recommendTarget starts with a sensible minimum for new users", () => {
  assert.equal(__testables.recommendTarget([], 0), 4);
  assert.equal(__testables.recommendTarget([], 5), 5);
});

test("recommendTarget gently pushes users after strong recent weeks", () => {
  const recommended = __testables.recommendTarget(
    [
      { completedDayOneCount: 5, completionRate: 100 },
      { completedDayOneCount: 4, completionRate: 90 },
      { completedDayOneCount: 4, completionRate: 80 }
    ],
    1
  );

  assert.equal(recommended, 6);
});

test("recommendTarget does not undershoot carry-forward backlog", () => {
  const recommended = __testables.recommendTarget(
    [
      { completedDayOneCount: 2, completionRate: 40 },
      { completedDayOneCount: 3, completionRate: 50 }
    ],
    4
  );

  assert.equal(recommended, 4);
});
