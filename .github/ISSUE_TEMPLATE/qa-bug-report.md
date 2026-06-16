---
name: QA Bug Report
author: ""
description: Report a bug found during Solatify QA
labels: [qa, bug]
body:
  - type: textarea
    id: summary
    attributes:
      label: Summary
      description: What happened?
      placeholder: Briefly describe the bug.
    validations:
      required: true
  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      description: Exact steps used to trigger the issue.
      placeholder: |
        1. Open the app
        2. Tap...
        3. Observe...
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Expected Result
      placeholder: What should have happened?
    validations:
      required: true
  - type: textarea
    id: actual
    attributes:
      label: Actual Result
      placeholder: What actually happened?
    validations:
      required: true
  - type: dropdown
    id: platform
    attributes:
      label: Platform
      options:
        - iOS
        - Android
        - Both
    validations:
      required: true
  - type: input
    id: device
    attributes:
      label: Device / OS
      placeholder: iPhone 15 Pro, iOS 17.5 / Pixel 8, Android 15
    validations:
      required: true
  - type: input
    id: build
    attributes:
      label: Build Number / Commit
      placeholder: 1.2.3 (45) / abc1234
    validations:
      required: true
  - type: textarea
    id: logs
    attributes:
      label: Logs / Screenshots
      description: Paste relevant logs and attach screenshots or screen recordings.
      placeholder: Include any error text, stack traces, or logcat/Xcode output.
    validations:
      required: true
  - type: textarea
    id: evidence
    attributes:
      label: Evidence Location
      description: Link to the screenshot, recording, or shared folder containing the evidence.
      placeholder: Shared drive link, attachment name, or folder path.
  - type: textarea
    id: notes
    attributes:
      label: Additional Notes
      placeholder: Anything else that may help triage.
