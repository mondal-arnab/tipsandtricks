# Dummy topic: finding files on Linux

This is a sample topic page showing how tips in this repository can be organized.

## Find a file by name

Use `find` to search a directory tree:

```bash
find ~/Documents -type f -name "notes.txt"
```

Replace `~/Documents` with the directory to search and `notes.txt` with the file name. Use `-iname` instead of `-name` to ignore letter case.

## Related

- [Back to the tips and tricks index](../../README.md)
