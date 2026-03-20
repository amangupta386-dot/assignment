const { Problem, RevisionProgress } = require("../models");
const { revisionStages } = require("../constants/enums");
const { getInitialProgress } = require("../services/revisionEngine");
const { incrementDailyLog } = require("../services/dailyLogService");

const createProblem = async (req, res) => {
  const userId = req.user.id;
  const problem = await Problem.create({ userId, ...req.body });

  const progress = getInitialProgress(problem.createdAt);
  await RevisionProgress.create({ problemId: problem.id, ...progress });

  await incrementDailyLog({ userId, field: "problemsSolved", by: 1, date: problem.createdAt });

  res.status(201).json({ problem });
};

const listProblems = async (req, res) => {
  const userId = req.user.id;
  const { status, pattern, difficulty } = req.query;

  const where = { userId };
  if (pattern) where.pattern = pattern;
  if (difficulty) where.difficulty = difficulty;
  if (status) where.initialStatus = status;

  const problems = await Problem.findAll({
    where,
    include: [{ model: RevisionProgress, attributes: ["currentStage"], required: false }],
    order: [["createdAt", "DESC"]]
  });

  res.json({
    problems: problems.map((problem) => {
      const json = problem.toJSON();
      const currentStage = json.RevisionProgress?.currentStage || null;
      return {
        ...json,
        initialStatus:
          currentStage === revisionStages.COMPLETED ? revisionStages.COMPLETED : json.initialStatus,
        revisionStage: currentStage
      };
    })
  });
};

module.exports = { createProblem, listProblems };
