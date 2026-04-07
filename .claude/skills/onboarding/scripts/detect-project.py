#!/usr/bin/env python3
"""
detect-project.py
Scans the parent directory of this repo clone for project indicators.
Outputs JSON describing the detected project.

Usage:
  python3 detect-project.py --output detected.json
  python3 detect-project.py  # prints to stdout
"""

import json
import sys
import argparse
from pathlib import Path

# This script lives in .claude/skills/onboarding/scripts/
# The repo root is 4 levels up, and the target project is the parent of that
SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent.parent.parent
TARGET_DIR = REPO_ROOT.parent

def detect_language(target: Path) -> str:
    """Detect primary programming language."""
    indicators = {
        "python": ["requirements.txt", "pyproject.toml", "setup.py", "Pipfile", "*.py"],
        "javascript": ["package.json"],
        "typescript": ["tsconfig.json"],
        "go": ["go.mod"],
        "rust": ["Cargo.toml"],
        "ruby": ["Gemfile"],
        "java": ["pom.xml", "build.gradle"],
        "php": ["composer.json"],
    }

    for lang, files in indicators.items():
        for f in files:
            if "*" in f:
                if list(target.glob(f)):
                    return lang
            elif (target / f).exists():
                return lang

    return "unknown"

def detect_framework(target: Path, language: str) -> list:
    """Detect frameworks based on package files."""
    frameworks = []

    # JavaScript/TypeScript frameworks
    pkg_json = target / "package.json"
    if pkg_json.exists():
        try:
            pkg = json.loads(pkg_json.read_text())
            deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}

            if "next" in deps:
                frameworks.append("Next.js")
            if "react" in deps:
                frameworks.append("React")
            if "vue" in deps:
                frameworks.append("Vue")
            if "svelte" in deps:
                frameworks.append("Svelte")
            if "@angular/core" in deps:
                frameworks.append("Angular")
            if "express" in deps:
                frameworks.append("Express")
            if "fastify" in deps:
                frameworks.append("Fastify")
            if "tailwindcss" in deps:
                frameworks.append("Tailwind")
            if "prisma" in deps or "@prisma/client" in deps:
                frameworks.append("Prisma")
            if "@supabase/supabase-js" in deps:
                frameworks.append("Supabase")
        except Exception:
            pass

    # Python frameworks
    req_txt = target / "requirements.txt"
    if req_txt.exists():
        try:
            reqs = req_txt.read_text().lower()
            if "django" in reqs:
                frameworks.append("Django")
            if "fastapi" in reqs:
                frameworks.append("FastAPI")
            if "flask" in reqs:
                frameworks.append("Flask")
        except Exception:
            pass

    return frameworks

def detect_package_manager(target: Path) -> str:
    """Detect package manager."""
    if (target / "pnpm-lock.yaml").exists():
        return "pnpm"
    if (target / "yarn.lock").exists():
        return "yarn"
    if (target / "package-lock.json").exists():
        return "npm"
    if (target / "Pipfile.lock").exists():
        return "pipenv"
    if (target / "poetry.lock").exists():
        return "poetry"
    if (target / "requirements.txt").exists():
        return "pip"
    if (target / "Cargo.lock").exists():
        return "cargo"
    if (target / "go.sum").exists():
        return "go"
    return "unknown"

def detect_test_runner(target: Path) -> str:
    """Detect test runner."""
    pkg_json = target / "package.json"
    if pkg_json.exists():
        try:
            pkg = json.loads(pkg_json.read_text())
            deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}
            scripts = pkg.get("scripts", {})

            if "vitest" in deps:
                return "vitest"
            if "jest" in deps or "@jest/core" in deps:
                return "jest"
            if "mocha" in deps:
                return "mocha"

            # Check scripts for hints
            test_script = scripts.get("test", "")
            if "vitest" in test_script:
                return "vitest"
            if "jest" in test_script:
                return "jest"
        except Exception:
            pass

    # Python test runners
    if (target / "pytest.ini").exists() or (target / "pyproject.toml").exists():
        try:
            content = (target / "pyproject.toml").read_text() if (target / "pyproject.toml").exists() else ""
            if "pytest" in content:
                return "pytest"
        except Exception:
            pass
        if (target / "pytest.ini").exists():
            return "pytest"

    return "unknown"

def detect_ci(target: Path) -> list:
    """Detect CI/CD setup."""
    ci = []
    if (target / ".github" / "workflows").exists():
        ci.append("GitHub Actions")
    if (target / "vercel.json").exists() or (target / ".vercel").exists():
        ci.append("Vercel")
    if (target / ".gitlab-ci.yml").exists():
        ci.append("GitLab CI")
    if (target / "Jenkinsfile").exists():
        ci.append("Jenkins")
    return ci

def detect_database(target: Path) -> list:
    """Detect database/ORM setup."""
    dbs = []

    pkg_json = target / "package.json"
    if pkg_json.exists():
        try:
            pkg = json.loads(pkg_json.read_text())
            deps = {**pkg.get("dependencies", {}), **pkg.get("devDependencies", {})}
            if "@prisma/client" in deps or "prisma" in deps:
                dbs.append("Prisma")
            if "@supabase/supabase-js" in deps:
                dbs.append("Supabase")
            if "mongoose" in deps:
                dbs.append("MongoDB/Mongoose")
            if "pg" in deps or "postgres" in deps:
                dbs.append("PostgreSQL")
            if "mysql2" in deps or "mysql" in deps:
                dbs.append("MySQL")
            if "drizzle-orm" in deps:
                dbs.append("Drizzle")
        except Exception:
            pass

    return dbs

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", help="Output JSON file path", default=None)
    parser.add_argument("--target", help="Target directory to scan (default: parent of repo)", default=None)
    args = parser.parse_args()

    target = Path(args.target) if args.target else TARGET_DIR

    # Check if target is a real project (not just home dir or root)
    has_project = any([
        (target / "package.json").exists(),
        (target / "requirements.txt").exists(),
        (target / "pyproject.toml").exists(),
        (target / "go.mod").exists(),
        (target / "Cargo.toml").exists(),
        (target / "Gemfile").exists(),
        (target / "pom.xml").exists(),
    ])

    language = detect_language(target) if has_project else "unknown"
    frameworks = detect_framework(target, language) if has_project else []

    result = {
        "has_project": has_project,
        "target_dir": str(target),
        "language": language,
        "stack": frameworks,
        "package_manager": detect_package_manager(target) if has_project else "unknown",
        "test_runner": detect_test_runner(target) if has_project else "unknown",
        "ci": detect_ci(target) if has_project else [],
        "databases": detect_database(target) if has_project else [],
        "has_existing_claude": (target / ".claude").exists(),
        "has_existing_claude_md": (target / "CLAUDE.md").exists(),
    }

    output_json = json.dumps(result, indent=2)

    if args.output:
        Path(args.output).write_text(output_json)
        print(f"Detection results written to {args.output}")
        print(f"  has_project: {result['has_project']}")
        print(f"  language: {result['language']}")
        print(f"  stack: {result['stack']}")
    else:
        print(output_json)

if __name__ == "__main__":
    main()
