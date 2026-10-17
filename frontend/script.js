// script.js - Frontend logic for LedgerDB Dashboard
// Fetch analytics data from the FastAPI backend and render charts using Chart.js

document.addEventListener('DOMContentLoaded', () => {
  const statusEl = document.getElementById('status');
  const loadBtn = document.getElementById('loadBtn');
  const outputEl = document.getElementById('output');

  // Helper to create a Chart.js instance
  function createChart(ctx, type, data, options) {
    return new Chart(ctx, {
      type,
      data,
      options,
    });
  }

  async function loadAnalytics() {
    statusEl.textContent = 'Loading analytics...';
    try {
      const resp = await fetch('/dashboard');
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      const analytics = await resp.json();
      outputEl.style.display = 'none';
      renderCharts(analytics);
      statusEl.textContent = 'Analytics loaded';
    } catch (e) {
      console.error(e);
      statusEl.textContent = 'Failed to load analytics';
      outputEl.style.display = 'block';
      outputEl.textContent = e.toString();
    }
  }

  function renderCharts(data) {
    // Monthly Summary - line chart (spending over time)
    if (data.monthly_summary && data.monthly_summary.length) {
      const ctx = document.getElementById('monthlyChart').getContext('2d');
      const labels = data.monthly_summary.map(r => `${r.month}/${r.year}`);
      const spending = data.monthly_summary.map(r => r.total_spending);
      const budget = data.monthly_summary.map(r => r.total_budget);
      createChart(ctx, 'line', {
        labels,
        datasets: [
          { label: 'Spending', data: spending, borderColor: 'hsl(220, 90%, 55%)', fill: false },
          { label: 'Budget', data: budget, borderColor: 'hsl(140, 70%, 55%)', fill: false },
        ],
      }, { responsive: true, maintainAspectRatio: false });
    }

    // Category Summary - pie chart
    if (data.category_summary && data.category_summary.length) {
      const ctx = document.getElementById('categoryChart').getContext('2d');
      const labels = data.category_summary.map(r => r.category_name);
      const values = data.category_summary.map(r => r.total_spending);
      createChart(ctx, 'pie', {
        labels,
        datasets: [{ data: values, backgroundColor: generateColors(values.length) }],
      }, { responsive: true, maintainAspectRatio: false });
    }

    // Budget vs Actual - bar chart
    if (data.budget_vs_actual && data.budget_vs_actual.length) {
      const ctx = document.getElementById('budgetChart').getContext('2d');
      const labels = data.budget_vs_actual.map(r => r.category_name);
      const budgetVals = data.budget_vs_actual.map(r => r.budget_amount);
      const actualVals = data.budget_vs_actual.map(r => r.actual_spending);
      createChart(ctx, 'bar', {
        labels,
        datasets: [
          { label: 'Budget', data: budgetVals, backgroundColor: 'hsl(140, 70%, 55%)' },
          { label: 'Actual', data: actualVals, backgroundColor: 'hsl(220, 90%, 55%)' },
        ],
      }, { responsive: true, maintainAspectRatio: false, scales: { y: { beginAtZero: true } } });
    }

    // Spending Trend - line chart (only spending)
    if (data.spending_trend && data.spending_trend.length) {
      const ctx = document.getElementById('trendChart').getContext('2d');
      const labels = data.spending_trend.map(r => `${r.month}/${r.year}`);
      const values = data.spending_trend.map(r => r.total_spending);
      createChart(ctx, 'line', {
        labels,
        datasets: [{ label: 'Spending Trend', data: values, borderColor: 'hsl(280, 70%, 55%)', fill: false }],
      }, { responsive: true, maintainAspectRatio: false });
    }
  }

  // Utility to generate an array of distinct HSL colors
  function generateColors(count) {
    const colors = [];
    for (let i = 0; i < count; i++) {
      const hue = (i * 137) % 360; // golden angle for visual variety
      colors.push(`hsl(${hue}, 70%, 60%)`);
    }
    return colors;
  }

  loadBtn.addEventListener('click', loadAnalytics);
});
