import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import api from "../api";

const Register = () => {
  const [form, setForm] = useState({ name: "", email: "", password: "" });
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    try {
      await api.post("/auth/register", form);
      navigate("/login");
    } catch (err) {
      setError(err.response?.data?.msg || "Register failed");
    }
  };

  return (
  <div className="flex justify-center items-center min-h-screen bg-gray-100 dark:bg-slate-950 px-4">
    <div className="w-full max-w-sm p-8 rounded-2xl bg-white/70 dark:bg-slate-900/70 backdrop-blur-lg shadow-xl border dark:border-slate-700">
      
      <form
        onSubmit={handleSubmit}
        className="space-y-4"
      >
        <h2 className="text-3xl font-bold text-center mb-6 text-gray-900 dark:text-white">
          Create Account
        </h2>

        {error && (
          <p className="text-sm text-red-500 text-center font-medium">
            {error}
          </p>
        )}

        <input
          name="name"
          placeholder="Name"
          onChange={handleChange}
          value={form.name}
          className="w-full px-4 py-3 rounded-xl bg-gray-100 dark:bg-slate-800 text-black dark:text-white border border-gray-300 dark:border-slate-600 focus:ring-2 focus:ring-indigo-500 outline-none transition"
        />

        <input
          name="email"
          type="email"
          placeholder="Email"
          onChange={handleChange}
          value={form.email}
          className="w-full px-4 py-3 rounded-xl bg-gray-100 dark:bg-slate-800 text-black dark:text-white border border-gray-300 dark:border-slate-600 focus:ring-2 focus:ring-indigo-500 outline-none transition"
        />

        <input
          name="password"
          type="password"
          placeholder="Password"
          onChange={handleChange}
          value={form.password}
          className="w-full px-4 py-3 rounded-xl bg-gray-100 dark:bg-slate-800 text-black dark:text-white border border-gray-300 dark:border-slate-600 focus:ring-2 focus:ring-indigo-500 outline-none transition"
        />

        <button
          type="submit"
          className="w-full py-3 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold shadow-md hover:shadow-lg transition"
        >
          Register
        </button>

        <p className="text-sm text-center mt-4 text-gray-700 dark:text-gray-300">
          Already have an account?{" "}
          <Link to="/login" className="text-indigo-600 hover:underline">
            Login
          </Link>
        </p>
      </form>
    </div>
  </div>
);

};

export default Register;
