---
name: given-when-then-test-structure
description: Tests must use
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b05e9da2-0c82-4146-a7c2-1b9260b0fe63
---

All unit tests must follow given/when/then structure with lowercase `# given`, `# when`, `# then` comments and blank lines between sections.

**Why:** Makes test intent immediately scannable — setup, action, and assertions are visually distinct. The user explicitly prefers this format.

**How to apply:** Every test method body should have three sections:

```python
def test_it_should_raise_error_when_device_not_found(self):
    # given
    mock_data = create_mock_data(status=NOT_FOUND)

    # when
    result = check_device(mock_data)

    # then
    self.assertFalse(result.success)
    self.assertEqual(result.error, "device not found")
```

Related: [[Write behavioral tests not implementation tests]]
