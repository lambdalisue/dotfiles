---
readonly_tools:
  - name: Read
    description: File content viewing - examine existing implementations
  - name: Grep
    description: Pattern search - find related code patterns
  - name: Glob
    description: File exploration - understand project structure
  - name: LS
    description: Directory structure - map system organization
  - name: context7
    description: Framework documentation - research best practices and APIs
  - name: serena
    description: Semantic code search - understand system relationships
---

# plan - Requirements Engineering Command

## Purpose

Transform vague ideas into precise technical specifications through systematic requirements analysis and stakeholder consultation.

## Requirements Engineering Framework

### Core Philosophy

1. **Requirements Before Solutions**
   - Understand the "why" before defining "how"
   - Challenge assumptions and stated solutions
   - Focus on underlying needs and constraints

2. **Stakeholder Engagement**
   - Ask smart questions that reveal hidden requirements
   - Validate understanding through concrete examples
   - Balance technical excellence with business needs

3. **Specification Precision**
   - Eliminate ambiguity through formal definitions
   - Use measurable success criteria
   - Define clear boundaries and interfaces

## Requirements Analysis Protocol

### Stage 1: Domain Discovery (5-10 minutes)

**Initial Assessment Matrix:**

```yaml
Context Analysis:
  Business Domain:
    - Core business process affected
    - Stakeholders impacted
    - Business value expected

  Technical Domain:
    - System components involved
    - Integration touchpoints
    - Technology constraints

  Risk Domain:
    - Security implications
    - Performance requirements
    - Scalability considerations
```

**Investigation Checklist:**

1. **Existing System Analysis**
   ```
   - Current implementation patterns
   - Architecture decisions in place
   - Technology stack and versions
   - Integration patterns used
   - Error handling approaches
   - Testing strategies employed
   ```

2. **Constraint Identification**
   ```
   Technical Constraints:
     - Language/framework limitations
     - Performance budgets
     - Memory/storage limits
     - Network bandwidth
     - Browser compatibility
     - API rate limits

   Business Constraints:
     - Timeline requirements
     - Budget limitations
     - Regulatory compliance
     - Backward compatibility
     - User experience standards
   ```

3. **Dependency Mapping**
   ```
   Internal Dependencies:
     - Required modules/services
     - Shared resources
     - Database schemas
     - Configuration systems

   External Dependencies:
     - Third-party services
     - External APIs
     - CDN requirements
     - Authentication providers
   ```

### Stage 2: Strategic Inquiry (Critical Phase)

**Question Engineering Framework:**

```python
# Question Generation Algorithm
def generate_strategic_questions(requirement):
    all_questions = []

    # Layer 1: Fundamental understanding
    all_questions.extend(identify_core_purpose_questions())

    # Layer 2: Technical decisions
    all_questions.extend(identify_architecture_questions())

    # Layer 3: Business rules
    all_questions.extend(identify_domain_logic_questions())

    # Layer 4: Quality attributes
    all_questions.extend(identify_nonfunctional_questions())

    # Layer 5: Integration concerns
    all_questions.extend(identify_integration_questions())

    # Scoring and filtering
    scored_questions = prioritize_by_impact(all_questions)
    return select_top_3_critical(scored_questions)
```

**Question Quality Criteria:**

| High-Value Questions | Low-Value Questions |
|---------------------|---------------------|
| Reveals hidden requirements | Already discoverable in code |
| Affects architecture decisions | Implementation details |
| Defines business rules | Style preferences |
| Clarifies acceptance criteria | Generic best practices |
| Identifies integration needs | Obvious requirements |

**Question Template Structure:**

```markdown
### Question [N]: [Concise Question Title]

**Question**: [Specific, unambiguous question]

**Why This Matters**:
[Explain how the answer affects the design/architecture]

**Impact on Design**:
- If Answer A → [Design implication]
- If Answer B → [Alternative design implication]

**Example Response Options**:
```
Option 1: [Concrete example answer]
Option 2: [Alternative example answer]
Option 3: [Another possibility]
```
```

### Stage 3: Requirements Synthesis

**Requirements Categorization:**

```yaml
Functional Requirements:
  User Stories:
    - As a [role]
    - I want [capability]
    - So that [business value]

  Acceptance Criteria:
    - Given [precondition]
    - When [action]
    - Then [expected outcome]

Non-Functional Requirements:
  Performance:
    - Response time targets
    - Throughput requirements
    - Resource utilization limits

  Security:
    - Authentication methods
    - Authorization rules
    - Data protection needs

  Usability:
    - Accessibility standards
    - User experience goals
    - Error handling expectations

  Reliability:
    - Availability targets
    - Failure recovery
    - Data integrity
```

### Stage 4: Specification Generation

## Requirements Document Template

```markdown
# Requirements Specification: [Feature/Project Name]

## Executive Summary

### Vision
[1-2 sentences describing the desired future state]

### Objectives
1. [Primary objective]
2. [Secondary objective]
3. [Tertiary objective]

## Stakeholder Analysis

### Primary Stakeholders
- **[Role]**: [Their needs and concerns]

### Secondary Stakeholders
- **[Role]**: [Their needs and concerns]

## Functional Requirements

### Core Functionality

#### FR-001: [Requirement Title]
- **Description**: [Detailed description]
- **Priority**: [Critical/High/Medium/Low]
- **Acceptance Criteria**:
  - [ ] [Measurable criterion 1]
  - [ ] [Measurable criterion 2]

#### FR-002: [Next Requirement]
[Continue pattern...]

### User Interactions

#### UI-001: [Interaction Requirement]
- **User Story**: As a [user], I want [goal] so that [benefit]
- **Mockup/Flow**: [Description or ASCII diagram]
- **Validation Rules**: [Input constraints]

## Non-Functional Requirements

### Performance Requirements

#### PF-001: Response Time
- **Requirement**: [Specific metric]
- **Measurement Method**: [How to verify]
- **Rationale**: [Why this matters]

### Security Requirements

#### SE-001: Authentication
- **Requirement**: [Security specification]
- **Threat Model**: [What we're protecting against]
- **Implementation Constraints**: [Specific requirements]

## Technical Specification

### Architecture Overview

```
[ASCII or Mermaid diagram showing component relationships]
```

### Component Specifications

#### [Component Name]
- **Purpose**: [What it does]
- **Interfaces**: [Input/output specifications]
- **Dependencies**: [What it requires]
- **Constraints**: [Limitations]

### Data Model

```yaml
Entity: [Name]
  Attributes:
    - field_name: type, constraints
  Relationships:
    - related_entity: relationship_type
```

### API Specifications

#### Endpoint: [Method] /path
- **Purpose**: [What it does]
- **Request**: [Format and parameters]
- **Response**: [Format and fields]
- **Errors**: [Possible error conditions]

## Implementation Strategy

### Development Phases

#### Phase 1: Foundation
- **Scope**: [What's included]
- **Duration**: [Estimated time]
- **Deliverables**: [What will be complete]

#### Phase 2: Core Features
[Continue pattern...]

### Technical Decisions

| Decision | Option Selected | Rationale |
|----------|----------------|-----------|
| [Area] | [Choice] | [Why] |

## Testing Requirements

### Test Strategy

#### Unit Testing
- **Coverage Target**: [Percentage]
- **Key Areas**: [What must be tested]

#### Integration Testing
- **Scenarios**: [Key integration points]

#### Acceptance Testing
- **Test Cases**: [User scenarios to validate]

## Risk Analysis

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|---------|------------|
| [Risk description] | [L/M/H] | [L/M/H] | [Strategy] |

### Business Risks

[Similar table structure]

## Success Metrics

### KPIs
1. **[Metric Name]**: [Target value]
   - Measurement: [How to measure]
   - Baseline: [Current value]

### Acceptance Criteria
- [ ] [Overall success criterion 1]
- [ ] [Overall success criterion 2]

## Constraints and Assumptions

### Constraints
- **Technical**: [Immutable technical limitations]
- **Business**: [Non-negotiable business rules]
- **Resource**: [Time/budget/personnel limits]

### Assumptions
- [Assumption 1 - what we're taking as given]
- [Assumption 2]

## Dependencies

### Upstream Dependencies
- **[System/Service]**: [What we need from it]

### Downstream Impact
- **[System/Service]**: [How it will be affected]

## Appendices

### Glossary
- **[Term]**: [Definition]

### References
- [Document/resource name]: [Why it's relevant]

---

## Review and Approval

### Technical Review
- **Feasibility**: [Assessment]
- **Completeness**: [Assessment]
- **Clarity**: [Assessment]

### Stakeholder Sign-off
- [ ] Product Owner
- [ ] Technical Lead
- [ ] QA Lead

## Metrics

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Requirements Clarity** | [0-100]% | [Assessment] |
| **Technical Feasibility** | [0-100]% | [Assessment] |
| **Business Alignment** | [0-100]% | [Assessment] |
| **Risk Level** | [Low/Medium/High] | [Key concerns] |
```

## Inquiry Best Practices

### Effective Question Patterns

**For Understanding Scope:**
```
"Should this feature support [specific scenario], or is it acceptable to
[simpler alternative]? For example, in a bulk upload, should we process
all items even if some fail, or stop at the first error?"
```

**For Performance Requirements:**
```
"What's the expected usage pattern? For instance:
- Typical number of concurrent users?
- Peak load scenarios?
- Acceptable response time for [operation]?"
```

**For Business Rules:**
```
"When [edge case] occurs, what should happen?
Example scenario: [concrete example]
Option A: [business-friendly handling]
Option B: [technically simpler handling]"
```

**For Integration Needs:**
```
"Will this need to integrate with [external system]? If yes:
- Real-time or batch synchronization?
- What data needs to be exchanged?
- Who owns the integration interface?"
```

### Question Anti-Patterns

❌ **Too Vague:**
"What about security?"

✅ **Specific:**
"What authentication method should we use: JWT tokens, OAuth 2.0, or session-based?"

---

❌ **Leading:**
"Don't you think we should use microservices?"

✅ **Neutral:**
"What are the scaling requirements that might influence architecture choices?"

---

❌ **Technical Jargon:**
"Should we implement CQRS with event sourcing?"

✅ **Business-Focused:**
"Do we need to track the history of all changes, or just the current state?"

## Quality Checklist

Before finalizing requirements:

### Completeness
- [ ] All functional requirements identified
- [ ] Non-functional requirements specified
- [ ] Acceptance criteria measurable
- [ ] Edge cases considered
- [ ] Error scenarios defined

### Clarity
- [ ] No ambiguous terms
- [ ] Technical terms defined
- [ ] Success criteria explicit
- [ ] Priorities assigned
- [ ] Dependencies mapped

### Feasibility
- [ ] Technical approach validated
- [ ] Resource requirements realistic
- [ ] Timeline achievable
- [ ] Risks identified and manageable
- [ ] Constraints acknowledged

### Alignment
- [ ] Stakeholder needs addressed
- [ ] Business value clear
- [ ] Technical excellence balanced with pragmatism
- [ ] Future extensibility considered
- [ ] Maintenance burden evaluated

## Parameters

- `$ARGUMENTS`: Feature or system requiring requirements definition (required)