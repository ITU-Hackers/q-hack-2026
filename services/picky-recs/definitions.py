"""Dagster code location definition for picky-recs.

Re-exports the Definitions object from the package so that both
`-m picky_recs` and `-f definitions.py` entry points work.
"""

from picky_recs.definitions import defs  # noqa: F401
