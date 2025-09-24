---
name: doc
description: Create or update technical documentation following living document principles
argument-hint: [topic-to-document]
---

# doc - Living Documentation Command

## Purpose

Create and maintain evergreen technical documentation that reflects current system state.
Documentation should be self-contained, comprehensive, and always represent the truth.

## Documentation Philosophy

### Living Document Principles

1. **Single Source of Truth**
   - Each document has one authoritative version
   - No version history within the document
   - Current state only, no "was" or "will be"

2. **Completeness Over Incrementalism**
   - Replace entire documents, don't patch
   - Every update results in a complete, standalone document
   - Reader should never need historical context

3. **Clarity Through Structure**
   - Information hierarchy guides understanding
   - Progressive disclosure from overview to details
   - Self-contained sections that build on each other

## Document Categories

### 1. Technical Specifications
```yaml
Purpose: Define what system does and how
Includes:
  - Architecture overview
  - Component descriptions
  - API contracts
  - Data schemas
  - Integration points
Excludes:
  - Implementation details
  - Code snippets (unless illustrative)
  - Deployment procedures
```

### 2. Usage Documentation
```yaml
Purpose: Enable users to effectively use the system
Includes:
  - Getting started guides
  - Feature explanations
  - Configuration options
  - Troubleshooting guides
  - Examples and patterns
Excludes:
  - Internal implementation
  - Development setup
  - Contributing guidelines
```

### 3. Reference Documentation
```yaml
Purpose: Comprehensive API/configuration reference
Includes:
  - Complete API endpoints
  - All parameters and options
  - Response formats
  - Error codes
  - Configuration schemas
Excludes:
  - Tutorials
  - Conceptual explanations
  - Best practices
```

## Document Creation Protocol

### Phase 1: Scope Definition

**Determine Document Type:**
```
IF topic is system behavior → Technical Specification
IF topic is how-to-use → Usage Documentation
IF topic is API/config details → Reference Documentation
IF topic is process/workflow → Process Documentation
```

**Set Document Boundaries:**
- What is IN scope (must be included)
- What is OUT of scope (must be excluded)
- What is the target audience
- What knowledge is assumed

### Phase 2: Information Gathering

**Collection Strategy:**
1. Code analysis for ground truth
2. Configuration review for settings
3. Test examination for behavior contracts
4. Comment extraction for intent
5. Error message review for troubleshooting

**Never Include:**
- Speculative features
- Historical decisions
- Alternative approaches considered
- Personal opinions
- Time-based information

### Phase 3: Structure Design

**Standard Document Structure:**

```markdown
# [Document Title]

## Overview
[1-2 paragraphs explaining what this documents and why it matters]

## Quick Start (if applicable)
[Minimal steps to get started]

## Core Concepts
[Essential concepts needed to understand the rest]

## [Main Content Sections]
[Organized by logical grouping]

### [Subsection]
[Detailed information]

## Configuration (if applicable)
[All configuration options]

## API Reference (if applicable)
[Complete API documentation]

## Troubleshooting (if applicable)
[Common issues and solutions]

## Examples (if applicable)
[Practical usage examples]

## Related Documentation
[Links to other relevant docs]
```

### Phase 4: Content Creation

**Writing Guidelines:**

1. **Use Present Tense**
   - ✅ "The system processes requests..."
   - ❌ "The system will process requests..."

2. **Be Definitive**
   - ✅ "Authentication uses JWT tokens"
   - ❌ "Authentication typically uses JWT tokens"

3. **Avoid Temporal References**
   - ✅ "The API accepts JSON"
   - ❌ "As of version 2.0, the API accepts JSON"

4. **Focus on What, Not Why Historical**
   - ✅ "The cache improves performance"
   - ❌ "We added cache because performance was poor"

## File Management Rules

### When to Update vs Create

**Update Existing Document When:**
- Topic is already covered in a document
- New information extends existing content
- Structure remains fundamentally same
- Audience hasn't changed

**Create New Document When:**
- Topic is orthogonal to existing docs
- Different audience or purpose
- Would make existing doc too large
- Fundamentally different structure needed

### Document Naming Conventions

```
technical-spec-[component].md    # Technical specifications
usage-[feature].md               # Usage documentation
reference-[api|config].md        # Reference documentation
guide-[topic].md                # How-to guides
troubleshooting-[area].md       # Problem-solving docs
```

## Quality Checklist

### Before Finalizing:

**Content Quality:**
- [ ] Information is current and accurate
- [ ] No historical artifacts remain
- [ ] All examples are tested and working
- [ ] Technical terms are defined
- [ ] No TODO or FIXME comments

**Structure Quality:**
- [ ] Clear hierarchy with headers
- [ ] Logical flow from general to specific
- [ ] Each section is self-contained
- [ ] Cross-references are valid
- [ ] Table of contents for long docs

**Style Quality:**
- [ ] Consistent terminology throughout
- [ ] Active voice predominates
- [ ] Concise without losing clarity
- [ ] Code blocks have language tags
- [ ] Lists are properly formatted

## Output Template

```markdown
# [Topic] Documentation

> **Document Type**: [Technical/Usage/Reference]
> **Scope**: [What this covers]
> **Audience**: [Who should read this]

## Overview

[2-3 sentences describing what this documentation covers and its importance]

## Table of Contents (for docs > 500 lines)

- [Section 1]
- [Section 2]
- [Etc.]

## [Sections based on document type]

---

*This is a living document representing the current state of [topic].*
```

## Anti-Patterns to Avoid

### ❌ Never Include:

1. **Change Logs**
   ```markdown
   ❌ "Updated 2024-01-15: Added new parameter"
   ❌ "v2.0: Redesigned authentication"
   ```

2. **Deprecation Notices Without Removal**
   ```markdown
   ❌ "This parameter is deprecated but still works"
   ❌ "Old method (do not use)"
   ```

3. **Future Promises**
   ```markdown
   ❌ "This will be improved in the next version"
   ❌ "Coming soon: feature X"
   ```

4. **Historical Context**
   ```markdown
   ❌ "Previously, we used method X"
   ❌ "This replaces the old system"
   ```

### ✅ Do Instead:

1. **Current State Only**
   ```markdown
   ✅ "The parameter accepts three values"
   ✅ "Authentication uses OAuth 2.0"
   ```

2. **Complete Replacement**
   ```markdown
   ✅ Remove old content entirely
   ✅ Document only what exists now
   ```

3. **Present Reality**
   ```markdown
   ✅ "The system supports X, Y, and Z"
   ✅ "Configuration requires three steps"
   ```

## Parameters

- `$ARGUMENTS`: Topic or component to document (optional - will analyze codebase if not specified)