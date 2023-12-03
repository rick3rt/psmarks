# psmarks
bashmarks inspired folder bookmark system for Powershell, with tab
autocompletion of known bookmarks

## Aliases
```
s <bookmark_name> - Saves the current directory as "bookmark_name"
g <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"
d <bookmark_name> - Deletes the bookmark
l                 - Lists all available bookmarks
```

## Full Commands
```powershell
Add-PSMark <bookmark_name>      # add a bookmark
Remove-PSMark <bookmark_name>   # remove a bookmark
Get-PSMarks                     # list all bookmarks
Open-PSMark                     # resolve a bookmark
```


## Credits
- https://github.com/stadub/PowershellScripts/tree/master/Bookmarks 
- https://github.com/huyng/bashmarks 