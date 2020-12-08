
Astrorama GitHub actions
========================

Collection of [Actions](https://docs.github.com/en/free-pro-team@latest/actions/creating-actions)
used by the [Astrorama](https://github.com/astrorama) projects.

## elements-project

Extracts the name and version of an [Elements](https://github.com/astrorama/Elements) project.

* Inputs: None
* Outputs:
    - `project` Project name
    - `version` Project version

Example:
```yaml
    steps:
        ...
        - id: package-version
          uses: astrorama/actions/elements-project@master
        ...
        - run: |
            echo ${{ steps.package-version.outputs.package }}
            echo ${{ steps.package-version.outputs.version }}
```

## setup-dependencies

Activate and install the dependencies for an Elements project.

* Inputs:
  - `dependency-list` Path to a text file with the list of dependencies
    (as rpm names, installed with `yum`)
  - `python-dependency-list` Path to a text file with the list of python
      dependencies (as rpm names **without** the `python-` prefix. The action
      will install `python3-*` or `python-*` depending on the platform
* Outputs: None

Example dependency list:
```
boost-devel  
log4cpp-devel  
doxygen  
CCfits-devel  
graphviz
```

Example python dependency list:

```
numpy  
pytest  
sphinx
```

`cmake make gcc-c++ rpm-build` are *always* installed, as they are dependencies
of Elements itself.

Example of usage:

```yaml
  steps:
    ...
    - name: Install dependencies  
      uses: astrorama/actions/setup-dependencies@master
      with:  
        dependency-list: .github/workflows/dependencies.txt  
        python-dependency-list: .github/workflows/dependencies-python.txt
```

## elements-build-rpm

Common logic to build rpms using Elements

* Inputs:
    - `build-dir` Directory for the build. Defaults to `build`
* Outputs:
    - `rpm-dir` Path to the directory where the rpms are stored
    - `srpm-dir` Path to the directory where the source rpms are stored

Example:

```yaml
  steps:
    ...
    - name: Build  
      id: build  
      uses: astroama/actions/elements-build-rpm@master
    ...
    - uses: actions/upload-artifact@v2
      with:  
        name: "my-artifact"
        path: ${{ steps.build.outputs.rpm-dir }}/*.rpm  
        retention-days: 15
```
