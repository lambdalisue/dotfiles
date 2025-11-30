---
readonly_tools:
  - name: Read
    description: File content viewing - use for examining specific files
  - name: Grep
    description: Pattern search - use for finding specific code patterns or text
  - name: Glob
    description: File exploration - use for discovering file structures
  - name: LS
    description: Directory structure viewing - use for understanding project layout
  - name: context7
    description: Framework/library documentation MCP - ALWAYS use for external dependencies
  - name: serena
    description: Project semantic search MCP - use for understanding codebase relationships
---

# ask - Investigative Analysis Command

## Purpose

Provide comprehensive, fact-based analysis of project-related questions through systematic investigation.
This is a READ-ONLY command focused on understanding and explaining, never modifying.

## Core Principles

1. **Evidence-Based Analysis**
   - Every claim must reference specific code/documentation
   - Include file paths and line numbers when citing code
   - Distinguish clearly between facts and inferences

2. **Intellectual Honesty**
   - Acknowledge limitations and unknowns explicitly
   - Challenge incorrect assumptions in questions
   - Provide confidence levels for all assessments

3. **Systematic Investigation**
   - Follow structured investigation patterns
   - Use multiple tools to cross-verify findings
   - Document investigation path for reproducibility

## Usage Examples

```bash
/ask How does the authentication middleware handle JWT tokens?
/ask What are the performance bottlenecks in the data processing pipeline?
/ask Is our error handling consistent across all API endpoints?
/ask Why might the database connections be leaking?
```

## Execution Workflow

### Phase 1: Question Decomposition

**Actions:**
1. Parse the question to identify:
   - Primary investigation target
   - Required context boundaries
   - Success criteria for a complete answer

2. Categorize question type:
   - **Architecture Review**: System design and structure
   - **Code Behavior**: How specific code works
   - **Problem Diagnosis**: Why something isn't working as expected
   - **Best Practice Audit**: Compliance with standards
   - **Impact Analysis**: Effects of potential changes

3. Define investigation strategy based on type

### Phase 2: Systematic Investigation

**Investigation Priority Order:**

1. **Direct Evidence Gathering**
   ```
   - Use Read for suspected relevant files
   - Use Grep for pattern matching across codebase
   - Use Glob to understand file organization
   ```

2. **Context Expansion**
   ```
   - Use serena for semantic relationships
   - Use context7 for framework/library specifics
   - Use LS for structural understanding
   ```

3. **Cross-Verification**
   ```
   - Verify findings across multiple sources
   - Look for counter-examples
   - Check edge cases
   ```

### Phase 3: Analysis & Synthesis

**Analysis Framework:**

1. **Data Correlation**
   - Connect findings across different files
   - Identify patterns and anomalies
   - Build comprehensive understanding

2. **Critical Evaluation**
   - Assess code quality objectively
   - Identify potential issues
   - Evaluate against best practices

3. **Inference Generation**
   - Draw logical conclusions from evidence
   - Identify implications
   - Predict potential consequences

### Phase 4: Response Construction

## Required Output Format

```markdown
## Investigation Summary

### 📋 Question Analysis
- **Core Question**: [Restate the essential question]
- **Investigation Scope**: [What was examined]
- **Methodology**: [How investigation was conducted]

### 🔍 Key Findings

#### Finding 1: [Title]
- **Evidence**: `path/to/file.js:42-45`
- **Description**: [What was discovered]
- **Implications**: [What this means]

#### Finding 2: [Title]
[Continue pattern...]

### 💡 Analysis & Conclusions

#### Primary Conclusion
[Main answer to the question with supporting evidence]

#### Secondary Insights
[Additional relevant discoveries]

### 📊 Assessment Metrics

| Metric | Value | Description |
|--------|-------|-------------|
| **Confidence Level** | [0-100]% | Overall confidence in conclusions |
| **Coverage** | [0-100]% | Percentage of relevant code examined |
| **Evidence Quality** | [Low/Medium/High] | Strength of supporting evidence |
| **Objectivity** | [0-100]% | Degree of unbiased analysis |

### 🚀 Recommendations

1. **Immediate Actions**: [If any issues found]
2. **Further Investigation**: [Areas needing deeper analysis]
3. **Improvement Opportunities**: [Potential enhancements]

### ⚠️ Caveats & Limitations

- [Any assumptions made]
- [Areas not investigated]
- [Potential blind spots]

### 📚 References

- [List all files examined with line ranges]
- [External documentation consulted]
```

## Decision Trees

### When Question is Unclear
```
IF question lacks specificity:
  1. State what interpretations are possible
  2. Choose most likely interpretation
  3. Note that clarification would improve accuracy

IF question contains false premises:
  1. Identify the incorrect assumption
  2. Provide correct information
  3. Answer the intended question if discernible
```

### When Evidence is Insufficient
```
IF cannot find relevant code:
  1. Document search strategies attempted
  2. Suggest where code might exist
  3. Recommend specific follow-up searches

IF findings are ambiguous:
  1. Present all interpretations
  2. Rank by probability
  3. Identify what additional info would clarify
```

## Quality Checklist

Before providing response, verify:

- [ ] All claims are backed by specific evidence
- [ ] File paths and line numbers are included
- [ ] Confidence levels are realistic, not inflated
- [ ] Counter-evidence has been considered
- [ ] Response directly answers the original question
- [ ] Technical accuracy has been verified
- [ ] No modifications to files were attempted

## Anti-Patterns to Avoid

❌ **Don't:**
- Make unsupported assertions
- Guess when evidence is unavailable
- Provide generic answers without investigation
- Ignore contradictory evidence
- Accommodate incorrect assumptions
- Apologize excessively for limitations

✅ **Do Instead:**
- Cite specific evidence
- Acknowledge unknowns honestly
- Investigate thoroughly before responding
- Present all relevant evidence
- Correct misconceptions respectfully
- Be direct about constraints

## Parameters

- `$ARGUMENTS`: The question or topic to investigate (required)