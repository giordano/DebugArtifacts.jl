module DebugArtifacts

export debug_artifact

# Adapt this script to debug why artifact installation might be failing

using Pkg, Pkg.Artifacts, Pkg.BinaryPlatforms, Pkg.PlatformEngines, InteractiveUtils

function get_meta(artifact_name, artifacts_toml, platform = platform_key_abi())
    artifact_dict = Pkg.Artifacts.load_artifacts_toml(artifacts_toml)
    meta = artifact_meta(artifact_name, artifact_dict, artifacts_toml; platform=platform)

    treehash = meta["git-tree-sha1"]
    tarball_url = first(meta["download"])["url"]
    tarball_hash = first(meta["download"])["sha256"]
    return treehash, tarball_url, tarball_hash
end

function print_download_artifact_cmd(treehash, tarball_url, tarball_hash)
    println()
    println("using Pkg.Artifacts")
    println("""
download_artifact(Base.SHA1($(repr(treehash))),
                  $(repr(tarball_url)),
                  $(repr(tarball_hash));
                  verbose = true)"""
            )
end

function print_download_artifact_cmd(artifact_name::String, platform = platform_key_abi())
    artifacts_toml_url = "https://raw.githubusercontent.com/JuliaBinaryWrappers/$(artifact_name)_jll.jl/master/Artifacts.toml"
    mktempdir() do tmp_dir
        artifacts_toml = joinpath(tmp_dir, "Artifacts.toml")
        Pkg.PlatformEngines.download(artifacts_toml_url, artifacts_toml; verbose = false)
        treehash, tarball_url, tarball_hash = get_meta(artifact_name, artifacts_toml, platform)
        @info "Run the following commands to install the artifact `$(artifact_name)_jll`:"
        print_download_artifact_cmd(treehash, tarball_url, tarball_hash)
    end
end

# Debug code contributed by @staticfloat
function debug_artifact(artifact_name::String, platform = platform_key_abi())
    @info "Platform: $(platform)"
    InteractiveUtils.versioninfo()
    println()

    # Initialize Pkg code
    probe_platform_engines!(; verbose=true)

    # Change these to whatever you need them to be, to debug your artifacts code
    artifacts_toml_url = "https://raw.githubusercontent.com/JuliaBinaryWrappers/$(artifact_name)_jll.jl/master/Artifacts.toml"

    mktempdir() do tmp_dir
        # First, download Artifacts.toml file to temporary directory
        artifacts_toml = joinpath(tmp_dir, "Artifacts.toml")
        @info("Downloading Artifacts.toml to $(artifacts_toml)...")
        Pkg.PlatformEngines.download(artifacts_toml_url, artifacts_toml; verbose=true)

        # Extract artifact metadata for the current platform (you can override this)
        @info("Extracting artifact info for platform $(triplet(platform))...")
        treehash, tarball_url, tarball_hash = get_meta(artifact_name, artifacts_toml, platform)

        @info("Found meta object with git-tree-sha1 $(treehash), attempting download...")
        destdir = joinpath(tmp_dir, "unpacked")
        download_verify_unpack(tarball_url, tarball_hash, destdir; verbose=true)

        if !Sys.iswindows()
            @info("Double-checking git-tree-sha (this is skipped on Windows)")
            calc_treehash = bytes2hex(Pkg.GitTools.tree_hash(destdir))
            if calc_treehash != treehash
                @warn("Calculated treehash ($(calc_treehash)) != promised treehash ($(treehash))!")
            end
        end
    end

end

end # module
