# Breaking Down DAU: A Data Engineer’s Guide to Duolingo’s Growth Model

[![Medium Complete Article](https://img.shields.io/badge/Detailed_Explanations-Medium_Article-03a57a?style=flat&logo=medium)](https://medium.com/@leofgonzalez/how-can-data-engineers-apply-duolingos-growth-model-to-their-own-realities-at-its-full-potential-9456f31f5908)

SQL implementation of Duolingo's state-based growth framework for user retention analysis. This repository provides production-ready queries to track user engagement states and transitions.

## 📊 Key Metrics Calculated

- **User State Classification**
  - `New Users`
  - `Current Users`
  - `Reactivated Users`
  - `Resurrected Users`
  - `At-Risk Users (WAU/MAU)`
  - `Dormant Users`

- **Core Growth Metrics**
  - Reactivation Rates
  - State Transition Probabilities
  - DAU Decomposition

## 🛠️ Files Overview

| File | Purpose | Output Metrics |
|------|---------|----------------|
| `New Users.sql` | Tracks first-time activations | Daily new user counts |
| `Current Users.sql` | Identifies daily active users (7-day window) | Current user counts |
| `Reactivated Users.sql` | Detects users returning after 8-29 days inactivity | Reactivation volumes |
| `Resurrected Users.sql` | Flags users returning after 30+ days inactivity | Resurrection counts |
| `At-Risk-WAU, At-Risk-MAU and Dormant Users.sql` | Predicts risk state transitions | At-risk population trends |
| `Reactivation Rate.sql` | Calculates daily reactivation performance | ReactivationRateₜ = ReactivatedUserₜ/AtRiskMAUₜ₋₁ |
