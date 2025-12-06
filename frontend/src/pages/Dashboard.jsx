import { useEffect, useMemo, useState } from "react";
import api from "../api";

const Dashboard = () => {
  const [problems, setProblems] = useState([]);
  const [progress, setProgress] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      const [pRes, progRes] = await Promise.all([
        api.get("/problems"),
        api.get("/progress"),
      ]);
      setProblems(pRes.data);
      setProgress(progRes.data);
    };
    fetchData();
  }, []);

  const progressMap = useMemo(() => {
    const map = {};
    progress.forEach((p) => {
      map[p.problemId] = p.status;
    });
    return map;
  }, [progress]);

  const handleToggle = async (problemId, checked) => {
    setProgress((prev) => {
      const existing = prev.find((p) => p.problemId === problemId);
      if (existing) {
        return prev.map((p) =>
          p.problemId === problemId ? { ...p, status: checked } : p
        );
      }
      return [...prev, { problemId, status: checked }];
    });

    await api.post("/progress/update", { problemId, status: checked });
  };

  const grouped = useMemo(() => {
    const map = {};
    problems.forEach((p) => {
      if (!map[p.topic]) map[p.topic] = [];
      map[p.topic].push(p);
    });
    return map;
  }, [problems]);

  return (
  <div className="min-h-screen bg-gray-100 dark:bg-slate-950">
    <div className="max-w-6xl mx-auto px-4 py-8">

      {Object.keys(grouped).map((topic) => (
        <div
          key={topic}
          className="mb-8 bg-white dark:bg-slate-900 rounded-2xl border dark:border-slate-700 p-5 shadow-sm"
        >
          {/* Topic header */}
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold dark:text-white">
              {topic}
            </h2>
            <span className="text-xs px-3 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-gray-600 dark:text-gray-300">
              {
                grouped[topic].filter((p) => progressMap[p._id])
                  .length
              }{" "}
              / {grouped[topic].length} completed
            </span>
          </div>

          {/* Table */}
          <div className="overflow-x-auto">
            <table className="w-full text-sm border-collapse">
              <thead>
                <tr className="bg-gray-100 dark:bg-slate-800 text-left">
                  <th className="px-3 py-2 rounded-tl-xl">Subtopic</th>
                  <th className="px-3 py-2">Problem</th>
                  <th className="px-3 py-2">Level</th>
                  <th className="px-3 py-2">Links</th>
                  <th className="px-3 py-2 rounded-tr-xl text-center">
                    Done
                  </th>
                </tr>
              </thead>
              <tbody>
                {grouped[topic].map((p, idx) => (
                  <tr
                    key={p._id}
                    className={`border-b dark:border-slate-700 ${
                      idx % 2 === 0
                        ? "bg-white dark:bg-slate-900"
                        : "bg-gray-50 dark:bg-slate-950"
                    }`}
                  >
                    <td className="px-3 py-2 align-top text-gray-700 dark:text-gray-300">
                      {p.subtopic || "-"}
                    </td>
                    <td className="px-3 py-2 align-top">
                      <div className="font-medium dark:text-white">
                        {p.title}
                      </div>
                    </td>
                    <td className="px-3 py-2 align-top">
                      <span
                        className={`text-xs px-2 py-1 rounded-full border ${
                          p.difficulty === "Easy"
                            ? "bg-green-500/10 text-green-600 border-green-400/30"
                            : p.difficulty === "Medium"
                            ? "bg-yellow-500/10 text-yellow-600 border-yellow-400/30"
                            : "bg-red-500/10 text-red-600 border-red-400/30"
                        }`}
                      >
                        {p.difficulty}
                      </span>
                    </td>
                    <td className="px-3 py-2 align-top">
                      <div className="flex flex-wrap gap-2 text-xs">
                        {p.problemLink && (
                          <a
                            href={p.problemLink}
                            target="_blank"
                            rel="noreferrer"
                            className="px-2 py-1 rounded-full bg-indigo-50 text-indigo-600 hover:bg-indigo-100 dark:bg-indigo-900/30 dark:text-indigo-300"
                          >
                            Problem
                          </a>
                        )}
                        {p.leetcodeLink && (
                          <a
                            href={p.leetcodeLink}
                            target="_blank"
                            rel="noreferrer"
                            className="px-2 py-1 rounded-full bg-orange-50 text-orange-600 hover:bg-orange-100 dark:bg-orange-900/30 dark:text-orange-300"
                          >
                            LeetCode
                          </a>
                        )}
                        {p.youtubeLink && (
                          <a
                            href={p.youtubeLink}
                            target="_blank"
                            rel="noreferrer"
                            className="px-2 py-1 rounded-full bg-red-50 text-red-600 hover:bg-red-100 dark:bg-red-900/30 dark:text-red-300"
                          >
                            YouTube
                          </a>
                        )}
                        {p.articleLink && (
                          <a
                            href={p.articleLink}
                            target="_blank"
                            rel="noreferrer"
                            className="px-2 py-1 rounded-full bg-blue-50 text-blue-600 hover:bg-blue-100 dark:bg-blue-900/30 dark:text-blue-300"
                          >
                            Article
                          </a>
                        )}
                      </div>
                    </td>
                    <td className="px-3 py-2 align-top text-center">
                      <label className="inline-flex items-center gap-2 cursor-pointer">
                        <input
                          type="checkbox"
                          className="w-4 h-4 accent-indigo-600"
                          checked={!!progressMap[p._id]}
                          onChange={(e) =>
                            handleToggle(p._id, e.target.checked)
                          }
                        />
                      </label>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      ))}

      {problems.length === 0 && (
        <p className="text-sm text-gray-600 dark:text-gray-300 text-center mt-10">
          No problems added yet. Use backend to seed some data.
        </p>
      )}
    </div>
  </div>
);

};

export default Dashboard;
