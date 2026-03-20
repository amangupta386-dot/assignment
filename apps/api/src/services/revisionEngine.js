const { revisionStages } = require("../constants/enums");
const { addDays, toDateOnly } = require("../utils/date");

const forwardConfig = {
  [revisionStages.REVISE]: { nextStage: revisionStages.SOLVE_AGAIN, plusDays: 1 },
  [revisionStages.SOLVE_AGAIN]: { nextStage: revisionStages.SOLVE_WITHOUT_SEEING, plusDays: 3 },
  [revisionStages.SOLVE_WITHOUT_SEEING]: { nextStage: revisionStages.FINAL_REVISIT, plusDays: 5 },
  [revisionStages.FINAL_REVISIT]: { nextStage: revisionStages.COMPLETED, plusDays: 0 },
  [revisionStages.COMPLETED]: { nextStage: revisionStages.COMPLETED, plusDays: 0 }
};

const getInitialProgress = (createdAt = new Date()) => ({
  currentStage: revisionStages.REVISE,
  nextReviewDate: toDateOnly(createdAt)
});

const completeStage = (currentStage, completedAt = new Date()) => {
  const rule = forwardConfig[currentStage] || forwardConfig[revisionStages.REVISE];
  return {
    currentStage: rule.nextStage,
    nextReviewDate:
      rule.nextStage === revisionStages.COMPLETED
        ? toDateOnly(completedAt)
        : addDays(completedAt, rule.plusDays),
    lastCompletedAt: completedAt
  };
};

const failStage = (failedAt = new Date()) => ({
  currentStage: revisionStages.REVISE,
  nextReviewDate: toDateOnly(failedAt),
  lastCompletedAt: null
});

const keepSameStage = (currentStage, currentDueDate) => ({
  currentStage,
  nextReviewDate: toDateOnly(currentDueDate),
  lastCompletedAt: null
});

module.exports = { getInitialProgress, completeStage, failStage, keepSameStage };
