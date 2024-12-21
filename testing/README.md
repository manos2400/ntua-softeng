# Testing

First enter the testing directory (must do this because of relative paths in the scripts):
```
cd testing
```

To test the backend use:
```
./test api

# or use -v for more details
./test -v api
```

To test the CLI:
```
./test cli

# or use -v for more details
./test -v cli
```

View the usage:
```
./test -h
```

>> TIP: The script checks if one of the expected outputs appear. Use verbose mode to confirm the output is correct.