# Pattern

[Information about your pattern]

## Checklist
- [ ] A pattern for this format doesn't exist yet (or this PR improves the existing one)
- [ ] The new pattern has been added to the relevant table in the Readme
- [ ] The new pattern has a description pragma (`#pragma description My pattern Description here`)
- [ ] The pattern was associated with all relevant MIME types (using `#pragma MIME mime-type` in the source code)
  - Make sure to never use `application/octet-stream` here as that means "Unidentifiable binary data"
- [ ] A test file for this pattern has been added to [/tests/patterns/test_data](/tests/patterns/test_data)
  - Try to keep this file below ~ 1 MB
