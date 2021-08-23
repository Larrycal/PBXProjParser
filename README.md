# PBXProjParser

解析pbxproj文件，并返回相应结构。

文件已经支持全部解析，但处理后的结构只包含以下类型

- [x] PBXBuildFile section
- [x] PBXFileReference section
- [x] PBXGroup section
- [x] PBXProject section

# Usage:

`> ./PBXProjParser -f /path/to/project.pbxproj -s filename`

```shell
/path/to/project.pbxproj
filename has been found. Searching...
../relative/path/to/filename
```


# TODO：
- [ ] PBXContainerItemProxy section
- [ ] BXFrameworksBuildPhase section
- [ ] PBXFileReference section
- [ ] PBXHeadersBuildPhase section
- [ ] PBXNativeTarget section
- [ ] PBXResourcesBuildPhase section
- [ ] PBXSourcesBuildPhase section
- [ ] PBXTargetDependency section
- [ ] XCBuildConfiguration section
- [ ] XCConfigurationList section
