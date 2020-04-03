# DebugArtifacts

Julia v1.3 introduced the concept of
[artifacts](https://github.com/giordano/DebugArtifacts.jl), which is a way to
deliver to the user some files on the Internet.  In the Julia ecosystem, this is
often used to provide pre-built packages of binary libraries.

Unfortunately, installation of artifacts can sometimes fail.  This is often due
to misconfiguration of the network in the user's system, or problems with
running the download application (e.g., `curl`).  Usually this manifests with
the an error message like the following:

```
Installed OpenSpecFun_jll ──── v0.5.3+1
ERROR: Unable to automatically install 'OpenSpecFun' from '/home/username/.julia/packages/OpenSpecFun_jll/XrUb6/Artifacts.toml'
Stacktrace:
[...]
```

The goal of this package is to help the user to identify the source of the
problem.  **Note**: this will _not_ fix the underlying issue, but oly make it
more apparent.

## Installation

This package is not registered, so you have to install it by specifing the URL
address.  Enter the package manager mode in the REPL with the `]` key and run
the command

```
add https://github.com/giordano/DebugArtifacts.jl.git
```

## Usage

The package defines a single function, `debug_artifact` which takes as argument
the string of an artifact.  In most cases, you can use any artifact for
debuggining, as usually problems with the installation is related to the
network, and not specific to a particular artifact.

An example of a successful download of an artifact (`OpenSpecFun` in this case):

```julia
julia> using DebugArtifacts

julia> debug_artifact("OpenSpecFun")
[ Info: Probing for download engine...
[ Info: Probing curl as a possibility...
[ Info:   Probe successful for curl
[ Info: Found download engine curl
[ Info: Probing for compression engine...
[ Info: Probing tar as a possibility...
[ Info:   Probe successful for tar
[ Info: Found compression engine tar
[ Info: Downloading Artifacts.toml to /tmp/jl_g6jz3K/Artifacts.toml...
######################################################################## 100.0%
[ Info: Extracting artifact info for platform x86_64-linux-gnu-libgfortran4-cxx11...
[ Info: Found meta object with git-tree-sha1 846b9ab259c1612b851f8b59bc3658997e23ff57, attempting download...
######################################################################## 100.0%
[ Info: No hash cache found
[ Info: Calculated hash 4f7927ae3ea60d2a44f207afd8e94f4209fb87112f630eac4cdba2b4e03ef5b6 for file /tmp/jl_neyNKK-download.gz
[ Info: Unpacking /tmp/jl_neyNKK-download.gz into /tmp/jl_g6jz3K/unpacked...
[ Info: Double-checking git-tree-sha (this is skipped on Windows)
```

## License

`DebugArtifacts` is released under the MIT "Expat" License.  The original author
is Mosè Giordano, with the invaluable help of [Elliot
Saba](https://github.com/staticfloat/).
