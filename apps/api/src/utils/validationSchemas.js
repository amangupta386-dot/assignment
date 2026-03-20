const { Joi } = require("../middlewares/validate");

const createProblemSchema = Joi.object({
  title: Joi.string().trim().min(2).max(120).required(),
  platform: Joi.string().trim().valid("LEETCODE", "GFG", "CODESTUDIO", "OTHER").required(),
  difficulty: Joi.string().trim().valid("EASY", "MEDIUM", "HARD").required(),
  pattern: Joi.string().trim().min(2).max(80).required(),
  initialStatus: Joi.string().trim().valid("SOLVED", "WITH_HELP", "NOT_SOLVED").default("SOLVED")
});

const weeklyGoalSchema = Joi.object({
  weekStart: Joi.date().iso().optional(),
  targetProblems: Joi.number().integer().min(1).required(),
  targetRevisions: Joi.number().integer().min(1).required(),
  focusPatterns: Joi.array().items(Joi.string().trim().max(80)).default([])
});

const weekPlanSchema = Joi.object({
  weekStart: Joi.date().iso().optional()
});

const markTaskDoneSchema = Joi.object({
  key: Joi.string().trim().required()
});

module.exports = {
  createProblemSchema,
  weeklyGoalSchema,
  weekPlanSchema,
  markTaskDoneSchema
};
