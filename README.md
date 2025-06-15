# AI Screenplay Analyzer 🎬🤖

An AI-powered application that evaluates film screenplays across storytelling dimensions like plot structure, character development, dialogue, subplots, and originality.
This project is designed for an AI startup looking to automate and scale early-stage script evaluations using cloud-native tools and generative AI.

---

## 🌐 Overview
The system allows users to upload screenplay files, which are then processed and analyzed by an AI model. Evaluation results are returned in a structured format, providing quick and insightful feedback for writers, reviewers, and producers.

---

## ⚙️ Technologies Used
- **AWS Bedrock** – for secure and scalable access to foundation models
- **AWS Lambda** – to handle serverless processing and script transformation
- **Amazon S3** – to store screenplay files and AI-generated results
- **API Gateway** – to expose a public API for uploading and triggering analysis
- **Terraform** – to provision and manage infrastructure as code

---

## 📌 Key Features
- Upload film scripts in `.fdx` format
- Convert and process scripts automatically
- AI-based evaluations across multiple storytelling categories
- Secure storage and retrieval of results
- Modular architecture designed for scalability and easy iteration

---

## 📁 Project Goals
- Demonstrate practical use of AWS Bedrock for creative applications
- Build a functional, serverless pipeline for processing and analyzing media content
- Showcase prompt engineering for targeted evaluation tasks
- Create reusable infrastructure using Terraform
