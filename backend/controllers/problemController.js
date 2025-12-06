const Problem = require("../models/problem");

exports.getAllProblems = async (req, res) => {
  const problems = await Problem.find().sort({ topic: 1 });
  res.json(problems);
};

exports.createProblem = async (req, res) => {
  const problem = await Problem.create(req.body);
  res.status(201).json(problem);
};
