# Markdown Text Update Command

## Overview

A slash command that creates or updates AI-generated text as markdown files. Prioritizes updating existing files and aims to maintain documents in a completed state.

## Specifications

### Basic Operation

- Output AI-generated text to markdown files
- Prioritize updating existing files over creating new ones
- Always maintain file contents in a completed state

### File Operation Rules

**Updating Existing Files**

- Choose update when files with the same theme/purpose exist
- Create complete document updates through content replacement or appending
- Create documents with overall consistency, not partial changes

**Creating New Files**

- Only for independent themes that cannot be covered by existing files
- Follow naming conventions that clearly express the content

## Document Creation Guidelines

### Required Content

- **Specifications and Requirements**: Functional and non-functional requirements the system must satisfy
- **Technical Background**: Prerequisites, architecture, and design philosophy needed for implementation
- **Usage**: Specific operational procedures, parameters, and constraints

### Prohibited Content

- Revision history, change logs
- Consideration process, discussion history
- Explanations of change reasons
- Comparisons with past versions

## Technical Background

### Document Management Philosophy

This command is based on the concept of "Living Document". Documents always maintain the latest completed state, providing only current accurate information rather than history or process.

### File System Design

- Single Responsibility Principle: One file has one clear purpose
- Idempotency: Always output the same result for the same input
- Atomicity: File updates either completely succeed or completely fail