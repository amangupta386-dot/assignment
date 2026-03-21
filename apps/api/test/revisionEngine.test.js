const test = require("node:test");
const assert = require("node:assert/strict");

const { revisionStages } = require("../src/constants/enums");
const {
  getInitialProgress,
  completeStage,
  failStage,
  keepSameStage
} = require("../src/services/revisionEngine");

test("getInitialProgress starts every problem at day 1 revise", () => {
  const initial = getInitialProgress(new Date("2026-03-18T09:30:00Z"));

  assert.deepEqual(initial, {
    currentStage: revisionStages.REVISE,
    nextReviewDate: "2026-03-18"
  });
});

test("completeStage moves through the full revision pipeline", () => {
  const dayOne = completeStage(
    revisionStages.REVISE,
    new Date("2026-03-18T09:30:00Z")
  );
  assert.equal(dayOne.currentStage, revisionStages.SOLVE_AGAIN);
  assert.equal(dayOne.nextReviewDate, "2026-03-19");

  const dayTwo = completeStage(
    revisionStages.SOLVE_AGAIN,
    new Date("2026-03-19T09:30:00Z")
  );
  assert.equal(dayTwo.currentStage, revisionStages.SOLVE_WITHOUT_SEEING);
  assert.equal(dayTwo.nextReviewDate, "2026-03-22");

  const dayFive = completeStage(
    revisionStages.SOLVE_WITHOUT_SEEING,
    new Date("2026-03-22T09:30:00Z")
  );
  assert.equal(dayFive.currentStage, revisionStages.FINAL_REVISIT);
  assert.equal(dayFive.nextReviewDate, "2026-03-27");

  const dayTen = completeStage(
    revisionStages.FINAL_REVISIT,
    new Date("2026-03-27T09:30:00Z")
  );
  assert.equal(dayTen.currentStage, revisionStages.COMPLETED);
  assert.equal(dayTen.nextReviewDate, "2026-03-27");
});

test("failStage resets revision back to day 1", () => {
  const failed = failStage(new Date("2026-03-25T12:00:00Z"));

  assert.deepEqual(failed, {
    currentStage: revisionStages.REVISE,
    nextReviewDate: "2026-03-25",
    lastCompletedAt: null
  });
});

test("keepSameStage preserves the current stage and due date", () => {
  const kept = keepSameStage(
    revisionStages.SOLVE_AGAIN,
    new Date("2026-03-19T12:00:00Z")
  );

  assert.deepEqual(kept, {
    currentStage: revisionStages.SOLVE_AGAIN,
    nextReviewDate: "2026-03-19",
    lastCompletedAt: null
  });
});
