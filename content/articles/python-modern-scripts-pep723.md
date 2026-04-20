+++
title = "Modern Python Scripts with PEP 723"
slug = "python-modern-scripts-pep723"
date = "2026-04-18T09:30:00+01:00"
description = "Modern Python Scripts with PEP 723"
draft = true
categories = ["automation", "programming", "python"]
tags = ["automation", "python"]
+++

## Example Script

```python
# /// script
# requires-python = ">=3.12.*"
# dependencies = [
#     "requests<3"
# ]
# ///

"""
Example Python script with requests.
"""

import requests

response = requests.get("FIXME")
data = response.json()
```
