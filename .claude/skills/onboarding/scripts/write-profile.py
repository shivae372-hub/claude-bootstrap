#!/usr/bin/env python3
"""
write-profile.py
Reads intake answers from stdin (JSON) and writes USER_PROFILE.json.
Also merges detected project data if passed as argument.

Usage:
  python3 write-profile.py --detected detected.json < answers.json
  python3 write-profile.py --update < partial_answers.json  (merge into existing)
"""

import json
import sys
import argparse
from datetime import datetime
from pathlib import Path

def infer_generation_tier(profile: dict) -> str:
    """Determine which template tier to use based on profile."""
    tech_level = profile.get("tech_level", 3)
    role = profile.get("role_type", "other")
    domain = profile.get("domain", "unknown")

    # Developers always get developer tier
    if role == "developer" or domain == "software":
        return "developer"

    # High tech level with any role gets developer tier
    if tech_level >= 4:
        return "developer"

    # Founders, designers, product people get hybrid
    if role in ("founder", "designer", "product"):
        return "hybrid"

    # Tech level 3 with software domain gets hybrid
    if tech_level == 3 and domain == "software":
        return "hybrid"

    # Everyone else: non-dev tier
    return "non-dev"

def infer_workflow_style(profile: dict) -> str:
    """Infer how autonomous Claude should be."""
    tech_level = profile.get("tech_level", 3)
    if tech_level >= 4:
        return "autonomous"   # Senior devs want Claude to just do it
    elif tech_level >= 2:
        return "collaborative" # Mid-level wants to stay in the loop
    else:
        return "supervised"   # Beginners want to understand each step

def validate_profile(profile: dict) -> list:
    """Return list of validation errors. Empty = valid."""
    errors = []
    required = ["role_type", "tech_level", "primary_goals", "generation_tier"]
    for field in required:
        if field not in profile:
            errors.append(f"Missing required field: {field}")
    if "tech_level" in profile:
        if not isinstance(profile["tech_level"], int) or not (1 <= profile["tech_level"] <= 5):
            errors.append("tech_level must be integer 1-5")
    if "generation_tier" in profile:
        if profile["generation_tier"] not in ("developer", "hybrid", "non-dev"):
            errors.append("generation_tier must be developer|hybrid|non-dev")
    return errors

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--detected", help="Path to detected project JSON", default=None)
    parser.add_argument("--update", action="store_true", help="Merge into existing USER_PROFILE.json")
    parser.add_argument("--output", help="Output path", default="USER_PROFILE.json")
    args = parser.parse_args()

    # Read answers from stdin
    try:
        answers = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    # Load detected project data if provided
    detected = {}
    if args.detected:
        try:
            detected = json.loads(Path(args.detected).read_text())
        except Exception as e:
            print(f"WARNING: Could not read detected project data: {e}", file=sys.stderr)

    # Load existing profile if updating
    existing = {}
    if args.update and Path(args.output).exists():
        try:
            existing = json.loads(Path(args.output).read_text())
        except Exception:
            pass

    # Build profile
    profile = {
        **existing,
        # Identity
        "role_type": answers.get("role_type", existing.get("role_type", "other")),
        "tech_level": answers.get("tech_level", existing.get("tech_level", 3)),
        "team_size": answers.get("team_size", existing.get("team_size", "solo")),
        "domain": answers.get("domain", existing.get("domain", "unknown")),

        # Goals
        "primary_goals": answers.get("primary_goals", existing.get("primary_goals", [])),
        "success_in_30_days": answers.get("success_in_30_days", existing.get("success_in_30_days", "")),

        # Project data (from detection)
        "project_detected": detected.get("has_project", existing.get("project_detected", False)),
        "has_existing_claude": detected.get("has_existing_claude", existing.get("has_existing_claude", False)),
        "stack": detected.get("stack", existing.get("stack", [])),
        "language": detected.get("language", existing.get("language", "unknown")),
        "package_manager": detected.get("package_manager", existing.get("package_manager", "unknown")),
        "test_runner": detected.get("test_runner", existing.get("test_runner", "unknown")),

        # Metadata
        "created_at": existing.get("created_at", datetime.now().isoformat()),
        "updated_at": datetime.now().isoformat(),
        "session_count": existing.get("session_count", 0),
        "bootstrap_version": "2.0.0",
    }

    # Infer derived fields
    profile["generation_tier"] = infer_generation_tier(profile)
    profile["workflow_style"] = infer_workflow_style(profile)

    # Validate
    errors = validate_profile(profile)
    if errors:
        print("ERROR: Profile validation failed:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        sys.exit(1)

    # Write
    Path(args.output).write_text(json.dumps(profile, indent=2))
    print(f"USER_PROFILE.json written to {args.output}")
    print(f"  tier: {profile['generation_tier']}")
    print(f"  workflow: {profile['workflow_style']}")
    print(f"  stack: {profile['stack']}")

if __name__ == "__main__":
    main()
