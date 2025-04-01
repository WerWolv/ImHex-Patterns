# Contributing

Contributing to the Database is very simple. Fork this repository, add your new files (or changes to existing files) to the right folders and create a PR.
When adding new files, please make sure to also add a link to them to the Table of Contents in the README.md file. That way the files can be discovered by others more easily.

Thanks a lot for any additions or improvements :)

## Adding new Patterns

When adding new patterns, if possible, please also add a test file named `<pattern_name>.hexpat.<extension>` to the `/tests/patterns/test_data` directory. This allows our Unit Tests to be run against your code so we can make sure it stays up-to-date and doesn't break when changes are made to the PatternLanguage.
Please try to keep these files as small as possible (~100kiB at most) so cloning stays fast.
Please also make sure to not submit any test files that are under copyright such as game files, ROMs or files extracted from other programs. We don't want a DMCA takedown on this repo.
