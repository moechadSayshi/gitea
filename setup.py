"""Legacy setuptools entry point.

Gitea itself is a Go application, so this file intentionally does not try to
package the server as a Python distribution. It provides a small, explicit
setup.py entry point for environments or tooling that expect one.
"""

from setuptools import setup


setup(
    name="gitea-source",
    version="0.0.0",
    description="Source tree and development metadata for the Gitea project",
    url="https://github.com/go-gitea/gitea",
    license="MIT",
    py_modules=[],
)
