---
argument-hint: [error-message]
description: Investigation-only command for identifying causes of errors, malfunctions, and other issues
readonly_tools:
  - name: Read
    description: File content viewing
  - name: Grep
    description: Pattern search
  - name: Glob
    description: File exploration
  - name: LS
    description: Directory structure viewing
  - name: context7
    description: MCP that provides latest documentation for frameworks and libraries (actively use when available)
  - name: serena
    description: MCP for semantic search, LSP search, and documentation within projects (actively use for efficient investigation)
  - name: playwrite
    description: Browser operations, DevTools error content confirmation, page display, layout confirmation (actively use when available)
---

# investigating-error - Root Cause Investigation Command

## Purpose

A command that identifies causes from error messages and user reports, providing fact-based analysis results.
Focuses solely on cause identification and investigation without resolving errors (resolution is handled by `/execute` command).

## Basic Principles

- **Log-first**: Prioritize logs as primary information source for root cause analysis, not speculation
- **Check surrounding code**: Suspicious code might be normal when compared to similar implementations in neighboring files. Consider alternative causes in such cases
- **Systematic investigation**: Track error occurrence path chronologically and by processing order
- **Non-sycophantic**: Provide objective analysis based on facts, not accommodating user assumptions
- **Read-only**: Never modify, create, or delete files

## Input

Error message etc.: $ARGUMENTS

## Execution Steps

### 1. Error Message Analysis

- Identify error type (syntax error, runtime error, logic error, etc.)
- Identify error location (filename, line number, function name)
- Analyze stack trace
- Check timestamps

### 2. Log Investigation (Most Important)

**Log File Exploration and Confirmation:**

- Application log confirmation

  - `!ls -la logs/ 2>/dev/null || ls -la *.log 2>/dev/null`
  - `!tail -n 100 [relevant-log-file]`
  - `!grep -i error [log-files]`

- System log confirmation (as needed)

  - `!journalctl -xe --no-pager -n 50` (Linux)
  - `!tail -n 100 /var/log/system.log` (macOS)

- Error context log confirmation
  - Processing flow before error
  - Detailed information at error occurrence
  - Impact scope after error

### 3. Code Investigation

Conduct investigation using read-only tools defined in the frontmatter.

**Investigation Items:**

- Code details at error location
- Related dependencies and imports
- Configuration file contents
- Environment variable usage
- Recent change history (from git log)

### 4. Environment Investigation

- Execution environment confirmation

  - OS, runtime version
  - Dependency package versions
  - Environment variable settings

- Resource status (as needed)
  - Disk space
  - Memory usage
  - Network connectivity

### 5. Providing Investigation Results

**Output Structure:**

#### Summary (example - only output investigated results)

- **Report Summary**
- **Investigation Results Summary**

#### 📝 Log Analysis Results

- **Key Log Information**:
  - [Important information extracted from log files]
  - [Context before and after error]
  - [Related Warnings and Info]

#### 🔍 Code Investigation Results

- **Problematic Code Location**:
  - [Relevant code quotation]
  - [Problem identification]

#### 🎯 Cause Identification

- **Direct Cause**: [Direct cause identified from logs and code]
- **Root Cause**: [Deeper cause (design, configuration, environment, etc.)]
- **Occurrence Conditions**: [Specific conditions that trigger the error]

#### 📊 Investigation Metrics

- **Confidence**: [0-100] Certainty of cause identification
- **Log Utilization**: [0-100] Level of log information utilization
- **Objectivity**: [0-100] Objectivity of fact-based judgment

#### 🔗 Related Information

- Impact Scope: [Functions and processes affected by this error]
- Similar Errors: [Past similar cases and patterns]

#### 💡 Response Strategy (No Implementation)

1. [Recommended fix method]
2. [Alternative approach]
3. [Preventive measures]

#### ⚠️ Items Requiring Additional Investigation

- [Unclear points or items requiring additional confirmation]

## Important Constraints

- Never edit, create, or delete files
- Do not fix errors or implement solutions (investigation and analysis only)
- **Use logs as the highest priority information source**
- Honestly report unclear points and clearly indicate need for additional investigation
- Judge based on facts rather than accepting user assumptions
- Provide fact-based investigation results instead of apologies

**Most Important**

- Your purpose is to correctly identify problems, not to forcibly output problem reports. Therefore, avoid contrived cause reports or forced speculation when problems cannot be identified.
- If problems cannot be identified, report this and confirm whether to proceed to the next step
  - Next step means: output logs with sequential numbers according to processing order
  - Then verify operation and identify the problem

## Parameters

- `$ARGUMENTS`: Error message (required)